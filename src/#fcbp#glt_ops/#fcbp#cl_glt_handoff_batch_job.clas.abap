"! Batch selector wrapper. It must call Source Handoff API and must not write GLT tables directly.
CLASS /fcbp/cl_glt_handoff_batch_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_receiver TYPE REF TO /fcbp/if_glt_handoff_receiver OPTIONAL.

    METHODS submit_candidate
      IMPORTING
        is_request       TYPE /fcbp/if_glt_types=>ty_handoff_request
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_types=>ty_handoff_result
      RAISING
        /fcbp/cx_glt_handoff.

  PRIVATE SECTION.
    DATA mo_receiver TYPE REF TO /fcbp/if_glt_handoff_receiver.

ENDCLASS.

CLASS /fcbp/cl_glt_handoff_batch_job IMPLEMENTATION.

  METHOD constructor.
    mo_receiver = io_receiver.
  ENDMETHOD.

  METHOD submit_candidate.
    IF mo_receiver IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
        EXPORTING
          reason_code    = 'NO_RECEIVER'
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = 'Batch handoff job requires the Source Handoff receiver.'.
    ENDIF.

    DATA(ls_request) = is_request.
    ls_request-processing_mode = /fcbp/if_glt_types=>c_processing_mode-batch.
    rs_result = mo_receiver->receive_scope( ls_request ).
  ENDMETHOD.

ENDCLASS.

