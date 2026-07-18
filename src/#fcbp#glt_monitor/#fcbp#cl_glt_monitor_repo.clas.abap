"! Monitoring and Status repository over /FCBP/GLT_* operational evidence.
CLASS /fcbp/cl_glt_monitor_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_monitor_repo.

  PRIVATE SECTION.
    METHODS create_id
      IMPORTING
        iv_prefix       TYPE char8
      RETURNING
        VALUE(rv_value) TYPE char32.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

    METHODS raise_monitor
      IMPORTING
        iv_text        TYPE char220
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_monitor_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_monitor_repo~read_transfer.
    SELECT SINGLE *
      FROM /fcbp/glt_hdr
      WHERE transfer_id = @iv_transfer_id
      INTO @DATA(ls_header).
    IF sy-subrc <> 0.
      raise_monitor(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Transfer { iv_transfer_id } was not found.| ).
    ENDIF.

    rs_transfer-header = CORRESPONDING #( ls_header ).

    SELECT *
      FROM /fcbp/glt_item
      WHERE transfer_id = @iv_transfer_id
      ORDER BY item_no
      INTO TABLE @DATA(lt_item).
    rs_transfer-items = CORRESPONDING #( lt_item ).

    SELECT *
      FROM /fcbp/glt_stat
      WHERE transfer_id = @iv_transfer_id
      ORDER BY seq_no
      INTO TABLE @DATA(lt_status).
    rs_transfer-statuses = CORRESPONDING #( lt_status ).

    SELECT *
      FROM /fcbp/glt_err
      WHERE transfer_id = @iv_transfer_id
      ORDER BY created_at
      INTO TABLE @DATA(lt_error).
    rs_transfer-errors = CORRESPONDING #( lt_error ).

    SELECT *
      FROM /fcbp/glt_ref
      WHERE transfer_id = @iv_transfer_id
      ORDER BY created_at
      INTO TABLE @DATA(lt_ref).
    rs_transfer-target_refs = CORRESPONDING #( lt_ref ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~query_monitor.
    SELECT *
      FROM /fcbp/glt_hdr
      WHERE ( @is_filter-transfer_id IS INITIAL OR transfer_id = @is_filter-transfer_id )
        AND ( @is_filter-external_status IS INITIAL OR external_status = @is_filter-external_status )
        AND ( @is_filter-status_code IS INITIAL OR status_code = @is_filter-status_code )
        AND ( @is_filter-internal_state IS INITIAL OR internal_state = @is_filter-internal_state )
        AND ( @is_filter-source_type IS INITIAL OR source_type = @is_filter-source_type )
        AND ( @is_filter-source_ref_id IS INITIAL OR source_ref_id = @is_filter-source_ref_id )
        AND ( @is_filter-target_id IS INITIAL OR target_id = @is_filter-target_id )
        AND ( @is_filter-company_code IS INITIAL OR company_code = @is_filter-company_code )
        AND ( @is_filter-confirmation_pending IS INITIAL OR confirmation_pending = @is_filter-confirmation_pending )
        AND ( @is_filter-operator_action_required IS INITIAL OR operator_action_required = @is_filter-operator_action_required )
      ORDER BY created_at DESCENDING, transfer_id DESCENDING
      INTO TABLE @DATA(lt_header).

    LOOP AT lt_header INTO DATA(ls_header).
      IF is_filter-created_from IS NOT INITIAL OR is_filter-created_to IS NOT INITIAL.
        CONVERT TIME STAMP ls_header-created_at TIME ZONE sy-zonlo INTO DATE DATA(lv_created_date).
        IF is_filter-created_from IS NOT INITIAL AND lv_created_date < is_filter-created_from.
          CONTINUE.
        ENDIF.
        IF is_filter-created_to IS NOT INITIAL AND lv_created_date > is_filter-created_to.
          CONTINUE.
        ENDIF.
      ENDIF.
      APPEND /fcbp/if_glt_monitor_repo~read_transfer( ls_header-transfer_id ) TO rt_transfer.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_error.
    DATA(ls_error) = is_error.
    IF ls_error-error_id IS INITIAL.
      ls_error-error_id = create_id( 'ERR' ).
    ENDIF.
    IF ls_error-created_at IS INITIAL.
      ls_error-created_at = now( ).
    ENDIF.
    IF ls_error-created_by IS INITIAL.
      ls_error-created_by = sy-uname.
    ENDIF.

    INSERT /fcbp/glt_err FROM @ls_error.
    IF sy-subrc <> 0.
      raise_monitor(
        iv_transfer_id = ls_error-transfer_id
        iv_text        = |Error row { ls_error-error_id } could not be inserted.| ).
    ENDIF.
    rv_error_id = ls_error-error_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_message.
    DATA(ls_message) = is_message.
    IF ls_message-message_id IS INITIAL.
      ls_message-message_id = create_id( 'MSG' ).
    ENDIF.
    IF ls_message-created_at IS INITIAL.
      ls_message-created_at = now( ).
    ENDIF.
    IF ls_message-created_by IS INITIAL.
      ls_message-created_by = sy-uname.
    ENDIF.

    INSERT /fcbp/glt_msg FROM @ls_message.
    IF sy-subrc <> 0.
      raise_monitor(
        iv_transfer_id = ls_message-transfer_id
        iv_text        = |Message { ls_message-message_id } could not be inserted.| ).
    ENDIF.
    rv_message_id = ls_message-message_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_target_ref.
    DATA(ls_ref) = is_target_ref.
    IF ls_ref-ref_id IS INITIAL.
      ls_ref-ref_id = create_id( 'REF' ).
    ENDIF.
    IF ls_ref-created_at IS INITIAL.
      ls_ref-created_at = now( ).
    ENDIF.

    INSERT /fcbp/glt_ref FROM @ls_ref.
    IF sy-subrc <> 0.
      raise_monitor(
        iv_transfer_id = ls_ref-transfer_id
        iv_text        = |Target reference { ls_ref-ref_id } could not be inserted.| ).
    ENDIF.
    rv_ref_id = ls_ref-ref_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_attempt.
    DATA(ls_attempt) = is_attempt.
    IF ls_attempt-attempt_id IS INITIAL.
      ls_attempt-attempt_id = create_id( 'ATT' ).
    ENDIF.
    IF ls_attempt-started_at IS INITIAL.
      ls_attempt-started_at = now( ).
    ENDIF.
    IF ls_attempt-created_by IS INITIAL.
      ls_attempt-created_by = sy-uname.
    ENDIF.

    INSERT /fcbp/glt_att FROM @ls_attempt.
    IF sy-subrc <> 0.
      raise_monitor(
        iv_transfer_id = ls_attempt-transfer_id
        iv_text        = |Attempt { ls_attempt-attempt_id } could not be inserted.| ).
    ENDIF.
    rv_attempt_id = ls_attempt-attempt_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_jobrun.
    DATA(ls_jobrun) = is_jobrun.
    IF ls_jobrun-jobrun_id IS INITIAL.
      ls_jobrun-jobrun_id = create_id( 'JOB' ).
    ENDIF.
    IF ls_jobrun-started_at IS INITIAL.
      ls_jobrun-started_at = now( ).
    ENDIF.

    INSERT /fcbp/glt_jobrun FROM @ls_jobrun.
    IF sy-subrc <> 0.
      raise_monitor( |Job run { ls_jobrun-jobrun_id } could not be inserted.| ).
    ENDIF.
    rv_jobrun_id = ls_jobrun-jobrun_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~update_jobrun.
    UPDATE /fcbp/glt_jobrun FROM @is_jobrun.
    IF sy-subrc <> 0.
      raise_monitor( |Job run { is_jobrun-jobrun_id } could not be updated.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_outbox_work.
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
      raise_monitor(
        iv_transfer_id = ls_work-transfer_id
        iv_text        = |Outbox work { ls_work-outbox_id } could not be inserted.| ).
    ENDIF.
    rv_outbox_id = ls_work-outbox_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~cancel_open_work.
    UPDATE /fcbp/glt_outbox
      SET processing_status = @/fcbp/if_glt_types=>c_outbox_status-cancelled
      WHERE transfer_id = @iv_transfer_id
        AND processing_status = @/fcbp/if_glt_types=>c_outbox_status-open.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~has_started_attempt.
    SELECT SINGLE attempt_id
      FROM /fcbp/glt_att
      WHERE transfer_id = @iv_transfer_id
      INTO @DATA(lv_attempt_id).
    rv_found = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~write_audit_event.
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
      raise_monitor(
        iv_transfer_id = ls_event-transfer_id
        iv_text        = |Audit event { ls_event-audit_id } could not be inserted.| ).
    ENDIF.
    rv_audit_id = ls_event-audit_id.
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

  METHOD raise_monitor.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        transfer_id    = iv_transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = iv_text.
  ENDMETHOD.

ENDCLASS.
