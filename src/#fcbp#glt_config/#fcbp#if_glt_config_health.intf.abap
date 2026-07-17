"! Configuration health check contract for activation and scheduled diagnostics.
INTERFACE /fcbp/if_glt_config_health PUBLIC.

  METHODS check_target_profile
    IMPORTING
      is_profile         TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RETURNING
      VALUE(rt_finding)  TYPE /fcbp/if_glt_config_types=>tt_health_finding
    RAISING
      /fcbp/cx_glt_config.

  METHODS check_effective_context
    IMPORTING
      is_context         TYPE /fcbp/if_glt_config_types=>ty_effective_context
    RETURNING
      VALUE(rt_finding)  TYPE /fcbp/if_glt_config_types=>tt_health_finding
    RAISING
      /fcbp/cx_glt_config.

  METHODS assert_healthy
    IMPORTING
      it_finding TYPE /fcbp/if_glt_config_types=>tt_health_finding
    RAISING
      /fcbp/cx_glt_config.

ENDINTERFACE.
