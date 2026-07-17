"! Counter helper for converting delegate outcomes into job-run results.
CLASS /fcbp/cl_glt_job_counters DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS add
      IMPORTING
        is_increment TYPE /fcbp/if_glt_job_types=>ty_job_result
      CHANGING
        cs_total     TYPE /fcbp/if_glt_job_types=>ty_job_result.

    CLASS-METHODS from_handoff_result
      IMPORTING
        is_result        TYPE /fcbp/if_glt_types=>ty_handoff_result
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_job_types=>ty_job_result.

    CLASS-METHODS derive_status
      IMPORTING
        is_context       TYPE /fcbp/if_glt_job_types=>ty_job_context
        is_result        TYPE /fcbp/if_glt_job_types=>ty_job_result
      RETURNING
        VALUE(rv_status) TYPE char12.

ENDCLASS.

CLASS /fcbp/cl_glt_job_counters IMPLEMENTATION.

  METHOD add.
    cs_total-selected_count    = cs_total-selected_count    + is_increment-selected_count.
    cs_total-claimed_count     = cs_total-claimed_count     + is_increment-claimed_count.
    cs_total-processed_count   = cs_total-processed_count   + is_increment-processed_count.
    cs_total-success_count     = cs_total-success_count     + is_increment-success_count.
    cs_total-failed_count      = cs_total-failed_count      + is_increment-failed_count.
    cs_total-skipped_count     = cs_total-skipped_count     + is_increment-skipped_count.
    cs_total-duplicate_count   = cs_total-duplicate_count   + is_increment-duplicate_count.
    cs_total-registered_count  = cs_total-registered_count  + is_increment-registered_count.
    cs_total-rescheduled_count = cs_total-rescheduled_count + is_increment-rescheduled_count.
    cs_total-no_work_count     = cs_total-no_work_count     + is_increment-no_work_count.
    cs_total-warning_count     = cs_total-warning_count     + is_increment-warning_count.
    cs_total-error_count       = cs_total-error_count       + is_increment-error_count.
    cs_total-dry_run_count     = cs_total-dry_run_count     + is_increment-dry_run_count.

    IF cs_total-message_text IS INITIAL.
      cs_total-message_text = is_increment-message_text.
    ENDIF.
  ENDMETHOD.

  METHOD from_handoff_result.
    rs_result-processed_count = 1.
    IF is_result-already_registered = abap_true.
      rs_result-duplicate_count = 1.
      rs_result-skipped_count = 1.
    ELSEIF is_result-transfer_id IS NOT INITIAL.
      rs_result-registered_count = 1.
      rs_result-success_count = 1.
    ELSE.
      rs_result-failed_count = 1.
      rs_result-error_count = 1.
    ENDIF.
    rs_result-message_text = is_result-message.
  ENDMETHOD.

  METHOD derive_status.
    IF is_result-status_code IS NOT INITIAL.
      rv_status = is_result-status_code.
      RETURN.
    ENDIF.

    IF is_context-dry_run = abap_true OR is_result-dry_run_count > 0.
      rv_status = /fcbp/if_glt_job_types=>c_job_status-dry_run.
      RETURN.
    ENDIF.

    IF is_result-selected_count = 0
       AND is_result-processed_count = 0
       AND is_result-registered_count = 0.
      rv_status = /fcbp/if_glt_job_types=>c_job_status-no_work.
      RETURN.
    ENDIF.

    IF is_result-failed_count > 0 OR is_result-error_count > 0.
      IF is_result-success_count > 0
         OR is_result-registered_count > 0
         OR is_result-skipped_count > 0
         OR is_result-rescheduled_count > 0.
        rv_status = /fcbp/if_glt_job_types=>c_job_status-partial.
      ELSE.
        rv_status = /fcbp/if_glt_job_types=>c_job_status-failed.
      ENDIF.
      RETURN.
    ENDIF.

    IF is_result-warning_count > 0
       OR is_result-skipped_count > 0
       OR is_result-rescheduled_count > 0
       OR is_result-duplicate_count > 0.
      rv_status = /fcbp/if_glt_job_types=>c_job_status-partial.
      RETURN.
    ENDIF.

    rv_status = /fcbp/if_glt_job_types=>c_job_status-success.
  ENDMETHOD.

ENDCLASS.
