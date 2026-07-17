"! Reads package evidence required by package validation rules.
INTERFACE /fcbp/if_glt_pkg_evidence PUBLIC.

  METHODS read_for_validation
    IMPORTING
      iv_transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      iv_policy_context_id TYPE /fcbp/if_glt_config_types=>ty_policy_context_id
    RETURNING
      VALUE(rs_evidence)   TYPE /fcbp/if_glt_val_types=>ty_package_evidence
    RAISING
      /fcbp/cx_glt_validation.

ENDINTERFACE.
