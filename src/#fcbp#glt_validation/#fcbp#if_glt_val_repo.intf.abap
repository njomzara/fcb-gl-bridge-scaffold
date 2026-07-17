"! Persistence seam for validation run and finding evidence.
INTERFACE /fcbp/if_glt_val_repo PUBLIC.

  METHODS create_run
    IMPORTING
      is_run           TYPE /fcbp/if_glt_val_types=>ty_run
    RETURNING
      VALUE(rv_run_id) TYPE /fcbp/if_glt_val_types=>ty_validation_run_id
    RAISING
      /fcbp/cx_glt_validation.

  METHODS insert_findings
    IMPORTING
      it_finding TYPE /fcbp/if_glt_val_types=>tt_finding
    RAISING
      /fcbp/cx_glt_validation.

  METHODS close_run
    IMPORTING
      is_result TYPE /fcbp/if_glt_val_types=>ty_result
    RAISING
      /fcbp/cx_glt_validation.

  METHODS read_latest_run
    IMPORTING
      iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id
    RETURNING
      VALUE(rs_run) TYPE /fcbp/if_glt_val_types=>ty_run
    RAISING
      /fcbp/cx_glt_validation.

ENDINTERFACE.
