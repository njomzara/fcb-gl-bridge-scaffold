"! Shared fixture repository implementing the GLT persistence seams for tests.
CLASS /fcbp/cl_glt_tst_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_repository.
    INTERFACES /fcbp/if_glt_handoff_repo.
    INTERFACES /fcbp/if_glt_outbox_repo.
    INTERFACES /fcbp/if_glt_config_repo.
    INTERFACES /fcbp/if_glt_src_repo.
    INTERFACES /fcbp/if_glt_package_repo.
    INTERFACES /fcbp/if_glt_val_repo.
    INTERFACES /fcbp/if_glt_map_repo.
    INTERFACES /fcbp/if_glt_monitor_repo.
    INTERFACES /fcbp/if_glt_audit_repo.

    METHODS constructor
      IMPORTING
        io_store TYPE REF TO /fcbp/cl_glt_tst_store OPTIONAL.

    METHODS get_store
      RETURNING
        VALUE(ro_store) TYPE REF TO /fcbp/cl_glt_tst_store.

  PRIVATE SECTION.
    DATA mo_store TYPE REF TO /fcbp/cl_glt_tst_store.

    METHODS find_transfer
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
      RETURNING
        VALUE(rv_index) TYPE sy-tabix.

    METHODS ensure_outbox_id
      CHANGING
        cs_work TYPE /fcbp/if_glt_types=>ty_outbox_work.

    METHODS ensure_audit_id
      CHANGING
        cs_event TYPE /fcbp/if_glt_types=>ty_audit_event.

ENDCLASS.

