"! Resolves one deterministic mapping rule for a field/source value.
INTERFACE /fcbp/if_glt_map_resolver PUBLIC.

  METHODS resolve
    IMPORTING
      is_field_context TYPE /fcbp/if_glt_map_types=>ty_field_context
      it_rule          TYPE /fcbp/if_glt_config_types=>tt_mapping_rule
    RETURNING
      VALUE(rs_decision) TYPE /fcbp/if_glt_map_types=>ty_decision
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
