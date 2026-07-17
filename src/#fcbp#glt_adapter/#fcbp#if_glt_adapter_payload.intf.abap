"! Builds target-specific request envelopes from target-normalized journal evidence.
INTERFACE /fcbp/if_glt_adapter_payload PUBLIC.

  METHODS build_submit_payload
    IMPORTING
      is_transfer      TYPE /fcbp/if_glt_types=>ty_transfer
      is_request       TYPE /fcbp/if_glt_adapter_types=>ty_submit_request
    RETURNING
      VALUE(rs_payload) TYPE /fcbp/if_glt_adapter_types=>ty_payload
    RAISING
      /fcbp/cx_glt_adapter.

  METHODS build_status_query_payload
    IMPORTING
      is_request       TYPE /fcbp/if_glt_adapter_types=>ty_query_request
    RETURNING
      VALUE(rs_payload) TYPE /fcbp/if_glt_adapter_types=>ty_payload
    RAISING
      /fcbp/cx_glt_adapter.

ENDINTERFACE.
