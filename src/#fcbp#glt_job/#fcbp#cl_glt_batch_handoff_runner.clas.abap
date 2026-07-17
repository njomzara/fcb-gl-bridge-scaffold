"! Batch source handoff runner: selector candidates flow through Source Handoff only.
CLASS /fcbp/cl_glt_batch_handoff_runner DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_job_runner.

    METHODS constructor
      IMPORTING
        io_context_builder TYPE REF TO /fcbp/cl_glt_job_context_builder OPTIONAL
        io_recorder        TYPE REF TO /fcbp/if_glt_job_run_recorder OPTIONAL
        io_auth_guard      TYPE REF TO /fcbp/if_glt_job_auth_guard OPTIONAL
        io_selector        TYPE REF TO /fcbp/if_glt_source_selector OPTIONAL
        io_receiver        TYPE REF TO /fcbp/if_glt_handoff_receiver OPTIONAL
        io_dispatcher      TYPE REF TO /fcbp/if_glt_outbox_dispatcher OPTIONAL
        io_message_mapper  TYPE REF TO /fcbp/cl_glt_job_message_mapper OPTIONAL.

  PRIVATE SECTION.
    DATA mo_context_builder TYPE REF TO /fcbp/cl_glt_job_context_builder.
    DATA mo_recorder        TYPE REF TO /fcbp/if_glt_job_run_recorder.
    DATA mo_auth_guard      TYPE REF TO /fcbp/if_glt_job_auth_guard.
    DATA mo_selector        TYPE REF TO /fcbp/if_glt_source_selector.
    DATA mo_receiver        TYPE REF TO /fcbp/if_glt_handoff_receiver.
    DATA mo_dispatcher      TYPE REF TO /fcbp/if_glt_outbox_dispatcher.
    DATA mo_message_mapper  TYPE REF TO /fcbp/cl_glt_job_message_mapper.

    METHODS build_selection_request
      IMPORTING
        is_context        TYPE /fcbp/if_glt_job_types=>ty_job_context
      RETURNING
        VALUE(rs_request) TYPE /fcbp/if_glt_job_types=>ty_source_selection_request.

    METHODS build_handoff_request
      IMPORTING
        is_candidate      TYPE /fcbp/if_glt_job_types=>ty_source_candidate
        is_context        TYPE /fcbp/if_glt_job_types=>ty_job_context
      RETURNING
        VALUE(rs_request) TYPE /fcbp/if_glt_types=>ty_handoff_request.

    METHODS build_dispatch_context
      IMPORTING
        is_context        TYPE /fcbp/if_glt_job_types=>ty_job_context
      RETURNING
        VALUE(rs_context) TYPE /fcbp/if_glt_job_types=>ty_dispatch_context.

ENDCLASS.

