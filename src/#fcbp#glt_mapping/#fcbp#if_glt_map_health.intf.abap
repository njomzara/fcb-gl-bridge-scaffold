"! Configuration health checks for mapping policies and rule sets.
INTERFACE /fcbp/if_glt_map_health PUBLIC.

  METHODS validate_effective_context
    IMPORTING
      is_context        TYPE /fcbp/if_glt_config_types=>ty_effective_context
    RETURNING
      VALUE(rt_finding) TYPE /fcbp/if_glt_config_types=>tt_health_finding
    RAISING
      /fcbp/cx_glt_config.

ENDINTERFACE.
