"! Target Routing and Policy Resolution diagnostic DTOs and constants.
INTERFACE /fcbp/if_glt_trp_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_lifecycle_state,
      requested              TYPE char30 VALUE 'REQUESTED',
      scope_normalized       TYPE char30 VALUE 'SCOPE_NORMALIZED',
      candidates_read        TYPE char30 VALUE 'CANDIDATES_READ',
      target_selected        TYPE char30 VALUE 'TARGET_SELECTED',
      policies_loaded        TYPE char30 VALUE 'POLICIES_LOADED',
      health_checked         TYPE char30 VALUE 'HEALTH_CHECKED',
      policy_context_created TYPE char30 VALUE 'POLICY_CONTEXT_CREATED',
      returned               TYPE char30 VALUE 'RETURNED',
      failed                 TYPE char30 VALUE 'FAILED',
    END OF c_lifecycle_state.

  CONSTANTS:
    BEGIN OF c_error_code,
      target_profile_missing   TYPE char40 VALUE 'TARGET_PROFILE_MISSING',
      target_profile_inactive  TYPE char40 VALUE 'TARGET_PROFILE_INACTIVE',
      target_profile_expired   TYPE char40 VALUE 'TARGET_PROFILE_EXPIRED',
      target_profile_ambiguous TYPE char40 VALUE 'TARGET_PROFILE_AMBIGUOUS',
      target_profile_unhealthy TYPE char40 VALUE 'TARGET_PROFILE_UNHEALTHY',
      policy_reference_missing TYPE char40 VALUE 'POLICY_REFERENCE_MISSING',
      policy_inactive          TYPE char40 VALUE 'POLICY_INACTIVE',
      policy_context_not_found TYPE char40 VALUE 'POLICY_CONTEXT_NOT_FOUND',
      routing_dimension_missing TYPE char40 VALUE 'ROUTING_DIMENSION_MISSING',
      config_inconsistent      TYPE char40 VALUE 'CONFIG_INCONSISTENT',
    END OF c_error_code.

  TYPES: BEGIN OF ty_route_simulation_result,
           routing_scope       TYPE /fcbp/if_glt_config_types=>ty_routing_scope,
           effective_context   TYPE /fcbp/if_glt_config_types=>ty_effective_context,
           route_context       TYPE /fcbp/if_glt_types=>ty_route_context,
           routing_bucket      TYPE char32,
           effective_hash      TYPE char64,
           lifecycle_state     TYPE char30,
           accepted            TYPE abap_bool,
           operator_text       TYPE char220,
         END OF ty_route_simulation_result.

  TYPES: BEGIN OF ty_context_compare_result,
           policy_context_id   TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           target_id           TYPE char20,
           historical_hash     TYPE char64,
           current_hash        TYPE char64,
           hashes_match        TYPE abap_bool,
           blocking            TYPE abap_bool,
           operator_text       TYPE char220,
         END OF ty_context_compare_result.

ENDINTERFACE.
