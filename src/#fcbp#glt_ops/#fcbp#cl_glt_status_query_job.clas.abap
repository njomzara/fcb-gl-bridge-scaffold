"! Application job shell for /FCBP/GLT_STATUS_QUERY.
CLASS /fcbp/cl_glt_status_query_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_factory TYPE REF TO /fcbp/cl_glt_adapter_factory OPTIONAL.

    METHODS execute
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_factory TYPE REF TO /fcbp/cl_glt_adapter_factory.

ENDCLASS.

CLASS /fcbp/cl_glt_status_query_job IMPLEMENTATION.

  METHOD constructor.
    IF io_factory IS BOUND.
      mo_factory = io_factory.
    ELSE.
      mo_factory = NEW /fcbp/cl_glt_adapter_factory( ).
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    " TODO: Claim UNKNOWN_CONFIRMATION work and call adapter QUERY_STATUS before any resubmit.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING transfer_id    = iv_transfer_id
                error_category = /fcbp/if_glt_types=>c_error_category-unknown_confirmation
                retryable      = abap_true
                operator_text  = 'Status-query job is not implemented in the scaffold.'.
  ENDMETHOD.

ENDCLASS.
