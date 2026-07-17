"! Test DISPATCH handler that runs package, validation, mapping, and mock target posting.
CLASS /fcbp/cl_glt_tst_wh_dispatch DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_work_handler.

    METHODS constructor
      IMPORTING
        io_repo            TYPE REF TO /fcbp/cl_glt_tst_repo
        io_config_provider TYPE REF TO /fcbp/if_glt_config_provider OPTIONAL
        io_preparer        TYPE REF TO /fcbp/if_glt_package_preparer OPTIONAL
        io_validator       TYPE REF TO /fcbp/if_glt_pkg_validator OPTIONAL
        io_mapper          TYPE REF TO /fcbp/if_glt_mapper OPTIONAL
        io_adapter         TYPE REF TO /fcbp/if_glt_transfer_adapter OPTIONAL
        io_status_manager  TYPE REF TO /fcbp/if_glt_status_manager OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repo TYPE REF TO /fcbp/cl_glt_tst_repo.
    DATA mo_config_provider TYPE REF TO /fcbp/if_glt_config_provider.
    DATA mo_preparer TYPE REF TO /fcbp/if_glt_package_preparer.
    DATA mo_validator TYPE REF TO /fcbp/if_glt_pkg_validator.
    DATA mo_mapper TYPE REF TO /fcbp/if_glt_mapper.
    DATA mo_adapter TYPE REF TO /fcbp/if_glt_transfer_adapter.
    DATA mo_status_manager TYPE REF TO /fcbp/if_glt_status_manager.

    METHODS build_scope
      IMPORTING
        is_transfer      TYPE /fcbp/if_glt_types=>ty_transfer
      RETURNING
        VALUE(rs_scope)  TYPE /fcbp/if_glt_config_types=>ty_routing_scope.

    METHODS build_route
      IMPORTING
        is_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
      RETURNING
        VALUE(rs_route)      TYPE /fcbp/if_glt_types=>ty_route.

ENDCLASS.