CLASS /fcbp/cl_glt_batch_handoff_runner IMPLEMENTATION.

  METHOD constructor.
    mo_context_builder = COND #( WHEN io_context_builder IS BOUND THEN io_context_builder ELSE NEW /fcbp/cl_glt_job_context_builder( ) ).
    mo_recorder        = COND #( WHEN io_recorder        IS BOUND THEN io_recorder        ELSE NEW /fcbp/cl_glt_job_run_recorder( ) ).
    mo_auth_guard      = COND #( WHEN io_auth_guard      IS BOUND THEN io_auth_guard      ELSE NEW /fcbp/cl_glt_job_auth_guard( ) ).
    mo_selector        = COND #( WHEN io_selector        IS BOUND THEN io_selector        ELSE NEW /fcbp/cl_glt_source_selector( ) ).
    mo_receiver        = io_receiver.
    mo_dispatcher      = COND #( WHEN io_dispatcher      IS BOUND THEN io_dispatcher      ELSE NEW /fcbp/cl_glt_outbox_dispatcher( ) ).
    mo_message_mapper  = COND #( WHEN io_message_mapper  IS BOUND THEN io_message_mapper  ELSE NEW /fcbp/cl_glt_job_message_mapper( ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_job_runner~run.
    DATA(ls_context) = is_context.
    IF ls_context-job_type IS INITIAL.
      ls_context = mo_context_builder->build( it_parameter ).
    ENDIF.
    ls_context-job_type = /fcbp/if_glt_job_types=>c_job_type-batch_handoff.

    mo_auth_guard->check_job_scope( ls_context ).
    ls_context-jobrun_id = mo_recorder->start_run( ls_context ).

    TRY.
        IF mo_receiver IS NOT BOUND AND ls_context-dry_run = abap_false.
          RAISE EXCEPTION TYPE /fcbp/cx_glt_error
            EXPORTING
              error_category = /fcbp/if_glt_types=>c_error_category-technical
              operator_text  = 'Batch handoff runner requires Source Handoff receiver for productive execution.'.
        ENDIF.

        DATA(lt_candidate) = mo_selector->select_eligible_scopes( build_selection_request( ls_context ) ).
        rs_result-selected_count = lines( lt_candidate ).

        LOOP AT lt_candidate INTO DATA(ls_candidate).
          IF ls_context-dry_run = abap_true.
            rs_result-dry_run_count = rs_result-dry_run_count + 1.
            rs_result-skipped_count = rs_result-skipped_count + 1.
            CONTINUE.
          ENDIF.

          TRY.
              DATA(ls_handoff_result) = mo_receiver->receive_scope(
                build_handoff_request(
                  is_candidate = ls_candidate
                  is_context   = ls_context ) ).
              DATA(ls_item_result) = /fcbp/cl_glt_job_counters=>from_handoff_result( ls_handoff_result ).
              /fcbp/cl_glt_job_counters=>add(
                EXPORTING is_increment = ls_item_result
                CHANGING  cs_total     = rs_result ).
            CATCH /fcbp/cx_glt_error INTO DATA(lx_item).
              rs_result-processed_count = rs_result-processed_count + 1.
              rs_result-failed_count = rs_result-failed_count + 1.
              rs_result-error_count = rs_result-error_count + 1.
              IF rs_result-message_text IS INITIAL.
                rs_result-message_text = lx_item->operator_text.
              ENDIF.
              IF ls_context-fail_fast = abap_true.
                RAISE EXCEPTION lx_item.
              ENDIF.
          ENDTRY.
        ENDLOOP.

        IF ls_context-immediate_dispatch = abap_true AND ls_context-dry_run = abap_false.
          DATA(ls_dispatch_result) = mo_dispatcher->dispatch_due_work( build_dispatch_context( ls_context ) ).
          /fcbp/cl_glt_job_counters=>add(
            EXPORTING is_increment = ls_dispatch_result
            CHANGING  cs_total     = rs_result ).
        ENDIF.

        rs_result = mo_message_mapper->complete_result(
          is_context = ls_context
          is_result  = rs_result ).

        mo_recorder->finish_run(
          iv_jobrun_id = ls_context-jobrun_id
          is_result    = rs_result ).

      CATCH /fcbp/cx_glt_error INTO DATA(lx_error).
        DATA(ls_failure) = mo_message_mapper->map_exception( lx_error ).
        ls_failure-jobrun_id = ls_context-jobrun_id.
        mo_recorder->fail_run(
          iv_jobrun_id = ls_context-jobrun_id
          is_failure   = ls_failure ).
        RAISE EXCEPTION lx_error.
    ENDTRY.
  ENDMETHOD.

  METHOD build_selection_request.
    rs_request = VALUE #(
      source_system  = is_context-source_system
      source_type    = is_context-source_type
      company_code   = is_context-company_code
      fiscal_year    = is_context-fiscal_year
      posting_period = is_context-posting_period
      date_from      = is_context-date_from
      date_to        = is_context-date_to
      target_id      = is_context-target_id
      selection_mode = is_context-selection_mode
      max_scopes     = is_context-max_scopes
      dry_run        = is_context-dry_run
      actor_id       = is_context-actor_id
      correlation_id = is_context-correlation_id ).
  ENDMETHOD.

  METHOD build_handoff_request.
    DATA(lv_requested_at) = VALUE utclong( ).
    GET TIME STAMP FIELD lv_requested_at.

    rs_request = VALUE #(
      source_type         = is_candidate-source_type
      source_reference    = is_candidate-source_reference
      source_doc_no       = is_candidate-source_doc_no
      reconciliation_key  = is_candidate-reconciliation_key
      event_type          = is_candidate-event_type
      event_id            = is_candidate-event_id
      company_code        = is_candidate-company_code
      ledger_group        = is_candidate-ledger_group
      processing_mode     = /fcbp/if_glt_types=>c_processing_mode-batch
      requested_by        = COND #( WHEN is_candidate-requested_by IS NOT INITIAL THEN is_candidate-requested_by ELSE is_context-actor_id )
      requested_at        = lv_requested_at
      external_corr_id    = is_candidate-external_corr_id
      source_payload_hash = is_candidate-source_payload_hash
      routing_hint        = is_candidate-routing_hint ).
  ENDMETHOD.

  METHOD build_dispatch_context.
    rs_context = VALUE #(
      jobrun_id           = is_context-jobrun_id
      claim_owner         = is_context-jobrun_id
      target_id           = is_context-target_id
      work_type           = /fcbp/if_glt_types=>c_outbox_work_type-dispatch
      processing_mode     = /fcbp/if_glt_types=>c_processing_mode-batch
      due_before          = is_context-due_before
      max_items           = is_context-max_items
      max_runtime_seconds = is_context-max_runtime_seconds
      priority_max        = is_context-priority_max
      dry_run             = is_context-dry_run
      actor_id            = is_context-actor_id
      correlation_id      = is_context-correlation_id ).
  ENDMETHOD.

ENDCLASS.
