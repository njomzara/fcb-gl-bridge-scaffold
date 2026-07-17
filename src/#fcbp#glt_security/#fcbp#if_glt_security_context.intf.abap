"! Normalizes actor/scope/purpose context for authorization and audit.
INTERFACE /fcbp/if_glt_security_context PUBLIC.

  METHODS get_current_context
    IMPORTING
      iv_purpose         TYPE char30 DEFAULT /fcbp/if_glt_sec_types=>c_purpose-monitor
      iv_company_code    TYPE char4 OPTIONAL
      iv_target_id       TYPE char20 OPTIONAL
      iv_correlation_id  TYPE /fcbp/if_glt_types=>ty_correlation_id OPTIONAL
    RETURNING
      VALUE(rs_context)  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RAISING
      /fcbp/cx_glt_auth.

  METHODS build_support_context
    IMPORTING
      is_scope           TYPE /fcbp/if_glt_sec_types=>ty_support_scope
    RETURNING
      VALUE(rs_context)  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RAISING
      /fcbp/cx_glt_auth.

  METHODS build_job_context
    IMPORTING
      iv_job_type        TYPE char30
      iv_jobrun_id       TYPE /fcbp/if_glt_types=>ty_jobrun_id OPTIONAL
    RETURNING
      VALUE(rs_context)  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RAISING
      /fcbp/cx_glt_auth.

  METHODS assert_context
    IMPORTING
      is_context TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RAISING
      /fcbp/cx_glt_auth.

ENDINTERFACE.
