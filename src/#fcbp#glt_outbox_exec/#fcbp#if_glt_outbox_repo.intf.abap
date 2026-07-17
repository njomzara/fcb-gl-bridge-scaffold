"! Owner-only persistence seam for /FCBP/GLT_OUTBOX execution.
INTERFACE /fcbp/if_glt_outbox_repo PUBLIC.

  METHODS select_due_work
    IMPORTING
      is_context     TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
    RETURNING
      VALUE(rt_work) TYPE /fcbp/if_glt_types=>tt_outbox_work
    RAISING
      /fcbp/cx_glt_error.

  METHODS claim_work
    IMPORTING
      iv_outbox_id   TYPE /fcbp/if_glt_types=>ty_outbox_id
      iv_claim_owner TYPE char40
      iv_lock_until  TYPE utclong
      is_context     TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
    RETURNING
      VALUE(rs_claim) TYPE /fcbp/if_glt_outbox_types=>ty_outbox_claim
    RAISING
      /fcbp/cx_glt_error.

  METHODS complete_work
    IMPORTING
      iv_outbox_id   TYPE /fcbp/if_glt_types=>ty_outbox_id
      iv_claim_owner TYPE char40
      is_result      TYPE /fcbp/if_glt_outbox_types=>ty_work_handler_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS fail_work
    IMPORTING
      iv_outbox_id   TYPE /fcbp/if_glt_types=>ty_outbox_id
      iv_claim_owner TYPE char40
      is_result      TYPE /fcbp/if_glt_outbox_types=>ty_work_handler_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS release_work
    IMPORTING
      iv_outbox_id   TYPE /fcbp/if_glt_types=>ty_outbox_id
      iv_claim_owner TYPE char40
      is_result      TYPE /fcbp/if_glt_outbox_types=>ty_work_handler_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS supersede_work
    IMPORTING
      iv_outbox_id             TYPE /fcbp/if_glt_types=>ty_outbox_id
      iv_claim_owner           TYPE char40
      iv_successor_outbox_id   TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
      is_result                TYPE /fcbp/if_glt_outbox_types=>ty_work_handler_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS enqueue_work
    IMPORTING
      is_work             TYPE /fcbp/if_glt_types=>ty_outbox_work
    RETURNING
      VALUE(rv_outbox_id) TYPE /fcbp/if_glt_types=>ty_outbox_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS recover_expired_locks
    IMPORTING
      is_request       TYPE /fcbp/if_glt_outbox_types=>ty_lock_recovery_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_outbox_types=>ty_lock_recovery_result
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
