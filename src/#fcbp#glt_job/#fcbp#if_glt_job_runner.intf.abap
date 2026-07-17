"! Testable Job Layer runner contract independent of the Application Job runtime.
INTERFACE /fcbp/if_glt_job_runner PUBLIC.

  METHODS run
    IMPORTING
      it_parameter      TYPE /fcbp/if_glt_job_types=>tt_job_parameter OPTIONAL
      is_context        TYPE /fcbp/if_glt_job_types=>ty_job_context OPTIONAL
    RETURNING
      VALUE(rs_result)  TYPE /fcbp/if_glt_job_types=>ty_job_result
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
