"! Deterministic aggregation signature builder.
INTERFACE /fcbp/if_glt_aggr_signature PUBLIC.

  METHODS build_signature
    IMPORTING
      is_source_line TYPE /fcbp/if_glt_pkg_types=>ty_source_gl_line
      is_policy      TYPE /fcbp/if_glt_config_types=>ty_aggregation_policy
      it_field       TYPE /fcbp/if_glt_config_types=>tt_aggregation_field
    RETURNING
      VALUE(rs_signature) TYPE /fcbp/if_glt_aggr_types=>ty_signature_result.

  METHODS is_supported_field
    IMPORTING
      iv_field_name TYPE char40
    RETURNING
      VALUE(rv_supported) TYPE abap_bool.

  METHODS is_supported_normalize_rule
    IMPORTING
      iv_rule TYPE char30
    RETURNING
      VALUE(rv_supported) TYPE abap_bool.

ENDINTERFACE.
