"! Configuration administration use cases for RAP actions and controlled APIs.
INTERFACE /fcbp/if_glt_config_admin PUBLIC.

  METHODS validate_target_profile
    IMPORTING
      is_profile        TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RETURNING
      VALUE(rt_finding) TYPE /fcbp/if_glt_config_types=>tt_health_finding
    RAISING
      /fcbp/cx_glt_config.

  METHODS check_target_health
    IMPORTING
      is_profile        TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RETURNING
      VALUE(rt_finding) TYPE /fcbp/if_glt_config_types=>tt_health_finding
    RAISING
      /fcbp/cx_glt_config.

  METHODS activate_target_profile
    IMPORTING
      is_profile        TYPE /fcbp/if_glt_config_types=>ty_target_profile
      is_context        TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RETURNING
      VALUE(rs_profile) TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RAISING
      /fcbp/cx_glt_config
      /fcbp/cx_glt_auth
      /fcbp/cx_glt_audit.

  METHODS deactivate_target_profile
    IMPORTING
      is_profile        TYPE /fcbp/if_glt_config_types=>ty_target_profile
      is_context        TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RETURNING
      VALUE(rs_profile) TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RAISING
      /fcbp/cx_glt_config
      /fcbp/cx_glt_auth
      /fcbp/cx_glt_audit.

  METHODS copy_target_profile
    IMPORTING
      is_profile        TYPE /fcbp/if_glt_config_types=>ty_target_profile
      iv_new_target_id  TYPE char20
    RETURNING
      VALUE(rs_profile) TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RAISING
      /fcbp/cx_glt_config.

  METHODS create_new_version
    IMPORTING
      is_profile        TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RETURNING
      VALUE(rs_profile) TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RAISING
      /fcbp/cx_glt_config.

  METHODS display_usage_impact
    IMPORTING
      iv_target_id       TYPE char20
    RETURNING
      VALUE(rt_context)  TYPE /fcbp/if_glt_config_types=>tt_policy_context
    RAISING
      /fcbp/cx_glt_config.

ENDINTERFACE.
