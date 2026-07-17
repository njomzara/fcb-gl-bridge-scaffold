"! Stateless runtime coordinator for intake, validation, status, dispatch, and reprocess.
CLASS /fcbp/cl_glt_orchestrator DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_transfer_api.

    METHODS constructor
      IMPORTING
        io_repository      TYPE REF TO /fcbp/if_glt_repository OPTIONAL
        io_status_manager  TYPE REF TO /fcbp/if_glt_status_manager OPTIONAL
        io_validator       TYPE REF TO /fcbp/if_glt_validator OPTIONAL
        io_idempotency     TYPE REF TO /fcbp/if_glt_idempotency OPTIONAL
        io_logger          TYPE REF TO /fcbp/if_glt_logger OPTIONAL
        io_config_provider TYPE REF TO /fcbp/if_glt_config_provider OPTIONAL
        io_retry_service   TYPE REF TO /fcbp/if_glt_retry_service OPTIONAL
        io_auth_check      TYPE REF TO /fcbp/if_glt_auth_check OPTIONAL.

    METHODS dispatch
      IMPORTING
        iv_transfer_id     TYPE /fcbp/if_glt_types=>ty_transfer_id
      RETURNING
        VALUE(rs_result)   TYPE /fcbp/if_glt_types=>ty_result
      RAISING
        /fcbp/cx_glt_error.

    METHODS request_reprocess
      IMPORTING
        is_request         TYPE /fcbp/if_glt_types=>ty_reprocess_request
      RETURNING
        VALUE(rv_retry_id) TYPE /fcbp/if_glt_types=>ty_retry_id
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_repository      TYPE REF TO /fcbp/if_glt_repository.
    DATA mo_status_manager  TYPE REF TO /fcbp/if_glt_status_manager.
    DATA mo_validator       TYPE REF TO /fcbp/if_glt_validator.
    DATA mo_idempotency     TYPE REF TO /fcbp/if_glt_idempotency.
    DATA mo_logger          TYPE REF TO /fcbp/if_glt_logger.
    DATA mo_config_provider TYPE REF TO /fcbp/if_glt_config_provider.
    DATA mo_retry_service   TYPE REF TO /fcbp/if_glt_retry_service.
    DATA mo_auth_check      TYPE REF TO /fcbp/if_glt_auth_check.
    DATA mo_request_factory TYPE REF TO /fcbp/cl_glt_request_factory.
    DATA mo_adapter_factory TYPE REF TO /fcbp/cl_glt_adapter_factory.

    METHODS ensure_dependencies
      RAISING /fcbp/cx_glt_error.

    METHODS has_blocking_messages
      IMPORTING
        it_message        TYPE /fcbp/if_glt_types=>tt_message
      RETURNING
        VALUE(rv_blocked) TYPE abap_bool.

    METHODS handle_adapter_result
      IMPORTING
        is_transfer       TYPE /fcbp/if_glt_types=>ty_transfer
        is_result         TYPE /fcbp/if_glt_types=>ty_adapter_result
      RETURNING
        VALUE(rs_result)  TYPE /fcbp/if_glt_types=>ty_result
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_orchestrator IMPLEMENTATION.

  METHOD constructor.
    DATA(lo_repository) = COND #(
      WHEN io_repository IS BOUND THEN io_repository
      ELSE NEW /fcbp/cl_glt_repository( ) ).
    DATA(lo_config_repo) = NEW /fcbp/cl_glt_config_repo( ).
    DATA(lo_config_provider) = NEW /fcbp/cl_glt_config_provider(
      io_repository     = lo_repository
      io_config_repo    = lo_config_repo
      io_health         = NEW /fcbp/cl_glt_config_health( io_repository = lo_config_repo )
      io_policy_context = NEW /fcbp/cl_glt_policy_context( io_repository = lo_config_repo ) ).

    mo_repository      = lo_repository.
    mo_status_manager  = COND #( WHEN io_status_manager  IS BOUND THEN io_status_manager  ELSE NEW /fcbp/cl_glt_status_mgr( io_repository = lo_repository ) ).
    mo_validator       = COND #( WHEN io_validator       IS BOUND THEN io_validator       ELSE NEW /fcbp/cl_glt_validator( ) ).
    mo_idempotency     = COND #( WHEN io_idempotency     IS BOUND THEN io_idempotency     ELSE NEW /fcbp/cl_glt_idempotency( io_repository = lo_repository ) ).
    mo_logger          = COND #( WHEN io_logger          IS BOUND THEN io_logger          ELSE NEW /fcbp/cl_glt_app_logger( io_repository = lo_repository ) ).
    mo_config_provider = COND #( WHEN io_config_provider IS BOUND THEN io_config_provider ELSE lo_config_provider ).
    mo_retry_service   = COND #( WHEN io_retry_service   IS BOUND THEN io_retry_service   ELSE NEW /fcbp/cl_glt_retry_service( io_repository = lo_repository ) ).
    mo_auth_check      = COND #( WHEN io_auth_check      IS BOUND THEN io_auth_check      ELSE NEW /fcbp/cl_glt_auth_check( ) ).
    mo_request_factory = NEW /fcbp/cl_glt_request_factory( ).
    mo_adapter_factory = NEW /fcbp/cl_glt_adapter_factory( ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_api~submit.
    ensure_dependencies( ).

    DATA(ls_transfer) = mo_request_factory->create_from_request( is_request ).
    DATA(ls_reservation) = VALUE /fcbp/if_glt_types=>ty_idemp_reservation(
      idempotency_key = ls_transfer-header-idempotency_key
      transfer_type   = ls_transfer-header-transfer_type
      source_system   = ls_transfer-header-source_system
      request_hash    = ls_transfer-header-request_hash
      transfer_id     = ls_transfer-header-transfer_id
      reserved_by     = sy-uname ).

    DATA(ls_decision) = mo_idempotency->reserve( ls_reservation ).
    IF ls_decision-duplicate = abap_true.
      rs_result-transfer_id     = ls_decision-transfer_id.
      rs_result-status_code     = ls_decision-status_code.
      rs_result-external_status = ls_decision-external_status.
      rs_result-duplicate       = abap_true.
      RETURN.
    ENDIF.

    DATA(lv_transfer_id) = mo_repository->create_transfer(
      is_header = ls_transfer-header
      it_item   = ls_transfer-items ).

    mo_status_manager->set_status(
      iv_transfer_id = lv_transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-validating
      iv_reason      = 'INTAKE' ).

    DATA(lt_message) = mo_validator->validate_request( ls_transfer ).
    IF has_blocking_messages( lt_message ) = abap_true.
      mo_status_manager->set_status(
        iv_transfer_id = lv_transfer_id
        iv_status      = /fcbp/if_glt_types=>c_status-validation_failed
        iv_reason      = 'VALIDATION' ).

      rs_result-transfer_id     = lv_transfer_id.
      rs_result-status_code     = /fcbp/if_glt_types=>c_status-validation_failed.
      rs_result-external_status = /fcbp/if_glt_types=>c_ext_status-failed.
      rs_result-messages        = lt_message.
      RETURN.
    ENDIF.

    DATA(ls_route) = mo_config_provider->resolve_route( ls_transfer-header ).
    ls_transfer-header-target_system  = ls_route-target_system.
    ls_transfer-header-target_adapter = ls_route-target_adapter.
    mo_repository->update_header( ls_transfer-header ).

    mo_status_manager->set_status(
      iv_transfer_id = lv_transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-ready
      iv_reason      = 'VALIDATED' ).

    rs_result-transfer_id     = lv_transfer_id.
    rs_result-status_code     = /fcbp/if_glt_types=>c_status-ready.
    rs_result-external_status = /fcbp/if_glt_types=>c_ext_status-received.
    rs_result-messages        = lt_message.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_api~get_status.
    ensure_dependencies( ).
    DATA(ls_transfer) = mo_repository->read_transfer( iv_transfer_id ).
    rs_status-transfer_id      = iv_transfer_id.
    rs_status-status_code      = ls_transfer-header-status_code.
    rs_status-external_status  = ls_transfer-header-external_status.
    rs_status-correlation_id   = ls_transfer-header-correlation_id.
    rs_status-idempotency_key  = ls_transfer-header-idempotency_key.
    rs_status-last_error_id    = ls_transfer-header-last_error_id.
    rs_status-target_refs      = ls_transfer-target_refs.
  ENDMETHOD.

  METHOD dispatch.
    ensure_dependencies( ).

    DATA(ls_transfer) = mo_repository->read_transfer( iv_transfer_id ).
    DATA(ls_route) = mo_config_provider->resolve_route( ls_transfer-header ).
    DATA(lo_adapter) = mo_adapter_factory->get_adapter( ls_route ).

    mo_status_manager->set_status(
      iv_transfer_id = iv_transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-processing
      iv_reason      = 'DISPATCH' ).

    DATA(ls_adapter_result) = lo_adapter->dispatch(
      is_transfer = ls_transfer
      is_route    = ls_route ).

    rs_result = handle_adapter_result(
      is_transfer = ls_transfer
      is_result   = ls_adapter_result ).
  ENDMETHOD.

  METHOD request_reprocess.
    ensure_dependencies( ).
    IF mo_auth_check IS BOUND.
      mo_auth_check->check_reprocess( is_request-transfer_id ).
    ENDIF.

    mo_status_manager->set_status(
      iv_transfer_id = is_request-transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-reprocess_requested
      iv_reason      = is_request-reason_code
      iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-user
      iv_actor_id    = sy-uname ).

    rv_retry_id = mo_retry_service->request_reprocess( is_request ).
  ENDMETHOD.

  METHOD handle_adapter_result.
    DATA(lv_next_status) = mo_retry_service->classify_adapter_result(
      is_result   = is_result
      is_transfer = is_transfer ).

    CASE lv_next_status.
      WHEN /fcbp/if_glt_types=>c_status-posted
        OR /fcbp/if_glt_types=>c_status-dispatched.
        IF is_result-target_ref-target_doc_no IS NOT INITIAL
           OR is_result-target_ref-target_corr_id IS NOT INITIAL.
          DATA(lv_ref_id) = mo_repository->insert_target_ref( is_result-target_ref ).
        ENDIF.
        mo_idempotency->confirm_completed(
          iv_idempotency_key = is_transfer-header-idempotency_key
          iv_transfer_id     = is_transfer-header-transfer_id ).

      WHEN /fcbp/if_glt_types=>c_status-unknown_confirmation.
        DATA(lv_unknown_error) = mo_logger->log_error(
          iv_transfer_id = is_transfer-header-transfer_id
          is_error       = is_result-error ).
        DATA(lv_status_query_id) = mo_retry_service->schedule_status_query(
          iv_transfer_id = is_transfer-header-transfer_id
          iv_error_id    = lv_unknown_error ).

      WHEN /fcbp/if_glt_types=>c_status-failed_retryable.
        DATA(lv_retry_error) = mo_logger->log_error(
          iv_transfer_id = is_transfer-header-transfer_id
          is_error       = is_result-error ).
        DATA(lv_retry_id) = mo_retry_service->schedule_retry(
          iv_transfer_id = is_transfer-header-transfer_id
          iv_error_id    = lv_retry_error ).

      WHEN /fcbp/if_glt_types=>c_status-failed_final.
        DATA(lv_final_error) = mo_logger->log_error(
          iv_transfer_id = is_transfer-header-transfer_id
          is_error       = is_result-error ).
    ENDCASE.

    mo_status_manager->set_status(
      iv_transfer_id = is_transfer-header-transfer_id
      iv_status      = lv_next_status
      iv_reason      = 'ADAPTER_RESULT' ).

    rs_result-transfer_id     = is_transfer-header-transfer_id.
    rs_result-status_code     = lv_next_status.
    rs_result-external_status = mo_status_manager->derive_external_status( lv_next_status ).
    rs_result-target_ref      = is_result-target_ref.
  ENDMETHOD.

  METHOD ensure_dependencies.
    IF mo_repository IS NOT BOUND
       OR mo_status_manager IS NOT BOUND
       OR mo_validator IS NOT BOUND
       OR mo_idempotency IS NOT BOUND
       OR mo_logger IS NOT BOUND
       OR mo_config_provider IS NOT BOUND
       OR mo_retry_service IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = 'Transfer Core orchestrator dependencies are not fully injected.'.
    ENDIF.
  ENDMETHOD.

  METHOD has_blocking_messages.
    LOOP AT it_message TRANSPORTING NO FIELDS WHERE blocking = abap_true.
      rv_blocked = abap_true.
      RETURN.
    ENDLOOP.
    rv_blocked = abap_false.
  ENDMETHOD.

ENDCLASS.
