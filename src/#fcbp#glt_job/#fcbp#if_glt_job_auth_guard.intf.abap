"! Authorization wrapper for scheduled/manual job execution scopes.
INTERFACE /fcbp/if_glt_job_auth_guard PUBLIC.

  METHODS check_job_scope
    IMPORTING
      is_context TYPE /fcbp/if_glt_job_types=>ty_job_context
    RAISING
      /fcbp/cx_glt_auth.

ENDINTERFACE.
