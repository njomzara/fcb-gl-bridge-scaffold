"! Builds and persists adapter attempt evidence without exposing raw payloads.
INTERFACE /fcbp/if_glt_adapter_evidence PUBLIC.

  METHODS start_attempt
    IMPORTING
      is_request       TYPE /fcbp/if_glt_adapter_types=>ty_submit_request
      iv_attempt_type  TYPE char20 DEFAULT /fcbp/if_glt_types=>c_attempt_type-submit
      iv_outbox_id     TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
      iv_jobrun_id     TYPE /fcbp/if_glt_types=>ty_jobrun_id OPTIONAL
    RETURNING
      VALUE(rs_attempt) TYPE /fcbp/if_glt_types=>ty_attempt
    RAISING
      /fcbp/cx_glt_repository.

  METHODS finish_attempt
    IMPORTING
      is_attempt       TYPE /fcbp/if_glt_types=>ty_attempt
      is_result        TYPE /fcbp/if_glt_types=>ty_adapter_result
    RETURNING
      VALUE(rs_attempt) TYPE /fcbp/if_glt_types=>ty_attempt
    RAISING
      /fcbp/cx_glt_repository.

  METHODS persist_attempt
    IMPORTING
      is_attempt TYPE /fcbp/if_glt_types=>ty_attempt
    RAISING
      /fcbp/cx_glt_repository.

ENDINTERFACE.
