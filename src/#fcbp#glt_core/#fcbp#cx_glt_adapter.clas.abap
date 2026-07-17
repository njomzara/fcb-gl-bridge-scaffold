CLASS /fcbp/cx_glt_adapter DEFINITION PUBLIC INHERITING FROM /fcbp/cx_glt_error FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    DATA target_id TYPE char20 READ-ONLY.
    DATA target_adapter TYPE char30 READ-ONLY.
    DATA destination_alias TYPE char40 READ-ONLY.
    DATA protocol_category TYPE char30 READ-ONLY.
    DATA http_status TYPE i READ-ONLY.
    DATA middleware_message_id TYPE char80 READ-ONLY.
    DATA target_message_code TYPE char40 READ-ONLY.

    METHODS constructor
      IMPORTING
        target_id            TYPE char20 OPTIONAL
        target_adapter       TYPE char30 OPTIONAL
        destination_alias    TYPE char40 OPTIONAL
        protocol_category    TYPE char30 OPTIONAL
        http_status          TYPE i OPTIONAL
        middleware_message_id TYPE char80 OPTIONAL
        target_message_code  TYPE char40 OPTIONAL
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

CLASS /fcbp/cx_glt_adapter IMPLEMENTATION.
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
    me->target_id = target_id.
    me->target_adapter = target_adapter.
    me->destination_alias = destination_alias.
    me->protocol_category = protocol_category.
    me->http_status = http_status.
    me->middleware_message_id = middleware_message_id.
    me->target_message_code = target_message_code.
  ENDMETHOD.
ENDCLASS.
