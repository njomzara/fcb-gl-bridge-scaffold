"! Outbox dispatcher: select due work, claim owner-only, route to handlers, and finalize rows.
CLASS /fcbp/cl_glt_outbox_dispatcher DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_outbox_dispatcher.

    METHODS constructor
      IMPORTING
        io_repo     TYPE REF TO /fcbp/if_glt_outbox_repo OPTIONAL
        io_registry TYPE REF TO /fcbp/cl_glt_work_handler_reg OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repo     TYPE REF TO /fcbp/if_glt_outbox_repo.
    DATA mo_registry TYPE REF TO /fcbp/cl_glt_work_handler_reg.

    METHODS validate_context
      IMPORTING
        is_context TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
      RAISING
        /fcbp/cx_glt_error.

    METHODS calculate_lock_until
      IMPORTING
        is_context            TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
      RETURNING
        VALUE(rv_lock_until)  TYPE utclong.

    METHODS finalize_claimed_work
      IMPORTING
        is_context TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
        is_result  TYPE /fcbp/if_glt_outbox_types=>ty_work_handler_result
      CHANGING
        cs_total   TYPE /fcbp/if_glt_job_types=>ty_job_result
      RAISING
        /fcbp/cx_glt_error.

    METHODS finalize_handler_error
      IMPORTING
        is_work    TYPE /fcbp/if_glt_types=>ty_outbox_work
        is_context TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
        ix_error   TYPE REF TO /fcbp/cx_glt_error
      CHANGING
        cs_total   TYPE /fcbp/if_glt_job_types=>ty_job_result
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_outbox_dispatcher IMPLEMENTATION.

  METHOD constructor.
    mo_repo = COND #( WHEN io_repo IS BOUND THEN io_repo ELSE NEW /fcbp/cl_glt_outbox_repo( ) ).
    mo_registry = COND #( WHEN io_registry IS BOUND THEN io_registry ELSE NEW /fcbp/cl_glt_work_handler_reg( ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_dispatcher~dispatch_due_work.
    validate_context( is_context ).

    DATA(lt_work) = mo_repo->select_due_work( is_context ).
    rs_result-selected_count = lines( lt_work ).

    LOOP AT lt_work INTO DATA(ls_work).
      IF is_context-dry_run = abap_true.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        rs_result-dry_run_count = rs_result-dry_run_count + 1.
        CONTINUE.
      ENDIF.

      DATA(ls_claim) = mo_repo->claim_work(
        iv_outbox_id   = ls_work-outbox_id
        iv_claim_owner = is_context-claim_owner
        iv_lock_until  = calculate_lock_until( is_context )
        is_context     = is_context ).

      IF ls_claim-claimed = abap_false.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        CONTINUE.
      ENDIF.

      rs_result-claimed_count = rs_result-claimed_count + 1.

      TRY.
          DATA(lo_handler) = mo_registry->resolve( ls_claim-work-work_type ).
          DATA(ls_handler_result) = lo_handler->handle(
            is_work    = ls_claim-work
            is_context = is_context ).
          IF ls_handler_result-outbox_id IS INITIAL.
            ls_handler_result-outbox_id = ls_claim-work-outbox_id.
          ENDIF.
          IF ls_handler_result-transfer_id IS INITIAL.
            ls_handler_result-transfer_id = ls_claim-work-transfer_id.
          ENDIF.

          finalize_claimed_work(
            EXPORTING
              is_context = is_context
              is_result  = ls_handler_result
            CHANGING
              cs_total   = rs_result ).

        CATCH /fcbp/cx_glt_error INTO DATA(lx_error).
          finalize_handler_error(
            EXPORTING
              is_work    = ls_claim-work
              is_context = is_context
              ix_error   = lx_error
            CHANGING
              cs_total   = rs_result ).
      ENDTRY.
    ENDLOOP.

    IF rs_result-status_code IS INITIAL.
      rs_result-status_code = COND #(
        WHEN rs_result-selected_count = 0
        THEN /fcbp/if_glt_job_types=>c_job_status-no_work
        WHEN is_context-dry_run = abap_true
        THEN /fcbp/if_glt_job_types=>c_job_status-dry_run
        ELSE /fcbp/cl_glt_job_counters=>derive_status(
          is_context = VALUE #( )
          is_result  = rs_result ) ).
    ENDIF.

    IF rs_result-message_text IS INITIAL.
      IF rs_result-status_code = /fcbp/if_glt_job_types=>c_job_status-no_work.
        rs_result-message_text = 'No due outbox work was selected.'.
      ELSEIF rs_result-status_code = /fcbp/if_glt_job_types=>c_job_status-dry_run.
        rs_result-message_text = 'Dry-run selected due outbox work without claiming rows.'.
      ELSE.
        rs_result-message_text = 'Outbox dispatcher completed due work processing.'.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validate_context.
    IF mo_repo IS NOT BOUND OR mo_registry IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = 'Outbox dispatcher requires repository and handler registry.'.
    ENDIF.

    IF is_context-claim_owner IS INITIAL AND is_context-dry_run = abap_false.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = 'Outbox dispatcher requires claim owner for productive execution.'.
    ENDIF.

    IF is_context-due_before IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = 'Outbox dispatcher requires due-before timestamp.'.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_lock_until.
    rv_lock_until = is_context-due_before.
    IF rv_lock_until IS INITIAL.
      GET TIME STAMP FIELD rv_lock_until.
    ENDIF.
  ENDMETHOD.

  METHOD finalize_claimed_work.
    DATA(ls_result) = is_result.
    IF ls_result-outbox_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = 'Work handler result must carry outbox ID.'.
    ENDIF.

    DATA(lv_successor_outbox_id) = VALUE /fcbp/if_glt_types=>ty_outbox_id( ).
    IF ls_result-followup_work-work_type IS NOT INITIAL.
      lv_successor_outbox_id = mo_repo->enqueue_work( ls_result-followup_work ).
      cs_total-rescheduled_count = cs_total-rescheduled_count + 1.
    ENDIF.

    CASE ls_result-next_action.
      WHEN /fcbp/if_glt_outbox_types=>c_next_action-release.
        mo_repo->release_work(
          iv_outbox_id   = ls_result-outbox_id
          iv_claim_owner = is_context-claim_owner
          is_result      = ls_result ).
        cs_total-skipped_count = cs_total-skipped_count + 1.

      WHEN /fcbp/if_glt_outbox_types=>c_next_action-fail_terminal
        OR /fcbp/if_glt_outbox_types=>c_next_action-operator_action.
        mo_repo->fail_work(
          iv_outbox_id   = ls_result-outbox_id
          iv_claim_owner = is_context-claim_owner
          is_result      = ls_result ).
        cs_total-failed_count = cs_total-failed_count + 1.
        cs_total-error_count = cs_total-error_count + 1.

      WHEN /fcbp/if_glt_outbox_types=>c_next_action-supersede.
        mo_repo->supersede_work(
          iv_outbox_id           = ls_result-outbox_id
          iv_claim_owner         = is_context-claim_owner
          iv_successor_outbox_id = lv_successor_outbox_id
          is_result              = ls_result ).
        cs_total-success_count = cs_total-success_count + 1.

      WHEN OTHERS.
        IF ls_result-completion_status = /fcbp/if_glt_types=>c_outbox_status-failed.
          mo_repo->fail_work(
            iv_outbox_id   = ls_result-outbox_id
            iv_claim_owner = is_context-claim_owner
            is_result      = ls_result ).
          cs_total-failed_count = cs_total-failed_count + 1.
          cs_total-error_count = cs_total-error_count + 1.
        ELSE.
          mo_repo->complete_work(
            iv_outbox_id   = ls_result-outbox_id
            iv_claim_owner = is_context-claim_owner
            is_result      = ls_result ).
          cs_total-success_count = cs_total-success_count + 1.
        ENDIF.
    ENDCASE.

    cs_total-processed_count = cs_total-processed_count + 1.
    IF cs_total-message_text IS INITIAL.
      cs_total-message_text = ls_result-message_text.
    ENDIF.
  ENDMETHOD.

  METHOD finalize_handler_error.
    DATA(ls_result) = VALUE /fcbp/if_glt_outbox_types=>ty_work_handler_result(
      outbox_id         = is_work-outbox_id
      transfer_id       = is_work-transfer_id
      next_action       = /fcbp/if_glt_outbox_types=>c_next_action-fail_terminal
      completion_status = /fcbp/if_glt_types=>c_outbox_status-failed
      message_text      = ix_error->operator_text
      retryable         = ix_error->retryable
      unknown_confirmation = ix_error->unknown_confirmation ).

    IF ls_result-message_text IS INITIAL.
      ls_result-message_text = ix_error->get_text( ).
    ENDIF.

    mo_repo->fail_work(
      iv_outbox_id   = is_work-outbox_id
      iv_claim_owner = is_context-claim_owner
      is_result      = ls_result ).

    cs_total-processed_count = cs_total-processed_count + 1.
    cs_total-failed_count = cs_total-failed_count + 1.
    cs_total-error_count = cs_total-error_count + 1.
    IF cs_total-message_text IS INITIAL.
      cs_total-message_text = ls_result-message_text.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
