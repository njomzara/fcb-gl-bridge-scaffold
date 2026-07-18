"! RETRY work handler: revalidate current package, remap, resubmit, and persist retry evidence.
CLASS /fcbp/cl_glt_wh_retry DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_work_handler.

    METHODS constructor
      IMPORTING
        io_repository      TYPE REF TO /fcbp/if_glt_repository OPTIONAL
        io_package_repo    TYPE REF TO /fcbp/if_glt_package_repo OPTIONAL
        io_config_provider TYPE REF TO /fcbp/if_glt_config_provider OPTIONAL
        io_config_repo     TYPE REF TO /fcbp/if_glt_config_repo OPTIONAL
        io_validator       TYPE REF TO /fcbp/if_glt_pkg_validator OPTIONAL
        io_mapper          TYPE REF TO /fcbp/if_glt_mapper OPTIONAL
        io_adapter_factory TYPE REF TO /fcbp/cl_glt_adapter_factory OPTIONAL
        io_evidence        TYPE REF TO /fcbp/if_glt_adapter_evidence OPTIONAL
        io_status_manager  TYPE REF TO /fcbp/if_glt_status_manager OPTIONAL
        io_retry_service   TYPE REF TO /fcbp/if_glt_retry_service OPTIONAL
        io_idempotency     TYPE REF TO /fcbp/if_glt_idempotency OPTIONAL
        io_logger          TYPE REF TO /fcbp/if_glt_logger OPTIONAL.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_submit_summary,
        status_code          TYPE /fcbp/if_glt_types=>ty_status,
        error_id             TYPE /fcbp/if_glt_types=>ty_error_id,
        attempt_id           TYPE /fcbp/if_glt_types=>ty_attempt_id,
        ref_id               TYPE /fcbp/if_glt_types=>ty_ref_id,
        followup_work        TYPE /fcbp/if_glt_types=>ty_outbox_work,
        message_text         TYPE char220,
        retryable            TYPE abap_bool,
        unknown_confirmation TYPE abap_bool,
      END OF ty_submit_summary.

    DATA mo_repository TYPE REF TO /fcbp/if_glt_repository.
    DATA mo_package_repo TYPE REF TO /fcbp/if_glt_package_repo.
    DATA mo_config_provider TYPE REF TO /fcbp/if_glt_config_provider.
    DATA mo_config_repo TYPE REF TO /fcbp/if_glt_config_repo.
    DATA mo_validator TYPE REF TO /fcbp/if_glt_pkg_validator.
    DATA mo_mapper TYPE REF TO /fcbp/if_glt_mapper.
    DATA mo_adapter_factory TYPE REF TO /fcbp/cl_glt_adapter_factory.
    DATA mo_evidence TYPE REF TO /fcbp/if_glt_adapter_evidence.
    DATA mo_status_manager TYPE REF TO /fcbp/if_glt_status_manager.
    DATA mo_retry_service TYPE REF TO /fcbp/if_glt_retry_service.
    DATA mo_idempotency TYPE REF TO /fcbp/if_glt_idempotency.
    DATA mo_logger TYPE REF TO /fcbp/if_glt_logger.

    METHODS assert_work_type
      IMPORTING
        is_work TYPE /fcbp/if_glt_types=>ty_outbox_work
      RAISING
        /fcbp/cx_glt_error.

    METHODS determine_current_package_id
      IMPORTING
        is_transfer           TYPE /fcbp/if_glt_types=>ty_transfer
      RETURNING
        VALUE(rv_package_id)  TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      RAISING
        /fcbp/cx_glt_error.

    METHODS sync_current_package_header
      IMPORTING
        iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      CHANGING
        cs_transfer   TYPE /fcbp/if_glt_types=>ty_transfer
      RAISING
        /fcbp/cx_glt_error.

    METHODS assert_package_retryable
      IMPORTING
        is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
        is_graph    TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
      RAISING
        /fcbp/cx_glt_error.

    METHODS build_scope
      IMPORTING
        is_transfer       TYPE /fcbp/if_glt_types=>ty_transfer
        is_work           TYPE /fcbp/if_glt_types=>ty_outbox_work
        is_context        TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
      RETURNING
        VALUE(rs_scope)   TYPE /fcbp/if_glt_config_types=>ty_routing_scope.

    METHODS build_effective_context
      IMPORTING
        is_transfer        TYPE /fcbp/if_glt_types=>ty_transfer
        is_work            TYPE /fcbp/if_glt_types=>ty_outbox_work
        is_context         TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
        is_graph           TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
        is_policy_context  TYPE /fcbp/if_glt_config_types=>ty_policy_context
      RETURNING
        VALUE(rs_context)  TYPE /fcbp/if_glt_config_types=>ty_effective_context
      RAISING
        /fcbp/cx_glt_error.

    METHODS build_route
      IMPORTING
        is_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
        is_policy_context    TYPE /fcbp/if_glt_config_types=>ty_policy_context
      RETURNING
        VALUE(rs_route)      TYPE /fcbp/if_glt_types=>ty_route.

    METHODS sync_transfer_target
      IMPORTING
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
        is_route             TYPE /fcbp/if_glt_types=>ty_route
      CHANGING
        cs_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
      RAISING
        /fcbp/cx_glt_error.

    METHODS move_retry_to_processing
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
        is_context     TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
      RAISING
        /fcbp/cx_glt_error.

    METHODS mark_failure_status
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_error_id    TYPE /fcbp/if_glt_types=>ty_error_id OPTIONAL
        iv_reason      TYPE char30
        is_context     TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
      RAISING
        /fcbp/cx_glt_error.

    METHODS build_validation_context
      IMPORTING
        is_work              TYPE /fcbp/if_glt_types=>ty_outbox_work
        is_context           TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
        iv_package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      RETURNING
        VALUE(rs_context)    TYPE /fcbp/if_glt_val_types=>ty_package_context.

    METHODS build_mapping_context
      IMPORTING
        is_work              TYPE /fcbp/if_glt_types=>ty_outbox_work
        is_context           TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
        is_policy_context    TYPE /fcbp/if_glt_config_types=>ty_policy_context
        is_validation_result TYPE /fcbp/if_glt_val_types=>ty_result
        iv_package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      RETURNING
        VALUE(rs_context)    TYPE /fcbp/if_glt_map_types=>ty_context.

    METHODS submit_mapped_journal
      IMPORTING
        is_work              TYPE /fcbp/if_glt_types=>ty_outbox_work
        is_context           TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
        is_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
        is_route             TYPE /fcbp/if_glt_types=>ty_route
        is_package_graph     TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
        is_mapping_result    TYPE /fcbp/if_glt_map_types=>ty_result
      RETURNING
        VALUE(rs_summary)    TYPE ty_submit_summary
      RAISING
        /fcbp/cx_glt_error.

    METHODS build_submit_request
      IMPORTING
        is_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
        is_route             TYPE /fcbp/if_glt_types=>ty_route
        is_mapping_result    TYPE /fcbp/if_glt_map_types=>ty_result
        is_outdoc            TYPE /fcbp/if_glt_pkg_types=>ty_outdoc
        io_adapter           TYPE REF TO /fcbp/if_glt_transfer_adapter
      RETURNING
        VALUE(rs_request)    TYPE /fcbp/if_glt_adapter_types=>ty_submit_request.

    METHODS adapter_result_from_exception
      IMPORTING
        ix_error           TYPE REF TO /fcbp/cx_glt_adapter
        is_request         TYPE /fcbp/if_glt_adapter_types=>ty_submit_request
      RETURNING
        VALUE(rs_result)   TYPE /fcbp/if_glt_types=>ty_adapter_result.

    METHODS build_followup_work
      IMPORTING
        is_work           TYPE /fcbp/if_glt_types=>ty_outbox_work
        iv_work_type      TYPE char20
      RETURNING
        VALUE(rs_work)    TYPE /fcbp/if_glt_types=>ty_outbox_work.

    METHODS log_pipeline_error
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_category    TYPE char24
        iv_text        TYPE char220
        iv_retryable   TYPE abap_bool DEFAULT abap_false
        iv_unknown     TYPE abap_bool DEFAULT abap_false
        ix_previous    TYPE REF TO cx_root OPTIONAL
      RETURNING
        VALUE(rv_error_id) TYPE /fcbp/if_glt_types=>ty_error_id.

    METHODS log_adapter_error
      IMPORTING
        is_result      TYPE /fcbp/if_glt_types=>ty_adapter_result
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
      RETURNING
        VALUE(rv_error_id) TYPE /fcbp/if_glt_types=>ty_error_id.

    METHODS source_reference
      IMPORTING
        is_transfer                TYPE /fcbp/if_glt_types=>ty_transfer
      RETURNING
        VALUE(rv_source_reference) TYPE char50.

    METHODS actor_id
      IMPORTING
        is_context       TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
      RETURNING
        VALUE(rv_actor)  TYPE char40.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

