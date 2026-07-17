"! Persistence seam for append-only audit evidence.
INTERFACE /fcbp/if_glt_audit_repo PUBLIC.

  METHODS insert_audit_event
    IMPORTING
      is_event           TYPE /fcbp/if_glt_types=>ty_audit_event
    RETURNING
      VALUE(rv_audit_id) TYPE /fcbp/if_glt_types=>ty_audit_id
    RAISING
      /fcbp/cx_glt_audit.

  METHODS query_audit
    IMPORTING
      is_filter       TYPE /fcbp/if_glt_sec_types=>ty_audit_filter
    RETURNING
      VALUE(rt_event) TYPE /fcbp/if_glt_types=>tt_audit_event
    RAISING
      /fcbp/cx_glt_audit.

ENDINTERFACE.