CLASS /fcbp/cl_glt_tst_wh_dispatch IMPLEMENTATION.

  METHOD constructor.
    mo_repo = io_repo.

    IF io_config_provider IS BOUND.
      mo_config_provider = io_config_provider.
    ELSE.
      mo_config_provider = NEW /fcbp/cl_glt_config_provider(
        io_config_repo    = io_repo
        io_policy_context = NEW /fcbp/cl_glt_policy_context( io_repository = io_repo ) ).
    ENDIF.

    DATA(lo_auth) = NEW /fcbp/cl_glt_tst_auth_allow( ).
    DATA(lo_source_reader) = NEW /fcbp/cl_glt_source_reader(
      io_recon_reader = NEW /fcbp/cl_glt_src_read_recon( io_repo = io_repo )
      io_doc_reader   = NEW /fcbp/cl_glt_src_read_doc( io_repo = io_repo )
      io_auth_check   = lo_auth ).

    mo_preparer = COND #( WHEN io_preparer IS BOUND THEN io_preparer ELSE NEW /fcbp/cl_glt_package_preparer(
      io_transfer_repo = io_repo
      io_source_reader = lo_source_reader
      io_package_repo  = io_repo
      io_status        = NEW /fcbp/cl_glt_package_status( ) ) ).

    mo_validator = COND #( WHEN io_validator IS BOUND THEN io_validator ELSE NEW /fcbp/cl_glt_pkg_validator(
      io_repo     = io_repo
      io_evidence = NEW /fcbp/cl_glt_pkg_evidence(
        io_transfer_repo = io_repo
        io_package_repo  = io_repo
        io_config_repo   = io_repo ) ) ).

    mo_mapper = COND #( WHEN io_mapper IS BOUND THEN io_mapper ELSE NEW /fcbp/cl_glt_mapper(
      io_map_repo     = io_repo
      io_package_repo = io_repo
      io_config_repo  = io_repo
      io_val_repo     = io_repo ) ).

    mo_adapter = COND #( WHEN io_adapter IS BOUND THEN io_adapter ELSE NEW /fcbp/cl_glt_tst_target_adptr( io_store = io_repo->get_store( ) ) ).
    mo_status_manager = COND #( WHEN io_status_manager IS BOUND THEN io_status_manager ELSE NEW /fcbp/cl_glt_status_mgr( io_repository = io_repo ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_work_handler~handle.
    IF is_work-work_type <> /fcbp/if_glt_types=>c_outbox_work_type-dispatch.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_work-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = |Test dispatch handler received work type { is_work-work_type }.|.
    ENDIF.

    DATA(ls_transfer) = mo_repo->/fcbp/if_glt_repository~read_transfer( is_work-transfer_id ).
    DATA(ls_effective_context) = mo_config_provider->resolve_effective_context( build_scope( ls_transfer ) ).

    mo_status_manager->set_status(
      iv_transfer_id = is_work-transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-validating
      iv_reason      = 'TST_PREPARE'
      iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
      iv_actor_id    = is_context-actor_id ).

    DATA(ls_package_result) = mo_preparer->prepare_for_dispatch(
      iv_transfer_id       = is_work-transfer_id
      is_effective_context = ls_effective_context
      iv_outbox_id         = is_work-outbox_id ).

    IF ls_package_result-accepted <> abap_true.
      rs_result = VALUE #(
        outbox_id = is_work-outbox_id
        transfer_id = is_work-transfer_id
        next_action = /fcbp/if_glt_outbox_types=>c_next_action-fail_terminal
        completion_status = /fcbp/if_glt_types=>c_outbox_status-failed
        status_code = /fcbp/if_glt_types=>c_status-validation_failed
        message_text = 'Package preparation did not accept the fixture graph.' ).
      RETURN.
    ENDIF.

    DATA(lv_package_id) = ls_package_result-graph-package_header-package_id.
    mo_status_manager->set_status(
      iv_transfer_id = is_work-transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-ready
      iv_reason      = 'TST_PACKAGE_READY'
      iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
      iv_actor_id    = is_context-actor_id ).

    DATA(ls_validation) = mo_validator->validate_package( VALUE #(
      transfer_id = is_work-transfer_id
      package_id = lv_package_id
      policy_context_id = ls_effective_context-policy_context_id
      outbox_id = is_work-outbox_id
      jobrun_id = is_context-jobrun_id
      target_id = ls_effective_context-target_profile-target_id
      actor_type = /fcbp/if_glt_types=>c_actor_type-job
      actor_id = is_context-actor_id
      run_mode = /fcbp/if_glt_val_types=>c_run_mode-dispatch ) ).

    IF ls_validation-passed <> abap_true.
      mo_status_manager->set_status(
        iv_transfer_id = is_work-transfer_id
        iv_status      = /fcbp/if_glt_types=>c_status-validation_failed
        iv_reason      = 'TST_VALIDATION_FAILED'
        iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
        iv_actor_id    = is_context-actor_id ).
      rs_result = VALUE #(
        outbox_id = is_work-outbox_id
        transfer_id = is_work-transfer_id
        next_action = /fcbp/if_glt_outbox_types=>c_next_action-fail_terminal
        completion_status = /fcbp/if_glt_types=>c_outbox_status-failed
        status_code = /fcbp/if_glt_types=>c_status-validation_failed
        message_text = 'Package validation failed in the happy-path fixture.' ).
      RETURN.
    ENDIF.

    DATA(ls_mapping) = mo_mapper->map_package( VALUE #(
      transfer_id = is_work-transfer_id
      package_id = lv_package_id
      policy_context_id = ls_effective_context-policy_context_id
      validation_run_id = ls_validation-validation_run_id
      target_id = ls_effective_context-target_profile-target_id
      outbox_id = is_work-outbox_id
      jobrun_id = is_context-jobrun_id
      actor_type = /fcbp/if_glt_types=>c_actor_type-job
      actor_id = is_context-actor_id
      run_mode = /fcbp/if_glt_map_types=>c_run_mode-dispatch ) ).

    IF ls_mapping-result_status <> /fcbp/if_glt_map_types=>c_result_status-mapped.
      rs_result = VALUE #(
        outbox_id = is_work-outbox_id
        transfer_id = is_work-transfer_id
        next_action = /fcbp/if_glt_outbox_types=>c_next_action-fail_terminal
        completion_status = /fcbp/if_glt_types=>c_outbox_status-failed
        status_code = /fcbp/if_glt_types=>c_status-validation_failed
        message_text = 'Package mapping failed in the happy-path fixture.' ).
      RETURN.
    ENDIF.

    mo_status_manager->set_status(
      iv_transfer_id = is_work-transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-processing
      iv_reason      = 'TST_ADAPTER'
      iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
      iv_actor_id    = is_context-actor_id ).

    DATA(ls_adapter_result) = mo_adapter->dispatch(
      is_transfer = mo_repo->/fcbp/if_glt_repository~read_transfer( is_work-transfer_id )
      is_route    = build_route( is_transfer = ls_transfer is_effective_context = ls_effective_context )
      is_request  = VALUE #(
        transfer_id = is_work-transfer_id
        package_id = lv_package_id
        policy_context_id = ls_effective_context-policy_context_id
        target_id = ls_effective_context-target_profile-target_id
        target_type = ls_effective_context-target_profile-target_type
        target_system = ls_effective_context-target_profile-target_id
        target_adapter = ls_effective_context-target_profile-adapter_type
        confirmation_mode = ls_effective_context-target_profile-confirmation_mode
        correlation_id = ls_transfer-header-correlation_id
        idempotency_key = ls_transfer-header-idempotency_key
        mock_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-posted ) ).

    DATA(lv_ref_id) = mo_repo->/fcbp/if_glt_repository~insert_target_ref( ls_adapter_result-target_ref ).

    mo_status_manager->set_status(
      iv_transfer_id = is_work-transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-posted
      iv_reason      = 'TST_POSTED'
      iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-adapter
      iv_actor_id    = 'TST_TARGET' ).

    rs_result = VALUE #(
      outbox_id = is_work-outbox_id
      transfer_id = is_work-transfer_id
      next_action = /fcbp/if_glt_outbox_types=>c_next_action-complete
      completion_status = /fcbp/if_glt_types=>c_outbox_status-done
      status_code = /fcbp/if_glt_types=>c_status-posted
      target_ref_id = lv_ref_id
      message_text = 'Happy-path dispatch posted to the test target.' ).
  ENDMETHOD.

  METHOD build_scope.
    rs_scope = VALUE #(
      transfer_id = is_transfer-header-transfer_id
      transfer_type = is_transfer-header-transfer_type
      source_system = is_transfer-header-source_system
      source_type = is_transfer-header-source_type
      source_reference = is_transfer-header-source_ref_id
      company_code = is_transfer-header-company_code
      processing_mode = is_transfer-header-processing_mode
      requested_by = sy-uname
      correlation_id = is_transfer-header-correlation_id ).
    rs_scope-resolution_date = sy-datum.
    rs_scope-resolution_time = sy-uzeit.
  ENDMETHOD.

  METHOD build_route.
    rs_route = VALUE #(
      route_id = 'TST_ROUTE'
      transfer_type = is_transfer-header-transfer_type
      source_system = is_transfer-header-source_system
      company_code = is_transfer-header-company_code
      target_system = is_effective_context-target_profile-target_id
      target_adapter = is_effective_context-target_profile-adapter_type
      priority = is_effective_context-target_profile-priority
      active = abap_true
      confirmation_mode = is_effective_context-target_profile-confirmation_mode
      retry_profile = is_effective_context-target_profile-retry_policy_id
      feature_switch_set = 'MOCK_POSTED'
      valid_from = '20260101'
      valid_to = '99991231'
      changed_by = sy-uname
      changed_at = mo_repo->get_store( )->now( ) ).
  ENDMETHOD.

ENDCLASS.
