"! Source Handoff receiver. Creates only local bridge registration evidence.
CLASS /fcbp/cl_glt_handoff_receiver DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_handoff_receiver.

    METHODS constructor
      IMPORTING
        io_validator        TYPE REF TO /fcbp/cl_glt_handoff_validator OPTIONAL
        io_profile_resolver TYPE REF TO /fcbp/if_glt_profile_resolver OPTIONAL
        io_key_builder      TYPE REF TO /fcbp/cl_glt_reg_key_builder OPTIONAL
        io_registry         TYPE REF TO /fcbp/cl_glt_source_registry OPTIONAL
        io_factory          TYPE REF TO /fcbp/cl_glt_handoff_factory OPTIONAL
        io_repository       TYPE REF TO /fcbp/if_glt_handoff_repo OPTIONAL
        io_outbox           TYPE REF TO /fcbp/if_glt_outbox_enqueuer OPTIONAL
        io_audit            TYPE REF TO /fcbp/if_glt_audit_writer OPTIONAL
        io_logger           TYPE REF TO /fcbp/cl_glt_handoff_logger OPTIONAL.

  PRIVATE SECTION.
    DATA mo_validator        TYPE REF TO /fcbp/cl_glt_handoff_validator.
    DATA mo_profile_resolver TYPE REF TO /fcbp/if_glt_profile_resolver.
    DATA mo_key_builder      TYPE REF TO /fcbp/cl_glt_reg_key_builder.
    DATA mo_registry         TYPE REF TO /fcbp/cl_glt_source_registry.
    DATA mo_factory          TYPE REF TO /fcbp/cl_glt_handoff_factory.
    DATA mo_repository       TYPE REF TO /fcbp/if_glt_handoff_repo.
    DATA mo_outbox           TYPE REF TO /fcbp/if_glt_outbox_enqueuer.
    DATA mo_audit            TYPE REF TO /fcbp/if_glt_audit_writer.
    DATA mo_logger           TYPE REF TO /fcbp/cl_glt_handoff_logger.

    METHODS ensure_dependencies
      RAISING /fcbp/cx_glt_handoff.

    METHODS mark_registration_failed
      IMPORTING
        iv_registration_key TYPE /fcbp/if_glt_types=>ty_registration_key
        iv_reason           TYPE char40.

ENDCLASS.

