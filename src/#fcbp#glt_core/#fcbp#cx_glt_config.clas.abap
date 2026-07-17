CLASS /fcbp/cx_glt_config DEFINITION PUBLIC INHERITING FROM /fcbp/cx_glt_error FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    DATA config_object_type TYPE char30 READ-ONLY.
    DATA config_object_key  TYPE char80 READ-ONLY.
    DATA target_id          TYPE char20 READ-ONLY.
    DATA policy_id          TYPE char20 READ-ONLY.
    DATA routing_bucket     TYPE char32 READ-ONLY.
    DATA reason_code        TYPE char40 READ-ONLY.
    DATA blocking           TYPE abap_bool READ-ONLY.

    METHODS constructor
      IMPORTING
        config_object_type  TYPE char30 OPTIONAL
        config_object_key   TYPE char80 OPTIONAL
        target_id           TYPE char20 OPTIONAL
        policy_id           TYPE char20 OPTIONAL
        routing_bucket      TYPE char32 OPTIONAL
        reason_code         TYPE char40 OPTIONAL
        blocking            TYPE abap_bool DEFAULT abap_true
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

CLASS /fcbp/cx_glt_config IMPLEMENTATION.
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
    me->config_object_type = config_object_type.
    me->config_object_key  = config_object_key.
    me->target_id          = target_id.
    me->policy_id          = policy_id.
    me->routing_bucket     = routing_bucket.
    me->reason_code        = reason_code.
    me->blocking           = blocking.
  ENDMETHOD.
ENDCLASS.
