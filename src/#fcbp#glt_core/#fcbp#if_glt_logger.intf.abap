"! Application-log and normalized-error persistence contract.
INTERFACE /fcbp/if_glt_logger PUBLIC.

  METHODS log_info
    IMPORTING
      iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      iv_subobject   TYPE char20
      iv_text        TYPE char220
    RAISING
      /fcbp/cx_glt_error.

  METHODS log_error
    IMPORTING
      iv_transfer_id     TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      is_error           TYPE /fcbp/if_glt_types=>ty_error
    RETURNING
      VALUE(rv_error_id) TYPE /fcbp/if_glt_types=>ty_error_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS save_log
    IMPORTING
      iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      iv_error_id    TYPE /fcbp/if_glt_types=>ty_error_id OPTIONAL
      iv_subobject   TYPE char20
    RETURNING
      VALUE(rv_logref_id) TYPE char32
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.

