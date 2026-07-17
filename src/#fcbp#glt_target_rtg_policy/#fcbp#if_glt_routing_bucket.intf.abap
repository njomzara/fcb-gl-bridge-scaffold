"! Central routing-bucket derivation contract.
INTERFACE /fcbp/if_glt_routing_bucket PUBLIC.

  METHODS build_bucket
    IMPORTING
      is_scope          TYPE /fcbp/if_glt_config_types=>ty_routing_scope
      is_profile        TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RETURNING
      VALUE(rv_bucket)  TYPE char32
    RAISING
      /fcbp/cx_glt_config.

ENDINTERFACE.
