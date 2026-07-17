"! Minimal profile resolver scaffold. Productive routing belongs to Target Routing/Configuration.
CLASS /fcbp/cl_glt_profile_resolver DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_profile_resolver.

    METHODS constructor
      IMPORTING
        io_config_provider TYPE REF TO /fcbp/if_glt_config_provider OPTIONAL
        io_bucket          TYPE REF TO /fcbp/if_glt_routing_bucket OPTIONAL.

  PRIVATE SECTION.
    DATA mo_config_provider TYPE REF TO /fcbp/if_glt_config_provider.
    DATA mo_bucket TYPE REF TO /fcbp/if_glt_routing_bucket.

ENDCLASS.

CLASS /fcbp/cl_glt_profile_resolver IMPLEMENTATION.

  METHOD constructor.
    mo_config_provider = io_config_provider.
    IF io_bucket IS BOUND.
      mo_bucket = io_bucket.
    ELSE.
      mo_bucket = NEW /fcbp/cl_glt_routing_bucket( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_profile_resolver~resolve_for_source.
    IF is_request-company_code IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_route
        EXPORTING
          source_type      = is_request-source_type
          source_reference = is_request-source_reference
          reason_code      = 'GLT_HND_008'
          error_category   = /fcbp/if_glt_types=>c_error_category-config
          operator_text    = 'Company code or another routing dimension is required before handoff registration.'.
    ENDIF.

    IF mo_config_provider IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_route
        EXPORTING
          source_type      = is_request-source_type
          source_reference = is_request-source_reference
          reason_code      = 'CONFIG_PROVIDER_MISSING'
          error_category   = /fcbp/if_glt_types=>c_error_category-config
          operator_text    = 'Configured target profile resolver requires a configuration provider implementation.'.
    ENDIF.

    DATA(ls_scope) = VALUE /fcbp/if_glt_config_types=>ty_routing_scope(
      transfer_type    = is_request-event_type
      source_system    = 'FCBP'
      source_type      = is_request-source_type
      source_reference = is_request-source_reference
      company_code     = is_request-company_code
      ledger_group     = is_request-ledger_group
      processing_mode  = is_request-processing_mode
      routing_hint     = is_request-routing_hint
      requested_by     = is_request-requested_by
      correlation_id   = is_request-external_corr_id ).
    ls_scope-resolution_date = sy-datum.
    ls_scope-resolution_time = sy-uzeit.

    TRY.
        DATA(ls_effective) = mo_config_provider->resolve_effective_context( ls_scope ).
      CATCH /fcbp/cx_glt_config INTO DATA(lx_config).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_route
          EXPORTING
            source_type         = is_request-source_type
            source_reference    = is_request-source_reference
            reason_code         = lx_config->reason_code
            error_category      = /fcbp/if_glt_types=>c_error_category-config
            operator_text       = lx_config->operator_text
            technical_reference = lx_config->technical_reference
            previous            = lx_config.
    ENDTRY.

    TRY.
        rs_context-routing_bucket = mo_bucket->build_bucket(
          is_scope   = ls_scope
          is_profile = ls_effective-target_profile ).
      CATCH /fcbp/cx_glt_config INTO DATA(lx_bucket).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_route
          EXPORTING
            source_type         = is_request-source_type
            source_reference    = is_request-source_reference
            reason_code         = lx_bucket->reason_code
            error_category      = /fcbp/if_glt_types=>c_error_category-config
            operator_text       = lx_bucket->operator_text
            technical_reference = lx_bucket->technical_reference
            previous            = lx_bucket.
    ENDTRY.
    rs_context-target_id         = ls_effective-target_profile-target_id.
    rs_context-target_type       = ls_effective-target_profile-target_type.
    rs_context-target_system     = ls_effective-target_profile-target_id.
    rs_context-target_adapter    = ls_effective-target_profile-adapter_type.
    rs_context-transfer_mode     = ls_effective-target_profile-transfer_mode.
    rs_context-confirmation_mode = ls_effective-target_profile-confirmation_mode.
    rs_context-priority          = ls_effective-target_profile-priority.
    rs_context-retry_profile     = ls_effective-target_profile-retry_policy_id.
    rs_context-policy_reference  = ls_effective-policy_context_id.
  ENDMETHOD.

ENDCLASS.
