"! Persists target confirmation evidence before a transfer is marked posted.
INTERFACE /fcbp/if_glt_reference_svc PUBLIC.

  METHODS record_confirmation
    IMPORTING
      is_target_ref      TYPE /fcbp/if_glt_types=>ty_target_ref
      iv_reason         TYPE char30 DEFAULT 'TARGET_CONFIRMED'
      iv_actor_id       TYPE char40 OPTIONAL
    RETURNING
      VALUE(rv_ref_id)  TYPE /fcbp/if_glt_types=>ty_ref_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS assert_posting_evidence
    IMPORTING
      is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
