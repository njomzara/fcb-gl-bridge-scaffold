"! Test target adapter that records mock GL documents in the fixture store.
CLASS /fcbp/cl_glt_tst_target_adptr DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_transfer_adapter.

    METHODS constructor
      IMPORTING
        io_store TYPE REF TO /fcbp/cl_glt_tst_store.

  PRIVATE SECTION.
    DATA mo_store TYPE REF TO /fcbp/cl_glt_tst_store.

    METHODS append_target_doc
      IMPORTING
        is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
        is_request  TYPE /fcbp/if_glt_adapter_types=>ty_submit_request
      RETURNING
        VALUE(rs_doc) TYPE /fcbp/if_glt_tst_types=>ty_target_doc.

ENDCLASS.

CLASS /fcbp/cl_glt_tst_target_adptr IMPLEMENTATION.

  METHOD constructor.
    mo_store = io_store.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~dispatch.
    DATA(ls_doc) = append_target_doc(
      is_transfer = is_transfer
      is_request  = is_request ).

    rs_result = VALUE #(
      outcome = /fcbp/if_glt_types=>c_adapter_outcome-posted
      response_hash = |TST-RESP-{ ls_doc-target_doc_no }|
      protocol_category = /fcbp/if_glt_adapter_types=>c_protocol_category-mock
      idempotency_status = /fcbp/if_glt_adapter_types=>c_idempotency_status-accepted
      target_message_text_safe = 'Test target document posted.'
      confirmed_at = ls_doc-created_at ).
    rs_result-target_ref = VALUE #(
      transfer_id = is_transfer-header-transfer_id
      target_system = is_route-target_system
      target_adapter = is_route-target_adapter
      target_doc_no = ls_doc-target_doc_no
      target_company_code = ls_doc-company_code
      target_fiscal_year = ls_doc-fiscal_year
      target_corr_id = is_transfer-header-correlation_id
      confirmation_mode = is_route-confirmation_mode
      confirmed_at = ls_doc-created_at
      raw_ref_hash = |TST-TARGET-{ ls_doc-target_doc_no }|
      created_at = ls_doc-created_at ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~query_status.
    READ TABLE mo_store->mt_target_doc INTO DATA(ls_doc)
      WITH KEY transfer_id = is_transfer-header-transfer_id.
    IF sy-subrc = 0.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-posted.
      rs_result-target_ref = VALUE #(
        transfer_id = is_transfer-header-transfer_id
        target_system = is_route-target_system
        target_adapter = is_route-target_adapter
        target_doc_no = ls_doc-target_doc_no
        target_company_code = ls_doc-company_code
        target_fiscal_year = ls_doc-fiscal_year
        target_corr_id = is_transfer-header-correlation_id
        confirmation_mode = is_route-confirmation_mode
        confirmed_at = ls_doc-created_at ).
    ELSE.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-not_found.
      rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_business.
      rs_result-error-operator_text = 'Test target document was not found.'.
    ENDIF.
    rs_result-protocol_category = /fcbp/if_glt_adapter_types=>c_protocol_category-mock.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~cancel.
    rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-final_failure.
    rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_business.
    rs_result-error-operator_text = |Test target cancellation rejected: { iv_reason }.|.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~validate_connection.
    rs_result = VALUE #(
      target_id = is_profile-target_id
      target_adapter = is_profile-adapter_type
      destination_alias = is_profile-destination_alias
      reachable = abap_true
      health_state = /fcbp/if_glt_config_types=>c_health_state-ok
      blocking = abap_false
      finding_code = 'TST_TARGET_OK'
      operator_text = 'Test target adapter is reachable.' ).
    GET TIME STAMP FIELD rs_result-checked_at.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~get_capabilities.
    rv_capabilities = 'TEST_TARGET;SYNC_CONFIRM;IDEMPOTENCY'.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~get_capability_matrix.
    rs_capability = NEW /fcbp/cl_glt_adapter_capability( )->/fcbp/if_glt_adapter_capability~get_by_adapter_type(
      /fcbp/if_glt_adapter_types=>c_adapter_type-mock ).
  ENDMETHOD.

  METHOD append_target_doc.
    DATA(lv_package_id) = COND /fcbp/if_glt_pkg_types=>ty_package_id(
      WHEN is_request-package_id IS NOT INITIAL THEN is_request-package_id
      ELSE is_transfer-header-current_package_id ).

    READ TABLE mo_store->mt_package INTO DATA(ls_graph)
      WITH KEY package_header-package_id = lv_package_id.
    READ TABLE ls_graph-outdocs INTO DATA(ls_outdoc) INDEX 1.

    rs_doc = VALUE #(
      target_doc_no = mo_store->next_id( 'TDOC' )
      transfer_id = is_transfer-header-transfer_id
      package_id = lv_package_id
      outdoc_id = ls_outdoc-outdoc_id
      company_code = is_transfer-header-company_code
      fiscal_year = is_transfer-header-posting_date(4)
      currency = is_transfer-header-currency
      debit_amount = ls_outdoc-debit_amount
      credit_amount = ls_outdoc-credit_amount
      line_count = ls_outdoc-line_count
      target_status = /fcbp/if_glt_types=>c_status-posted
      correlation_id = is_transfer-header-correlation_id
      created_at = mo_store->now( ) ).
    APPEND rs_doc TO mo_store->mt_target_doc.
  ENDMETHOD.

ENDCLASS.
