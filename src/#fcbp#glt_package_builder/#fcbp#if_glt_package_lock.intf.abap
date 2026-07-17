"! Package publication lock/ownership seam.
INTERFACE /fcbp/if_glt_package_lock PUBLIC.

  METHODS acquire
    IMPORTING
      iv_transfer_id      TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_outbox_id        TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
      iv_build_mode       TYPE char20 OPTIONAL
    RETURNING
      VALUE(rv_acquired)  TYPE abap_bool
    RAISING
      /fcbp/cx_glt_error.

  METHODS release
    IMPORTING
      iv_transfer_id      TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_outbox_id        TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
      iv_build_mode       TYPE char20 OPTIONAL
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
