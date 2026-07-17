"! Released communication/client wrapper seam for adapter contract tests.
INTERFACE /fcbp/if_glt_adapter_client PUBLIC.

  METHODS submit
    IMPORTING
      is_request        TYPE /fcbp/if_glt_adapter_types=>ty_submit_request
      is_payload        TYPE /fcbp/if_glt_adapter_types=>ty_payload
    RETURNING
      VALUE(rs_response) TYPE /fcbp/if_glt_adapter_types=>ty_protocol_response
    RAISING
      /fcbp/cx_glt_adapter.

  METHODS query_status
    IMPORTING
      is_request        TYPE /fcbp/if_glt_adapter_types=>ty_query_request
      is_payload        TYPE /fcbp/if_glt_adapter_types=>ty_payload
    RETURNING
      VALUE(rs_response) TYPE /fcbp/if_glt_adapter_types=>ty_protocol_response
    RAISING
      /fcbp/cx_glt_adapter.

  METHODS cancel
    IMPORTING
      is_request        TYPE /fcbp/if_glt_adapter_types=>ty_query_request
      iv_reason         TYPE char30
    RETURNING
      VALUE(rs_response) TYPE /fcbp/if_glt_adapter_types=>ty_protocol_response
    RAISING
      /fcbp/cx_glt_adapter.

  METHODS check_connection
    IMPORTING
      is_profile        TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RETURNING
      VALUE(rs_result)  TYPE /fcbp/if_glt_adapter_types=>ty_connection_result
    RAISING
      /fcbp/cx_glt_adapter.

ENDINTERFACE.
