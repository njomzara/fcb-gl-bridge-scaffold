"! Retry/reprocess scheduler. Unknown confirmation always schedules status query first.
CLASS /fcbp/cl_glt_retry_service DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_retry_service.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_repository OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_repository.

    METHODS schedule
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_error_id    TYPE /fcbp/if_glt_types=>ty_error_id OPTIONAL
        iv_retry_type  TYPE char20
      RETURNING
        VALUE(rv_retry_id) TYPE /fcbp/if_glt_types=>ty_retry_id
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_retry_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD /fcbp/if_glt_retry_service~classify_adapter_result.
    CASE is_result-outcome.
      WHEN /fcbp/if_glt_types=>c_adapter_outcome-posted.
        rv_status = /fcbp/if_glt_types=>c_status-posted.
      WHEN /fcbp/if_glt_types=>c_adapter_outcome-dispatched.
        rv_status = /fcbp/if_glt_types=>c_status-dispatched.
      WHEN /fcbp/if_glt_types=>c_adapter_outcome-unknown_confirmation.
        rv_status = /fcbp/if_glt_types=>c_status-unknown_confirmation.
      WHEN /fcbp/if_glt_types=>c_adapter_outcome-retryable_failure.
        rv_status = /fcbp/if_glt_types=>c_status-failed_retryable.
      WHEN OTHERS.
        rv_status = /fcbp/if_glt_types=>c_status-failed_final.
    ENDCASE.
  ENDMETHOD.

  METHOD /fcbp/if_glt_retry_service~schedule_retry.
    rv_retry_id = schedule(
      iv_transfer_id = iv_transfer_id
      iv_error_id    = iv_error_id
      iv_retry_type  = iv_retry_type ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_retry_service~schedule_status_query.
    rv_retry_id = schedule(
      iv_transfer_id = iv_transfer_id
      iv_error_id    = iv_error_id
      iv_retry_type  = /fcbp/if_glt_types=>c_retry_type-status_query ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_retry_service~request_reprocess.
    DATA(lv_type) = COND char20(
      WHEN is_request-status_query = abap_true THEN /fcbp/if_glt_types=>c_retry_type-status_query
      ELSE /fcbp/if_glt_types=>c_retry_type-reprocess ).

    rv_retry_id = schedule(
      iv_transfer_id = is_request-transfer_id
      iv_retry_type  = lv_type ).
  ENDMETHOD.

  METHOD schedule.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-repository
                  operator_text  = 'Retry service requires a repository implementation.'.
    ENDIF.

    rv_retry_id = mo_repository->insert_retry( VALUE #(
      retry_id      = |RTY-{ sy-datum }-{ sy-uzeit }|
      transfer_id   = iv_transfer_id
      attempt_no    = 1
      retry_type    = iv_retry_type
      status_code   = /fcbp/if_glt_types=>c_retry_status-due
      last_error_id = iv_error_id
      max_attempts  = 5 ) ).
  ENDMETHOD.

ENDCLASS.

