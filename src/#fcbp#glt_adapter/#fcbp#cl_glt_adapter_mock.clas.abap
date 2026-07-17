"! Mock downstream adapter for ABAP Unit and local POC flows.
CLASS /fcbp/cl_glt_adapter_mock DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_transfer_adapter.

  PRIVATE SECTION.
    DATA mv_query_count TYPE i.

    METHODS resolve_scenario
      IMPORTING
        iv_route_switch TYPE char80 OPTIONAL
        iv_correlation  TYPE /fcbp/if_glt_types=>ty_correlation_id OPTIONAL
        iv_requested    TYPE char30 OPTIONAL
      RETURNING
        VALUE(rv_scenario) TYPE char30.

ENDCLASS.

CLASS /fcbp/cl_glt_adapter_mock IMPLEMENTATION.

  METHOD /fcbp/if_glt_transfer_adapter~dispatch.
    DATA(lv_scenario) = resolve_scenario(
      iv_route_switch = is_route-feature_switch_set
      iv_correlation  = is_transfer-header-correlation_id
      iv_requested    = is_request-mock_scenario ).

    rs_result-target_ref-transfer_id    = is_transfer-header-transfer_id.
    rs_result-target_ref-target_system  = is_route-target_system.
    rs_result-target_ref-target_adapter = is_route-target_adapter.
    rs_result-target_ref-target_corr_id = is_transfer-header-correlation_id.
    rs_result-response_hash             = |MOCKRESP-{ sy-datum }-{ sy-uzeit }|.
    rs_result-protocol_category         = /fcbp/if_glt_adapter_types=>c_protocol_category-mock.
    rs_result-idempotency_status        = /fcbp/if_glt_adapter_types=>c_idempotency_status-accepted.
    rs_result-capability_used           = 'MOCK;IDEMPOTENCY;CORRELATION'.

    IF lv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-unknown_confirmation
       OR lv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-timeout_after_send.
      rs_result-outcome              = /fcbp/if_glt_types=>c_adapter_outcome-unknown_confirmation.
      rs_result-unknown_confirmation = abap_true.
      rs_result-retryable            = abap_false.
      rs_result-error-category       = /fcbp/if_glt_types=>c_error_category-unknown_confirmation.
      rs_result-error-operator_text  = 'Mock adapter returned unknown confirmation.'.
    ELSEIF lv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-retryable_failure
       OR lv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-timeout_before_send.
      rs_result-outcome             = /fcbp/if_glt_types=>c_adapter_outcome-retryable_failure.
      rs_result-retryable           = abap_true.
      rs_result-error-category      = /fcbp/if_glt_types=>c_error_category-adapter_technical.
      rs_result-error-operator_text = 'Mock adapter returned retryable technical failure.'.
    ELSEIF lv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-final_failure.
      rs_result-outcome             = /fcbp/if_glt_types=>c_adapter_outcome-final_failure.
      rs_result-retryable           = abap_false.
      rs_result-error-category      = /fcbp/if_glt_types=>c_error_category-adapter_business.
      rs_result-error-operator_text = 'Mock adapter returned final target rejection.'.
    ELSEIF lv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-pending.
      rs_result-outcome                    = /fcbp/if_glt_types=>c_adapter_outcome-dispatched.
      rs_result-middleware_message_id      = |MOCKMSG-{ sy-datum }-{ sy-uzeit }|.
      rs_result-target_message_text_safe   = 'Mock adapter accepted request for asynchronous confirmation.'.
    ELSE.
      rs_result-outcome                         = /fcbp/if_glt_types=>c_adapter_outcome-posted.
      rs_result-target_ref-target_doc_no        = |MOCK-{ sy-datum }-{ sy-uzeit }|.
      rs_result-target_ref-target_company_code  = is_transfer-header-company_code.
      rs_result-target_ref-target_corr_id       = is_transfer-header-correlation_id.
      rs_result-target_ref-confirmation_mode    = is_route-confirmation_mode.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~query_status.
    DATA(lv_scenario) = resolve_scenario(
      iv_route_switch = is_route-feature_switch_set
      iv_correlation  = is_transfer-header-correlation_id
      iv_requested    = is_request-mock_scenario ).

    mv_query_count = mv_query_count + 1.
    IF lv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-not_found.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-not_found.
      rs_result-retryable = abap_false.
      rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_business.
      rs_result-error-operator_text = 'Mock status query did not find a target document.'.
    ELSEIF lv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-unknown_confirmation AND
           mv_query_count = 1.
      rs_result-outcome              = /fcbp/if_glt_types=>c_adapter_outcome-unknown_confirmation.
      rs_result-unknown_confirmation = abap_true.
    ELSE.
      rs_result-outcome                         = /fcbp/if_glt_types=>c_adapter_outcome-posted.
      rs_result-target_ref-transfer_id          = is_transfer-header-transfer_id.
      rs_result-target_ref-target_system        = is_route-target_system.
      rs_result-target_ref-target_adapter       = is_route-target_adapter.
      rs_result-target_ref-target_doc_no        = |MOCK-{ sy-datum }-{ sy-uzeit }|.
      rs_result-target_ref-target_company_code  = is_transfer-header-company_code.
      rs_result-target_ref-target_corr_id       = is_transfer-header-correlation_id.
      rs_result-target_ref-confirmation_mode    = is_route-confirmation_mode.
    ENDIF.
    rs_result-protocol_category = /fcbp/if_glt_adapter_types=>c_protocol_category-mock.
    rs_result-query_handle_type = /fcbp/if_glt_adapter_types=>c_query_handle_type-bridge_correlation.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~cancel.
    rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-final_failure.
    rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_business.
    rs_result-error-operator_text = |Mock cancellation rejected: { iv_reason }.|.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~get_capabilities.
    rv_capabilities = 'IDEMPOTENCY;STATUS_QUERY;SYNC_CONFIRM'.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~get_capability_matrix.
    rs_capability = NEW /fcbp/cl_glt_adapter_capability( )->/fcbp/if_glt_adapter_capability~get_by_adapter_type(
      /fcbp/if_glt_adapter_types=>c_adapter_type-mock ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~validate_connection.
    rs_result = VALUE #(
      target_id = is_profile-target_id
      target_adapter = is_profile-adapter_type
      destination_alias = is_profile-destination_alias
      reachable = abap_true
      health_state = /fcbp/if_glt_config_types=>c_health_state-ok
      blocking = abap_false
      finding_code = 'MOCK_OK'
      operator_text = 'Mock adapter health simulation is reachable.'
      capability = /fcbp/if_glt_transfer_adapter~get_capability_matrix( is_profile ) ).
    GET TIME STAMP FIELD rs_result-checked_at.
  ENDMETHOD.

  METHOD resolve_scenario.
    IF iv_requested IS NOT INITIAL.
      rv_scenario = iv_requested.
    ELSEIF iv_route_switch CP '*MOCK_UNKNOWN*' OR iv_correlation CP 'UNKNOWN*'.
      rv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-unknown_confirmation.
    ELSEIF iv_route_switch CP '*MOCK_RETRY*' OR iv_correlation CP 'RETRY*'.
      rv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-retryable_failure.
    ELSEIF iv_route_switch CP '*MOCK_FINAL*'.
      rv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-final_failure.
    ELSEIF iv_route_switch CP '*MOCK_PENDING*'.
      rv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-pending.
    ELSEIF iv_route_switch CP '*MOCK_NOT_FOUND*'.
      rv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-not_found.
    ELSE.
      rv_scenario = /fcbp/if_glt_adapter_types=>c_mock_scenario-posted.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
