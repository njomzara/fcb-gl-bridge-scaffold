"! Public mapping contract for target-normalized canonical journals.
INTERFACE /fcbp/if_glt_mapper PUBLIC.

  METHODS map_journal
    IMPORTING
      is_context       TYPE /fcbp/if_glt_map_types=>ty_context
      is_journal       TYPE /fcbp/if_glt_map_types=>ty_canonical_journal
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_map_types=>ty_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS map_package
    IMPORTING
      is_context       TYPE /fcbp/if_glt_map_types=>ty_context
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_map_types=>ty_result
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
