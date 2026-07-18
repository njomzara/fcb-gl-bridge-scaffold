"! Outbox Execution repository over /FCBP/GLT_OUTBOX.
CLASS /fcbp/cl_glt_outbox_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_outbox_repo.

  PRIVATE SECTION.
    METHODS create_id
      IMPORTING
        iv_prefix       TYPE char8
      RETURNING
        VALUE(rv_value) TYPE char32.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

    METHODS raise_outbox
      IMPORTING
        iv_text TYPE char220
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_outbox_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_outbox_repo~select_due_work.
    DATA(lv_due_before) = is_context-due_before.
    IF lv_due_before IS INITIAL.
      lv_due_before = now( ).
    ENDIF.

    SELECT *
      FROM /fcbp/glt_outbox
      WHERE processing_status = @/fcbp/if_glt_types=>c_outbox_status-open
        AND due_at <= @lv_due_before
        AND ( lock_status = @/fcbp/if_glt_types=>c_lock_status-free OR lock_until <= @lv_due_before )
        AND ( @is_context-target_id IS INITIAL OR target_id = @is_context-target_id )
        AND ( @is_context-work_type IS INITIAL OR work_type = @is_context-work_type )
        AND ( @is_context-processing_mode IS INITIAL OR processing_mode = @is_context-processing_mode )
        AND ( @is_context-priority_max IS INITIAL OR priority <= @is_context-priority_max )
      ORDER BY priority ASCENDING, due_at ASCENDING, outbox_id ASCENDING
      INTO TABLE @DATA(lt_work).

    rt_work = CORRESPONDING #( lt_work ).
    IF is_context-max_items > 0.
      WHILE lines( rt_work ) > is_context-max_items.
        DELETE rt_work INDEX lines( rt_work ).
      ENDWHILE.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~claim_work.
    DATA(lv_now) = now( ).
    IF is_context-dry_run = abap_true.
      SELECT SINGLE *
        FROM /fcbp/glt_outbox
        WHERE outbox_id = @iv_outbox_id
        INTO @DATA(ls_dry_work).
      IF sy-subrc = 0.
        rs_claim = VALUE #(
          claimed      = abap_false
          outbox_id    = iv_outbox_id
          work         = CORRESPONDING #( ls_dry_work )
          claim_owner  = iv_claim_owner
          message_text = 'Dry run: work was selected but not claimed.' ).
      ENDIF.
      RETURN.
    ENDIF.

    UPDATE /fcbp/glt_outbox
      SET processing_status = @/fcbp/if_glt_types=>c_outbox_status-in_process,
          lock_status = @/fcbp/if_glt_types=>c_lock_status-locked,
          lock_owner = @iv_claim_owner,
          locked_at = @lv_now,
          lock_until = @iv_lock_until
      WHERE outbox_id = @iv_outbox_id
        AND processing_status = @/fcbp/if_glt_types=>c_outbox_status-open
        AND ( lock_status = @/fcbp/if_glt_types=>c_lock_status-free OR lock_until <= @lv_now ).

    IF sy-subrc <> 0.
      rs_claim = VALUE #(
        claimed      = abap_false
        outbox_id    = iv_outbox_id
        claim_owner  = iv_claim_owner
        message_text = 'Outbox work was not open or was already claimed.' ).
      RETURN.
    ENDIF.

    SELECT SINGLE *
      FROM /fcbp/glt_outbox
      WHERE outbox_id = @iv_outbox_id
      INTO @DATA(ls_claimed_work).
    rs_claim = VALUE #(
      claimed      = abap_true
      outbox_id    = iv_outbox_id
      work         = CORRESPONDING #( ls_claimed_work )
      claim_owner  = iv_claim_owner
      claim_token  = |{ iv_outbox_id }-{ iv_claim_owner }|
      message_text = 'Outbox work claimed.' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~complete_work.
    DATA lv_initial_ts TYPE utclong.
    UPDATE /fcbp/glt_outbox
      SET processing_status = @/fcbp/if_glt_types=>c_outbox_status-done,
          lock_status = @/fcbp/if_glt_types=>c_lock_status-free,
          lock_owner = '',
          locked_at = @lv_initial_ts,
          lock_until = @lv_initial_ts
      WHERE outbox_id = @iv_outbox_id
        AND lock_owner = @iv_claim_owner.
    IF sy-subrc <> 0.
      raise_outbox( |Outbox work { iv_outbox_id } could not be completed by owner { iv_claim_owner }.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~fail_work.
    DATA lv_initial_ts TYPE utclong.
    UPDATE /fcbp/glt_outbox
      SET processing_status = @/fcbp/if_glt_types=>c_outbox_status-failed,
          lock_status = @/fcbp/if_glt_types=>c_lock_status-free,
          lock_owner = '',
          locked_at = @lv_initial_ts,
          lock_until = @lv_initial_ts
      WHERE outbox_id = @iv_outbox_id
        AND lock_owner = @iv_claim_owner.
    IF sy-subrc <> 0.
      raise_outbox( |Outbox work { iv_outbox_id } could not be failed by owner { iv_claim_owner }.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~release_work.
    DATA lv_initial_ts TYPE utclong.
    UPDATE /fcbp/glt_outbox
      SET processing_status = @/fcbp/if_glt_types=>c_outbox_status-open,
          lock_status = @/fcbp/if_glt_types=>c_lock_status-free,
          lock_owner = '',
          locked_at = @lv_initial_ts,
          lock_until = @lv_initial_ts
      WHERE outbox_id = @iv_outbox_id
        AND lock_owner = @iv_claim_owner.
    IF sy-subrc <> 0.
      raise_outbox( |Outbox work { iv_outbox_id } could not be released by owner { iv_claim_owner }.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~supersede_work.
    DATA lv_initial_ts TYPE utclong.
    UPDATE /fcbp/glt_outbox
      SET processing_status = @/fcbp/if_glt_types=>c_outbox_status-superseded,
          lock_status = @/fcbp/if_glt_types=>c_lock_status-free,
          lock_owner = '',
          locked_at = @lv_initial_ts,
          lock_until = @lv_initial_ts
      WHERE outbox_id = @iv_outbox_id
        AND lock_owner = @iv_claim_owner.
    IF sy-subrc <> 0.
      raise_outbox( |Outbox work { iv_outbox_id } could not be superseded by owner { iv_claim_owner }.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~enqueue_work.
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
      raise_outbox( |Outbox work { ls_work-outbox_id } could not be inserted.| ).
    ENDIF.
    rv_outbox_id = ls_work-outbox_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~recover_expired_locks.
    DATA(lv_cutoff) = is_request-lock_expired_before.
    IF lv_cutoff IS INITIAL.
      lv_cutoff = now( ).
    ENDIF.
    DATA lv_initial_ts TYPE utclong.

    SELECT *
      FROM /fcbp/glt_outbox
      WHERE lock_status = @/fcbp/if_glt_types=>c_lock_status-locked
        AND lock_until <= @lv_cutoff
        AND ( @is_request-target_id IS INITIAL OR target_id = @is_request-target_id )
        AND ( @is_request-work_type IS INITIAL OR work_type = @is_request-work_type )
      ORDER BY lock_until ASCENDING, outbox_id ASCENDING
      INTO TABLE @DATA(lt_expired).

    LOOP AT lt_expired INTO DATA(ls_expired).
      IF is_request-max_items > 0 AND rs_result-selected_count >= is_request-max_items.
        EXIT.
      ENDIF.

      rs_result-selected_count = rs_result-selected_count + 1.
      rs_result-stale_lock_count = rs_result-stale_lock_count + 1.
      IF is_request-dry_run = abap_true.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        CONTINUE.
      ENDIF.

      UPDATE /fcbp/glt_outbox
        SET processing_status = @/fcbp/if_glt_types=>c_outbox_status-open,
            lock_status = @/fcbp/if_glt_types=>c_lock_status-free,
            lock_owner = '',
            locked_at = @lv_initial_ts,
            lock_until = @lv_initial_ts
        WHERE outbox_id = @ls_expired-outbox_id
          AND lock_status = @/fcbp/if_glt_types=>c_lock_status-locked.
      IF sy-subrc = 0.
        rs_result-released_count = rs_result-released_count + 1.
      ELSE.
        rs_result-failed_count = rs_result-failed_count + 1.
      ENDIF.
    ENDLOOP.

    rs_result-message_text = |Recovered { rs_result-released_count } expired outbox locks.|.
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

  METHOD raise_outbox.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = iv_text.
  ENDMETHOD.

ENDCLASS.
