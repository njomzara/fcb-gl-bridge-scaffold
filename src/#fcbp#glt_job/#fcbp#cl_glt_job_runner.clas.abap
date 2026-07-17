"! Common outbox-backed Job Layer runner for dispatch/retry/poll/status-query wake-ups.
CLASS /fcbp/cl_glt_job_runner DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_job_runner.

    METHODS constructor
      IMPORTING
        io_context_builder TYPE REF TO /fcbp/cl_glt_job_context_builder OPTIONAL
        io_recorder        TYPE REF TO /fcbp/if_glt_job_run_recorder OPTIONAL
        io_auth_guard      TYPE REF TO /fcbp/if_glt_job_auth_guard OPTIONAL
        io_dispatcher      TYPE REF TO /fcbp/if_glt_outbox_dispatcher OPTIONAL
        io_message_mapper  TYPE REF TO /fcbp/cl_glt_job_message_mapper OPTIONAL.

  PRIVATE SECTION.
    DATA mo_context_builder TYPE REF TO /fcbp/cl_glt_job_context_builder.
    DATA mo_recorder        TYPE REF TO /fcbp/if_glt_job_run_recorder.
    DATA mo_auth_guard      TYPE REF TO /fcbp/if_glt_job_auth_guard.
    DATA mo_dispatcher      TYPE REF TO /fcbp/if_glt_outbox_dispatcher.
    DATA mo_message_mapper  TYPE REF TO /fcbp/cl_glt_job_message_mapper.

    METHODS build_dispatch_context
      IMPORTING
        is_context        TYPE /fcbp/if_glt_job_types=>ty_job_context
      RETURNING
        VALUE(rs_context) TYPE /fcbp/if_glt_job_types=>ty_dispatch_context.

ENDCLASS.

CLASS /fcbp/cl_glt_job_runner IMPLEMENTATION.

  METHOD constructor.
    mo_context_builder = COND #( WHEN io_context_builder IS BOUND THEN io_context_builder ELSE NEW /fcbp/cl_glt_job_context_builder( ) ).
    mo_recorder        = COND #( WHEN io_recorder        IS BOUND THEN io_recorder        ELSE NEW /fcbp/cl_glt_job_run_recorder( ) ).
    mo_auth_guard      = COND #( WHEN io_auth_guard      IS BOUND THEN io_auth_guard      ELSE NEW /fcbp/cl_glt_job_auth_guard( ) ).
    mo_dispatcher      = COND #( WHEN io_dispatcher      IS BOUND THEN io_dispatcher      ELSE NEW /fcbp/cl_glt_outbox_dispatcher( ) ).
    mo_message_mapper  = COND #( WHEN io_message_mapper  IS BOUND THEN io_message_mapper  ELSE NEW /fcbp/cl_glt_job_message_mapper( ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_job_runner~run.
    DATA(ls_context) = is_context.
    IF ls_context-job_type IS INITIAL.
      ls_context = mo_context_builder->build( it_parameter ).
    ENDIF.

    mo_auth_guard->check_job_scope( ls_context ).
    ls_context-jobrun_id = mo_recorder->start_run( ls_context ).

    TRY.
        DATA(ls_dispatch_context) = build_dispatch_context( ls_context ).
        rs_result = mo_dispatcher->dispatch_due_work( ls_dispatch_context ).
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

  METHOD build_dispatch_context.
    rs_context = VALUE #(
      jobrun_id           = is_context-jobrun_id
      claim_owner         = is_context-jobrun_id
      target_id           = is_context-target_id
      work_type           = is_context-work_type
      processing_mode     = is_context-processing_mode
      due_before          = is_context-due_before
      max_items           = is_context-max_items
      max_runtime_seconds = is_context-max_runtime_seconds
      priority_max        = is_context-priority_max
      dry_run             = is_context-dry_run
      actor_id            = is_context-actor_id
      correlation_id      = is_context-correlation_id ).
  ENDMETHOD.

ENDCLASS.
