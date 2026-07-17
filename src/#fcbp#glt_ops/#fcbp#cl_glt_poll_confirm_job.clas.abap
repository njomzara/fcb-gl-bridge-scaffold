"! Application job shell for POLL work after async or unknown confirmation.
CLASS /fcbp/cl_glt_poll_confirm_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS execute
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_poll_confirm_job IMPLEMENTATION.

  METHOD execute.
    " TODO: Claim POLL work, call adapter QUERY_STATUS, and let retry/status services classify the result.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        transfer_id    = iv_transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-unknown_confirmation
        retryable      = abap_true
        operator_text  = 'Poll-confirmation job is not implemented in the scaffold.'.
  ENDMETHOD.

ENDCLASS.
