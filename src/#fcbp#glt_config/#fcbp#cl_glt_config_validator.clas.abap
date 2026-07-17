"! Field and cross-policy validation for configuration save/activation.
CLASS /fcbp/cl_glt_config_validator DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS validate_target_profile
      IMPORTING
        is_profile TYPE /fcbp/if_glt_config_types=>ty_target_profile
      RAISING
        /fcbp/cx_glt_config.

    METHODS validate_effective_context
      IMPORTING
        is_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
      RAISING
        /fcbp/cx_glt_config.

    METHODS assert_can_activate
      IMPORTING
        is_profile TYPE /fcbp/if_glt_config_types=>ty_target_profile
        it_finding TYPE /fcbp/if_glt_config_types=>tt_health_finding
      RAISING
        /fcbp/cx_glt_config.

ENDCLASS.

CLASS /fcbp/cl_glt_config_validator IMPLEMENTATION.

  METHOD validate_target_profile.
    IF is_profile-target_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = 'GLT_CFG_001'
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          operator_text      = 'Target ID is required.'.
    ENDIF.

    IF is_profile-target_type IS INITIAL OR is_profile-adapter_type IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = 'GLT_CFG_003'
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          config_object_key  = is_profile-target_id
          target_id          = is_profile-target_id
          operator_text      = 'Target type and adapter type are required.'.
    ENDIF.

    IF is_profile-valid_from IS NOT INITIAL AND
       is_profile-valid_to IS NOT INITIAL AND
       is_profile-valid_from > is_profile-valid_to.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = 'GLT_CFG_007'
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          config_object_key  = is_profile-target_id
          target_id          = is_profile-target_id
          operator_text      = 'Target profile validity range is invalid.'.
    ENDIF.
  ENDMETHOD.

  METHOD validate_effective_context.
    validate_target_profile( is_context-target_profile ).

    IF is_context-target_profile-active_flag = abap_false.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-inactive
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          config_object_key  = is_context-target_profile-target_id
          target_id          = is_context-target_profile-target_id
          operator_text      = 'Inactive target profile cannot be used by runtime.'.
    ENDIF.

    IF is_context-confirmation_policy-unknown_behavior = 'RETRY'.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = 'GLT_CFG_019'
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-confirmation_policy
          config_object_key  = is_context-target_profile-confirmation_policy_id
          target_id          = is_context-target_profile-target_id
          operator_text      = 'Unknown-confirmation policy must not allow blind retry.'.
    ENDIF.
  ENDMETHOD.

  METHOD assert_can_activate.
    validate_target_profile( is_profile ).

    IF is_profile-config_hash IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = 'GLT_CFG_010'
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          config_object_key  = is_profile-target_id
          target_id          = is_profile-target_id
          operator_text      = 'Configuration hash is required before activation.'.
    ENDIF.

    LOOP AT it_finding INTO DATA(ls_finding) WHERE blocking_flag = abap_true.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-unhealthy
          config_object_type = ls_finding-config_object_type
          config_object_key  = ls_finding-config_object_key
          target_id          = ls_finding-target_id
          operator_text      = ls_finding-operator_text.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
