"! Stale outbox lock recovery/reporting contract.
INTERFACE /fcbp/if_glt_lock_recovery PUBLIC.

  METHODS recover_expired_locks
    IMPORTING
      is_request       TYPE /fcbp/if_glt_outbox_types=>ty_lock_recovery_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_outbox_types=>ty_lock_recovery_result
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
