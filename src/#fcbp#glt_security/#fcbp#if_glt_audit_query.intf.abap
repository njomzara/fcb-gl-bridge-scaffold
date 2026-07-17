"! Secured audit read service.
INTERFACE /fcbp/if_glt_audit_query PUBLIC.

  METHODS query_audit
    IMPORTING
      is_filter       TYPE /fcbp/if_glt_sec_types=>ty_audit_filter
      is_context      TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RETURNING
      VALUE(rt_event) TYPE /fcbp/if_glt_types=>tt_audit_event
    RAISING
      /fcbp/cx_glt_auth
      /fcbp/cx_glt_audit.

  METHODS get_transfer_audit
    IMPORTING
      iv_transfer_id  TYPE /fcbp/if_glt_types=>ty_transfer_id
      is_context      TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RETURNING
      VALUE(rt_event) TYPE /fcbp/if_glt_types=>tt_audit_event
    RAISING
      /fcbp/cx_glt_auth
      /fcbp/cx_glt_audit.

ENDINTERFACE.
