"! Converts normalized adapter outcomes into outbox next actions.
INTERFACE /fcbp/if_glt_outcome_classifier PUBLIC.

  METHODS classify
    IMPORTING
      is_work          TYPE /fcbp/if_glt_types=>ty_outbox_work
      is_attempt       TYPE /fcbp/if_glt_types=>ty_attempt OPTIONAL
      is_result        TYPE /fcbp/if_glt_types=>ty_adapter_result
      is_context       TYPE /fcbp/if_glt_job_types=>ty_dispatch_context
    RETURNING
      VALUE(rs_decision) TYPE /fcbp/if_glt_outbox_types=>ty_outcome_decision
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
