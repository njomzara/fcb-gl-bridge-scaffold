"! Normalizes and persists operator-safe monitoring messages.
INTERFACE /fcbp/if_glt_message_svc PUBLIC.

  METHODS normalize_message
    IMPORTING
      iv_transfer_id             TYPE /fcbp/if_glt_types=>ty_transfer_id
      is_message                 TYPE /fcbp/if_glt_types=>ty_message
      iv_category                TYPE char24 DEFAULT /fcbp/if_glt_types=>c_error_category-technical
      iv_retryable               TYPE abap_bool DEFAULT abap_false
      iv_unknown_confirmation    TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(rs_error)            TYPE /fcbp/if_glt_types=>ty_error.

  METHODS record_error
    IMPORTING
      is_error           TYPE /fcbp/if_glt_types=>ty_error
    RETURNING
      VALUE(rv_error_id) TYPE /fcbp/if_glt_types=>ty_error_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS record_message
    IMPORTING
      is_message           TYPE /fcbp/if_glt_types=>ty_monitor_message
    RETURNING
      VALUE(rv_message_id) TYPE /fcbp/if_glt_types=>ty_message_id
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
