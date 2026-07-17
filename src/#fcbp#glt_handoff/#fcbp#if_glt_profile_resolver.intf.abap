"! Resolves deterministic route context for a source scope.
INTERFACE /fcbp/if_glt_profile_resolver PUBLIC.

  METHODS resolve_for_source
    IMPORTING
      is_request        TYPE /fcbp/if_glt_types=>ty_handoff_request
    RETURNING
      VALUE(rs_context) TYPE /fcbp/if_glt_types=>ty_route_context
    RAISING
      /fcbp/cx_glt_route.

ENDINTERFACE.

