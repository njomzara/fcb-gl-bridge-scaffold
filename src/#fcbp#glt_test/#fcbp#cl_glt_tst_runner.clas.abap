"! Runs the seeded Source Handoff -> Outbox -> Package -> Validation -> Mapping -> Adapter happy path.
CLASS /fcbp/cl_glt_tst_runner DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_factory TYPE REF TO /fcbp/cl_glt_tst_factory OPTIONAL.

    METHODS run_happy_path
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_tst_types=>ty_run_result
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_factory TYPE REF TO /fcbp/cl_glt_tst_factory.

    METHODS collect_result
      IMPORTING
        is_handoff       TYPE /fcbp/if_glt_types=>ty_handoff_result
        is_job_result    TYPE /fcbp/if_glt_job_types=>ty_job_result
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_tst_types=>ty_run_result.

ENDCLASS.

CLASS /fcbp/cl_glt_tst_runner IMPLEMENTATION.

  METHOD constructor.
    IF io_factory IS BOUND.
      mo_factory = io_factory.
    ELSE.
      mo_factory = NEW /fcbp/cl_glt_tst_factory( ).
    ENDIF.
  ENDMETHOD.

  METHOD run_happy_path.
    DATA(lo_store) = mo_factory->get_store( ).
    DATA(lo_seed) = mo_factory->create_seed( ).
    lo_seed->reset_and_seed_happy_path( ).

    DATA(lo_receiver) = mo_factory->create_handoff_receiver( ).
    DATA(ls_handoff) = lo_receiver->receive_scope( VALUE #(
      source_type         = /fcbp/if_glt_types=>c_source_type-recon_key
      source_reference    = /fcbp/if_glt_tst_types=>c_seed-source_reference
      source_doc_no       = /fcbp/if_glt_tst_types=>c_seed-source_doc_no
      reconciliation_key  = /fcbp/if_glt_tst_types=>c_seed-source_reference
      event_type          = /fcbp/if_glt_tst_types=>c_seed-transfer_type
      event_id            = /fcbp/if_glt_tst_types=>c_scenario-happy_recon_post
      company_code        = /fcbp/if_glt_tst_types=>c_seed-company_code
      ledger_group        = '0L'
      processing_mode     = /fcbp/if_glt_types=>c_processing_mode-realtime
      requested_by        = /fcbp/if_glt_tst_types=>c_seed-actor_id
      requested_at        = lo_store->now( )
      external_corr_id    = 'TST-HAPPY-CORR'
      source_payload_hash = 'TST-HAPPY-PAYLOAD-HASH'
      routing_hint        = 'HAPPY_PATH' ) ).

    DATA(lo_dispatcher) = mo_factory->create_dispatcher( ).
    DATA(ls_job_result) = lo_dispatcher->dispatch_due_work( VALUE #(
      jobrun_id       = lo_store->next_id( 'JOB' )
      claim_owner     = /fcbp/if_glt_tst_types=>c_seed-actor_id
      target_id       = /fcbp/if_glt_tst_types=>c_seed-target_id
      work_type       = /fcbp/if_glt_types=>c_outbox_work_type-dispatch
      processing_mode = /fcbp/if_glt_types=>c_processing_mode-realtime
      due_before      = lo_store->now( )
      max_items       = 10
      dry_run         = abap_false
      actor_id        = /fcbp/if_glt_tst_types=>c_seed-actor_id
      correlation_id  = 'TST-HAPPY-CORR' ) ).

    rs_result = collect_result(
      is_handoff    = ls_handoff
      is_job_result = ls_job_result ).
    rs_result = NEW /fcbp/cl_glt_tst_assert( )->assert_happy_path( rs_result ).
  ENDMETHOD.

  METHOD collect_result.
    DATA(lo_store) = mo_factory->get_store( ).

    rs_result = VALUE #(
      scenario_id  = /fcbp/if_glt_tst_types=>c_scenario-happy_recon_post
      transfer_id  = is_handoff-transfer_id
      message_text = is_job_result-message_text ).

    READ TABLE lo_store->mt_transfer INTO DATA(ls_transfer)
      WITH KEY header-transfer_id = is_handoff-transfer_id.
    IF sy-subrc = 0.
      rs_result-final_status = ls_transfer-header-status_code.
      rs_result-package_id = ls_transfer-header-current_package_id.
    ENDIF.

    READ TABLE lo_store->mt_outbox INTO DATA(ls_work)
      WITH KEY transfer_id = is_handoff-transfer_id.
    IF sy-subrc = 0.
      rs_result-outbox_id = ls_work-outbox_id.
      rs_result-outbox_status = ls_work-processing_status.
    ENDIF.

    READ TABLE lo_store->mt_policy_context INTO DATA(ls_context)
      WITH KEY transfer_id = is_handoff-transfer_id.
    IF sy-subrc = 0.
      rs_result-policy_context_id = ls_context-policy_context_id.
    ENDIF.

    READ TABLE lo_store->mt_validation_run INTO DATA(ls_run)
      WITH KEY transfer_id = is_handoff-transfer_id.
    IF sy-subrc = 0.
      rs_result-validation_run_id = ls_run-validation_run_id.
      rs_result-validation_status = ls_run-result_status.
    ENDIF.

    READ TABLE lo_store->mt_mapping_event INTO DATA(ls_event)
      WITH KEY transfer_id = is_handoff-transfer_id.
    IF sy-subrc = 0.
      rs_result-mapping_run_id = ls_event-mapping_event_id.
      rs_result-mapping_status = ls_event-result_status.
    ENDIF.

    READ TABLE lo_store->mt_target_doc INTO DATA(ls_target_doc)
      WITH KEY transfer_id = is_handoff-transfer_id.
    IF sy-subrc = 0.
      rs_result-target_doc_no = ls_target_doc-target_doc_no.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
