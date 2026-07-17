"! Preparation exception for aggregation, split, trace, and balance failures.
CLASS /fcbp/cx_glt_preparation DEFINITION PUBLIC INHERITING FROM /fcbp/cx_glt_error FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    DATA package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id READ-ONLY.
    DATA outdoc_id TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id READ-ONLY.
    DATA line_id TYPE /fcbp/if_glt_pkg_types=>ty_line_id READ-ONLY.
    DATA policy_context_id TYPE /fcbp/if_glt_config_types=>ty_policy_context_id READ-ONLY.
    DATA profile_id TYPE char20 READ-ONLY.
    DATA rule_id TYPE char30 READ-ONLY.
    DATA field_name TYPE char40 READ-ONLY.
    DATA source_reference TYPE char50 READ-ONLY.

    METHODS constructor
      IMPORTING
        package_id           TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
        outdoc_id            TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id OPTIONAL
        line_id              TYPE /fcbp/if_glt_pkg_types=>ty_line_id OPTIONAL
        policy_context_id    TYPE /fcbp/if_glt_config_types=>ty_policy_context_id OPTIONAL
        profile_id           TYPE char20 OPTIONAL
        rule_id              TYPE char30 OPTIONAL
        field_name           TYPE char40 OPTIONAL
        source_reference     TYPE char50 OPTIONAL
        transfer_id          TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
        correlation_id       TYPE /fcbp/if_glt_types=>ty_correlation_id OPTIONAL
        idempotency_key      TYPE /fcbp/if_glt_types=>ty_idempotency_key OPTIONAL
        error_category       TYPE char24 OPTIONAL
        retryable            TYPE abap_bool DEFAULT abap_false
        unknown_confirmation TYPE abap_bool DEFAULT abap_false
        operator_text        TYPE char220 OPTIONAL
        technical_reference  TYPE string OPTIONAL
        textid               LIKE if_t100_message=>t100key OPTIONAL
        previous             TYPE REF TO cx_root OPTIONAL.
ENDCLASS.

CLASS /fcbp/cx_glt_preparation IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
      transfer_id          = transfer_id
      correlation_id       = correlation_id
      idempotency_key      = idempotency_key
      error_category       = error_category
      retryable            = retryable
      unknown_confirmation = unknown_confirmation
      operator_text        = operator_text
      technical_reference  = technical_reference
      textid               = textid
      previous             = previous ).
    me->package_id = package_id.
    me->outdoc_id = outdoc_id.
    me->line_id = line_id.
    me->policy_context_id = policy_context_id.
    me->profile_id = profile_id.
    me->rule_id = rule_id.
    me->field_name = field_name.
    me->source_reference = source_reference.
  ENDMETHOD.
ENDCLASS.
