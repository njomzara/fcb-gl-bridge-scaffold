"! REBUILD work handler: create successor package evidence and validate it after correction.
CLASS /fcbp/cl_glt_wh_rebuild DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_work_handler.

    METHODS constructor
      IMPORTING
        io_repository       TYPE REF TO /fcbp/if_glt_repository OPTIONAL
        io_package_repo     TYPE REF TO /fcbp/if_glt_package_repo OPTIONAL
        io_config_provider  TYPE REF TO /fcbp/if_glt_config_provider OPTIONAL
        io_config_repo      TYPE REF TO /fcbp/if_glt_config_repo OPTIONAL
        io_package_preparer TYPE REF TO /fcbp/if_glt_package_preparer OPTIONAL
        io_validator        TYPE REF TO /fcbp/if_glt_pkg_validator OPTIONAL
        io_status_manager   TYPE REF TO /fcbp/if_glt_status_manager OPTIONAL
        io_logger           TYPE REF TO /fcbp/if_glt_logger OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_repository.
    DATA mo_package_repo TYPE REF TO /fcbp/if_glt_package_repo.
    DATA mo_config_provider TYPE REF TO /fcbp/if_glt_config_provider.
    DATA mo_config_repo TYPE REF TO /fcbp/if_glt_config_repo.
    DATA mo_package_preparer TYPE REF TO /fcbp/if_glt_package_preparer.
    DATA mo_validator TYPE REF TO /fcbp/if_glt_pkg_validator.
    DATA mo_status_manager TYPE REF TO /fcbp/if_glt_status_manager.
    DATA mo_logger TYPE REF TO /fcbp/if_glt_logger.

    METHODS assert_work_type
      IMPORTING
        is_work TYPE /fcbp/if_glt_types=>ty_outbox_work
      RAISING
        /fcbp/cx_glt_error.

    METHODS determine_predecessor_package_id
      IMPORTING
        is_transfer           TYPE /fcbp/if_glt_types=>ty_transfer
      RETURNING
        VALUE(rv_package_id)  TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      RAISING
        /fcbp/cx_glt_error.

    METHODS assert_rebuild_allowed
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

    METHODS build_route
      IMPORTING
        is_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
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

    METHODS move_rebuild_to_validating
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
        is_context     TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
      RAISING
        /fcbp/cx_glt_error.

    METHODS mark_ready_if_needed
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
        is_context     TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
      RAISING
        /fcbp/cx_glt_error.

    METHODS rebuild_dispatch_approved
      IMPORTING
        is_work              TYPE /fcbp/if_glt_types=>ty_outbox_work
        is_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
        is_context           TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
      RETURNING
        VALUE(rv_approved)   TYPE abap_bool.

    METHODS build_successor_dispatch_work
      IMPORTING
        is_work              TYPE /fcbp/if_glt_types=>ty_outbox_work
        is_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
        is_context           TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
      RETURNING
        VALUE(rs_work)       TYPE /fcbp/if_glt_types=>ty_outbox_work.

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

    METHODS first_blocking_prep_message
      IMPORTING
        it_message          TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message
      RETURNING
        VALUE(rv_text)      TYPE char220.

    METHODS first_blocking_val_message
      IMPORTING
        it_message          TYPE /fcbp/if_glt_types=>tt_message
      RETURNING
        VALUE(rv_text)      TYPE char220.

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

