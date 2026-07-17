"! Attempt-evidence scaffold. Replace placeholder IDs/hashes with released APIs.
CLASS /fcbp/cl_glt_adapter_evidence DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_adapter_evidence.

  PRIVATE SECTION.
    METHODS safe_key_hash
      IMPORTING
        iv_value       TYPE char64
      RETURNING
        VALUE(rv_hash) TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_adapter_evidence IMPLEMENTATION.

  METHOD /fcbp/if_glt_adapter_evidence~start_attempt.
    rs_attempt = VALUE #(
      attempt_id            = |ATT-{ sy-datum }-{ sy-uzeit }|
      transfer_id           = is_request-transfer_id
      outbox_id             = iv_outbox_id
      jobrun_id             = iv_jobrun_id
      attempt_no            = 1
      attempt_type          = iv_attempt_type
      package_id            = is_request-package_id
      outdoc_id             = is_request-outdoc_id
      policy_context_id     = is_request-policy_context_id
      target_system         = is_request-target_system
      target_adapter        = is_request-target_adapter
      destination_alias     = is_request-destination_alias
      correlation_id        = is_request-correlation_id
      idempotency_key_hash  = safe_key_hash( is_request-idempotency_key )
      outcome               = /fcbp/if_glt_types=>c_attempt_outcome-started
      request_hash          = is_request-request_hash
      raw_request_ref       = is_request-raw_request_ref
      created_by            = sy-uname ).
    GET TIME STAMP FIELD rs_attempt-started_at.
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_evidence~finish_attempt.
    rs_attempt = is_attempt.
    rs_attempt-outcome = is_result-outcome.
    rs_attempt-retryable = is_result-retryable.
    rs_attempt-unknown_confirmation = is_result-unknown_confirmation.
    rs_attempt-response_hash = is_result-response_hash.
    rs_attempt-raw_response_ref = is_result-raw_response_ref.
    rs_attempt-middleware_message_id = is_result-middleware_message_id.
    rs_attempt-target_status_handle = is_result-query_handle_type.
    rs_attempt-error_id = is_result-error-error_id.
    GET TIME STAMP FIELD rs_attempt-finished_at.
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_evidence~persist_attempt.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_repository
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = 'Adapter attempt persistence must be bound to /FCBP/GLT_ATT in the target tenant.'.
  ENDMETHOD.

  METHOD safe_key_hash.
    rv_hash = |IDEMP-LEN-{ strlen( iv_value ) }|.
  ENDMETHOD.

ENDCLASS.
