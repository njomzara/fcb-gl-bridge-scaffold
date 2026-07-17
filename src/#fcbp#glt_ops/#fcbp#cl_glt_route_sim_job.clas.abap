"! Diagnostic job shell for route and effective-context simulation.
CLASS /fcbp/cl_glt_route_sim_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_config_provider TYPE REF TO /fcbp/if_glt_config_provider OPTIONAL
        io_bucket          TYPE REF TO /fcbp/if_glt_routing_bucket OPTIONAL
        io_hash            TYPE REF TO /fcbp/if_glt_effective_ctx_hash OPTIONAL.

    METHODS execute
      IMPORTING
        is_scope         TYPE /fcbp/if_glt_config_types=>ty_routing_scope
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_trp_types=>ty_route_simulation_result
      RAISING
        /fcbp/cx_glt_config.

  PRIVATE SECTION.
    DATA mo_config_provider TYPE REF TO /fcbp/if_glt_config_provider.
    DATA mo_bucket TYPE REF TO /fcbp/if_glt_routing_bucket.
    DATA mo_hash TYPE REF TO /fcbp/if_glt_effective_ctx_hash.

ENDCLASS.

CLASS /fcbp/cl_glt_route_sim_job IMPLEMENTATION.

  METHOD constructor.
    mo_config_provider = io_config_provider.
    IF io_bucket IS BOUND.
      mo_bucket = io_bucket.
    ELSE.
      mo_bucket = NEW /fcbp/cl_glt_routing_bucket( ).
    ENDIF.
    IF io_hash IS BOUND.
      mo_hash = io_hash.
    ELSE.
      mo_hash = NEW /fcbp/cl_glt_effective_ctx_hash( ).
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    IF mo_config_provider IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-missing
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          operator_text      = 'Route simulation requires a configuration provider implementation.'.
    ENDIF.

    rs_result-routing_scope = is_scope.
    rs_result-effective_context = mo_config_provider->resolve_effective_context( is_scope ).
    rs_result-routing_bucket = mo_bucket->build_bucket(
      is_scope   = is_scope
      is_profile = rs_result-effective_context-target_profile ).
    rs_result-effective_hash = mo_hash->hash_effective_context( rs_result-effective_context ).
    rs_result-route_context = VALUE #(
      routing_bucket    = rs_result-routing_bucket
      target_id         = rs_result-effective_context-target_profile-target_id
      target_type       = rs_result-effective_context-target_profile-target_type
      target_system     = rs_result-effective_context-target_profile-target_id
      target_adapter    = rs_result-effective_context-target_profile-adapter_type
      transfer_mode     = rs_result-effective_context-target_profile-transfer_mode
      confirmation_mode = rs_result-effective_context-target_profile-confirmation_mode
      priority          = rs_result-effective_context-target_profile-priority
      retry_profile     = rs_result-effective_context-target_profile-retry_policy_id
      policy_reference  = rs_result-effective_context-policy_context_id ).
    rs_result-lifecycle_state = /fcbp/if_glt_trp_types=>c_lifecycle_state-returned.
    rs_result-accepted = abap_true.
    rs_result-operator_text = 'Route simulation resolved one target profile and effective context.'.
  ENDMETHOD.

ENDCLASS.
