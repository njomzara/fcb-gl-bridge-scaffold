"! Duplicate detection and reservation contract.
INTERFACE /fcbp/if_glt_idempotency PUBLIC.

  METHODS reserve
    IMPORTING
      is_reservation     TYPE /fcbp/if_glt_types=>ty_idemp_reservation
    RETURNING
      VALUE(rs_decision) TYPE /fcbp/if_glt_types=>ty_idemp_decision
    RAISING
      /fcbp/cx_glt_error.

  METHODS confirm_completed
    IMPORTING
      iv_idempotency_key TYPE /fcbp/if_glt_types=>ty_idempotency_key
      iv_transfer_id     TYPE /fcbp/if_glt_types=>ty_transfer_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS mark_failed
    IMPORTING
      iv_idempotency_key TYPE /fcbp/if_glt_types=>ty_idempotency_key
      iv_transfer_id     TYPE /fcbp/if_glt_types=>ty_transfer_id
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.

