"! Package Builder integration contract for aggregation/split output.
INTERFACE /fcbp/if_glt_package_builder PUBLIC.

  METHODS build_package
    IMPORTING
      is_context           TYPE /fcbp/if_glt_pkg_types=>ty_package_build_context
      it_source_line       TYPE /fcbp/if_glt_pkg_types=>tt_source_gl_line
      is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
    RETURNING
      VALUE(rs_result)     TYPE /fcbp/if_glt_aggr_types=>ty_package_build_result
    RAISING
      /fcbp/cx_glt_preparation.

ENDINTERFACE.
