"! Maps delegate exceptions and results to concise job-run status/messages.
CLASS /fcbp/cl_glt_job_message_mapper DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS map_exception
      IMPORTING
        ix_error         TYPE REF TO /fcbp/cx_glt_error
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_job_types=>ty_job_result.

    METHODS complete_result
      IMPORTING
        is_context       TYPE /fcbp/if_glt_job_types=>ty_job_context
        is_result        TYPE /fcbp/if_glt_job_types=>ty_job_result
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_job_types=>ty_job_result.

ENDCLASS.

CLASS /fcbp/cl_glt_job_message_mapper IMPLEMENTATION.

  METHOD map_exception.
    rs_result-status_code = /fcbp/if_glt_job_types=>c_job_status-failed.
    rs_result-failed_count = 1.
    rs_result-error_count = 1.
    rs_result-retryable = ix_error->retryable.

    IF ix_error->operator_text IS NOT INITIAL.
      rs_result-message_text = ix_error->operator_text.
    ELSE.
      rs_result-message_text = ix_error->get_text( ).
    ENDIF.
  ENDMETHOD.

  METHOD complete_result.
    rs_result = is_result.
    rs_result-jobrun_id = is_context-jobrun_id.
    rs_result-status_code = /fcbp/cl_glt_job_counters=>derive_status(
      is_context = is_context
      is_result  = rs_result ).

    IF rs_result-message_text IS INITIAL.
      CASE rs_result-status_code.
        WHEN /fcbp/if_glt_job_types=>c_job_status-no_work.
          rs_result-message_text = 'No eligible work was found for the job scope.'.
        WHEN /fcbp/if_glt_job_types=>c_job_status-dry_run.
          rs_result-message_text = 'Dry-run completed without productive mutations.'.
        WHEN /fcbp/if_glt_job_types=>c_job_status-partial.
          rs_result-message_text = 'Job completed with partial results.'.
        WHEN /fcbp/if_glt_job_types=>c_job_status-success.
          rs_result-message_text = 'Job completed successfully.'.
        WHEN OTHERS.
          rs_result-message_text = 'Job completed.'.
      ENDCASE.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
