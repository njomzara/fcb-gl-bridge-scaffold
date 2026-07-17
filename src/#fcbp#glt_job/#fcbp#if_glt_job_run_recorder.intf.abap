"! Job-run evidence persistence contract for /FCBP/GLT_JOBRUN.
INTERFACE /fcbp/if_glt_job_run_recorder PUBLIC.

  METHODS start_run
    IMPORTING
      is_context          TYPE /fcbp/if_glt_job_types=>ty_job_context
    RETURNING
      VALUE(rv_jobrun_id) TYPE /fcbp/if_glt_types=>ty_jobrun_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS finish_run
    IMPORTING
      iv_jobrun_id TYPE /fcbp/if_glt_types=>ty_jobrun_id
      is_result    TYPE /fcbp/if_glt_job_types=>ty_job_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS fail_run
    IMPORTING
      iv_jobrun_id TYPE /fcbp/if_glt_types=>ty_jobrun_id
      is_failure   TYPE /fcbp/if_glt_job_types=>ty_job_result
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
