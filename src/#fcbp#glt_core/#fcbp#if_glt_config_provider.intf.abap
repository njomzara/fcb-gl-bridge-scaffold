"! Configuration and routing lookup contract.
INTERFACE /fcbp/if_glt_config_provider PUBLIC.

  METHODS get_transfer_config
    IMPORTING
      iv_transfer_type TYPE char20
    RETURNING
      VALUE(rs_config) TYPE /fcbp/if_glt_types=>ty_config
    RAISING
      /fcbp/cx_glt_config.

  METHODS resolve_route
    IMPORTING
      is_header       TYPE /fcbp/if_glt_types=>ty_header
    RETURNING
      VALUE(rs_route) TYPE /fcbp/if_glt_types=>ty_route
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_target_profile
    IMPORTING
      iv_target_id       TYPE char20
    RETURNING
      VALUE(rs_profile)  TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RAISING
      /fcbp/cx_glt_config.

  METHODS resolve_effective_context
    IMPORTING
      is_scope           TYPE /fcbp/if_glt_config_types=>ty_routing_scope
    RETURNING
      VALUE(rs_context)  TYPE /fcbp/if_glt_config_types=>ty_effective_context
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_policy_context
    IMPORTING
      iv_context_id      TYPE /fcbp/if_glt_config_types=>ty_policy_context_id
    RETURNING
      VALUE(rs_context)  TYPE /fcbp/if_glt_config_types=>ty_policy_context
    RAISING
      /fcbp/cx_glt_config.

ENDINTERFACE.
