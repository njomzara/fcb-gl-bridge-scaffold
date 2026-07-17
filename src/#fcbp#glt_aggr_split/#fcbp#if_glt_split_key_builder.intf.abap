"! Builds deterministic split keys for outbound document grouping.
INTERFACE /fcbp/if_glt_split_key_builder PUBLIC.

  METHODS build_key
    IMPORTING
      is_line         TYPE /fcbp/if_glt_pkg_types=>ty_canonical_line
      is_split_policy TYPE /fcbp/if_glt_config_types=>ty_split_policy
    RETURNING
      VALUE(rs_key)   TYPE /fcbp/if_glt_aggr_types=>ty_split_key.

ENDINTERFACE.
