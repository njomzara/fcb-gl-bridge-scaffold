"! Audit and Security exception for invalid or failed audit evidence writes.
CLASS /fcbp/cx_glt_audit DEFINITION PUBLIC INHERITING FROM /fcbp/cx_glt_error FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    DATA event_type TYPE char30 READ-ONLY.
    DATA event_category TYPE char30 READ-ONLY.
    DATA criticality TYPE char20 READ-ONLY.

    METHODS constructor
      IMPORTING
        event_type           TYPE char30 OPTIONAL
        event_category       TYPE char30 OPTIONAL
        criticality          TYPE char20 OPTIONAL
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

CLASS /fcbp/cx_glt_audit IMPLEMENTATION.
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
    me->event_type = event_type.
    me->event_category = event_category.
    me->criticality = criticality.
  ENDMETHOD.
ENDCLASS.
