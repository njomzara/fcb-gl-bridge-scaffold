"! Persistence seam for Configuration Layer target profiles, policies, health, and policy-context evidence.
INTERFACE /fcbp/if_glt_config_repo PUBLIC.

  METHODS query_target_profiles
    IMPORTING
      is_scope          TYPE /fcbp/if_glt_config_types=>ty_routing_scope
    RETURNING
      VALUE(rt_profile) TYPE /fcbp/if_glt_config_types=>tt_target_profile
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_target_profile
    IMPORTING
      iv_target_id      TYPE char20
    RETURNING
      VALUE(rs_profile) TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_retry_policy
    IMPORTING
      iv_policy_id      TYPE char20
      iv_version        TYPE i OPTIONAL
    RETURNING
      VALUE(rs_policy)  TYPE /fcbp/if_glt_config_types=>ty_retry_policy
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_aggregation_policy
    IMPORTING
      iv_profile_id     TYPE char20
      iv_version        TYPE i OPTIONAL
    RETURNING
      VALUE(rs_policy)  TYPE /fcbp/if_glt_config_types=>ty_aggregation_policy
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_aggregation_fields
    IMPORTING
      iv_profile_id     TYPE char20
      iv_version        TYPE i OPTIONAL
    RETURNING
      VALUE(rt_field)   TYPE /fcbp/if_glt_config_types=>tt_aggregation_field
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_split_policy
    IMPORTING
      iv_profile_id     TYPE char20
      iv_version        TYPE i OPTIONAL
    RETURNING
      VALUE(rs_policy)  TYPE /fcbp/if_glt_config_types=>ty_split_policy
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_validation_rules
    IMPORTING
      iv_profile_id     TYPE char20
      iv_version        TYPE i OPTIONAL
    RETURNING
      VALUE(rt_rule)    TYPE /fcbp/if_glt_config_types=>tt_validation_rule
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_mapping_rules
    IMPORTING
      iv_policy_id      TYPE char20
      iv_version        TYPE i OPTIONAL
    RETURNING
      VALUE(rt_rule)    TYPE /fcbp/if_glt_config_types=>tt_mapping_rule
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_throttle_policy
    IMPORTING
      iv_policy_id      TYPE char20
      iv_version        TYPE i OPTIONAL
    RETURNING
      VALUE(rs_policy)  TYPE /fcbp/if_glt_config_types=>ty_throttle_policy
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_confirmation_policy
    IMPORTING
      iv_policy_id      TYPE char20
      iv_version        TYPE i OPTIONAL
    RETURNING
      VALUE(rs_policy)  TYPE /fcbp/if_glt_config_types=>ty_confirmation_policy
    RAISING
      /fcbp/cx_glt_config.

  METHODS insert_policy_context
    IMPORTING
      is_context              TYPE /fcbp/if_glt_config_types=>ty_policy_context
    RETURNING
      VALUE(rv_context_id)    TYPE /fcbp/if_glt_config_types=>ty_policy_context_id
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_policy_context
    IMPORTING
      iv_context_id           TYPE /fcbp/if_glt_config_types=>ty_policy_context_id
    RETURNING
      VALUE(rs_context)       TYPE /fcbp/if_glt_config_types=>ty_policy_context
    RAISING
      /fcbp/cx_glt_config.

  METHODS insert_health_finding
    IMPORTING
      is_finding TYPE /fcbp/if_glt_config_types=>ty_health_finding
    RAISING
      /fcbp/cx_glt_config.

ENDINTERFACE.
