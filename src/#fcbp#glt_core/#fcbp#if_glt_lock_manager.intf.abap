"! Logical lock and due-work claim contract.
INTERFACE /fcbp/if_glt_lock_manager PUBLIC.

  METHODS try_lock_transfer
    IMPORTING
      iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_owner       TYPE char40
      iv_lock_until  TYPE utclong
    RETURNING
      VALUE(rv_locked) TYPE abap_bool
    RAISING
      /fcbp/cx_glt_lock.

  METHODS release_transfer
    IMPORTING
      iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_owner       TYPE char40
    RAISING
      /fcbp/cx_glt_lock.

  METHODS claim_retry
    IMPORTING
      iv_owner       TYPE char40
      iv_lock_until  TYPE utclong
    RETURNING
      VALUE(rs_retry) TYPE /fcbp/if_glt_types=>ty_retry
    RAISING
      /fcbp/cx_glt_lock.

ENDINTERFACE.

