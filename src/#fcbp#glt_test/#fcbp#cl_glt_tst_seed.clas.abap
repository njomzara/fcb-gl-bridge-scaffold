"! Seeds deterministic source, config, and mock target fixture state.
CLASS /fcbp/cl_glt_tst_seed DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_store TYPE REF TO /fcbp/cl_glt_tst_store.

    METHODS reset_and_seed_happy_path.

  PRIVATE SECTION.
    DATA mo_store TYPE REF TO /fcbp/cl_glt_tst_store.

    METHODS seed_config.
    METHODS seed_source.
    METHODS add_pass_through_mapping_rule
      IMPORTING
        iv_field_name TYPE char40
        iv_priority   TYPE i.

ENDCLASS.

CLASS /fcbp/cl_glt_tst_seed IMPLEMENTATION.

  METHOD constructor.
    mo_store = io_store.
  ENDMETHOD.

  METHOD reset_and_seed_happy_path.
    mo_store->reset( ).
    seed_config( ).
    seed_source( ).
  ENDMETHOD.

  METHOD seed_config.
    DATA(lv_now) = mo_store->now( ).

    APPEND VALUE #(
      target_id = /fcbp/if_glt_tst_types=>c_seed-target_id
      target_type = /fcbp/if_glt_config_types=>c_target_type-mock
      adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-mock
      destination_alias = 'MOCK'
      transfer_mode = 'POST'
      confirmation_mode = /fcbp/if_glt_types=>c_confirmation_mode-sync_confirm
      retry_policy_id = 'TST_RETRY'
      aggregation_profile_id = 'TST_AGGR'
      split_profile_id = 'TST_SPLIT'
      validation_profile_id = 'TST_VAL'
      mapping_policy_id = 'TST_MAP'
      throttle_policy_id = 'TST_THR'
      confirmation_policy_id = 'TST_CONF'
      source_system = 'FCBP'
      source_type = /fcbp/if_glt_types=>c_source_type-recon_key
      transfer_type = /fcbp/if_glt_tst_types=>c_seed-transfer_type
      company_code = /fcbp/if_glt_tst_types=>c_seed-company_code
      processing_mode = /fcbp/if_glt_types=>c_processing_mode-realtime
      active_flag = abap_true
      lifecycle_state = /fcbp/if_glt_config_types=>c_lifecycle_state-active
      valid_from = '20260101'
      valid_to = '99991231'
      priority = 1
      health_state = /fcbp/if_glt_config_types=>c_health_state-ok
      config_version = 1
      config_hash = 'TST-TARGET-HASH'
      created_by = sy-uname
      created_at = lv_now
      changed_by = sy-uname
      changed_at = lv_now ) TO mo_store->mt_target_profile.

    APPEND VALUE #(
      retry_policy_id = 'TST_RETRY'
      version = 1
      active_flag = abap_true
      lifecycle_state = /fcbp/if_glt_config_types=>c_lifecycle_state-active
      valid_from = '20260101'
      valid_to = '99991231'
      config_hash = 'TST-RETRY-HASH'
      max_attempts = 3
      retryable_categories = 'ADAPTER_TECHNICAL'
      initial_delay_sec = 60
      max_delay_sec = 300
      backoff_model = 'FIXED'
      jitter_policy = 'NONE'
      exhaustion_behavior = 'FAIL_FINAL'
      poll_before_retry = abap_true
      changed_by = sy-uname
      changed_at = lv_now ) TO mo_store->mt_retry_policy.

    APPEND VALUE #(
      aggregation_profile_id = 'TST_AGGR'
      version = 1
      active_flag = abap_true
      lifecycle_state = /fcbp/if_glt_config_types=>c_lifecycle_state-active
      config_hash = 'TST-AGGR-HASH'
      grouping_mode = /fcbp/if_glt_pkg_types=>c_grouping_mode-none
      netting_allowed = abap_false
      source_hash_version = 'V1'
      changed_by = sy-uname
      changed_at = lv_now ) TO mo_store->mt_aggregation_policy.

    APPEND VALUE #(
      split_profile_id = 'TST_SPLIT'
      version = 1
      active_flag = abap_true
      lifecycle_state = /fcbp/if_glt_config_types=>c_lifecycle_state-active
      config_hash = 'TST-SPLIT-HASH'
      max_lines_per_doc = 999
      split_by_company_code = abap_true
      split_by_currency = abap_true
      split_by_posting_date = abap_true
      split_by_gl_doc_type = abap_true
      split_by_ledger_group = abap_true
      balance_scope = /fcbp/if_glt_pkg_types=>c_balance_scope-document
      changed_by = sy-uname
      changed_at = lv_now ) TO mo_store->mt_split_policy.

    APPEND VALUE #(
      validation_profile_id = 'TST_VAL'
      rule_id = 'TST_VAL_ACTIVE'
      version = 1
      active_flag = abap_true
      config_hash = 'TST-VAL-HASH'
      rule_category = /fcbp/if_glt_val_types=>c_category-advisory
      severity = /fcbp/if_glt_types=>c_severity-info
      blocking_flag = abap_false
      target_scope = /fcbp/if_glt_tst_types=>c_seed-target_id
      changed_by = sy-uname
      changed_at = lv_now ) TO mo_store->mt_validation_rule.

    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-company_code iv_priority = 10 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-gl_doc_type iv_priority = 20 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-ledger_group iv_priority = 30 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-reference iv_priority = 40 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-header_text iv_priority = 50 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-gl_account iv_priority = 60 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-profit_center iv_priority = 70 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-cost_center iv_priority = 80 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-segment iv_priority = 90 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-internal_order iv_priority = 100 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-trading_partner iv_priority = 110 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-tax_code iv_priority = 120 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-assignment iv_priority = 130 ).
    add_pass_through_mapping_rule( iv_field_name = /fcbp/if_glt_map_types=>c_field-item_text iv_priority = 140 ).

    APPEND VALUE #(
      throttle_policy_id = 'TST_THR'
      version = 1
      active_flag = abap_true
      lifecycle_state = /fcbp/if_glt_config_types=>c_lifecycle_state-active
      config_hash = 'TST-THR-HASH'
      max_parallel = 1
      max_per_run = 10
      rate_limit = 100
      changed_by = sy-uname
      changed_at = lv_now ) TO mo_store->mt_throttle_policy.

    APPEND VALUE #(
      confirmation_policy_id = 'TST_CONF'
      version = 1
      active_flag = abap_true
      lifecycle_state = /fcbp/if_glt_config_types=>c_lifecycle_state-active
      config_hash = 'TST-CONF-HASH'
      confirmation_mode = /fcbp/if_glt_types=>c_confirmation_mode-sync_confirm
      status_query_required = abap_false
      unknown_behavior = 'QUERY_FIRST'
      safe_retry_after_negative_query = abap_true
      changed_by = sy-uname
      changed_at = lv_now ) TO mo_store->mt_confirmation_policy.
  ENDMETHOD.

  METHOD add_pass_through_mapping_rule.
    DATA(lv_now) = mo_store->now( ).
    APPEND VALUE #(
      mapping_policy_id = 'TST_MAP'
      mapping_rule_id = |TST_MAP_{ iv_priority }|
      version = 1
      active_flag = abap_true
      config_hash = |TST-MAP-HASH-{ iv_priority }|
      field_name = iv_field_name
      decision_type = /fcbp/if_glt_map_types=>c_decision_type-pass_through
      pass_through_allowed = abap_true
      priority = iv_priority
      changed_by = sy-uname
      changed_at = lv_now ) TO mo_store->mt_mapping_rule.
  ENDMETHOD.

  METHOD seed_source.
    DATA(lv_now) = mo_store->now( ).
    DATA(lv_reference) = /fcbp/if_glt_tst_types=>c_seed-source_reference.

    APPEND VALUE #(
      reconciliation_key = lv_reference
      source_reference = lv_reference
      source_snapshot_id = 'TST-SNAPSHOT-0001'
      source_status = 'CLOSED'
      closed_flag = abap_true
      frozen_flag = abap_true
      immutable_flag = abap_true
      company_code = /fcbp/if_glt_tst_types=>c_seed-company_code
      currency = /fcbp/if_glt_tst_types=>c_seed-currency
      item_count = 2
      control_hash = 'TST-SOURCE-CONTROL' ) TO mo_store->mt_recon_header.

    APPEND VALUE #(
      source_type = /fcbp/if_glt_src_types=>c_source_type-reconciliation_key
      source_reference = lv_reference
      source_doc_no = /fcbp/if_glt_tst_types=>c_seed-source_doc_no
      source_item_no = '000001'
      reconciliation_key = lv_reference
      routing_bucket = 'TST-1000-REALTIME'
      source_snapshot_id = 'TST-SNAPSHOT-0001'
      immutable_source_hash = 'TST-SOURCE-LINE-0001'
      source_status = 'CLOSED'
      company_code = /fcbp/if_glt_tst_types=>c_seed-company_code
      chart_of_accounts = 'FCBP'
      gl_account = '0000400000'
      amount = '100.00'
      currency = /fcbp/if_glt_tst_types=>c_seed-currency
      debit_credit = 'S'
      posting_date = '20260101'
      document_type = 'SA'
      ledger_group = '0L'
      item_text = 'Test debit source line' ) TO mo_store->mt_source_item.

    APPEND VALUE #(
      source_type = /fcbp/if_glt_src_types=>c_source_type-reconciliation_key
      source_reference = lv_reference
      source_doc_no = /fcbp/if_glt_tst_types=>c_seed-source_doc_no
      source_item_no = '000002'
      reconciliation_key = lv_reference
      routing_bucket = 'TST-1000-REALTIME'
      source_snapshot_id = 'TST-SNAPSHOT-0001'
      immutable_source_hash = 'TST-SOURCE-LINE-0002'
      source_status = 'CLOSED'
      company_code = /fcbp/if_glt_tst_types=>c_seed-company_code
      chart_of_accounts = 'FCBP'
      gl_account = '0000200000'
      amount = '100.00'
      currency = /fcbp/if_glt_tst_types=>c_seed-currency
      debit_credit = 'H'
      posting_date = '20260101'
      document_type = 'SA'
      ledger_group = '0L'
      item_text = 'Test credit source line' ) TO mo_store->mt_source_item.
  ENDMETHOD.

ENDCLASS.