CLASS /fcbp/cl_glt_wh_rebuild IMPLEMENTATION.

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

    mo_package_preparer = COND #(
      WHEN io_package_preparer IS BOUND THEN io_package_preparer
      ELSE NEW /fcbp/cl_glt_package_preparer(
        io_transfer_repo = mo_repository
        io_package_repo  = mo_package_repo ) ).

    mo_validator = COND #(
      WHEN io_validator IS BOUND THEN io_validator
      ELSE NEW /fcbp/cl_glt_pkg_validator(
        io_evidence = NEW /fcbp/cl_glt_pkg_evidence(
          io_transfer_repo = mo_repository
          io_package_repo  = mo_package_repo
          io_config_repo   = mo_config_repo ) ) ).

    mo_status_manager = COND #( WHEN io_status_manager IS BOUND THEN io_status_manager ELSE NEW /fcbp/cl_glt_status_mgr( io_repository = mo_repository ) ).
    mo_logger = COND #( WHEN io_logger IS BOUND THEN io_logger ELSE NEW /fcbp/cl_glt_app_logger( io_repository = mo_repository ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_work_handler~handle.
    assert_work_type( is_work ).

    TRY.
        DATA(ls_transfer) = mo_repository->read_transfer( is_work-transfer_id ).
        DATA(lv_predecessor_package_id) = determine_predecessor_package_id( ls_transfer ).

        DATA(ls_predecessor_graph) = mo_package_repo->read_package( lv_predecessor_package_id ).
        assert_rebuild_allowed(
          is_transfer = ls_transfer
          is_graph    = ls_predecessor_graph ).

        DATA(ls_scope) = build_scope(
          is_transfer = ls_transfer
          is_work     = is_work
          is_context  = is_context ).
        DATA(ls_effective_context) = mo_config_provider->resolve_effective_context( ls_scope ).
        DATA(ls_route) = build_route(
          is_transfer          = ls_transfer
          is_effective_context = ls_effective_context ).

        sync_transfer_target(
          EXPORTING
            is_effective_context = ls_effective_context
            is_route             = ls_route
          CHANGING
            cs_transfer          = ls_transfer ).

        move_rebuild_to_validating(
          iv_transfer_id = is_work-transfer_id
          is_context     = is_context ).

        DATA(ls_package_result) = mo_package_preparer->rebuild_package(
          iv_transfer_id            = is_work-transfer_id
          iv_predecessor_package_id = lv_predecessor_package_id
          iv_reason_code            = /fcbp/if_glt_types=>c_monitor_action-rebuild_after_correction
          is_effective_context      = ls_effective_context ).

        IF ls_package_result-accepted <> abap_true.
          DATA(lv_prep_text) = first_blocking_prep_message( ls_package_result-messages ).
          DATA(lv_prep_error) = log_pipeline_error(
            iv_transfer_id = is_work-transfer_id
            iv_category    = /fcbp/if_glt_types=>c_error_category-validation
            iv_text        = lv_prep_text ).
          mark_failure_status(
            iv_transfer_id = is_work-transfer_id
            iv_error_id    = lv_prep_error
            iv_reason      = 'REBUILD_PREP'
            is_context     = is_context ).
          rs_result = VALUE #(
            outbox_id         = is_work-outbox_id
            transfer_id       = is_work-transfer_id
            next_action       = /fcbp/if_glt_outbox_types=>c_next_action-operator_action
            completion_status = /fcbp/if_glt_types=>c_outbox_status-failed
            status_code       = /fcbp/if_glt_types=>c_status-validation_failed
            error_id          = lv_prep_error
            message_text      = lv_prep_text ).
          RETURN.
        ENDIF.

        DATA(lv_package_id) = ls_package_result-graph-package_header-package_id.
        DATA(ls_validation_result) = mo_validator->validate_package(
          build_validation_context(
            is_work              = is_work
            is_context           = is_context
            is_effective_context = ls_effective_context
            iv_package_id        = lv_package_id ) ).

        IF ls_validation_result-passed <> abap_true.
          DATA(lv_val_text) = first_blocking_val_message( ls_validation_result-messages ).
          DATA(lv_val_error) = log_pipeline_error(
            iv_transfer_id = is_work-transfer_id
            iv_category    = /fcbp/if_glt_types=>c_error_category-validation
            iv_text        = lv_val_text ).
          mark_failure_status(
            iv_transfer_id = is_work-transfer_id
            iv_error_id    = lv_val_error
            iv_reason      = 'REBUILD_VALIDATE'
            is_context     = is_context ).
          rs_result = VALUE #(
            outbox_id         = is_work-outbox_id
            transfer_id       = is_work-transfer_id
            next_action       = /fcbp/if_glt_outbox_types=>c_next_action-operator_action
            completion_status = /fcbp/if_glt_types=>c_outbox_status-failed
            status_code       = /fcbp/if_glt_types=>c_status-validation_failed
            error_id          = lv_val_error
            message_text      = lv_val_text ).
          RETURN.
        ENDIF.

        mark_ready_if_needed(
          iv_transfer_id = is_work-transfer_id
          is_context     = is_context ).

        DATA(ls_followup_work) = VALUE /fcbp/if_glt_types=>ty_outbox_work( ).
        DATA(lv_message_text) = CONV char220( |Package { lv_package_id } rebuilt and validated.| ).

        IF rebuild_dispatch_approved(
             is_work              = is_work
             is_transfer          = ls_transfer
             is_context           = is_context
             is_effective_context = ls_effective_context ) = abap_true.
          ls_followup_work = build_successor_dispatch_work(
            is_work              = is_work
            is_transfer          = ls_transfer
            is_context           = is_context
            is_effective_context = ls_effective_context ).
          lv_message_text = |Package { lv_package_id } rebuilt and validated; successor DISPATCH queued.|.
        ENDIF.

        rs_result = VALUE #(
          outbox_id         = is_work-outbox_id
          transfer_id       = is_work-transfer_id
          next_action       = /fcbp/if_glt_outbox_types=>c_next_action-complete
          completion_status = /fcbp/if_glt_types=>c_outbox_status-done
          status_code       = /fcbp/if_glt_types=>c_status-ready
          followup_work     = ls_followup_work
          message_text      = lv_message_text ).

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
              iv_reason      = 'REBUILD_ERR'
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
    IF is_work-work_type <> /fcbp/if_glt_types=>c_outbox_work_type-rebuild.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_work-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = |REBUILD handler received work type { is_work-work_type }.|.
    ENDIF.
  ENDMETHOD.

  METHOD determine_predecessor_package_id.
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
          operator_text  = 'Rebuild requires an existing current package as predecessor evidence.'.
    ENDIF.

    IF lines( lt_package_id ) > 1.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-conflict
          operator_text  = 'Rebuild found more than one current package for the transfer.'.
    ENDIF.

    READ TABLE lt_package_id INTO rv_package_id INDEX 1.
  ENDMETHOD.

  METHOD assert_rebuild_allowed.
    IF is_graph-package_header-package_id IS INITIAL
       OR is_graph-package_header-transfer_id <> is_transfer-header-transfer_id.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Rebuild predecessor package evidence does not belong to the transfer.'.
    ENDIF.

    IF is_graph-package_header-current_flag <> abap_true
       OR is_graph-package_header-superseded_by_package_id IS NOT INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-conflict
          operator_text  = 'Rebuild can only use the current, non-superseded package as predecessor.'.
    ENDIF.

    CASE is_transfer-header-status_code.
      WHEN /fcbp/if_glt_types=>c_status-reprocess_requested
        OR /fcbp/if_glt_types=>c_status-validation_failed
        OR /fcbp/if_glt_types=>c_status-failed_final.
        RETURN.
      WHEN /fcbp/if_glt_types=>c_status-unknown_confirmation.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_error
          EXPORTING
            transfer_id    = is_transfer-header-transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-conflict
            operator_text  = 'Unknown confirmation must be resolved before package rebuild.'.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_error
          EXPORTING
            transfer_id    = is_transfer-header-transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-conflict
            operator_text  = |Rebuild requires REPROCESS_REQUESTED, VALIDATION_FAILED, or FAILED_FINAL state; current status is { is_transfer-header-status_code }.|.
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
      processing_mode  = COND char10(
                           WHEN is_work-processing_mode IS NOT INITIAL
                           THEN is_work-processing_mode
                           WHEN is_transfer-header-processing_mode IS NOT INITIAL
                           THEN is_transfer-header-processing_mode
                           ELSE is_context-processing_mode )
      target_id        = COND char20(
                           WHEN is_work-target_id IS NOT INITIAL
                           THEN is_work-target_id
                           WHEN is_transfer-header-target_id IS NOT INITIAL
                           THEN is_transfer-header-target_id
                           ELSE is_context-target_id )
      requested_by     = actor_id( is_context )
      correlation_id   = is_context-correlation_id
      resolution_date  = sy-datum
      resolution_time  = sy-uzeit ).
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
      retry_profile     = is_effective_context-target_profile-retry_policy_id ).

    TRY.
        DATA(ls_route) = mo_config_provider->resolve_route( is_transfer-header ).
        IF ls_route-target_adapter IS NOT INITIAL.
          rs_route = ls_route.
        ENDIF.
      CATCH /fcbp/cx_glt_config.
    ENDTRY.

    IF rs_route-target_adapter IS INITIAL.
      rs_route-target_adapter = is_effective_context-target_profile-adapter_type.
    ENDIF.
    IF rs_route-confirmation_mode IS INITIAL.
      rs_route-confirmation_mode = is_effective_context-target_profile-confirmation_mode.
    ENDIF.
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

  METHOD move_rebuild_to_validating.
    DATA(ls_transfer) = mo_repository->read_transfer( iv_transfer_id ).

    CASE ls_transfer-header-status_code.
      WHEN /fcbp/if_glt_types=>c_status-validating.
        RETURN.
      WHEN /fcbp/if_glt_types=>c_status-reprocess_requested.
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-validating
          iv_reason      = 'REBUILD_START'
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
      WHEN /fcbp/if_glt_types=>c_status-validation_failed
        OR /fcbp/if_glt_types=>c_status-failed_final.
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-reprocess_requested
          iv_reason      = 'REBUILD_SELECTED'
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-validating
          iv_reason      = 'REBUILD_START'
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_error
          EXPORTING
            transfer_id    = iv_transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-conflict
            operator_text  = |Rebuild cannot start from status { ls_transfer-header-status_code }.|.
    ENDCASE.
  ENDMETHOD.

  METHOD mark_ready_if_needed.
    DATA(ls_transfer) = mo_repository->read_transfer( iv_transfer_id ).
    IF ls_transfer-header-status_code = /fcbp/if_glt_types=>c_status-validating.
      mo_status_manager->set_status(
        iv_transfer_id = iv_transfer_id
        iv_status      = /fcbp/if_glt_types=>c_status-ready
        iv_reason      = 'REBUILD_VALIDATED'
        iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
        iv_actor_id    = actor_id( is_context ) ).
    ENDIF.
  ENDMETHOD.

  METHOD rebuild_dispatch_approved.
    DATA(lv_processing_mode) = is_work-processing_mode.
    IF lv_processing_mode IS INITIAL.
      lv_processing_mode = is_transfer-header-processing_mode.
    ENDIF.
    IF lv_processing_mode IS INITIAL.
      lv_processing_mode = is_context-processing_mode.
    ENDIF.
    IF lv_processing_mode IS INITIAL.
      lv_processing_mode = is_effective_context-routing_scope-processing_mode.
    ENDIF.

    rv_approved = xsdbool(
      is_context-immediate_dispatch = abap_true AND
      lv_processing_mode = /fcbp/if_glt_types=>c_processing_mode-realtime ).
  ENDMETHOD.

  METHOD build_successor_dispatch_work.
    DATA(lv_now) = now( ).
    DATA(lv_processing_mode) = is_work-processing_mode.
    IF lv_processing_mode IS INITIAL.
      lv_processing_mode = is_transfer-header-processing_mode.
    ENDIF.
    IF lv_processing_mode IS INITIAL.
      lv_processing_mode = is_context-processing_mode.
    ENDIF.
    IF lv_processing_mode IS INITIAL.
      lv_processing_mode = is_effective_context-routing_scope-processing_mode.
    ENDIF.

    rs_work = VALUE #(
      transfer_id       = is_work-transfer_id
      work_type         = /fcbp/if_glt_types=>c_outbox_work_type-dispatch
      due_at            = lv_now
      priority          = COND i( WHEN is_work-priority > 0 THEN is_work-priority ELSE 5 )
      target_id         = COND char20(
                            WHEN is_effective_context-target_profile-target_id IS NOT INITIAL
                            THEN is_effective_context-target_profile-target_id
                            WHEN is_work-target_id IS NOT INITIAL
                            THEN is_work-target_id
                            WHEN is_context-target_id IS NOT INITIAL
                            THEN is_context-target_id
                            ELSE is_transfer-header-target_id )
      processing_mode   = lv_processing_mode
      processing_status = /fcbp/if_glt_types=>c_outbox_status-open
      lock_status       = /fcbp/if_glt_types=>c_lock_status-free
      attempt_no        = 0
      created_at        = lv_now
      created_by        = sy-uname ).
  ENDMETHOD.

  METHOD mark_failure_status.
    DATA(ls_transfer) = mo_repository->read_transfer( iv_transfer_id ).
    CASE ls_transfer-header-status_code.
      WHEN /fcbp/if_glt_types=>c_status-validating.
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-validation_failed
          iv_reason      = iv_reason
          iv_error_id    = iv_error_id
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
      WHEN /fcbp/if_glt_types=>c_status-reprocess_requested.
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-validating
          iv_reason      = iv_reason
          iv_error_id    = iv_error_id
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
        mo_status_manager->set_status(
          iv_transfer_id = iv_transfer_id
          iv_status      = /fcbp/if_glt_types=>c_status-validation_failed
          iv_reason      = iv_reason
          iv_error_id    = iv_error_id
          iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-job
          iv_actor_id    = actor_id( is_context ) ).
      WHEN /fcbp/if_glt_types=>c_status-validation_failed
        OR /fcbp/if_glt_types=>c_status-failed_final.
        " Keep the existing operator-action state if rebuild failed before status advancement.
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
      run_mode          = /fcbp/if_glt_val_types=>c_run_mode-rebuild ).
  ENDMETHOD.

  METHOD first_blocking_prep_message.
    rv_text = 'Package rebuild was blocked.'.
    LOOP AT it_message INTO DATA(ls_message) WHERE blocking = abap_true.
      rv_text = ls_message-operator_text.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD first_blocking_val_message.
    rv_text = 'Rebuilt package validation failed.'.
    LOOP AT it_message INTO DATA(ls_message) WHERE blocking = abap_true.
      rv_text = ls_message-operator_text.
      RETURN.
    ENDLOOP.
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
