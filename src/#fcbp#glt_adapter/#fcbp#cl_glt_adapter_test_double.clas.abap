"! Adapter test double for contract tests and timeout simulations.
CLASS /fcbp/cl_glt_adapter_test_double DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_transfer_adapter.

    METHODS set_next_response
      IMPORTING
        is_response TYPE /fcbp/if_glt_adapter_types=>ty_protocol_response.

  PRIVATE SECTION.
    DATA ms_next_response TYPE /fcbp/if_glt_adapter_types=>ty_protocol_response.
    DATA mo_normalizer TYPE REF TO /fcbp/if_glt_adapter_normalizer.

ENDCLASS.

CLASS /fcbp/cl_glt_adapter_test_double IMPLEMENTATION.

  METHOD set_next_response.
    ms_next_response = is_response.
    IF mo_normalizer IS NOT BOUND.
      mo_normalizer = NEW /fcbp/cl_glt_adapter_normalizer( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~dispatch.
    IF mo_normalizer IS NOT BOUND.
      mo_normalizer = NEW /fcbp/cl_glt_adapter_normalizer( ).
    ENDIF.
    rs_result = mo_normalizer->from_protocol_response( is_response = ms_next_response is_request = is_request ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~query_status.
    IF mo_normalizer IS NOT BOUND.
      mo_normalizer = NEW /fcbp/cl_glt_adapter_normalizer( ).
    ENDIF.
    rs_result = mo_normalizer->from_protocol_response( ms_next_response ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~cancel.
    rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-final_failure.
    rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_business.
    rs_result-error-operator_text = |Test double cancel rejected: { iv_reason }.|.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~validate_connection.
    rs_result = VALUE #(
      target_id = is_profile-target_id
      target_adapter = is_profile-adapter_type
      reachable = abap_true
      health_state = /fcbp/if_glt_config_types=>c_health_state-ok
      finding_code = 'TEST_DOUBLE_OK'
      operator_text = 'Adapter test double connection is simulated.' ).
    GET TIME STAMP FIELD rs_result-checked_at.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~get_capabilities.
    rv_capabilities = 'TEST_DOUBLE'.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~get_capability_matrix.
    rs_capability = VALUE #(
      adapter_type = 'TEST_DOUBLE'
      supports_submit = abap_true
      supports_status_query = abap_true
      supports_idempotency_key = abap_true
      supports_correlation_id = abap_true
      matrix_complete = abap_true ).
  ENDMETHOD.

ENDCLASS.
