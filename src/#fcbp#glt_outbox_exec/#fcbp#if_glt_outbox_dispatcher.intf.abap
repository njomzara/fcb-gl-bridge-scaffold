"! Outbox Execution dispatcher contract consumed by the Job Layer.
INTERFACE /fcbp/if_glt_outbox_dispatcher PUBLIC.

  METHODS dispatch_due_work
    IMPORTING
      is_context       TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_job_types=>ty_job_result
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
