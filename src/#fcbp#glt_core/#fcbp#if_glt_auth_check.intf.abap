"! Authorization enforcement contract for RAP actions, jobs, and support reads.
INTERFACE /fcbp/if_glt_auth_check PUBLIC.

  METHODS check_display
    IMPORTING
      iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
      is_context     TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RAISING
      /fcbp/cx_glt_auth.

  METHODS check_action
    IMPORTING
      iv_action      TYPE char30
      iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
      is_context     TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RETURNING
      VALUE(rs_decision) TYPE /fcbp/if_glt_sec_types=>ty_auth_decision
    RAISING
      /fcbp/cx_glt_auth.

  METHODS check_reprocess
    IMPORTING
      iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
      is_context     TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RAISING
      /fcbp/cx_glt_auth.

  METHODS check_config
    IMPORTING
      iv_transfer_type       TYPE char20 OPTIONAL
      iv_company_code        TYPE char4 OPTIONAL
      iv_config_object_type  TYPE char30 OPTIONAL
      iv_config_object_key   TYPE char80 OPTIONAL
      iv_activity            TYPE char30 DEFAULT /fcbp/if_glt_sec_types=>c_action-config_view
      iv_target_id           TYPE char20 OPTIONAL
      is_context             TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RAISING
      /fcbp/cx_glt_auth.

  METHODS check_audit_read
    IMPORTING
      iv_transfer_id  TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      iv_company_code TYPE char4 OPTIONAL
      iv_target_id    TYPE char20 OPTIONAL
      is_context      TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RAISING
      /fcbp/cx_glt_auth.

  METHODS check_support_access
    IMPORTING
      is_scope   TYPE /fcbp/if_glt_sec_types=>ty_support_scope
      is_context TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RAISING
      /fcbp/cx_glt_auth.

  METHODS check_worker_execute
    IMPORTING
      iv_job_type TYPE char30
      is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RAISING
      /fcbp/cx_glt_auth.

ENDINTERFACE.
