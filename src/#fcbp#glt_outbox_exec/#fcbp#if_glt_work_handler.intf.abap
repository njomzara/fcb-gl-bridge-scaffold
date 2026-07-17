"! Handles exactly one claimed outbox work item.
INTERFACE /fcbp/if_glt_work_handler PUBLIC.

  METHODS handle
    IMPORTING
      is_work          TYPE /fcbp/if_glt_types=>ty_outbox_work
      is_context       TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_outbox_types=>ty_work_handler_result
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
