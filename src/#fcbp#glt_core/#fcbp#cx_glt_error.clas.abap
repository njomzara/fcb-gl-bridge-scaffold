"! Root checked exception for Transfer Core.
CLASS /fcbp/cx_glt_error DEFINITION PUBLIC INHERITING FROM cx_static_check
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_t100_message.

    DATA transfer_id          TYPE /fcbp/if_glt_types=>ty_transfer_id READ-ONLY.
    DATA correlation_id       TYPE /fcbp/if_glt_types=>ty_correlation_id READ-ONLY.
    DATA idempotency_key      TYPE /fcbp/if_glt_types=>ty_idempotency_key READ-ONLY.
    DATA error_category       TYPE char24 READ-ONLY.
    DATA retryable            TYPE abap_bool READ-ONLY.
    DATA unknown_confirmation TYPE abap_bool READ-ONLY.
    DATA operator_text        TYPE char220 READ-ONLY.
    DATA technical_reference  TYPE string READ-ONLY.

    METHODS constructor
      IMPORTING
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

CLASS /fcbp/cx_glt_error IMPLEMENTATION.

  METHOD constructor.
    super->constructor( previous = previous ).
    me->transfer_id          = transfer_id.
    me->correlation_id       = correlation_id.
    me->idempotency_key      = idempotency_key.
    me->error_category       = error_category.
    me->retryable            = retryable.
    me->unknown_confirmation = unknown_confirmation.
    me->operator_text        = operator_text.
    me->technical_reference  = technical_reference.
    IF textid IS SUPPLIED.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