ENDCLASS.

CLASS /fcbp/cl_glt_wh_retry IMPLEMENTATION.

  METHOD constructor.
    mo_repository = COND #( WHEN io_repository IS BOUND THEN io_repository ELSE NEW /fcbp/cl_glt_repository( ) ).
    mo_package_repo = COND #( WHEN io_package_repo IS BOUND THEN io_package_repo ELSE NEW /fcbp/cl_glt_package_repo( ) ).
    mo_config_repo = COND #( WHEN io_config_repo IS BOUND THEN io_config_repo ELSE NEW /fcbp/cl_glt_config_repo( ) ).

    mo_config_provider = COND #(
      WHEN io_config_provider IS BOUND THEN io_config_provider
      ELSE NEW /fcbp/cl_glt_config_provider(
        io_repository     = mo_repository
        io_config_repo    = mo_config_repo
        io_health         = NEW /fcbp/cl_glt_config_health( io_repository = mo_config_repo )
        io_policy_context = NEW /fcbp/cl_glt_policy_context( io_repository = mo_config_repo ) ) ).

    mo_validator = COND #(
      WHEN io_validator IS BOUND THEN io_validator
      ELSE NEW /fcbp/cl_glt_pkg_validator(
        io_evidence = NEW /fcbp/cl_glt_pkg_evidence(
          io_transfer_repo = mo_repository
          io_package_repo  = mo_package_repo
          io_config_repo   = mo_config_repo ) ) ).

    mo_mapper = COND #(
      WHEN io_mapper IS BOUND THEN io_mapper
      ELSE NEW /fcbp/cl_glt_mapper(
        io_package_repo = mo_package_repo
        io_config_repo  = mo_config_repo ) ).

    mo_adapter_factory = COND #( WHEN io_adapter_factory IS BOUND THEN io_adapter_factory ELSE NEW /fcbp/cl_glt_adapter_factory( ) ).
    mo_evidence = COND #( WHEN io_evidence IS BOUND THEN io_evidence ELSE NEW /fcbp/cl_glt_adapter_evidence( ) ).
    mo_status_manager = COND #( WHEN io_status_manager IS BOUND THEN io_status_manager ELSE NEW /fcbp/cl_glt_status_mgr( io_repository = mo_repository ) ).
    mo_retry_service = COND #( WHEN io_retry_service IS BOUND THEN io_retry_service ELSE NEW /fcbp/cl_glt_retry_service( io_repository = mo_repository ) ).
    mo_idempotency = COND #( WHEN io_idempotency IS BOUND THEN io_idempotency ELSE NEW /fcbp/cl_glt_idempotency( io_repository = mo_repository ) ).
    mo_logger = COND #( WHEN io_logger IS BOUND THEN io_logger ELSE NEW /fcbp/cl_glt_app_logger( io_repository = mo_repository ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_work_handler~handle.
    assert_work_type( is_work ).

    TRY.
        DATA(ls_transfer) = mo_repository->read_transfer( is_work-transfer_id ).
        DATA(lv_package_id) = determine_current_package_id( ls_transfer ).

        sync_current_package_header(
          EXPORTING
            iv_package_id = lv_package_id
          CHANGING
            cs_transfer   = ls_transfer ).

        DATA(ls_package_graph) = mo_package_repo->read_package( lv_package_id ).
        assert_package_retryable(
          is_transfer = ls_transfer
          is_graph    = ls_package_graph ).

        DATA(ls_policy_context) = mo_config_provider->read_policy_context( ls_package_graph-package_header-policy_context_id ).
        DATA(ls_effective_context) = build_effective_context(
          is_transfer       = ls_transfer
          is_work           = is_work
          is_context        = is_context
          is_graph          = ls_package_graph
          is_policy_context = ls_policy_context ).
        DATA(ls_route) = build_route(
          is_transfer          = ls_transfer
          is_effective_context = ls_effective_context
          is_policy_context    = ls_policy_context ).

        sync_transfer_target(
          EXPORTING
            is_effective_context = ls_effective_context
            is_route             = ls_route
          CHANGING
            cs_transfer          = ls_transfer ).

        DATA(ls_validation_result) = mo_validator->revalidate_package(
          build_validation_context(
            is_work              = is_work
            is_context           = is_context
            is_effective_context = ls_effective_context
            iv_package_id        = lv_package_id ) ).

        IF ls_validation_result-passed <> abap_true.
          DATA(lv_val_text) = CONV char220( 'Retry package validation failed.' ).
          LOOP AT ls_validation_result-messages INTO DATA(ls_val_msg) WHERE blocking = abap_true.
            lv_val_text = ls_val_msg-operator_text.
            EXIT.
          ENDLOOP.
          DATA(lv_val_error) = log_pipeline_error(
            iv_transfer_id = is_work-transfer_id
            iv_category    = /fcbp/if_glt_types=>c_error_category-validation
            iv_text        = lv_val_text ).
          mark_failure_status(
            iv_transfer_id = is_work-transfer_id
            iv_error_id    = lv_val_error
            iv_reason      = 'RETRY_VALIDATE'
            is_context     = is_context ).
          rs_result = VALUE #(
            outbox_id         = is_work-outbox_id
            transfer_id       = is_work-transfer_id
            next_action       = /fcbp/if_glt_outbox_types=>c_next_action-operator_action
            completion_status = /fcbp/if_glt_types=>c_outbox_status-failed
            status_code       = /fcbp/if_glt_types=>c_status-failed_final
            error_id          = lv_val_error
            message_text      = lv_val_text ).
          RETURN.
        ENDIF.

        DATA(ls_mapping_result) = mo_mapper->map_package(
          build_mapping_context(
            is_work              = is_work
            is_context           = is_context
            is_effective_context = ls_effective_context
            is_policy_context    = ls_policy_context
            is_validation_result = ls_validation_result
            iv_package_id        = lv_package_id ) ).

        IF ls_mapping_result-result_status <> /fcbp/if_glt_map_types=>c_result_status-mapped.
          DATA(lv_map_text) = CONV char220( 'Retry package mapping failed.' ).
          LOOP AT ls_mapping_result-messages INTO DATA(ls_map_msg) WHERE blocking = abap_true.
            lv_map_text = ls_map_msg-operator_text.
            EXIT.
          ENDLOOP.
          DATA(lv_map_error) = log_pipeline_error(
            iv_transfer_id = is_work-transfer_id
            iv_category    = /fcbp/if_glt_types=>c_error_category-validation
            iv_text        = lv_map_text ).
          mark_failure_status(
            iv_transfer_id = is_work-transfer_id
            iv_error_id    = lv_map_error
            iv_reason      = 'RETRY_MAPPING'
            is_context     = is_context ).
          rs_result = VALUE #(
            outbox_id         = is_work-outbox_id
            transfer_id       = is_work-transfer_id
            next_action       = /fcbp/if_glt_outbox_types=>c_next_action-operator_action
            completion_status = /fcbp/if_glt_types=>c_outbox_status-failed
            status_code       = /fcbp/if_glt_types=>c_status-failed_final
            error_id          = lv_map_error
            message_text      = lv_map_text ).
          RETURN.
        ENDIF.

        move_retry_to_processing(
          iv_transfer_id = is_work-transfer_id
          is_context     = is_context ).
        ls_transfer = mo_repository->read_transfer( is_work-transfer_id ).

        DATA(ls_submit_summary) = submit_mapped_journal(
          is_work              = is_work
          is_context           = is_context
          is_transfer          = ls_transfer
          is_effective_context = ls_effective_context
          is_route             = ls_route
          is_package_graph     = ls_package_graph
          is_mapping_result    = ls_mapping_result ).

        mo_status_manager->set_status(
          iv_transfer_id = is_work-transfer_id
          iv_status      = ls_submit_summary-status_code
          iv_reason      = 'RETRY_RESULT'
          iv_error_id    = ls_submit_summary-error_id
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).

        IF ls_submit_summary-status_code = /fcbp/if_glt_types=>c_status-posted
           AND ls_transfer-header-idempotency_key IS NOT INITIAL.
          mo_idempotency->confirm_completed(
            iv_idempotency_key = ls_transfer-header-idempotency_key
            iv_transfer_id     = is_work-transfer_id ).
        ENDIF.

        rs_result = VALUE #(
          outbox_id             = is_work-outbox_id
          transfer_id           = is_work-transfer_id
          status_code           = ls_submit_summary-status_code
          attempt_id            = ls_submit_summary-attempt_id
          target_ref_id         = ls_submit_summary-ref_id
          error_id              = ls_submit_summary-error_id
          followup_work         = ls_submit_summary-followup_work
          message_text          = ls_submit_summary-message_text
          retryable             = ls_submit_summary-retryable
          unknown_confirmation  = ls_submit_summary-unknown_confirmation ).

        CASE ls_submit_summary-status_code.
          WHEN /fcbp/if_glt_types=>c_status-posted.
            rs_result-next_action = /fcbp/if_glt_outbox_types=>c_next_action-mark_posted.
            rs_result-completion_status = /fcbp/if_glt_types=>c_outbox_status-done.
          WHEN /fcbp/if_glt_types=>c_status-dispatched.
            rs_result-next_action = /fcbp/if_glt_outbox_types=>c_next_action-mark_dispatched.
            rs_result-completion_status = /fcbp/if_glt_types=>c_outbox_status-done.
          WHEN /fcbp/if_glt_types=>c_status-unknown_confirmation.
            rs_result-next_action = /fcbp/if_glt_outbox_types=>c_next_action-schedule_status_query.
            rs_result-completion_status = /fcbp/if_glt_types=>c_outbox_status-done.
          WHEN /fcbp/if_glt_types=>c_status-failed_retryable.
            rs_result-next_action = /fcbp/if_glt_outbox_types=>c_next_action-schedule_retry.
            rs_result-completion_status = /fcbp/if_glt_types=>c_outbox_status-done.
          WHEN OTHERS.
            rs_result-next_action = /fcbp/if_glt_outbox_types=>c_next_action-fail_terminal.
            rs_result-completion_status = /fcbp/if_glt_types=>c_outbox_status-failed.
        ENDCASE.

      CATCH /fcbp/cx_glt_error INTO DATA(lx_error).
        DATA(lv_error_id) = log_pipeline_error(
          iv_transfer_id = is_work-transfer_id
          iv_category    = COND #( WHEN lx_error->error_category IS INITIAL THEN /fcbp/if_glt_types=>c_error_category-technical ELSE lx_error->error_category )
          iv_text        = COND #( WHEN lx_error->operator_text IS INITIAL THEN CONV char220( lx_error->get_text( ) ) ELSE lx_error->operator_text )
          iv_retryable   = lx_error->retryable
          iv_unknown     = lx_error->unknown_confirmation
          ix_previous    = lx_error ).
        TRY.
            mark_failure_status(
              iv_transfer_id = is_work-transfer_id
              iv_error_id    = lv_error_id
              iv_reason      = 'RETRY_ERR'
              is_context     = is_context ).
          CATCH /fcbp/cx_glt_error.
        ENDTRY.

        rs_result = VALUE #(
          outbox_id             = is_work-outbox_id
          transfer_id           = is_work-transfer_id
          next_action           = /fcbp/if_glt_outbox_types=>c_next_action-fail_terminal
          completion_status     = /fcbp/if_glt_types=>c_outbox_status-failed
          status_code           = /fcbp/if_glt_types=>c_status-failed_final
          error_id              = lv_error_id
          message_text          = COND #( WHEN lx_error->operator_text IS INITIAL THEN CONV char220( lx_error->get_text( ) ) ELSE lx_error->operator_text )
          retryable             = lx_error->retryable
          unknown_confirmation  = lx_error->unknown_confirmation ).
    ENDTRY.
  ENDMETHOD.

  METHOD assert_work_type.
    IF is_work-work_type <> /fcbp/if_glt_types=>c_outbox_work_type-retry.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_work-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = |RETRY handler received work type { is_work-work_type }.|.
    ENDIF.
  ENDMETHOD.

  METHOD determine_current_package_id.
    rv_package_id = is_transfer-header-current_package_id.
    IF rv_package_id IS NOT INITIAL.
      RETURN.
    ENDIF.

    SELECT package_id
      FROM /fcbp/glt_pkg
      WHERE transfer_id = @is_transfer-header-transfer_id
        AND current_flag = @abap_true
      INTO TABLE @DATA(lt_package_id)
      UP TO 2 ROWS.

    IF lt_package_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Retry requires a current package on the transfer or package evidence tables.'.
    ENDIF.

    IF lines( lt_package_id ) > 1.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-conflict
          operator_text  = 'Retry found more than one current package for the transfer.'.
    ENDIF.

    READ TABLE lt_package_id INTO rv_package_id INDEX 1.
  ENDMETHOD.

  METHOD sync_current_package_header.
    IF cs_transfer-header-current_package_id = iv_package_id.
      RETURN.
    ENDIF.

    IF cs_transfer-header-current_package_id IS NOT INITIAL
       AND cs_transfer-header-current_package_id <> iv_package_id.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = cs_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-conflict
          operator_text  = |Transfer current package { cs_transfer-header-current_package_id } conflicts with retry package { iv_package_id }.|.
    ENDIF.

    DATA(ls_header) = cs_transfer-header.
    ls_header-current_package_id = iv_package_id.
    ls_header-changed_by = sy-uname.
    ls_header-changed_at = now( ).
    ls_header-version_no = ls_header-version_no + 1.
    mo_repository->update_header( ls_header ).
    cs_transfer-header = ls_header.
  ENDMETHOD.

  METHOD assert_package_retryable.
    IF is_graph-package_header-package_id IS INITIAL
       OR is_graph-package_header-transfer_id <> is_transfer-header-transfer_id.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Retry package evidence does not belong to the transfer.'.
    ENDIF.

    IF is_graph-package_header-current_flag <> abap_true
       OR is_graph-package_header-superseded_by_package_id IS NOT INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-conflict
          operator_text  = 'Retry can only resubmit the current, non-superseded package.'.
    ENDIF.

    IF is_graph-package_header-policy_context_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = 'Retry package evidence has no policy context id.'.
    ENDIF.

    CASE is_transfer-header-status_code.
      WHEN /fcbp/if_glt_types=>c_status-failed_retryable
        OR /fcbp/if_glt_types=>c_status-reprocess_requested
        OR /fcbp/if_glt_types=>c_status-processing.
        RETURN.
      WHEN /fcbp/if_glt_types=>c_status-unknown_confirmation.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_error
          EXPORTING
            transfer_id    = is_transfer-header-transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-conflict
            operator_text  = 'Unknown confirmation must be handled by STATUS_QUERY before retry.'.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_error
          EXPORTING
            transfer_id    = is_transfer-header-transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-conflict
            operator_text  = |Retry requires FAILED_RETRYABLE, REPROCESS_REQUESTED, or PROCESSING state; current status is { is_transfer-header-status_code }.|.
    ENDCASE.
  ENDMETHOD.

  METHOD build_scope.
    rs_scope = VALUE #(
      transfer_id      = is_transfer-header-transfer_id
      transfer_type    = is_transfer-header-transfer_type
      source_system    = is_transfer-header-source_system
      source_type      = is_transfer-header-source_type
      source_reference = source_reference( is_transfer )
      company_code     = is_transfer-header-company_code
      processing_mode  = COND #( WHEN is_work-processing_mode IS NOT INITIAL THEN is_work-processing_mode ELSE is_transfer-header-processing_mode )
      target_id        = COND #( WHEN is_work-target_id IS NOT INITIAL THEN is_work-target_id ELSE is_transfer-header-target_id )
      requested_by     = actor_id( is_context )
      correlation_id   = is_context-correlation_id
      resolution_date  = sy-datum
      resolution_time  = sy-uzeit ).
  ENDMETHOD.

  METHOD build_effective_context.
    DATA(lv_target_id) = COND char20(
      WHEN is_policy_context-target_id IS NOT INITIAL THEN is_policy_context-target_id
      ELSE is_graph-package_header-target_id ).

    IF lv_target_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = 'Retry policy context has no target id.'.
    ENDIF.

    rs_context-routing_scope = build_scope(
      is_transfer = is_transfer
      is_work     = is_work
      is_context  = is_context ).
    rs_context-target_profile = mo_config_provider->read_target_profile( lv_target_id ).
    rs_context-policy_context_id = is_policy_context-policy_context_id.

    IF is_policy_context-retry_policy_id IS NOT INITIAL.
      rs_context-retry_policy = mo_config_repo->read_retry_policy(
        iv_policy_id = is_policy_context-retry_policy_id
        iv_version   = is_policy_context-retry_version ).
    ENDIF.
    IF is_policy_context-validation_profile_id IS NOT INITIAL.
      rs_context-validation_rules = mo_config_repo->read_validation_rules(
        iv_profile_id = is_policy_context-validation_profile_id
        iv_version    = is_policy_context-validation_version ).
    ENDIF.
    IF is_policy_context-mapping_policy_id IS NOT INITIAL.
      rs_context-mapping_rules = mo_config_repo->read_mapping_rules(
        iv_policy_id = is_policy_context-mapping_policy_id
        iv_version    = is_policy_context-mapping_version ).
    ENDIF.
    IF is_policy_context-throttle_policy_id IS NOT INITIAL.
      rs_context-throttle_policy = mo_config_repo->read_throttle_policy(
        iv_policy_id = is_policy_context-throttle_policy_id
        iv_version   = is_policy_context-throttle_version ).
    ENDIF.
    IF is_policy_context-confirmation_policy_id IS NOT INITIAL.
      rs_context-confirmation_policy = mo_config_repo->read_confirmation_policy(
        iv_policy_id = is_policy_context-confirmation_policy_id
        iv_version   = is_policy_context-confirmation_version ).
    ENDIF.

    rs_context-resolved_at = now( ).
    rs_context-resolved_by = sy-uname.
  ENDMETHOD.

  METHOD build_route.
    rs_route = VALUE #(
      route_id          = is_effective_context-target_profile-target_id
      transfer_type     = is_transfer-header-transfer_type
      source_system     = is_transfer-header-source_system
      company_code      = is_transfer-header-company_code
      target_system     = COND #( WHEN is_transfer-header-target_system IS NOT INITIAL THEN is_transfer-header-target_system ELSE is_effective_context-target_profile-target_type )
      target_adapter    = is_effective_context-target_profile-adapter_type
      priority          = is_effective_context-target_profile-priority
      active            = abap_true
      confirmation_mode = is_effective_context-target_profile-confirmation_mode
      retry_profile     = COND #( WHEN is_policy_context-retry_policy_id IS NOT INITIAL THEN is_policy_context-retry_policy_id ELSE is_effective_context-target_profile-retry_policy_id ) ).
  ENDMETHOD.

  METHOD sync_transfer_target.
    DATA(ls_header) = cs_transfer-header.
    DATA(lv_changed) = abap_false.

    IF is_effective_context-target_profile-target_id IS NOT INITIAL
       AND ls_header-target_id <> is_effective_context-target_profile-target_id.
      ls_header-target_id = is_effective_context-target_profile-target_id.
      lv_changed = abap_true.
    ENDIF.
    IF is_route-target_system IS NOT INITIAL AND ls_header-target_system <> is_route-target_system.
      ls_header-target_system = is_route-target_system.
      lv_changed = abap_true.
    ENDIF.
    IF is_route-target_adapter IS NOT INITIAL AND ls_header-target_adapter <> is_route-target_adapter.
      ls_header-target_adapter = is_route-target_adapter.
      lv_changed = abap_true.
    ENDIF.

    IF lv_changed = abap_true.
      ls_header-changed_by = sy-uname.
      ls_header-changed_at = now( ).
      ls_header-version_no = ls_header-version_no + 1.
      mo_repository->update_header( ls_header ).
      cs_transfer-header = ls_header.
    ENDIF.
  ENDMETHOD.

  METHOD move_retry_to_processing.
    DATA(ls_transfer) = mo_repository->read_transfer( iv_transfer_id ).

    CASE ls_transfer-header-status_code.
      WHEN /fcbp/if_glt_types=>c_status-processing.
        RETURN.
      WHEN /fcbp/if_glt_types=>c_status-failed_retryable.
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-reprocess_requested
          iv_reason      = 'RETRY_SELECTED'
          iv_attempt_no  = ls_transfer-header-retry_count + 1
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-processing
          iv_reason      = 'RETRY_SUBMIT'
          iv_attempt_no  = ls_transfer-header-retry_count + 1
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
      WHEN /fcbp/if_glt_types=>c_status-reprocess_requested.
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-processing
          iv_reason      = 'RETRY_SUBMIT'
          iv_attempt_no  = ls_transfer-header-retry_count + 1
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_error
          EXPORTING
            transfer_id    = iv_transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-conflict
            operator_text  = |Retry requires FAILED_RETRYABLE or REPROCESS_REQUESTED state; current status is { ls_transfer-header-status_code }.|.
    ENDCASE.
  ENDMETHOD.

  METHOD mark_failure_status.
    DATA(ls_transfer) = mo_repository->read_transfer( iv_transfer_id ).
    CASE ls_transfer-header-status_code.
      WHEN /fcbp/if_glt_types=>c_status-failed_retryable.
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-reprocess_requested
          iv_reason      = iv_reason
          iv_error_id    = iv_error_id
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-processing
          iv_reason      = iv_reason
          iv_error_id    = iv_error_id
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-failed_final
          iv_reason      = iv_reason
          iv_error_id    = iv_error_id
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
      WHEN /fcbp/if_glt_types=>c_status-reprocess_requested.
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-processing
          iv_reason      = iv_reason
          iv_error_id    = iv_error_id
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-failed_final
          iv_reason      = iv_reason
          iv_error_id    = iv_error_id
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
      WHEN /fcbp/if_glt_types=>c_status-processing
        OR /fcbp/if_glt_types=>c_status-unknown_confirmation
        OR /fcbp/if_glt_types=>c_status-dispatched.
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-failed_final
          iv_reason      = iv_reason
          iv_error_id    = iv_error_id
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
      WHEN OTHERS.
        " Keep terminal or unrelated states unchanged.
    ENDCASE.
  ENDMETHOD.

  METHOD build_validation_context.
    rs_context = VALUE #(
      transfer_id       = is_work-transfer_id
      package_id        = iv_package_id
      policy_context_id = is_effective_context-policy_context_id
      outbox_id         = is_work-outbox_id
      jobrun_id         = is_context-jobrun_id
      target_id         = is_effective_context-target_profile-target_id
      actor_type        = /fcbp/if_glt_types=>c_actor_type-job
      actor_id          = actor_id( is_context )
      run_mode          = /fcbp/if_glt_val_types=>c_run_mode-revalidate ).
  ENDMETHOD.

  METHOD build_mapping_context.
    rs_context = VALUE #(
      transfer_id        = is_work-transfer_id
      package_id         = iv_package_id
      policy_context_id  = is_effective_context-policy_context_id
      validation_run_id  = is_validation_result-validation_run_id
      target_id          = is_effective_context-target_profile-target_id
      mapping_policy_id  = COND #( WHEN is_policy_context-mapping_policy_id IS NOT INITIAL THEN is_policy_context-mapping_policy_id ELSE is_effective_context-target_profile-mapping_policy_id )
      mapping_version    = is_policy_context-mapping_version
      mapping_hash       = is_policy_context-mapping_hash
      outbox_id          = is_work-outbox_id
      jobrun_id          = is_context-jobrun_id
      actor_type         = /fcbp/if_glt_types=>c_actor_type-job
      actor_id           = actor_id( is_context )
      run_mode           = /fcbp/if_glt_map_types=>c_run_mode-retry
      mapping_rules      = is_effective_context-mapping_rules ).
  ENDMETHOD.

  METHOD submit_mapped_journal.
    DATA(lo_adapter) = mo_adapter_factory->get_adapter_for_profile( is_effective_context-target_profile ).
    DATA(lt_outdoc) = is_mapping_result-mapped_journal-outdocs.
    IF lt_outdoc IS INITIAL.
      lt_outdoc = is_package_graph-outdocs.
    ENDIF.
    IF lt_outdoc IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_work-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-validation
          operator_text  = 'Retry package contains no outbound documents.'.
    ENDIF.

    DATA(lv_any_dispatched) = abap_false.
    DATA(lv_attempt_no) = 0.
    rs_summary-status_code = /fcbp/if_glt_types=>c_status-posted.
    rs_summary-message_text = 'Retry completed.'.

    LOOP AT lt_outdoc INTO DATA(ls_outdoc).
      lv_attempt_no = lv_attempt_no + 1.
      DATA(ls_request) = build_submit_request(
        is_transfer          = is_transfer
        is_effective_context = is_effective_context
        is_route             = is_route
        is_mapping_result    = is_mapping_result
        is_outdoc            = ls_outdoc
        io_adapter           = lo_adapter ).
      DATA(ls_attempt) = mo_evidence->start_attempt(
        is_request      = ls_request
        iv_attempt_type = /fcbp/if_glt_types=>c_attempt_type-retry
        iv_outbox_id    = is_work-outbox_id
        iv_jobrun_id    = is_context-jobrun_id ).
      ls_attempt-attempt_no = is_work-attempt_no + lv_attempt_no.

      DATA(ls_adapter_result) = VALUE /fcbp/if_glt_types=>ty_adapter_result( ).
      TRY.
          ls_adapter_result = lo_adapter->dispatch(
            is_transfer = is_transfer
            is_route    = is_route
            is_request  = ls_request ).
        CATCH /fcbp/cx_glt_adapter INTO DATA(lx_adapter).
          ls_adapter_result = adapter_result_from_exception(
            ix_error   = lx_adapter
            is_request = ls_request ).
      ENDTRY.

      IF ls_adapter_result-error-category IS NOT INITIAL
         OR ls_adapter_result-error-operator_text IS NOT INITIAL.
        DATA(lv_adapter_error) = log_adapter_error(
          is_result      = ls_adapter_result
          iv_transfer_id = is_work-transfer_id ).
        ls_adapter_result-error-error_id = lv_adapter_error.
        rs_summary-error_id = lv_adapter_error.
      ENDIF.

      DATA(ls_finished_attempt) = mo_evidence->finish_attempt(
        is_attempt = ls_attempt
        is_result  = ls_adapter_result ).
      mo_evidence->persist_attempt( ls_finished_attempt ).
      rs_summary-attempt_id = ls_finished_attempt-attempt_id.

      IF ls_adapter_result-target_ref-target_doc_no IS NOT INITIAL
         OR ls_adapter_result-target_ref-target_corr_id IS NOT INITIAL
         OR ls_adapter_result-target_ref-raw_ref_hash IS NOT INITIAL.
        DATA(ls_ref) = ls_adapter_result-target_ref.
        IF ls_ref-transfer_id IS INITIAL.
          ls_ref-transfer_id = is_work-transfer_id.
        ENDIF.
        IF ls_ref-target_system IS INITIAL.
          ls_ref-target_system = is_route-target_system.
        ENDIF.
        IF ls_ref-target_adapter IS INITIAL.
          ls_ref-target_adapter = is_route-target_adapter.
        ENDIF.
        IF ls_ref-confirmation_mode IS INITIAL.
          ls_ref-confirmation_mode = is_route-confirmation_mode.
        ENDIF.
        rs_summary-ref_id = mo_repository->insert_target_ref( ls_ref ).
      ENDIF.

      DATA(lv_status) = mo_retry_service->classify_adapter_result(
        is_result   = ls_adapter_result
        is_transfer = is_transfer ).
      rs_summary-message_text = COND #(
        WHEN ls_adapter_result-target_message_text_safe IS NOT INITIAL THEN ls_adapter_result-target_message_text_safe
        WHEN ls_adapter_result-error-operator_text IS NOT INITIAL THEN ls_adapter_result-error-operator_text
        ELSE rs_summary-message_text ).

      CASE lv_status.
        WHEN /fcbp/if_glt_types=>c_status-posted.
          CONTINUE.
        WHEN /fcbp/if_glt_types=>c_status-dispatched.
          lv_any_dispatched = abap_true.
          IF is_effective_context-confirmation_policy-status_query_required = abap_true.
            rs_summary-followup_work = build_followup_work(
              is_work      = is_work
              iv_work_type = /fcbp/if_glt_types=>c_outbox_work_type-poll ).
          ENDIF.
        WHEN /fcbp/if_glt_types=>c_status-unknown_confirmation.
          rs_summary-status_code = lv_status.
          rs_summary-unknown_confirmation = abap_true.
          DATA(lv_status_retry_id) = mo_retry_service->schedule_status_query(
            iv_transfer_id = is_work-transfer_id
            iv_error_id    = rs_summary-error_id ).
          rs_summary-followup_work = build_followup_work(
            is_work      = is_work
            iv_work_type = /fcbp/if_glt_types=>c_outbox_work_type-status_query ).
          RETURN.
        WHEN /fcbp/if_glt_types=>c_status-failed_retryable.
          rs_summary-status_code = lv_status.
          rs_summary-retryable = abap_true.
          DATA(lv_retry_id) = mo_retry_service->schedule_retry(
            iv_transfer_id = is_work-transfer_id
            iv_error_id    = rs_summary-error_id ).
          rs_summary-followup_work = build_followup_work(
            is_work      = is_work
            iv_work_type = /fcbp/if_glt_types=>c_outbox_work_type-retry ).
          RETURN.
        WHEN OTHERS.
          rs_summary-status_code = /fcbp/if_glt_types=>c_status-failed_final.
          RETURN.
      ENDCASE.
    ENDLOOP.

    IF lv_any_dispatched = abap_true.
      rs_summary-status_code = /fcbp/if_glt_types=>c_status-dispatched.
    ENDIF.
  ENDMETHOD.

  METHOD build_submit_request.
    rs_request = VALUE #(
      transfer_id       = is_transfer-header-transfer_id
      package_id        = is_mapping_result-package_id
      outdoc_id         = is_outdoc-outdoc_id
      policy_context_id = is_mapping_result-policy_context_id
      target_id         = is_effective_context-target_profile-target_id
      target_type       = is_effective_context-target_profile-target_type
      target_system     = is_route-target_system
      target_adapter    = is_route-target_adapter
      destination_alias = is_effective_context-target_profile-destination_alias
      confirmation_mode = COND #( WHEN is_route-confirmation_mode IS NOT INITIAL THEN is_route-confirmation_mode ELSE is_effective_context-target_profile-confirmation_mode )
      correlation_id    = is_transfer-header-correlation_id
      idempotency_key   = is_transfer-header-idempotency_key
      request_hash      = is_transfer-header-request_hash
      journal_hash      = is_mapping_result-mapping_hash
      raw_request_ref   = |PKG:{ is_mapping_result-package_id }:DOC:{ is_outdoc-outdoc_id }:RETRY:{ is_transfer-header-retry_count + 1 }|
      timeout_policy    = VALUE #(
        poll_interval_sec = is_effective_context-confirmation_policy-poll_interval_sec
        max_poll_sec      = is_effective_context-confirmation_policy-max_poll_duration_sec )
      capability        = io_adapter->get_capability_matrix( is_effective_context-target_profile ) ).
  ENDMETHOD.

  METHOD adapter_result_from_exception.
    rs_result = VALUE #(
      outcome = COND #(
        WHEN ix_error->unknown_confirmation = abap_true THEN /fcbp/if_glt_types=>c_adapter_outcome-unknown_confirmation
        WHEN ix_error->retryable = abap_true THEN /fcbp/if_glt_types=>c_adapter_outcome-retryable_failure
        ELSE /fcbp/if_glt_types=>c_adapter_outcome-final_failure )
      retryable = ix_error->retryable
      unknown_confirmation = ix_error->unknown_confirmation
      protocol_category = ix_error->protocol_category
      http_status = ix_error->http_status
      middleware_message_id = ix_error->middleware_message_id
      target_message_code = ix_error->target_message_code
      target_message_text_safe = ix_error->operator_text
      target_ref = VALUE #(
        transfer_id = is_request-transfer_id
        target_system = is_request-target_system
        target_adapter = is_request-target_adapter
        confirmation_mode = is_request-confirmation_mode )
      error = VALUE #(
        transfer_id = is_request-transfer_id
        severity = /fcbp/if_glt_types=>c_severity-error
        category = COND #( WHEN ix_error->error_category IS INITIAL THEN /fcbp/if_glt_types=>c_error_category-adapter_technical ELSE ix_error->error_category )
        retryable = ix_error->retryable
        unknown_confirmation = ix_error->unknown_confirmation
        operator_text = ix_error->operator_text
        technical_ref = ix_error->technical_reference ) ).
  ENDMETHOD.

  METHOD build_followup_work.
    rs_work = VALUE #(
      transfer_id       = is_work-transfer_id
      work_type         = iv_work_type
      due_at            = now( )
      priority          = is_work-priority
      target_id         = is_work-target_id
      processing_mode   = is_work-processing_mode
      processing_status = /fcbp/if_glt_types=>c_outbox_status-open
      lock_status       = /fcbp/if_glt_types=>c_lock_status-free
      attempt_no        = is_work-attempt_no + 1
      created_by        = sy-uname ).
  ENDMETHOD.

  METHOD log_pipeline_error.
    DATA(lv_text) = iv_text.
    IF lv_text IS INITIAL AND ix_previous IS BOUND.
      lv_text = ix_previous->get_text( ).
    ENDIF.

    TRY.
        rv_error_id = mo_logger->log_error(
          iv_transfer_id = iv_transfer_id
          is_error       = VALUE #(
            transfer_id          = iv_transfer_id
            severity             = /fcbp/if_glt_types=>c_severity-error
            category             = iv_category
            retryable            = iv_retryable
            unknown_confirmation = iv_unknown
            operator_text        = lv_text
            technical_ref        = COND string( WHEN ix_previous IS BOUND THEN ix_previous->get_text( ) ELSE `` ) ) ).
      CATCH /fcbp/cx_glt_error.
        rv_error_id = ||.
    ENDTRY.
  ENDMETHOD.

  METHOD log_adapter_error.
    DATA(ls_error) = is_result-error.
    IF ls_error-transfer_id IS INITIAL.
      ls_error-transfer_id = iv_transfer_id.
    ENDIF.
    IF ls_error-severity IS INITIAL.
      ls_error-severity = /fcbp/if_glt_types=>c_severity-error.
    ENDIF.
    IF ls_error-category IS INITIAL.
      ls_error-category = COND #(
        WHEN is_result-unknown_confirmation = abap_true THEN /fcbp/if_glt_types=>c_error_category-unknown_confirmation
        WHEN is_result-retryable = abap_true THEN /fcbp/if_glt_types=>c_error_category-adapter_technical
        ELSE /fcbp/if_glt_types=>c_error_category-adapter_business ).
    ENDIF.
    ls_error-retryable = is_result-retryable.
    ls_error-unknown_confirmation = is_result-unknown_confirmation.
    IF ls_error-operator_text IS INITIAL.
      ls_error-operator_text = is_result-target_message_text_safe.
    ENDIF.

    TRY.
        rv_error_id = mo_logger->log_error(
          iv_transfer_id = iv_transfer_id
          is_error       = ls_error ).
      CATCH /fcbp/cx_glt_error.
        rv_error_id = ||.
    ENDTRY.
  ENDMETHOD.

  METHOD source_reference.
    rv_source_reference = is_transfer-header-source_ref_id.
    IF rv_source_reference IS INITIAL AND is_transfer-header-reconciliation_key IS NOT INITIAL.
      rv_source_reference = is_transfer-header-reconciliation_key.
    ENDIF.
    IF rv_source_reference IS INITIAL AND is_transfer-header-source_doc_no IS NOT INITIAL.
      rv_source_reference = is_transfer-header-source_doc_no.
    ENDIF.
  ENDMETHOD.

  METHOD actor_id.
    rv_actor = is_context-actor_id.
    IF rv_actor IS INITIAL.
      rv_actor = is_context-claim_owner.
    ENDIF.
    IF rv_actor IS INITIAL.
      rv_actor = sy-uname.
    ENDIF.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

ENDCLASS.
