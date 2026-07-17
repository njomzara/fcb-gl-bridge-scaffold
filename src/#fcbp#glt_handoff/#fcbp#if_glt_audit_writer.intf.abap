"! Append-only audit boundary for lifecycle, security, config, support, and job events.
INTERFACE /fcbp/if_glt_audit_writer PUBLIC.

  METHODS write_event
    IMPORTING
      is_event           TYPE /fcbp/if_glt_types=>ty_audit_event
      iv_criticality     TYPE char20 DEFAULT /fcbp/if_glt_sec_types=>c_criticality-business_critical
    RETURNING
      VALUE(rv_audit_id) TYPE /fcbp/if_glt_types=>ty_audit_id
    RAISING
      /fcbp/cx_glt_audit.

  METHODS write_authorization_denial
    IMPORTING
      is_decision        TYPE /fcbp/if_glt_sec_types=>ty_auth_decision
      is_context         TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING
      VALUE(rv_audit_id) TYPE /fcbp/if_glt_types=>ty_audit_id
    RAISING
      /fcbp/cx_glt_audit.

  METHODS write_support_access
    IMPORTING
      is_scope           TYPE /fcbp/if_glt_sec_types=>ty_support_scope
      is_context         TYPE /fcbp/if_glt_sec_types=>ty_security_context
      iv_outcome         TYPE char30
    RETURNING
      VALUE(rv_audit_id) TYPE /fcbp/if_glt_types=>ty_audit_id
    RAISING
      /fcbp/cx_glt_audit.

ENDINTERFACE.
