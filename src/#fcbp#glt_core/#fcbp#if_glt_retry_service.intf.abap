"! Retry, unknown-confirmation, and manual reprocess scheduling contract.
INTERFACE /fcbp/if_glt_retry_service PUBLIC.

  METHODS classify_adapter_result
    IMPORTING
      is_result         TYPE /fcbp/if_glt_types=>ty_adapter_result
      is_transfer       TYPE /fcbp/if_glt_types=>ty_transfer
    RETURNING
      VALUE(rv_status)  TYPE /fcbp/if_glt_types=>ty_status
    RAISING
      /fcbp/cx_glt_error.

  METHODS schedule_retry
    IMPORTING
      iv_transfer_id  TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_error_id     TYPE /fcbp/if_glt_types=>ty_error_id OPTIONAL
      iv_retry_type   TYPE char20 DEFAULT /fcbp/if_glt_types=>c_retry_type-retry
    RETURNING
      VALUE(rv_retry_id) TYPE /fcbp/if_glt_types=>ty_retry_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS schedule_status_query
    IMPORTING
      iv_transfer_id  TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_error_id     TYPE /fcbp/if_glt_types=>ty_error_id OPTIONAL
    RETURNING
      VALUE(rv_retry_id) TYPE /fcbp/if_glt_types=>ty_retry_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS request_reprocess
    IMPORTING
      is_request      TYPE /fcbp/if_glt_types=>ty_reprocess_request
    RETURNING
      VALUE(rv_retry_id) TYPE /fcbp/if_glt_types=>ty_retry_id
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.

