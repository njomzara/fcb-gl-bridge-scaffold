"! Deterministic hash contract for resolved target/profile policy evidence.
INTERFACE /fcbp/if_glt_effective_ctx_hash PUBLIC.

  METHODS hash_effective_context
    IMPORTING
      is_context      TYPE /fcbp/if_glt_config_types=>ty_effective_context
    RETURNING
      VALUE(rv_hash)  TYPE char64.

  METHODS hash_policy_context
    IMPORTING
      is_context      TYPE /fcbp/if_glt_config_types=>ty_policy_context
    RETURNING
      VALUE(rv_hash)  TYPE char64.

ENDINTERFACE.
