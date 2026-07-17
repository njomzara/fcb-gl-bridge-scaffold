"! Adapter capability matrix for runtime checks and Configuration health.
INTERFACE /fcbp/if_glt_adapter_capability PUBLIC.

  METHODS get_by_adapter_type
    IMPORTING
      iv_adapter_type       TYPE char30
    RETURNING
      VALUE(rs_capability)  TYPE /fcbp/if_glt_adapter_types=>ty_capability.

  METHODS get_for_profile
    IMPORTING
      is_profile           TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RETURNING
      VALUE(rs_capability) TYPE /fcbp/if_glt_adapter_types=>ty_capability.

  METHODS validate_profile
    IMPORTING
      is_profile          TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RETURNING
      VALUE(rt_finding)   TYPE /fcbp/if_glt_config_types=>tt_health_finding.

  METHODS get_registered_catalog
    RETURNING
      VALUE(rt_capability) TYPE /fcbp/if_glt_adapter_types=>tt_capability.

ENDINTERFACE.
