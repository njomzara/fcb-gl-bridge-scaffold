"! Migration helper from early GLT_CFG/GLT_ROUTE compatibility tables to CC_* control-plane rows.
CLASS /fcbp/cl_glt_config_migration DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build_target_profile_from_route
      IMPORTING
        is_route          TYPE /fcbp/if_glt_types=>ty_route
        is_config         TYPE /fcbp/if_glt_types=>ty_config OPTIONAL
      RETURNING
        VALUE(rs_profile) TYPE /fcbp/if_glt_config_types=>ty_target_profile.

    METHODS build_retry_policy_from_config
      IMPORTING
        is_config        TYPE /fcbp/if_glt_types=>ty_config
      RETURNING
        VALUE(rs_policy) TYPE /fcbp/if_glt_config_types=>ty_retry_policy.

ENDCLASS.

CLASS /fcbp/cl_glt_config_migration IMPLEMENTATION.

  METHOD build_target_profile_from_route.
    rs_profile = VALUE #(
      target_id         = COND #( WHEN is_route-target_system IS NOT INITIAL THEN is_route-target_system ELSE is_route-route_id )
      target_type       = 'MIGRATED'
      adapter_type      = is_route-target_adapter
      transfer_mode     = /fcbp/if_glt_types=>c_processing_mode-realtime
      confirmation_mode = is_route-confirmation_mode
      retry_policy_id   = is_route-retry_profile
      source_system     = is_route-source_system
      transfer_type     = is_route-transfer_type
      company_code      = is_route-company_code
      active_flag       = is_route-active
      lifecycle_state   = COND #( WHEN is_route-active = abap_true THEN /fcbp/if_glt_config_types=>c_lifecycle_state-active ELSE /fcbp/if_glt_config_types=>c_lifecycle_state-inactive )
      valid_from        = is_route-valid_from
      valid_to          = is_route-valid_to
      priority          = is_route-priority
      health_state      = /fcbp/if_glt_config_types=>c_health_state-unknown
      config_version    = 1
      changed_by        = is_route-changed_by
      changed_at        = is_route-changed_at ).
  ENDMETHOD.

  METHOD build_retry_policy_from_config.
    rs_policy = VALUE #(
      retry_policy_id      = |{ is_config-transfer_type }_RETRY|
      version              = 1
      active_flag          = is_config-active
      lifecycle_state      = COND #( WHEN is_config-active = abap_true THEN /fcbp/if_glt_config_types=>c_lifecycle_state-active ELSE /fcbp/if_glt_config_types=>c_lifecycle_state-inactive )
      max_attempts         = is_config-default_max_retry
      initial_delay_sec    = is_config-default_backoff_sec
      backoff_model        = 'FIXED'
      exhaustion_behavior  = 'OPERATOR_ACTION'
      poll_before_retry    = abap_true
      changed_by           = is_config-changed_by
      changed_at           = is_config-changed_at ).
  ENDMETHOD.

ENDCLASS.
