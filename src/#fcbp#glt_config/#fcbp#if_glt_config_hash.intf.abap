"! Stable hash contract for runtime-relevant configuration fields.
INTERFACE /fcbp/if_glt_config_hash PUBLIC.

  METHODS hash_target_profile
    IMPORTING
      is_profile     TYPE /fcbp/if_glt_config_types=>ty_target_profile
    RETURNING
      VALUE(rv_hash) TYPE char64.

  METHODS hash_effective_context
    IMPORTING
      is_context     TYPE /fcbp/if_glt_config_types=>ty_effective_context
    RETURNING
      VALUE(rv_hash) TYPE char64.

  METHODS hash_config_change
    IMPORTING
      is_change      TYPE /fcbp/if_glt_sec_types=>ty_config_change
    RETURNING
      VALUE(rv_hash) TYPE char64.

ENDINTERFACE.
