"! Default job-run recorder through the Monitoring repository seam.
CLASS /fcbp/cl_glt_job_run_recorder DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_job_run_recorder.

    METHODS constructor
      IMPORTING
        io_repo TYPE REF TO /fcbp/if_glt_monitor_repo OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repo TYPE REF TO /fcbp/if_glt_monitor_repo.

    METHODS ensure_repo
      RAISING
        /fcbp/cx_glt_error.

    METHODS create_jobrun_id
      RETURNING
        VALUE(rv_jobrun_id) TYPE /fcbp/if_glt_types=>ty_jobrun_id
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_job_run_recorder IMPLEMENTATION.

  METHOD constructor.
    IF io_repo IS BOUND.
      mo_repo = io_repo.
    ELSE.
      mo_repo = NEW /fcbp/cl_glt_monitor_repo( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_job_run_recorder~start_run.
    ensure_repo( ).

    DATA(lv_now) = VALUE utclong( ).
    GET TIME STAMP FIELD lv_now.

    DATA(ls_jobrun) = VALUE /fcbp/if_glt_types=>ty_jobrun(
      jobrun_id      = create_jobrun_id( )
      job_name       = is_context-job_name
      job_type       = is_context-job_type
      status_code    = /fcbp/if_glt_job_types=>c_job_status-running
      target_id      = is_context-target_id
      actor_id       = is_context-actor_id
      message_text   = 'Job run started.'
      started_at     = lv_now ).

    IF ls_jobrun-job_name IS INITIAL.
      ls_jobrun-job_name = ls_jobrun-job_type.
    ENDIF.

    rv_jobrun_id = mo_repo->insert_jobrun( ls_jobrun ).
    IF rv_jobrun_id IS INITIAL.
      rv_jobrun_id = ls_jobrun-jobrun_id.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_job_run_recorder~finish_run.
    ensure_repo( ).

    DATA(lv_now) = VALUE utclong( ).
    GET TIME STAMP FIELD lv_now.

    DATA(ls_jobrun) = VALUE /fcbp/if_glt_types=>ty_jobrun(
      jobrun_id       = iv_jobrun_id
      status_code     = is_result-status_code
      selected_count  = is_result-selected_count
      processed_count = is_result-processed_count
      success_count   = is_result-success_count
      failed_count    = is_result-failed_count
      message_text    = is_result-message_text
      finished_at     = lv_now ).

    IF ls_jobrun-status_code IS INITIAL.
      ls_jobrun-status_code = /fcbp/if_glt_job_types=>c_job_status-success.
    ENDIF.

    mo_repo->update_jobrun( ls_jobrun ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_job_run_recorder~fail_run.
    ensure_repo( ).

    DATA(ls_failure) = is_failure.
    IF ls_failure-status_code IS INITIAL.
      ls_failure-status_code = /fcbp/if_glt_job_types=>c_job_status-failed.
    ENDIF.
    IF ls_failure-failed_count IS INITIAL.
      ls_failure-failed_count = 1.
    ENDIF.

    /fcbp/if_glt_job_run_recorder~finish_run(
      iv_jobrun_id = iv_jobrun_id
      is_result    = ls_failure ).
  ENDMETHOD.

  METHOD ensure_repo.
    IF mo_repo IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Job-run recorder requires a monitor repository.'.
    ENDIF.
  ENDMETHOD.

  METHOD create_jobrun_id.
    TRY.
        rv_jobrun_id = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error INTO DATA(lx_uuid).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_error
          EXPORTING
            error_category      = /fcbp/if_glt_types=>c_error_category-technical
            operator_text       = 'Job-run UUID generation failed.'
            technical_reference = lx_uuid->get_text( ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
