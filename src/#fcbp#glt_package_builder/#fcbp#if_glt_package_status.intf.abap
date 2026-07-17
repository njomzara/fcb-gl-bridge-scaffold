"! Status/message/audit facade for Package Builder orchestration.
INTERFACE /fcbp/if_glt_package_status PUBLIC.

  METHODS preparation_started
    IMPORTING
      is_transfer  TYPE /fcbp/if_glt_types=>ty_transfer
      iv_outbox_id TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
      iv_build_mode TYPE char20
    RAISING
      /fcbp/cx_glt_error.

  METHODS preparation_blocked
    IMPORTING
      is_transfer   TYPE /fcbp/if_glt_types=>ty_transfer
      iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
      it_message    TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message
      iv_build_mode TYPE char20
    RAISING
      /fcbp/cx_glt_error.

  METHODS preparation_succeeded
    IMPORTING
      is_transfer   TYPE /fcbp/if_glt_types=>ty_transfer
      iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      it_message    TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message OPTIONAL
      iv_build_mode TYPE char20
    RAISING
      /fcbp/cx_glt_error.

  METHODS preparation_failed
    IMPORTING
      is_transfer   TYPE /fcbp/if_glt_types=>ty_transfer
      iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
      ix_error      TYPE REF TO /fcbp/cx_glt_error OPTIONAL
      iv_build_mode TYPE char20
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
