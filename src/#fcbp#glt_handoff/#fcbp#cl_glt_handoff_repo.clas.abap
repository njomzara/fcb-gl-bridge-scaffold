"! Source Handoff repository over /FCBP/GLT_REG and core evidence tables.
CLASS /fcbp/cl_glt_handoff_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_handoff_repo.

  PRIVATE SECTION.
    METHODS create_id
      IMPORTING
        iv_prefix       TYPE char8
      RETURNING
        VALUE(rv_value) TYPE char32.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

    METHODS raise_handoff
      IMPORTING
        iv_operation        TYPE char40
        iv_registration_key TYPE /fcbp/if_glt_types=>ty_registration_key OPTIONAL
        iv_text             TYPE char220 OPTIONAL
      RAISING
        /fcbp/cx_glt_handoff.

ENDCLASS.

CLASS /fcbp/cl_glt_handoff_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_handoff_repo~try_reserve_reg.
    DATA(ls_registration) = is_registration.
    IF ls_registration-registration_key IS INITIAL.
      raise_handoff(
        iv_operation = 'TRY_RESERVE_REG'
        iv_text      = 'Registration key is required.' ).
    ENDIF.

    DATA(lv_now) = now( ).
    IF ls_registration-registration_status IS INITIAL.
      ls_registration-registration_status = /fcbp/if_glt_types=>c_reg_status-reserved.
    ENDIF.
    IF ls_registration-reserved_by IS INITIAL.
      ls_registration-reserved_by = sy-uname.
    ENDIF.
    IF ls_registration-reserved_at IS INITIAL.
      ls_registration-reserved_at = lv_now.
    ENDIF.
    IF ls_registration-created_at IS INITIAL.
      ls_registration-created_at = lv_now.
    ENDIF.
    IF ls_registration-changed_at IS INITIAL.
      ls_registration-changed_at = lv_now.
    ENDIF.

    DATA(ls_db_registration) = CORRESPONDING /fcbp/glt_reg( ls_registration ).
    INSERT /fcbp/glt_reg FROM @ls_db_registration.
    IF sy-subrc = 0.
      rs_decision = VALUE #(
        decision            = /fcbp/if_glt_types=>c_reg_status-reserved
        registration_key    = ls_registration-registration_key
        transfer_id         = ls_registration-transfer_id
        registration_status = ls_registration-registration_status
        message             = 'Registration reserved.' ).
      RETURN.
    ENDIF.

    SELECT SINGLE *
      FROM /fcbp/glt_reg
      WHERE registration_key = @ls_registration-registration_key
      INTO @DATA(ls_existing_db).
    IF sy-subrc <> 0.
      raise_handoff(
        iv_operation        = 'TRY_RESERVE_REG'
        iv_registration_key = ls_registration-registration_key
        iv_text             = 'Registration could not be reserved and no existing row was found.' ).
    ENDIF.

    DATA(ls_existing) = CORRESPONDING /fcbp/if_glt_types=>ty_registration( ls_existing_db ).
    rs_decision = VALUE #(
      registration_key    = ls_existing-registration_key
      transfer_id         = ls_existing-transfer_id
      registration_status = ls_existing-registration_status ).

    CASE ls_existing-registration_status.
      WHEN /fcbp/if_glt_types=>c_reg_status-reserved
        OR /fcbp/if_glt_types=>c_reg_status-in_progress.
        rs_decision-decision = /fcbp/if_glt_types=>c_reg_status-in_progress.
        rs_decision-in_progress = abap_true.
        rs_decision-message = 'Registration is already reserved or in progress.'.
      WHEN /fcbp/if_glt_types=>c_reg_status-active.
        rs_decision-decision = /fcbp/if_glt_types=>c_reg_status-duplicate.
        rs_decision-already_registered = abap_true.
        rs_decision-message = 'Registration already has an active transfer.'.
      WHEN /fcbp/if_glt_types=>c_reg_status-failed.
        rs_decision-decision = /fcbp/if_glt_types=>c_reg_status-failed.
        rs_decision-conflict = abap_true.
        rs_decision-message = ls_existing-last_error_code.
      WHEN OTHERS.
        rs_decision-decision = /fcbp/if_glt_types=>c_reg_status-duplicate.
        rs_decision-already_registered = abap_true.
        rs_decision-message = 'Registration already exists.'.
    ENDCASE.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~read_reg.
    SELECT SINGLE *
      FROM /fcbp/glt_reg
      WHERE registration_key = @iv_registration_key
      INTO @DATA(ls_registration).
    IF sy-subrc <> 0.
      raise_handoff(
        iv_operation        = 'READ_REG'
        iv_registration_key = iv_registration_key
        iv_text             = |Registration { iv_registration_key } was not found.| ).
    ENDIF.
    rs_registration = CORRESPONDING #( ls_registration ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~create_transfer_root.
    DATA(ls_header) = is_header.
    IF ls_header-transfer_id IS INITIAL.
      raise_handoff(
        iv_operation        = 'CREATE_TRANSFER_ROOT'
        iv_registration_key = ls_header-source_registration_key
        iv_text             = 'Transfer id is required before creating the transfer root.' ).
    ENDIF.

    DATA(lv_now) = now( ).
    IF ls_header-created_at IS INITIAL.
      ls_header-created_at = lv_now.
    ENDIF.
    IF ls_header-changed_at IS INITIAL.
      ls_header-changed_at = lv_now.
    ENDIF.
    IF ls_header-created_by IS INITIAL.
      ls_header-created_by = sy-uname.
    ENDIF.
    IF ls_header-changed_by IS INITIAL.
      ls_header-changed_by = ls_header-created_by.
    ENDIF.

    INSERT /fcbp/glt_hdr FROM @ls_header.
    IF sy-subrc <> 0.
      raise_handoff(
        iv_operation        = 'CREATE_TRANSFER_ROOT'
        iv_registration_key = ls_header-source_registration_key
        iv_text             = |Transfer root { ls_header-transfer_id } could not be inserted.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~insert_initial_status.
    DATA(ls_status) = is_status.
    IF ls_status-seq_no IS INITIAL.
      ls_status-seq_no = 1.
    ENDIF.
    IF ls_status-created_at IS INITIAL.
      ls_status-created_at = now( ).
    ENDIF.

    INSERT /fcbp/glt_stat FROM @ls_status.
    IF sy-subrc <> 0.
      raise_handoff(
        iv_operation = 'INSERT_INITIAL_STATUS'
        iv_text      = |Initial status for transfer { ls_status-transfer_id } could not be inserted.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~insert_outbox_work.
    DATA(ls_work) = is_work.
    IF ls_work-outbox_id IS INITIAL.
      ls_work-outbox_id = create_id( 'OBX' ).
    ENDIF.
    IF ls_work-processing_status IS INITIAL.
      ls_work-processing_status = /fcbp/if_glt_types=>c_outbox_status-open.
    ENDIF.
    IF ls_work-lock_status IS INITIAL.
      ls_work-lock_status = /fcbp/if_glt_types=>c_lock_status-free.
    ENDIF.
    IF ls_work-due_at IS INITIAL.
      ls_work-due_at = now( ).
    ENDIF.
    IF ls_work-created_at IS INITIAL.
      ls_work-created_at = now( ).
    ENDIF.
    IF ls_work-created_by IS INITIAL.
      ls_work-created_by = sy-uname.
    ENDIF.

    INSERT /fcbp/glt_outbox FROM @ls_work.
    IF sy-subrc <> 0.
      raise_handoff(
        iv_operation = 'INSERT_OUTBOX_WORK'
        iv_text      = |Outbox work { ls_work-outbox_id } could not be inserted.| ).
    ENDIF.
    rv_outbox_id = ls_work-outbox_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~write_audit_event.
    DATA(ls_event) = is_event.
    IF ls_event-audit_id IS INITIAL.
      ls_event-audit_id = create_id( 'AUD' ).
    ENDIF.
    IF ls_event-created_at IS INITIAL.
      ls_event-created_at = now( ).
    ENDIF.
    IF ls_event-actor_type IS INITIAL.
      ls_event-actor_type = /fcbp/if_glt_types=>c_actor_type-system.
    ENDIF.
    IF ls_event-actor_id IS INITIAL.
      ls_event-actor_id = sy-uname.
    ENDIF.

    INSERT /fcbp/glt_aud FROM @ls_event.
    IF sy-subrc <> 0.
      raise_handoff(
        iv_operation = 'WRITE_AUDIT_EVENT'
        iv_text      = |Audit event { ls_event-audit_id } could not be inserted.| ).
    ENDIF.
    rv_audit_id = ls_event-audit_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~activate_reg.
    DATA(lv_now) = now( ).
    UPDATE /fcbp/glt_reg
      SET transfer_id = @iv_transfer_id,
          registration_status = @/fcbp/if_glt_types=>c_reg_status-active,
          completed_at = @lv_now,
          changed_at = @lv_now
      WHERE registration_key = @iv_registration_key.
    IF sy-subrc <> 0.
      raise_handoff(
        iv_operation        = 'ACTIVATE_REG'
        iv_registration_key = iv_registration_key
        iv_text             = |Registration { iv_registration_key } could not be activated.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~mark_reg_failed.
    DATA(lv_now) = now( ).
    UPDATE /fcbp/glt_reg
      SET registration_status = @/fcbp/if_glt_types=>c_reg_status-failed,
          last_error_code = @iv_reason,
          changed_at = @lv_now
      WHERE registration_key = @iv_registration_key.
    IF sy-subrc <> 0.
      raise_handoff(
        iv_operation        = 'MARK_REG_FAILED'
        iv_registration_key = iv_registration_key
        iv_text             = |Registration { iv_registration_key } could not be marked failed.| ).
    ENDIF.
  ENDMETHOD.

  METHOD create_id.
    TRY.
        rv_value = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        rv_value = |{ iv_prefix }{ sy-datum }{ sy-uzeit }|.
    ENDTRY.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

  METHOD raise_handoff.
    DATA(lv_text) = COND char220(
      WHEN iv_text IS INITIAL THEN |Handoff repository operation { iv_operation } failed.|
      ELSE iv_text ).
    RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
      EXPORTING
        registration_key = iv_registration_key
        reason_code      = iv_operation
        error_category   = /fcbp/if_glt_types=>c_error_category-repository
        operator_text    = lv_text.
  ENDMETHOD.

ENDCLASS.
