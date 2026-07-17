"! Creates and reads immutable runtime policy-context snapshots.
INTERFACE /fcbp/if_glt_policy_context PUBLIC.

  METHODS create_context
    IMPORTING
      is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
      iv_transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      iv_package_id        TYPE char32 OPTIONAL
      iv_outbox_id         TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
    RETURNING
      VALUE(rv_context_id) TYPE /fcbp/if_glt_config_types=>ty_policy_context_id
    RAISING
      /fcbp/cx_glt_config.

  METHODS read_context
    IMPORTING
      iv_context_id       TYPE /fcbp/if_glt_config_types=>ty_policy_context_id
    RETURNING
      VALUE(rs_context)   TYPE /fcbp/if_glt_config_types=>ty_policy_context
    RAISING
      /fcbp/cx_glt_config.

ENDINTERFACE.
