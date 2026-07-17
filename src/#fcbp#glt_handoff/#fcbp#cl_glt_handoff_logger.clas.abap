"! Handoff-specific logging wrapper. Keeps request context out of raw exception text.
CLASS /fcbp/cl_glt_handoff_logger DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_logger TYPE REF TO /fcbp/if_glt_logger OPTIONAL.

    METHODS log_duplicate
      IMPORTING
        is_result TYPE /fcbp/if_glt_types=>ty_handoff_result.

    METHODS log_rejected
      IMPORTING
        is_request TYPE /fcbp/if_glt_types=>ty_handoff_request
        ix_error   TYPE REF TO /fcbp/cx_glt_handoff.

  PRIVATE SECTION.
    DATA mo_logger TYPE REF TO /fcbp/if_glt_logger.

ENDCLASS.

CLASS /fcbp/cl_glt_handoff_logger IMPLEMENTATION.

  METHOD constructor.
    mo_logger = io_logger.
  ENDMETHOD.

  METHOD log_duplicate.
    IF mo_logger IS BOUND.
      TRY.
          mo_logger->log_info(
            iv_transfer_id = is_result-transfer_id
            iv_subobject   = 'HANDOFF'
            iv_text        = |Duplicate handoff returned registration { is_result-registration_key }.| ).
        CATCH /fcbp/cx_glt_error.
          " Logging failure must not convert duplicate reads into failed handoffs.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD log_rejected.
    IF mo_logger IS BOUND.
      TRY.
          mo_logger->log_info(
            iv_subobject = 'HANDOFF'
            iv_text      = |Handoff rejected for source { is_request-source_type }/{ is_request-source_reference }: { ix_error->reason_code }.| ).
        CATCH /fcbp/cx_glt_error.
          " Rejection reason is already carried by the raised handoff exception.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
