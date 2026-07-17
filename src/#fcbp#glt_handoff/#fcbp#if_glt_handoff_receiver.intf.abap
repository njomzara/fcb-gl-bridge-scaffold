"! Public Source Handoff API. Real-time and batch intake converge here.
INTERFACE /fcbp/if_glt_handoff_receiver PUBLIC.

  METHODS receive_scope
    IMPORTING
      is_request       TYPE /fcbp/if_glt_types=>ty_handoff_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_types=>ty_handoff_result
    RAISING
      /fcbp/cx_glt_handoff.

  METHODS get_registration
    IMPORTING
      iv_registration_key    TYPE /fcbp/if_glt_types=>ty_registration_key
    RETURNING
      VALUE(rs_registration) TYPE /fcbp/if_glt_types=>ty_registration
    RAISING
      /fcbp/cx_glt_handoff.

ENDINTERFACE.

