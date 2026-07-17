"! Transfer-context entry point for package preparation and rebuild.
INTERFACE /fcbp/if_glt_package_preparer PUBLIC.

  METHODS prepare_for_dispatch
    IMPORTING
      iv_transfer_id          TYPE /fcbp/if_glt_types=>ty_transfer_id
      is_effective_context    TYPE /fcbp/if_glt_config_types=>ty_effective_context
      iv_outbox_id            TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
    RETURNING
      VALUE(rs_result)        TYPE /fcbp/if_glt_aggr_types=>ty_package_build_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS rebuild_package
    IMPORTING
      iv_transfer_id            TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_predecessor_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      iv_reason_code            TYPE char30
      is_effective_context      TYPE /fcbp/if_glt_config_types=>ty_effective_context
    RETURNING
      VALUE(rs_result)          TYPE /fcbp/if_glt_aggr_types=>ty_package_build_result
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
