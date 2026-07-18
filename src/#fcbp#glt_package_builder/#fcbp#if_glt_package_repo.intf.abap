"! Package Builder persistence seam for complete package graph publication.
INTERFACE /fcbp/if_glt_package_repo PUBLIC.

  METHODS persist_graph
    IMPORTING
      is_graph TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
    RAISING
      /fcbp/cx_glt_repository.

  METHODS publish_current
    IMPORTING
      iv_transfer_id                 TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_package_id                  TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      iv_lock_owner                  TYPE char40
      iv_expected_current_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
    RAISING
      /fcbp/cx_glt_repository.

  METHODS read_package
    IMPORTING
      iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id
    RETURNING
      VALUE(rs_graph) TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
    RAISING
      /fcbp/cx_glt_repository.

  METHODS read_current_package
    IMPORTING
      iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
    RETURNING
      VALUE(rs_graph) TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
    RAISING
      /fcbp/cx_glt_repository.

  METHODS check_consistency
    IMPORTING
      iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id
    RETURNING
      VALUE(rt_message) TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message
    RAISING
      /fcbp/cx_glt_repository.

ENDINTERFACE.
