"! Assertion helper for seeded happy-path executions.
CLASS /fcbp/cl_glt_tst_assert DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS assert_happy_path
      IMPORTING
        is_result        TYPE /fcbp/if_glt_tst_types=>ty_run_result
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_tst_types=>ty_run_result
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    METHODS fail
      IMPORTING
        iv_text TYPE char220
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_tst_assert IMPLEMENTATION.

  METHOD assert_happy_path.
    rs_result = is_result.

    IF rs_result-transfer_id IS INITIAL.
      fail( 'Happy-path run did not create a transfer.' ).
    ENDIF.

    IF rs_result-outbox_id IS INITIAL.
      fail( 'Happy-path run did not create dispatch outbox work.' ).
    ENDIF.

    IF rs_result-package_id IS INITIAL.
      fail( 'Happy-path run did not create package evidence.' ).
    ENDIF.

    IF rs_result-policy_context_id IS INITIAL.
      fail( 'Happy-path run did not persist policy-context evidence.' ).
    ENDIF.

    IF rs_result-validation_run_id IS INITIAL OR
       rs_result-validation_status <> /fcbp/if_glt_val_types=>c_run_status-passed.
      fail( 'Happy-path run did not pass package validation.' ).
    ENDIF.

    IF rs_result-mapping_status <> /fcbp/if_glt_map_types=>c_result_status-mapped.
      fail( 'Happy-path run did not create successful mapping evidence.' ).
    ENDIF.

    IF rs_result-target_doc_no IS INITIAL.
      fail( 'Happy-path run did not post a mock target GL document.' ).
    ENDIF.

    IF rs_result-final_status <> /fcbp/if_glt_types=>c_status-posted.
      fail( |Happy-path final status is { rs_result-final_status }, expected POSTED.| ).
    ENDIF.

    IF rs_result-outbox_status <> /fcbp/if_glt_types=>c_outbox_status-done.
      fail( |Happy-path outbox status is { rs_result-outbox_status }, expected DONE.| ).
    ENDIF.

    rs_result-passed = abap_true.
    IF rs_result-message_text IS INITIAL.
      rs_result-message_text = 'Happy-path scaffold completed successfully.'.
    ENDIF.
  ENDMETHOD.

  METHOD fail.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-validation
        operator_text  = iv_text.
  ENDMETHOD.

ENDCLASS.
