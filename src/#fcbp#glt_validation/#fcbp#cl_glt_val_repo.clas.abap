"! Validation repository over /FCBP/GLT_VALRUN and /FCBP/GLT_VALFND.
CLASS /fcbp/cl_glt_val_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_val_repo.

  PRIVATE SECTION.
    METHODS create_id
      RETURNING
        VALUE(rv_value) TYPE char32.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

    METHODS raise_validation
      IMPORTING
        iv_text        TYPE char220
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      RAISING
        /fcbp/cx_glt_validation.

ENDCLASS.

CLASS /fcbp/cl_glt_val_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_val_repo~create_run.
    DATA(ls_run) = is_run.
    IF ls_run-validation_run_id IS INITIAL.
      ls_run-validation_run_id = create_id( ).
    ENDIF.
    IF ls_run-started_at IS INITIAL.
      ls_run-started_at = now( ).
    ENDIF.
    IF ls_run-created_at IS INITIAL.
      ls_run-created_at = ls_run-started_at.
    ENDIF.
    IF ls_run-changed_at IS INITIAL.
      ls_run-changed_at = ls_run-created_at.
    ENDIF.
    IF ls_run-result_status IS INITIAL.
      ls_run-result_status = /fcbp/if_glt_val_types=>c_run_status-running.
    ENDIF.
    IF ls_run-created_by IS INITIAL.
      ls_run-created_by = sy-uname.
    ENDIF.
    IF ls_run-changed_by IS INITIAL.
      ls_run-changed_by = ls_run-created_by.
    ENDIF.

    INSERT /fcbp/glt_valrun FROM @ls_run.
    IF sy-subrc <> 0.
      raise_validation(
        iv_transfer_id = ls_run-transfer_id
        iv_text        = |Validation run { ls_run-validation_run_id } could not be inserted.| ).
    ENDIF.
    rv_run_id = ls_run-validation_run_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_repo~insert_findings.
    LOOP AT it_finding INTO DATA(ls_finding).
      IF ls_finding-validation_run_id IS INITIAL.
        raise_validation(
          iv_transfer_id = ls_finding-transfer_id
          iv_text        = 'Validation finding requires a validation run id.' ).
      ENDIF.
      IF ls_finding-finding_seq IS INITIAL.
        SELECT MAX( finding_seq )
          FROM /fcbp/glt_valfnd
          WHERE validation_run_id = @ls_finding-validation_run_id
          INTO @DATA(lv_seq).
        ls_finding-finding_seq = lv_seq + 1.
      ENDIF.
      IF ls_finding-created_at IS INITIAL.
        ls_finding-created_at = now( ).
      ENDIF.
      IF ls_finding-created_by IS INITIAL.
        ls_finding-created_by = sy-uname.
      ENDIF.

      INSERT /fcbp/glt_valfnd FROM @ls_finding.
      IF sy-subrc <> 0.
        raise_validation(
          iv_transfer_id = ls_finding-transfer_id
          iv_text        = |Validation finding { ls_finding-validation_run_id }/{ ls_finding-finding_seq } could not be inserted.| ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_repo~close_run.
    IF is_result-validation_run_id IS INITIAL.
      raise_validation(
        iv_transfer_id = is_result-transfer_id
        iv_text        = 'Validation run id is required to close a run.' ).
    ENDIF.

    DATA(lv_now) = now( ).
    UPDATE /fcbp/glt_valrun
      SET result_status = @is_result-result_status,
          blocking_count = @is_result-blocking_count,
          warning_count = @is_result-warning_count,
          ended_at = @lv_now,
          changed_at = @lv_now,
          changed_by = @sy-uname
      WHERE validation_run_id = @is_result-validation_run_id.
    IF sy-subrc <> 0.
      raise_validation(
        iv_transfer_id = is_result-transfer_id
        iv_text        = |Validation run { is_result-validation_run_id } could not be closed.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_repo~read_latest_run.
    SELECT *
      FROM /fcbp/glt_valrun
      WHERE package_id = @iv_package_id
      ORDER BY started_at DESCENDING, validation_run_id DESCENDING
      INTO TABLE @DATA(lt_run).
    READ TABLE lt_run INTO DATA(ls_run) INDEX 1.
    IF sy-subrc <> 0.
      raise_validation( |No validation run found for package { iv_package_id }.| ).
    ENDIF.
    rs_run = CORRESPONDING #( ls_run ).
  ENDMETHOD.

  METHOD create_id.
    TRY.
        rv_value = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        rv_value = |VAL{ sy-datum }{ sy-uzeit }|.
    ENDTRY.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

  METHOD raise_validation.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_validation
      EXPORTING
        transfer_id    = iv_transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = iv_text.
  ENDMETHOD.

ENDCLASS.
