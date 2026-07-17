"! Configuration authorization/audit helper.
INTERFACE /fcbp/if_glt_config_audit PUBLIC.

  METHODS record_config_change
    IMPORTING
      is_change         TYPE /fcbp/if_glt_sec_types=>ty_config_change
      is_context        TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RETURNING
      VALUE(rv_audit_id) TYPE /fcbp/if_glt_types=>ty_audit_id
    RAISING
      /fcbp/cx_glt_auth
      /fcbp/cx_glt_audit.

  METHODS record_config_activation
    IMPORTING
      is_change         TYPE /fcbp/if_glt_sec_types=>ty_config_change
      is_context        TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
    RETURNING
      VALUE(rv_audit_id) TYPE /fcbp/if_glt_types=>ty_audit_id
    RAISING
      /fcbp/cx_glt_auth
      /fcbp/cx_glt_audit.

ENDINTERFACE.
