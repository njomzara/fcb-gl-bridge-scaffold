"! Missing, inactive, or ambiguous route context for source handoff.
CLASS /fcbp/cx_glt_route DEFINITION PUBLIC INHERITING FROM /fcbp/cx_glt_handoff FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
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

CLASS /fcbp/cx_glt_route IMPLEMENTATION.
  METHOD constructor.
    super->constructor(
      source_type          = source_type
      source_reference     = source_reference
      registration_key     = registration_key
      reason_code          = reason_code
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
  ENDMETHOD.
ENDCLASS.
