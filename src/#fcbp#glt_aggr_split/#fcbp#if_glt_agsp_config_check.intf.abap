"! Aggregation/Split configuration health checks.
INTERFACE /fcbp/if_glt_agsp_config_check PUBLIC.

  METHODS validate_effective_context
    IMPORTING
      is_context        TYPE /fcbp/if_glt_config_types=>ty_effective_context
    RETURNING
      VALUE(rt_finding) TYPE /fcbp/if_glt_config_types=>tt_health_finding.

ENDINTERFACE.
