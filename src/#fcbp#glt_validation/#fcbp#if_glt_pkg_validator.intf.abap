"! Package-level validation gate before Mapping and Adapter execution.
INTERFACE /fcbp/if_glt_pkg_validator PUBLIC.

  METHODS validate_package
    IMPORTING
      is_context       TYPE /fcbp/if_glt_val_types=>ty_package_context
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_val_types=>ty_result
    RAISING
      /fcbp/cx_glt_validation.

  METHODS revalidate_package
    IMPORTING
      is_context       TYPE /fcbp/if_glt_val_types=>ty_package_context
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_val_types=>ty_result
    RAISING
      /fcbp/cx_glt_validation.

ENDINTERFACE.
