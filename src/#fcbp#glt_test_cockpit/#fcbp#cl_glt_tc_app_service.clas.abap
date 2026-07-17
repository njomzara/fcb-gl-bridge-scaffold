"! Application service seam for cockpit actions.
"! The persistence TODOs are intentionally isolated here so the RAP handler stays thin.
CLASS /fcbp/cl_glt_tc_app_service DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS kickoff_happy_path
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_tc_types=>ty_kickoff_result
      RAISING
        /fcbp/cx_glt_error.

    METHODS refresh_run
      IMPORTING
        iv_run_id TYPE /fcbp/if_glt_tc_types=>ty_run_id
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_tc_types=>ty_kickoff_result.

  PRIVATE SECTION.
    METHODS build_run_id
      IMPORTING
        is_result        TYPE /fcbp/if_glt_tst_types=>ty_run_result
      RETURNING
        VALUE(rv_run_id) TYPE /fcbp/if_glt_tc_types=>ty_run_id.

ENDCLASS.

CLASS /fcbp/cl_glt_tc_app_service IMPLEMENTATION.

  METHOD kickoff_happy_path.
    DATA(ls_test_result) = NEW /fcbp/cl_glt_tst_runner( )->run_happy_path( ).

    rs_result = VALUE #(
      run_id        = build_run_id( ls_test_result )
      scenario_id   = ls_test_result-scenario_id
      run_status    = COND #( WHEN ls_test_result-passed = abap_true
                              THEN /fcbp/if_glt_tc_types=>c_status-passed
                              ELSE /fcbp/if_glt_tc_types=>c_status-failed )
      transfer_id   = ls_test_result-transfer_id
      package_id    = ls_test_result-package_id
      target_doc_no = ls_test_result-target_doc_no
      message_text  = ls_test_result-message_text ).

    " TODO: Persist /FCBP/GLT_TCRUN and snapshot child rows from the runner store.
    " The snapshot writer should copy seeded source rows, transfer items, outbox,
    " status/audit events, canonical lines, and mock target tree nodes in one LUW.
  ENDMETHOD.

  METHOD refresh_run.
    rs_result = VALUE #(
      run_id      = iv_run_id
      run_status  = /fcbp/if_glt_tc_types=>c_status-stale
      message_text = 'Refresh scaffold: bind to snapshot rebuild or latest persisted run state.' ).
  ENDMETHOD.

  METHOD build_run_id.
    rv_run_id = COND #(
      WHEN is_result-transfer_id IS NOT INITIAL THEN is_result-transfer_id
      ELSE |TCRUN{ sy-datum }{ sy-uzeit }| ).
  ENDMETHOD.

ENDCLASS.
