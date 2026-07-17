"! Redaction service for sensitive monitor, audit, support, and technical fields.
INTERFACE /fcbp/if_glt_redaction PUBLIC.

  METHODS redact_value
    IMPORTING
      is_request       TYPE /fcbp/if_glt_sec_types=>ty_redaction_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_sec_types=>ty_redaction_result.

  METHODS redact_error
    IMPORTING
      is_error         TYPE /fcbp/if_glt_types=>ty_error
      is_context       TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING
      VALUE(rs_error)  TYPE /fcbp/if_glt_types=>ty_error.

  METHODS redact_audit_event
    IMPORTING
      is_event         TYPE /fcbp/if_glt_types=>ty_audit_event
      is_context       TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING
      VALUE(rs_event)  TYPE /fcbp/if_glt_types=>ty_audit_event.

ENDINTERFACE.