CLASS /fcbp/cl_glt_handoff_receiver IMPLEMENTATION.

  METHOD constructor.
    DATA(lo_handoff_repo) = COND #(
      WHEN io_repository IS BOUND THEN io_repository
      ELSE NEW /fcbp/cl_glt_handoff_repo( ) ).
    DATA(lo_config_repo) = NEW /fcbp/cl_glt_config_repo( ).
    DATA(lo_config_provider) = NEW /fcbp/cl_glt_config_provider(
      io_config_repo    = lo_config_repo
      io_health         = NEW /fcbp/cl_glt_config_health( io_repository = lo_config_repo )
      io_policy_context = NEW /fcbp/cl_glt_policy_context( io_repository = lo_config_repo ) ).

    mo_validator        = COND #( WHEN io_validator        IS BOUND THEN io_validator        ELSE NEW /fcbp/cl_glt_handoff_validator( ) ).
    mo_profile_resolver = COND #( WHEN io_profile_resolver IS BOUND THEN io_profile_resolver ELSE NEW /fcbp/cl_glt_profile_resolver( io_config_provider = lo_config_provider ) ).
    mo_key_builder      = COND #( WHEN io_key_builder      IS BOUND THEN io_key_builder      ELSE NEW /fcbp/cl_glt_reg_key_builder( ) ).
    mo_registry         = COND #( WHEN io_registry         IS BOUND THEN io_registry         ELSE NEW /fcbp/cl_glt_source_registry( io_repository = lo_handoff_repo ) ).
    mo_factory          = COND #( WHEN io_factory          IS BOUND THEN io_factory          ELSE NEW /fcbp/cl_glt_handoff_factory( ) ).
    mo_repository       = lo_handoff_repo.
    mo_outbox           = COND #( WHEN io_outbox           IS BOUND THEN io_outbox           ELSE NEW /fcbp/cl_glt_outbox_enqueuer( io_repository = lo_handoff_repo ) ).
    mo_audit            = COND #( WHEN io_audit            IS BOUND THEN io_audit            ELSE NEW /fcbp/cl_glt_audit_writer( io_repository = NEW /fcbp/cl_glt_audit_repo( ) ) ).
    mo_logger           = COND #( WHEN io_logger           IS BOUND THEN io_logger           ELSE NEW /fcbp/cl_glt_handoff_logger( io_logger = NEW /fcbp/cl_glt_app_logger( ) ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_receiver~receive_scope.
    ensure_dependencies( ).

    DATA(ls_request) = is_request.
    IF ls_request-requested_by IS INITIAL.
      ls_request-requested_by = sy-uname.
    ENDIF.
    IF ls_request-requested_at IS INITIAL.
      GET TIME STAMP FIELD ls_request-requested_at.
    ENDIF.
    IF ls_request-processing_mode IS INITIAL.
      ls_request-processing_mode = /fcbp/if_glt_types=>c_processing_mode-realtime.
    ENDIF.

    DATA lv_registration_key TYPE /fcbp/if_glt_types=>ty_registration_key.

    TRY.
        mo_validator->validate_request( ls_request ).

        DATA(ls_route_context) = mo_profile_resolver->resolve_for_source( ls_request ).
        lv_registration_key = mo_key_builder->build(
          is_request       = ls_request
          is_route_context = ls_route_context ).

        DATA(ls_registration) = mo_factory->create_registration(
          is_request          = ls_request
          is_route_context    = ls_route_context
          iv_registration_key = lv_registration_key ).

        DATA(ls_decision) = mo_registry->reserve( ls_registration ).
        IF ls_decision-already_registered = abap_true
           OR ls_decision-registration_status = /fcbp/if_glt_types=>c_reg_status-active
           OR ls_decision-registration_status = /fcbp/if_glt_types=>c_reg_status-duplicate.

          DATA(ls_existing) = mo_registry->read_existing( lv_registration_key ).
          DATA(ls_duplicate_header) = mo_factory->create_header(
            is_request          = ls_request
            is_route_context    = ls_route_context
            iv_registration_key = lv_registration_key ).
          ls_duplicate_header-transfer_id     = ls_existing-transfer_id.
          ls_duplicate_header-external_status = /fcbp/if_glt_types=>c_ext_status-received.
          ls_duplicate_header-internal_state  = /fcbp/if_glt_types=>c_internal_state-new.

          rs_result = mo_factory->create_result(
            is_header              = ls_duplicate_header
            iv_registration_key    = lv_registration_key
            iv_registration_status = /fcbp/if_glt_types=>c_reg_status-duplicate
            iv_already_registered  = abap_true
            iv_message             = 'Duplicate handoff returned existing transfer.' ).

          IF mo_logger IS BOUND.
            mo_logger->log_duplicate( rs_result ).
          ENDIF.
          RETURN.
        ENDIF.

        DATA(ls_header) = mo_factory->create_header(
          is_request          = ls_request
          is_route_context    = ls_route_context
          iv_registration_key = lv_registration_key ).

        DATA(ls_status) = mo_factory->create_initial_status( ls_header ).
        DATA(ls_work) = mo_factory->create_outbox(
          is_header        = ls_header
          is_route_context = ls_route_context ).
        DATA(ls_audit) = mo_factory->create_audit_event(
          is_request       = ls_request
          is_header        = ls_header
          is_route_context = ls_route_context
          iv_outcome       = 'REGISTERED' ).

        mo_repository->create_transfer_root( ls_header ).
        mo_repository->insert_initial_status( ls_status ).
        DATA(lv_outbox_id) = mo_outbox->enqueue_work( ls_work ).
        DATA(lv_audit_id) = mo_audit->write_event( ls_audit ).
        mo_registry->activate(
          iv_registration_key = lv_registration_key
          iv_transfer_id      = ls_header-transfer_id ).

        rs_result = mo_factory->create_result(
          is_header              = ls_header
          iv_registration_key    = lv_registration_key
          iv_registration_status = /fcbp/if_glt_types=>c_reg_status-active
          iv_already_registered  = abap_false
          iv_message             = 'Source handoff registered and dispatch work queued.' ).

      CATCH /fcbp/cx_glt_handoff INTO DATA(lx_handoff).
        mark_registration_failed(
          iv_registration_key = lv_registration_key
          iv_reason           = COND #( WHEN lx_handoff->reason_code IS INITIAL THEN 'HANDOFF_FAILED' ELSE lx_handoff->reason_code ) ).
        IF mo_logger IS BOUND.
          mo_logger->log_rejected( is_request = ls_request ix_error = lx_handoff ).
        ENDIF.
        RAISE EXCEPTION lx_handoff.
      CATCH /fcbp/cx_glt_audit INTO DATA(lx_audit).
        mark_registration_failed(
          iv_registration_key = lv_registration_key
          iv_reason           = 'AUDIT_WRITE_FAILED' ).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
          EXPORTING
            source_type         = ls_request-source_type
            source_reference    = ls_request-source_reference
            reason_code         = 'AUDIT_WRITE_FAILED'
            transfer_id         = lx_audit->transfer_id
            correlation_id      = lx_audit->correlation_id
            error_category      = /fcbp/if_glt_types=>c_error_category-technical
            operator_text       = 'Source handoff audit evidence could not be written.'
            technical_reference = lx_audit->technical_reference
            previous            = lx_audit.
    ENDTRY.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_receiver~get_registration.
    ensure_dependencies( ).
    rs_registration = mo_registry->read_existing( iv_registration_key ).
  ENDMETHOD.

  METHOD ensure_dependencies.
    IF mo_validator IS NOT BOUND
       OR mo_profile_resolver IS NOT BOUND
       OR mo_key_builder IS NOT BOUND
       OR mo_registry IS NOT BOUND
       OR mo_factory IS NOT BOUND
       OR mo_repository IS NOT BOUND
       OR mo_outbox IS NOT BOUND
       OR mo_audit IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
        EXPORTING
          reason_code    = 'MISSING_DEPENDENCY'
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = 'Source Handoff receiver dependencies are not fully injected.'.
    ENDIF.
  ENDMETHOD.

  METHOD mark_registration_failed.
    IF iv_registration_key IS INITIAL OR mo_registry IS NOT BOUND.
      RETURN.
    ENDIF.

    TRY.
        mo_registry->mark_failed(
          iv_registration_key = iv_registration_key
          iv_reason           = iv_reason ).
      CATCH /fcbp/cx_glt_handoff.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
