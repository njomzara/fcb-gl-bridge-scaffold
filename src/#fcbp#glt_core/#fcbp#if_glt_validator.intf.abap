"! Validation contract for new requests and reprocessing.
INTERFACE /fcbp/if_glt_validator PUBLIC.

  METHODS validate_request
    IMPORTING
      is_transfer       TYPE /fcbp/if_glt_types=>ty_transfer
    RETURNING
      VALUE(rt_message) TYPE /fcbp/if_glt_types=>tt_message
    RAISING
      /fcbp/cx_glt_validation.

  METHODS validate_reprocess
    IMPORTING
      iv_transfer_id    TYPE /fcbp/if_glt_types=>ty_transfer_id
    RETURNING
      VALUE(rt_message) TYPE /fcbp/if_glt_types=>tt_message
    RAISING
      /fcbp/cx_glt_validation.

ENDINTERFACE.