CLASS /fcbp/cl_glt_tst_repo IMPLEMENTATION.

  METHOD constructor.
    IF io_store IS BOUND.
      mo_store = io_store.
    ELSE.
      mo_store = NEW /fcbp/cl_glt_tst_store( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_store.
    ro_store = mo_store.
  ENDMETHOD.

  METHOD find_transfer.
    LOOP AT mo_store->mt_transfer INTO DATA(ls_transfer).
      IF ls_transfer-header-transfer_id = iv_transfer_id.
        rv_index = sy-tabix.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD ensure_outbox_id.
    IF cs_work-outbox_id IS INITIAL.
      cs_work-outbox_id = mo_store->next_id( 'OBX' ).
    ENDIF.
    IF cs_work-created_at IS INITIAL.
      cs_work-created_at = mo_store->now( ).
    ENDIF.
    IF cs_work-created_by IS INITIAL.
      cs_work-created_by = sy-uname.
    ENDIF.
  ENDMETHOD.

  METHOD ensure_audit_id.
    IF cs_event-audit_id IS INITIAL.
      cs_event-audit_id = mo_store->next_id( 'AUD' ).
    ENDIF.
    IF cs_event-created_at IS INITIAL.
      cs_event-created_at = mo_store->now( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~create_transfer.
    DATA(ls_transfer) = VALUE /fcbp/if_glt_types=>ty_transfer(
      header = is_header
      items  = it_item ).
    IF ls_transfer-header-transfer_id IS INITIAL.
      ls_transfer-header-transfer_id = mo_store->next_id( 'TRF' ).
    ENDIF.
    rv_transfer_id = ls_transfer-header-transfer_id.
    LOOP AT ls_transfer-items ASSIGNING FIELD-SYMBOL(<ls_item>).
      <ls_item>-transfer_id = rv_transfer_id.
    ENDLOOP.
    APPEND ls_transfer TO mo_store->mt_transfer.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~read_transfer.
    DATA(lv_index) = find_transfer( iv_transfer_id ).
    IF lv_index > 0.
      READ TABLE mo_store->mt_transfer INTO rs_transfer INDEX lv_index.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~update_header.
    DATA(lv_index) = find_transfer( is_header-transfer_id ).
    IF lv_index > 0.
      READ TABLE mo_store->mt_transfer ASSIGNING FIELD-SYMBOL(<ls_transfer>) INDEX lv_index.
      <ls_transfer>-header = is_header.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_status.
    DATA(lv_index) = find_transfer( is_status-transfer_id ).
    IF lv_index > 0.
      READ TABLE mo_store->mt_transfer ASSIGNING FIELD-SYMBOL(<ls_transfer>) INDEX lv_index.
      APPEND is_status TO <ls_transfer>-statuses.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_error.
    rv_error_id = is_error-error_id.
    IF rv_error_id IS INITIAL.
      rv_error_id = mo_store->next_id( 'ERR' ).
    ENDIF.
    DATA(lv_index) = find_transfer( is_error-transfer_id ).
    IF lv_index > 0.
      DATA(ls_error) = is_error.
      ls_error-error_id = rv_error_id.
      READ TABLE mo_store->mt_transfer ASSIGNING FIELD-SYMBOL(<ls_transfer>) INDEX lv_index.
      APPEND ls_error TO <ls_transfer>-errors.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~reserve_idempotency.
    rs_decision = VALUE #(
      decision = /fcbp/if_glt_types=>c_idemp_decision-created
      idempotency_key = is_reservation-idempotency_key
      transfer_id = is_reservation-transfer_id
      status_code = /fcbp/if_glt_types=>c_status-received
      external_status = /fcbp/if_glt_types=>c_ext_status-received ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~confirm_idempotency.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_retry.
    rv_retry_id = is_retry-retry_id.
    IF rv_retry_id IS INITIAL.
      rv_retry_id = mo_store->next_id( 'RTY' ).
    ENDIF.
    DATA(ls_retry) = is_retry.
    ls_retry-retry_id = rv_retry_id.
    APPEND ls_retry TO mo_store->mt_retry.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_target_ref.
    rv_ref_id = is_target_ref-ref_id.
    IF rv_ref_id IS INITIAL.
      rv_ref_id = mo_store->next_id( 'REF' ).
    ENDIF.
    DATA(ls_ref) = is_target_ref.
    ls_ref-ref_id = rv_ref_id.
    DATA(lv_index) = find_transfer( ls_ref-transfer_id ).
    IF lv_index > 0.
      READ TABLE mo_store->mt_transfer ASSIGNING FIELD-SYMBOL(<ls_transfer>) INDEX lv_index.
      APPEND ls_ref TO <ls_transfer>-target_refs.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~read_config.
    rs_config = VALUE #(
      transfer_type = iv_transfer_type
      active = abap_true
      balance_required = abap_true
      period_check_mode = 'NONE'
      default_max_retry = 3
      default_backoff_sec = 60
      allow_manual_reprocess = abap_true
      valid_from = '20260101'
      valid_to = '99991231'
      changed_by = sy-uname
      changed_at = mo_store->now( ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~resolve_route.
    rs_route = VALUE #(
      route_id = 'TST_ROUTE'
      transfer_type = is_header-transfer_type
      source_system = is_header-source_system
      company_code = is_header-company_code
      target_system = /fcbp/if_glt_tst_types=>c_seed-target_id
      target_adapter = /fcbp/if_glt_adapter_types=>c_adapter_type-mock
      priority = 1
      active = abap_true
      confirmation_mode = /fcbp/if_glt_types=>c_confirmation_mode-sync_confirm
      retry_profile = 'TST_RETRY'
      feature_switch_set = 'MOCK_POSTED'
      valid_from = '20260101'
      valid_to = '99991231'
      changed_by = sy-uname
      changed_at = mo_store->now( ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~query_reconciliation.
    rt_transfer = mo_store->mt_transfer.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~try_reserve_reg.
    READ TABLE mo_store->mt_registration INTO DATA(ls_existing)
      WITH KEY registration_key = is_registration-registration_key.
    IF sy-subrc = 0.
      rs_decision = VALUE #(
        decision = /fcbp/if_glt_types=>c_reg_status-duplicate
        registration_key = ls_existing-registration_key
        transfer_id = ls_existing-transfer_id
        registration_status = ls_existing-registration_status
        already_registered = abap_true
        message = 'Test registration already exists.' ).
      RETURN.
    ENDIF.

    DATA(ls_registration) = is_registration.
    IF ls_registration-reserved_at IS INITIAL.
      ls_registration-reserved_at = mo_store->now( ).
    ENDIF.
    APPEND ls_registration TO mo_store->mt_registration.
    rs_decision = VALUE #(
      decision = /fcbp/if_glt_types=>c_reg_status-reserved
      registration_key = ls_registration-registration_key
      registration_status = /fcbp/if_glt_types=>c_reg_status-reserved ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~read_reg.
    READ TABLE mo_store->mt_registration INTO rs_registration
      WITH KEY registration_key = iv_registration_key.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~create_transfer_root.
    DATA(ls_transfer) = VALUE /fcbp/if_glt_types=>ty_transfer( header = is_header ).
    APPEND ls_transfer TO mo_store->mt_transfer.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~insert_initial_status.
    /fcbp/if_glt_repository~insert_status( is_status ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~insert_outbox_work.
    DATA(ls_work) = is_work.
    ensure_outbox_id( CHANGING cs_work = ls_work ).
    rv_outbox_id = ls_work-outbox_id.
    APPEND ls_work TO mo_store->mt_outbox.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~write_audit_event.
    DATA(ls_event) = is_event.
    ensure_audit_id( CHANGING cs_event = ls_event ).
    rv_audit_id = ls_event-audit_id.
    APPEND ls_event TO mo_store->mt_audit.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~activate_reg.
    READ TABLE mo_store->mt_registration ASSIGNING FIELD-SYMBOL(<ls_reg>)
      WITH KEY registration_key = iv_registration_key.
    IF sy-subrc = 0.
      <ls_reg>-transfer_id = iv_transfer_id.
      <ls_reg>-registration_status = /fcbp/if_glt_types=>c_reg_status-active.
      <ls_reg>-completed_at = mo_store->now( ).
      <ls_reg>-changed_at = mo_store->now( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~mark_reg_failed.
    READ TABLE mo_store->mt_registration ASSIGNING FIELD-SYMBOL(<ls_reg>)
      WITH KEY registration_key = iv_registration_key.
    IF sy-subrc = 0.
      <ls_reg>-registration_status = /fcbp/if_glt_types=>c_reg_status-failed.
      <ls_reg>-last_error_code = iv_reason.
      <ls_reg>-changed_at = mo_store->now( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~select_due_work.
    LOOP AT mo_store->mt_outbox INTO DATA(ls_work)
      WHERE processing_status = /fcbp/if_glt_types=>c_outbox_status-open.
      IF is_context-work_type IS NOT INITIAL AND ls_work-work_type <> is_context-work_type.
        CONTINUE.
      ENDIF.
      IF is_context-target_id IS NOT INITIAL AND ls_work-target_id <> is_context-target_id.
        CONTINUE.
      ENDIF.
      IF is_context-due_before IS NOT INITIAL AND ls_work-due_at > is_context-due_before.
        CONTINUE.
      ENDIF.
      APPEND ls_work TO rt_work.
      IF is_context-max_items > 0 AND lines( rt_work ) >= is_context-max_items.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~claim_work.
    READ TABLE mo_store->mt_outbox ASSIGNING FIELD-SYMBOL(<ls_work>)
      WITH KEY outbox_id = iv_outbox_id.
    IF sy-subrc = 0 AND <ls_work>-processing_status = /fcbp/if_glt_types=>c_outbox_status-open.
      <ls_work>-processing_status = /fcbp/if_glt_types=>c_outbox_status-in_process.
      <ls_work>-lock_status = /fcbp/if_glt_types=>c_lock_status-locked.
      <ls_work>-lock_owner = iv_claim_owner.
      <ls_work>-locked_at = mo_store->now( ).
      <ls_work>-lock_until = iv_lock_until.
      rs_claim = VALUE #(
        claimed = abap_true
        outbox_id = iv_outbox_id
        work = <ls_work>
        claim_owner = iv_claim_owner
        claim_token = iv_claim_owner ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~complete_work.
    READ TABLE mo_store->mt_outbox ASSIGNING FIELD-SYMBOL(<ls_work>)
      WITH KEY outbox_id = iv_outbox_id.
    IF sy-subrc = 0.
      <ls_work>-processing_status = /fcbp/if_glt_types=>c_outbox_status-done.
      <ls_work>-lock_status = /fcbp/if_glt_types=>c_lock_status-free.
      CLEAR: <ls_work>-lock_owner, <ls_work>-lock_until.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~fail_work.
    READ TABLE mo_store->mt_outbox ASSIGNING FIELD-SYMBOL(<ls_work>)
      WITH KEY outbox_id = iv_outbox_id.
    IF sy-subrc = 0.
      <ls_work>-processing_status = /fcbp/if_glt_types=>c_outbox_status-failed.
      <ls_work>-lock_status = /fcbp/if_glt_types=>c_lock_status-free.
      CLEAR: <ls_work>-lock_owner, <ls_work>-lock_until.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~release_work.
    READ TABLE mo_store->mt_outbox ASSIGNING FIELD-SYMBOL(<ls_work>)
      WITH KEY outbox_id = iv_outbox_id.
    IF sy-subrc = 0.
      <ls_work>-processing_status = /fcbp/if_glt_types=>c_outbox_status-open.
      <ls_work>-lock_status = /fcbp/if_glt_types=>c_lock_status-free.
      CLEAR: <ls_work>-lock_owner, <ls_work>-lock_until.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~supersede_work.
    READ TABLE mo_store->mt_outbox ASSIGNING FIELD-SYMBOL(<ls_work>)
      WITH KEY outbox_id = iv_outbox_id.
    IF sy-subrc = 0.
      <ls_work>-processing_status = /fcbp/if_glt_types=>c_outbox_status-superseded.
      <ls_work>-lock_status = /fcbp/if_glt_types=>c_lock_status-free.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~enqueue_work.
    DATA(ls_work) = is_work.
    ensure_outbox_id( CHANGING cs_work = ls_work ).
    rv_outbox_id = ls_work-outbox_id.
    APPEND ls_work TO mo_store->mt_outbox.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~recover_expired_locks.
    LOOP AT mo_store->mt_outbox ASSIGNING FIELD-SYMBOL(<ls_work>)
      WHERE lock_status = /fcbp/if_glt_types=>c_lock_status-locked.
      IF <ls_work>-lock_until <= is_request-lock_expired_before.
        <ls_work>-processing_status = /fcbp/if_glt_types=>c_outbox_status-open.
        <ls_work>-lock_status = /fcbp/if_glt_types=>c_lock_status-free.
        CLEAR <ls_work>-lock_owner.
        rs_result-released_count = rs_result-released_count + 1.
      ENDIF.
    ENDLOOP.
    rs_result-selected_count = rs_result-released_count.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~query_target_profiles.
    LOOP AT mo_store->mt_target_profile INTO DATA(ls_profile)
      WHERE active_flag = abap_true.
      IF is_scope-company_code IS NOT INITIAL AND ls_profile-company_code IS NOT INITIAL AND ls_profile-company_code <> is_scope-company_code.
        CONTINUE.
      ENDIF.
      IF is_scope-source_type IS NOT INITIAL AND ls_profile-source_type IS NOT INITIAL AND ls_profile-source_type <> is_scope-source_type.
        CONTINUE.
      ENDIF.
      IF is_scope-processing_mode IS NOT INITIAL AND ls_profile-processing_mode IS NOT INITIAL AND ls_profile-processing_mode <> is_scope-processing_mode.
        CONTINUE.
      ENDIF.
      APPEND ls_profile TO rt_profile.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_target_profile.
    READ TABLE mo_store->mt_target_profile INTO rs_profile
      WITH KEY target_id = iv_target_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_retry_policy.
    READ TABLE mo_store->mt_retry_policy INTO rs_policy
      WITH KEY retry_policy_id = iv_policy_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_aggregation_policy.
    READ TABLE mo_store->mt_aggregation_policy INTO rs_policy
      WITH KEY aggregation_profile_id = iv_profile_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_aggregation_fields.
    LOOP AT mo_store->mt_aggregation_field INTO DATA(ls_field)
      WHERE aggregation_profile_id = iv_profile_id.
      APPEND ls_field TO rt_field.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_split_policy.
    READ TABLE mo_store->mt_split_policy INTO rs_policy
      WITH KEY split_profile_id = iv_profile_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_validation_rules.
    LOOP AT mo_store->mt_validation_rule INTO DATA(ls_rule)
      WHERE validation_profile_id = iv_profile_id.
      APPEND ls_rule TO rt_rule.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_mapping_rules.
    LOOP AT mo_store->mt_mapping_rule INTO DATA(ls_rule)
      WHERE mapping_policy_id = iv_policy_id.
      APPEND ls_rule TO rt_rule.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_throttle_policy.
    READ TABLE mo_store->mt_throttle_policy INTO rs_policy
      WITH KEY throttle_policy_id = iv_policy_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_confirmation_policy.
    READ TABLE mo_store->mt_confirmation_policy INTO rs_policy
      WITH KEY confirmation_policy_id = iv_policy_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~insert_policy_context.
    DATA(ls_context) = is_context.
    IF ls_context-policy_context_id IS INITIAL.
      ls_context-policy_context_id = mo_store->next_id( 'PCTX' ).
    ENDIF.
    rv_context_id = ls_context-policy_context_id.
    APPEND ls_context TO mo_store->mt_policy_context.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_policy_context.
    READ TABLE mo_store->mt_policy_context INTO rs_context
      WITH KEY policy_context_id = iv_context_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~insert_health_finding.
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_repo~read_recon_header.
    READ TABLE mo_store->mt_recon_header INTO rs_header
      WITH KEY reconciliation_key = iv_reconciliation_key.
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_repo~read_recon_items.
    LOOP AT mo_store->mt_source_item INTO DATA(ls_item)
      WHERE reconciliation_key = iv_reconciliation_key.
      APPEND ls_item TO rt_item.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_repo~read_document_header.
    READ TABLE mo_store->mt_doc_header INTO rs_header
      WITH KEY source_reference = iv_source_reference.
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_repo~read_document_items.
    LOOP AT mo_store->mt_source_item INTO DATA(ls_item)
      WHERE source_reference = iv_source_reference.
      APPEND ls_item TO rt_item.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~persist_graph.
    DATA(ls_graph) = is_graph.
    APPEND ls_graph TO mo_store->mt_package.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~publish_current.
    DATA(lv_transfer_index) = find_transfer( iv_transfer_id ).
    IF lv_transfer_index = 0.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_repository
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = |Transfer { iv_transfer_id } was not found for package publication.|.
    ENDIF.

    READ TABLE mo_store->mt_transfer ASSIGNING FIELD-SYMBOL(<ls_transfer>) INDEX lv_transfer_index.
    IF <ls_transfer>-header-current_package_id IS NOT INITIAL
       AND <ls_transfer>-header-current_package_id <> iv_expected_current_package_id
       AND <ls_transfer>-header-current_package_id <> iv_package_id.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_repository
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-conflict
          operator_text  = |Transfer current package changed from expected { iv_expected_current_package_id } to { <ls_transfer>-header-current_package_id }.|.
    ENDIF.

    READ TABLE mo_store->mt_package ASSIGNING FIELD-SYMBOL(<ls_target_graph>)
      WITH KEY package_header-package_id = iv_package_id.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_repository
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = |Package { iv_package_id } does not belong to transfer { iv_transfer_id }.|.
    ENDIF.

    IF <ls_target_graph>-package_header-transfer_id <> iv_transfer_id.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_repository
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = |Package { iv_package_id } does not belong to transfer { iv_transfer_id }.|.
    ENDIF.

    IF <ls_target_graph>-package_header-package_id <> iv_expected_current_package_id
       AND <ls_target_graph>-package_header-predecessor_package_id IS NOT INITIAL
       AND <ls_target_graph>-package_header-predecessor_package_id <> iv_expected_current_package_id.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_repository
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-conflict
          operator_text  = |Package { iv_package_id } does not follow expected predecessor { iv_expected_current_package_id }.|.
    ENDIF.

    LOOP AT mo_store->mt_package ASSIGNING FIELD-SYMBOL(<ls_graph>)
      WHERE package_header-transfer_id = iv_transfer_id.
      <ls_graph>-package_header-current_flag = abap_false.
      IF <ls_graph>-package_header-package_id <> iv_package_id.
        <ls_graph>-package_header-package_status = /fcbp/if_glt_pkg_types=>c_package_status-superseded.
        <ls_graph>-package_header-superseded_by_package_id = iv_package_id.
      ENDIF.
      IF <ls_graph>-package_header-package_id = iv_package_id.
        <ls_graph>-package_header-current_flag = abap_true.
        <ls_graph>-package_header-package_status = /fcbp/if_glt_pkg_types=>c_package_status-current.
        CLEAR <ls_graph>-package_header-superseded_by_package_id.
      ENDIF.
    ENDLOOP.

    <ls_transfer>-header-current_package_id = iv_package_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~read_package.
    READ TABLE mo_store->mt_package INTO rs_graph
      WITH KEY package_header-package_id = iv_package_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~read_current_package.
    LOOP AT mo_store->mt_package INTO DATA(ls_graph)
      WHERE package_header-transfer_id = iv_transfer_id
        AND package_header-current_flag = abap_true.
      IF rs_graph-package_header-package_id IS INITIAL OR
         ls_graph-package_header-package_version > rs_graph-package_header-package_version.
        rs_graph = ls_graph.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~check_consistency.
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_repo~create_run.
    DATA(ls_run) = is_run.
    IF ls_run-validation_run_id IS INITIAL.
      ls_run-validation_run_id = mo_store->next_id( 'VAL' ).
    ENDIF.
    rv_run_id = ls_run-validation_run_id.
    APPEND ls_run TO mo_store->mt_validation_run.
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_repo~insert_findings.
    APPEND LINES OF it_finding TO mo_store->mt_validation_finding.
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_repo~close_run.
    READ TABLE mo_store->mt_validation_run ASSIGNING FIELD-SYMBOL(<ls_run>)
      WITH KEY validation_run_id = is_result-validation_run_id.
    IF sy-subrc = 0.
      <ls_run>-result_status = is_result-result_status.
      <ls_run>-blocking_count = is_result-blocking_count.
      <ls_run>-warning_count = is_result-warning_count.
      <ls_run>-ended_at = mo_store->now( ).
      <ls_run>-changed_at = <ls_run>-ended_at.
      <ls_run>-changed_by = sy-uname.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_repo~read_latest_run.
    LOOP AT mo_store->mt_validation_run INTO DATA(ls_run)
      WHERE package_id = iv_package_id.
      rs_run = ls_run.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_map_repo~insert_events.
    APPEND LINES OF it_event TO mo_store->mt_mapping_event.
  ENDMETHOD.

  METHOD /fcbp/if_glt_map_repo~read_events_for_package.
    LOOP AT mo_store->mt_mapping_event INTO DATA(ls_event)
      WHERE package_id = iv_package_id.
      APPEND ls_event TO rt_event.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_map_repo~mark_superseded.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~read_transfer.
    rs_transfer = /fcbp/if_glt_repository~read_transfer( iv_transfer_id ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~query_monitor.
    rt_transfer = mo_store->mt_transfer.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_error.
    rv_error_id = /fcbp/if_glt_repository~insert_error( is_error ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_message.
    rv_message_id = is_message-message_id.
    IF rv_message_id IS INITIAL.
      rv_message_id = mo_store->next_id( 'MSG' ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_target_ref.
    rv_ref_id = /fcbp/if_glt_repository~insert_target_ref( is_target_ref ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_attempt.
    rv_attempt_id = is_attempt-attempt_id.
    IF rv_attempt_id IS INITIAL.
      rv_attempt_id = mo_store->next_id( 'ATT' ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_jobrun.
    DATA(ls_jobrun) = is_jobrun.
    IF ls_jobrun-jobrun_id IS INITIAL.
      ls_jobrun-jobrun_id = mo_store->next_id( 'JOB' ).
    ENDIF.
    rv_jobrun_id = ls_jobrun-jobrun_id.
    APPEND ls_jobrun TO mo_store->mt_jobrun.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~update_jobrun.
    READ TABLE mo_store->mt_jobrun ASSIGNING FIELD-SYMBOL(<ls_jobrun>)
      WITH KEY jobrun_id = is_jobrun-jobrun_id.
    IF sy-subrc = 0.
      <ls_jobrun>-status_code = is_jobrun-status_code.
      <ls_jobrun>-selected_count = is_jobrun-selected_count.
      <ls_jobrun>-processed_count = is_jobrun-processed_count.
      <ls_jobrun>-success_count = is_jobrun-success_count.
      <ls_jobrun>-failed_count = is_jobrun-failed_count.
      <ls_jobrun>-message_text = is_jobrun-message_text.
      <ls_jobrun>-finished_at = is_jobrun-finished_at.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_outbox_work.
    rv_outbox_id = /fcbp/if_glt_outbox_repo~enqueue_work( is_work ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~cancel_open_work.
    LOOP AT mo_store->mt_outbox ASSIGNING FIELD-SYMBOL(<ls_work>)
      WHERE transfer_id = iv_transfer_id
        AND processing_status = /fcbp/if_glt_types=>c_outbox_status-open.
      <ls_work>-processing_status = /fcbp/if_glt_types=>c_outbox_status-cancelled.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~has_started_attempt.
    rv_found = abap_false.
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~write_audit_event.
    DATA(ls_event) = is_event.
    ensure_audit_id( CHANGING cs_event = ls_event ).
    rv_audit_id = ls_event-audit_id.
    APPEND ls_event TO mo_store->mt_audit.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_repo~insert_audit_event.
    DATA(ls_event) = is_event.
    ensure_audit_id( CHANGING cs_event = ls_event ).
    rv_audit_id = ls_event-audit_id.
    APPEND ls_event TO mo_store->mt_audit.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_repo~query_audit.
    rt_event = mo_store->mt_audit.
  ENDMETHOD.

ENDCLASS.
