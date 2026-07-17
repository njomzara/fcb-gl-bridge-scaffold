"! Downstream posting/export adapter boundary.
INTERFACE /fcbp/if_glt_transfer_adapter PUBLIC.

  METHODS dispatch
    IMPORTING
      is_transfer       TYPE /fcbp/if_glt_types=>ty_transfer
      is_route          TYPE /fcbp/if_glt_types=>ty_route
      is_request        TYPE /fcbp/if_glt_adapter_types=>ty_submit_request OPTIONAL
    RETURNING
      VALUE(rs_result)  TYPE /fcbp/if_glt_types=>ty_adapter_result
    RAISING
      /fcbp/cx_glt_adapter.

  METHODS query_status
    IMPORTING
      is_transfer       TYPE /fcbp/if_glt_types=>ty_transfer
      is_route          TYPE /fcbp/if_glt_types=>ty_route
      is_request        TYPE /fcbp/if_glt_adapter_types=>ty_query_request OPTIONAL
    RETURNING
      VALUE(rs_result)  TYPE /fcbp/if_glt_types=>ty_adapter_result
    RAISING
      /fcbp/cx_glt_adapter.

  METHODS cancel
    IMPORTING
      is_transfer       TYPE /fcbp/if_glt_types=>ty_transfer
      is_route          TYPE /fcbp/if_glt_types=>ty_route
      iv_reason         TYPE char30
    RETURNING
      VALUE(rs_result)  TYPE /fcbp/if_glt_types=>ty_adapter_result
    RAISING
      /fcbp/cx_glt_adapter.

  METHODS validate_connection
    IMPORTING
      is_profile             TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RETURNING
      VALUE(rs_result)       TYPE /fcbp/if_glt_adapter_types=>ty_connection_result
    RAISING
      /fcbp/cx_glt_adapter.

  METHODS get_capabilities
    RETURNING
      VALUE(rv_capabilities) TYPE string.

  METHODS get_capability_matrix
    IMPORTING
      is_profile             TYPE /fcbp/if_glt_config_types=>ty_target_profile OPTIONAL
    RETURNING
      VALUE(rs_capability)   TYPE /fcbp/if_glt_adapter_types=>ty_capability.

ENDINTERFACE.
