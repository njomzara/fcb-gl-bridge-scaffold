"! Side-effect-free package validation rule evaluator.
INTERFACE /fcbp/if_glt_val_rule_eval PUBLIC.

  METHODS evaluate
    IMPORTING
      is_evidence       TYPE /fcbp/if_glt_val_types=>ty_package_evidence
      it_rule           TYPE /fcbp/if_glt_config_types=>tt_validation_rule
    RETURNING
      VALUE(rt_finding) TYPE /fcbp/if_glt_val_types=>tt_finding
    RAISING
      /fcbp/cx_glt_validation.

ENDINTERFACE.
