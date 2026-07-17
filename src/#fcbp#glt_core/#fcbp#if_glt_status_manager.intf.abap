"! Single authority for status transitions and status-history append.
INTERFACE /fcbp/if_glt_status_manager PUBLIC.

  METHODS set_status
    IMPORTING
      iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_status      TYPE /fcbp/if_glt_types=>ty_status
      iv_reason      TYPE char30 OPTIONAL
      iv_error_id    TYPE /fcbp/if_glt_types=>ty_error_id OPTIONAL
      iv_attempt_no  TYPE i OPTIONAL
      iv_actor_type  TYPE char12 DEFAULT /fcbp/if_glt_types=>c_actor_type-system
      iv_actor_id    TYPE char40 OPTIONAL
    RAISING
      /fcbp/cx_glt_error.

  METHODS assert_transition
    IMPORTING
      iv_old_status TYPE /fcbp/if_glt_types=>ty_status
      iv_new_status TYPE /fcbp/if_glt_types=>ty_status
    RAISING
      /fcbp/cx_glt_error.

  METHODS derive_external_status
    IMPORTING
      iv_status              TYPE /fcbp/if_glt_types=>ty_status
    RETURNING
      VALUE(rv_ext_status)   TYPE /fcbp/if_glt_types=>ty_ext_status.

ENDINTERFACE.

