"! Public API contract for upstream transfer submissions and status reads.
INTERFACE /fcbp/if_glt_transfer_api PUBLIC.

  METHODS submit
    IMPORTING
      is_request       TYPE /fcbp/if_glt_types=>ty_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_types=>ty_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS get_status
    IMPORTING
      iv_transfer_id   TYPE /fcbp/if_glt_types=>ty_transfer_id
    RETURNING
      VALUE(rs_status) TYPE /fcbp/if_glt_types=>ty_status_result
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.

