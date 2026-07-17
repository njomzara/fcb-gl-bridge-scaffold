"! Batch source discovery seam. It returns candidates only; Source Handoff creates transfers.
INTERFACE /fcbp/if_glt_source_selector PUBLIC.

  METHODS select_eligible_scopes
    IMPORTING
      is_request          TYPE /fcbp/if_glt_job_types=>ty_source_selection_request
    RETURNING
      VALUE(rt_candidate) TYPE /fcbp/if_glt_job_types=>tt_source_candidate
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
