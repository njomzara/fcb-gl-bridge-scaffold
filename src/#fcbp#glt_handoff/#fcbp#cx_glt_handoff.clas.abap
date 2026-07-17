"! Root exception for Source Handoff failures.
CLASS /fcbp/cx_glt_handoff DEFINITION PUBLIC INHERITING FROM /fcbp/cx_glt_error
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA source_type       TYPE char20 READ-ONLY.
    DATA source_reference  TYPE char50 READ-ONLY.
    DATA registration_key  TYPE /fcbp/if_glt_types=>ty_registration_key READ-ONLY.
    DATA reason_code       TYPE char40 READ-ONLY.

    METHODS constructor
      IMPORTING
        source_type          TYPE char20 OPTIONAL
        source_reference     TYPE char50 OPTIONAL
        registration_key     TYPE /fcbp/if_glt_types=>ty_registration_key OPTIONAL
        reason_code          TYPE char40 OPTIONAL
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

CLASS /fcbp/cx_glt_handoff IMPLEMENTATION.

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
    me->source_type      = source_type.
    me->source_reference = source_reference.
    me->registration_key = registration_key.
    me->reason_code      = reason_code.
  ENDMETHOD.

ENDCLASS.

