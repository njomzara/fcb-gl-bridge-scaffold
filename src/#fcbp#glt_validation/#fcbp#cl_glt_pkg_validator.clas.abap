"! Package-level validation facade and run lifecycle coordinator.
CLASS /fcbp/cl_glt_pkg_validator DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_pkg_validator.

    METHODS constructor
      IMPORTING
        io_repo       TYPE REF TO /fcbp/if_glt_val_repo OPTIONAL
        io_evidence   TYPE REF TO /fcbp/if_glt_pkg_evidence OPTIONAL
        io_rule_eval  TYPE REF TO /fcbp/if_glt_val_rule_eval OPTIONAL
        io_result     TYPE REF TO /fcbp/cl_glt_val_result OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repo TYPE REF TO /fcbp/if_glt_val_repo.
    DATA mo_evidence TYPE REF TO /fcbp/if_glt_pkg_evidence.
    DATA mo_rule_eval TYPE REF TO /fcbp/if_glt_val_rule_eval.
    DATA mo_result TYPE REF TO /fcbp/cl_glt_val_result.

    METHODS execute
      IMPORTING
        is_context       TYPE /fcbp/if_glt_val_types=>ty_package_context
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_val_types=>ty_result
      RAISING
        /fcbp/cx_glt_validation.

    METHODS create_run
      IMPORTING
        is_context           TYPE /fcbp/if_glt_val_types=>ty_package_context
        is_evidence          TYPE /fcbp/if_glt_val_types=>ty_package_evidence
      RETURNING
        VALUE(rs_run)        TYPE /fcbp/if_glt_val_types=>ty_run.

    METHODS create_run_id
      RETURNING
        VALUE(rv_run_id) TYPE /fcbp/if_glt_val_types=>ty_validation_run_id.

    METHODS stamp_findings
      IMPORTING
        iv_validation_run_id TYPE /fcbp/if_glt_val_types=>ty_validation_run_id
      CHANGING
        ct_finding           TYPE /fcbp/if_glt_val_types=>tt_finding.

ENDCLASS.

CLASS /fcbp/cl_glt_pkg_validator IMPLEMENTATION.

  METHOD constructor.
    IF io_repo IS BOUND.
      mo_repo = io_repo.
    ELSE.
      mo_repo = NEW /fcbp/cl_glt_val_repo( ).
    ENDIF.

    IF io_evidence IS BOUND.
      mo_evidence = io_evidence.
    ELSE.
      mo_evidence = NEW /fcbp/cl_glt_pkg_evidence( ).
    ENDIF.

    IF io_rule_eval IS BOUND.
      mo_rule_eval = io_rule_eval.
    ELSE.
      mo_rule_eval = NEW /fcbp/cl_glt_val_rules( ).
    ENDIF.

    IF io_result IS BOUND.
      mo_result = io_result.
    ELSE.
      mo_result = NEW /fcbp/cl_glt_val_result( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_pkg_validator~validate_package.
    rs_result = execute( is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_pkg_validator~revalidate_package.
    DATA(ls_context) = is_context.
    IF ls_context-run_mode IS INITIAL.
      ls_context-run_mode = /fcbp/if_glt_val_types=>c_run_mode-revalidate.
    ENDIF.
    rs_result = execute( ls_context ).
  ENDMETHOD.

  METHOD execute.
    IF is_context-transfer_id IS INITIAL OR is_context-package_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_validation
        EXPORTING
          transfer_id    = is_context-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-validation
          operator_text  = 'Package validation requires transfer id and package id.'.
    ENDIF.

    DATA(ls_evidence) = mo_evidence->read_for_validation(
      iv_transfer_id       = is_context-transfer_id
      iv_package_id        = is_context-package_id
      iv_policy_context_id = is_context-policy_context_id ).

    DATA(ls_run) = create_run(
      is_context  = is_context
      is_evidence = ls_evidence ).
    DATA(lv_run_id) = mo_repo->create_run( ls_run ).

    DATA(lt_finding) = mo_rule_eval->evaluate(
      is_evidence = ls_evidence
      it_rule     = ls_evidence-validation_rules ).
    stamp_findings(
      EXPORTING iv_validation_run_id = lv_run_id
      CHANGING  ct_finding = lt_finding ).

    mo_repo->insert_findings( lt_finding ).

    rs_result = mo_result->compute(
      is_context           = is_context
      iv_validation_run_id = lv_run_id
      it_finding           = lt_finding ).

    mo_repo->close_run( rs_result ).
  ENDMETHOD.

  METHOD create_run.
    rs_run = VALUE #(
      validation_run_id = create_run_id( )
      transfer_id = is_context-transfer_id
      package_id = is_context-package_id
      policy_context_id = is_context-policy_context_id
      validation_profile_id = is_evidence-policy_context-validation_profile_id
      validation_profile_version = is_evidence-policy_context-validation_version
      validation_hash = is_evidence-policy_context-validation_hash
      result_status = /fcbp/if_glt_val_types=>c_run_status-running
      actor_type = COND #( WHEN is_context-actor_type IS INITIAL THEN /fcbp/if_glt_types=>c_actor_type-job ELSE is_context-actor_type )
      actor_id = is_context-actor_id
      jobrun_id = is_context-jobrun_id
      outbox_id = is_context-outbox_id
      waiver_id = is_context-waiver_context_id
      created_by = sy-uname
      changed_by = sy-uname ).
    GET TIME STAMP FIELD rs_run-started_at.
    rs_run-created_at = rs_run-started_at.
    rs_run-changed_at = rs_run-started_at.
  ENDMETHOD.

  METHOD create_run_id.
    TRY.
        rv_run_id = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_root.
        DATA(lv_timestamp) = ``.
        GET TIME STAMP FIELD lv_timestamp.
        rv_run_id = |VAL{ lv_timestamp }|.
    ENDTRY.
  ENDMETHOD.

  METHOD stamp_findings.
    DATA(lv_seq) = 0.
    LOOP AT ct_finding ASSIGNING FIELD-SYMBOL(<ls_finding>).
      lv_seq = lv_seq + 1.
      <ls_finding>-validation_run_id = iv_validation_run_id.
      <ls_finding>-finding_seq = lv_seq.
      IF <ls_finding>-created_by IS INITIAL.
        <ls_finding>-created_by = sy-uname.
      ENDIF.
      IF <ls_finding>-created_at IS INITIAL.
        GET TIME STAMP FIELD <ls_finding>-created_at.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
