"! Provider support access guard and audit contract.
INTERFACE /fcbp/if_glt_support_access PUBLIC.

  METHODS request_access
    IMPORTING
      is_scope          TYPE /fcbp/if_glt_sec_types=>ty_support_scope
    RETURNING
      VALUE(rs_context) TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RAISING
      /fcbp/cx_glt_auth
      /fcbp/cx_glt_audit.

  METHODS record_access
    IMPORTING
      is_scope          TYPE /fcbp/if_glt_sec_types=>ty_support_scope
      is_context        TYPE /fcbp/if_glt_sec_types=>ty_security_context
      iv_outcome        TYPE char30
    RETURNING
      VALUE(rv_audit_id) TYPE /fcbp/if_glt_types=>ty_audit_id
    RAISING
      /fcbp/cx_glt_audit.

ENDINTERFACE.
