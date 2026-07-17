"! Splits canonical lines into deterministic outbound documents.
INTERFACE /fcbp/if_glt_splitter PUBLIC.

  METHODS split
    IMPORTING
      it_canonical_line TYPE /fcbp/if_glt_pkg_types=>tt_canonical_line
      it_source_trace   TYPE /fcbp/if_glt_pkg_types=>tt_source_trace
      is_split_policy   TYPE /fcbp/if_glt_config_types=>ty_split_policy
      is_policy_context TYPE /fcbp/if_glt_config_types=>ty_policy_context
    RETURNING
      VALUE(rs_result)  TYPE /fcbp/if_glt_aggr_types=>ty_split_result
    RAISING
      /fcbp/cx_glt_preparation.

ENDINTERFACE.
