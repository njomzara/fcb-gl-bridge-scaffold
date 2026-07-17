"! Package id generation seam.
INTERFACE /fcbp/if_glt_package_id_factory PUBLIC.

  METHODS create_package_id
    IMPORTING
      iv_transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      iv_build_mode        TYPE char20 OPTIONAL
    RETURNING
      VALUE(rv_package_id) TYPE /fcbp/if_glt_pkg_types=>ty_package_id
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
