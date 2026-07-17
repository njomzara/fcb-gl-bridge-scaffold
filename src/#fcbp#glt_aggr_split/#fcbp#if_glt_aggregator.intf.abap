"! Aggregates source GL lines into canonical journal lines with source trace.
INTERFACE /fcbp/if_glt_aggregator PUBLIC.

  METHODS aggregate
    IMPORTING
      it_source_line     TYPE /fcbp/if_glt_pkg_types=>tt_source_gl_line
      is_aggr_policy    TYPE /fcbp/if_glt_config_types=>ty_aggregation_policy
      it_aggr_field     TYPE /fcbp/if_glt_config_types=>tt_aggregation_field
      is_policy_context TYPE /fcbp/if_glt_config_types=>ty_policy_context
    RETURNING
      VALUE(rs_result)  TYPE /fcbp/if_glt_aggr_types=>ty_aggregation_result
    RAISING
      /fcbp/cx_glt_preparation.

ENDINTERFACE.
