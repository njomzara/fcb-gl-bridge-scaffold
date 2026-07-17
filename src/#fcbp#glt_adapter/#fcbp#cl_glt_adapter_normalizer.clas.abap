"! Normalization scaffold. Default uncertainty is UNKNOWN_CONFIRMATION.
CLASS /fcbp/cl_glt_adapter_normalizer DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_adapter_normalizer.

  PRIVATE SECTION.
    METHODS fill_common
      IMPORTING
        is_response TYPE /fcbp/if_glt_adapter_types=>ty_protocol_response
        is_request  TYPE /fcbp/if_glt_adapter_types=>ty_submit_request OPTIONAL
      CHANGING
        cs_result   TYPE /fcbp/if_glt_types=>ty_adapter_result.

ENDCLASS.

CLASS /fcbp/cl_glt_adapter_normalizer IMPLEMENTATION.

  METHOD /fcbp/if_glt_adapter_normalizer~from_protocol_response.
    fill_common(
      EXPORTING
        is_response = is_response
        is_request  = is_request
      CHANGING
        cs_result   = rs_result ).

    IF is_response-timeout_occurred = abap_true AND
       is_response-may_have_been_sent = abap_true.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-unknown_confirmation.
      rs_result-unknown_confirmation = abap_true.
      rs_result-retryable = abap_false.
      rs_result-error-category = /fcbp/if_glt_types=>c_error_category-unknown_confirmation.
      rs_result-error-operator_text = 'Target outcome is unknown after timeout or interrupted communication.'.
    ELSEIF is_response-timeout_occurred = abap_true.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-retryable_failure.
      rs_result-retryable = abap_true.
      rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_technical.
      rs_result-error-operator_text = 'Target request did not leave the adapter boundary before timeout.'.
    ELSEIF is_response-confirmed = abap_true OR is_response-duplicate_replay = abap_true.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-posted.
      rs_result-target_ref-target_doc_no = is_response-target_doc_no.
      rs_result-target_ref-target_company_code = is_response-target_company_code.
      rs_result-target_ref-target_fiscal_year = is_response-target_fiscal_year.
      rs_result-target_ref-target_corr_id = is_response-target_correlation_id.
      GET TIME STAMP FIELD rs_result-target_ref-confirmed_at.
      rs_result-confirmed_at = rs_result-target_ref-confirmed_at.
    ELSEIF is_response-accepted_pending = abap_true.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-dispatched.
    ELSEIF is_response-not_found = abap_true.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-not_found.
      rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_business.
      rs_result-error-operator_text = 'Status query did not find a target posting for the supplied handles.'.
    ELSEIF is_response-business_rejection = abap_true.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-final_failure.
      rs_result-retryable = abap_false.
      rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_business.
      rs_result-error-operator_text = is_response-target_message_text_safe.
    ELSEIF is_response-retryable_safe = abap_true.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-retryable_failure.
      rs_result-retryable = abap_true.
      rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_technical.
      rs_result-error-operator_text = is_response-target_message_text_safe.
    ELSEIF is_response-http_status >= 200 AND is_response-http_status <= 299.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-dispatched.
    ELSE.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-unknown_confirmation.
      rs_result-unknown_confirmation = abap_true.
      rs_result-retryable = abap_false.
      rs_result-error-category = /fcbp/if_glt_types=>c_error_category-unknown_confirmation.
      rs_result-error-operator_text = 'Adapter response could not prove final target outcome.'.
    ENDIF.

    /fcbp/if_glt_adapter_normalizer~assert_result_safe( CHANGING cs_result = rs_result ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_normalizer~from_exception.
    IF iv_may_have_been_sent = abap_true.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-unknown_confirmation.
      rs_result-unknown_confirmation = abap_true.
      rs_result-retryable = abap_false.
      rs_result-error-category = /fcbp/if_glt_types=>c_error_category-unknown_confirmation.
      rs_result-error-operator_text = 'Adapter exception occurred after the request may have reached the target.'.
    ELSE.
      rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-retryable_failure.
      rs_result-retryable = abap_true.
      rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_technical.
      rs_result-error-operator_text = 'Adapter exception occurred before target submission.'.
    ENDIF.

    IF ix_previous IS BOUND.
      rs_result-error-technical_ref = ix_previous->get_text( ).
    ENDIF.
    rs_result-protocol_category = iv_protocol_category.
    rs_result-target_ref-transfer_id = is_request-transfer_id.
    rs_result-target_ref-target_system = is_request-target_system.
    rs_result-target_ref-target_adapter = is_request-target_adapter.
    rs_result-target_ref-confirmation_mode = is_request-confirmation_mode.
    /fcbp/if_glt_adapter_normalizer~assert_result_safe( CHANGING cs_result = rs_result ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_normalizer~assert_result_safe.
    IF cs_result-unknown_confirmation = abap_true.
      cs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-unknown_confirmation.
      cs_result-retryable = abap_false.
      cs_result-error-unknown_confirmation = abap_true.
      IF cs_result-error-category IS INITIAL.
        cs_result-error-category = /fcbp/if_glt_types=>c_error_category-unknown_confirmation.
      ENDIF.
    ENDIF.

    IF cs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-posted AND
       cs_result-target_ref-target_doc_no IS INITIAL AND
       cs_result-target_ref-target_corr_id IS INITIAL AND
       cs_result-target_ref-raw_ref_hash IS INITIAL.
      cs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-unknown_confirmation.
      cs_result-unknown_confirmation = abap_true.
      cs_result-retryable = abap_false.
      cs_result-error-category = /fcbp/if_glt_types=>c_error_category-unknown_confirmation.
      cs_result-error-operator_text = 'Posted adapter result lacked target proof and was downgraded to unknown confirmation.'.
    ENDIF.
  ENDMETHOD.

  METHOD fill_common.
    cs_result-response_hash = is_response-response_hash.
    cs_result-raw_response_ref = is_response-raw_response_ref.
    cs_result-target_message_code = is_response-target_message_code.
    cs_result-target_message_text_safe = is_response-target_message_text_safe.
    cs_result-http_status = is_response-http_status.
    cs_result-protocol_category = is_response-protocol_category.
    cs_result-middleware_message_id = is_response-middleware_message_id.
    cs_result-target_correlation_id = is_response-target_correlation_id.
    cs_result-idempotency_status = is_response-idempotency_status.
    cs_result-query_handle_type = is_response-query_handle_type.
    cs_result-target_ref-transfer_id = is_request-transfer_id.
    cs_result-target_ref-target_system = is_request-target_system.
    cs_result-target_ref-target_adapter = is_request-target_adapter.
    cs_result-target_ref-confirmation_mode = is_request-confirmation_mode.
    cs_result-error-transfer_id = is_request-transfer_id.
    cs_result-error-technical_ref = is_response-raw_response_ref.
  ENDMETHOD.

ENDCLASS.
