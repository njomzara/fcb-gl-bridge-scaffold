"! SAP Integration Suite adapter scaffold.
CLASS /fcbp/cl_glt_adapter_cpi DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_transfer_adapter.

    METHODS constructor
      IMPORTING
        io_client     TYPE REF TO /fcbp/if_glt_adapter_client OPTIONAL
        io_payload    TYPE REF TO /fcbp/if_glt_adapter_payload OPTIONAL
        io_normalizer TYPE REF TO /fcbp/if_glt_adapter_normalizer OPTIONAL.

  PRIVATE SECTION.
    DATA mo_client TYPE REF TO /fcbp/if_glt_adapter_client.
    DATA mo_payload TYPE REF TO /fcbp/if_glt_adapter_payload.
    DATA mo_normalizer TYPE REF TO /fcbp/if_glt_adapter_normalizer.

    METHODS ensure_bound
      IMPORTING
        iv_operation TYPE char30
        is_route     TYPE /fcbp/if_glt_types=>ty_route OPTIONAL
      RAISING
        /fcbp/cx_glt_adapter.

ENDCLASS.

CLASS /fcbp/cl_glt_adapter_cpi IMPLEMENTATION.

  METHOD constructor.
    mo_client = io_client.
    mo_payload = io_payload.
    mo_normalizer = io_normalizer.
    IF mo_payload IS NOT BOUND.
      mo_payload = NEW /fcbp/cl_glt_payload_cpi( ).
    ENDIF.
    IF mo_normalizer IS NOT BOUND.
      mo_normalizer = NEW /fcbp/cl_glt_adapter_normalizer( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~dispatch.
    ensure_bound( iv_operation = 'CPI_SUBMIT' is_route = is_route ).
    DATA(ls_payload) = mo_payload->build_submit_payload( is_transfer = is_transfer is_request = is_request ).
    DATA(ls_response) = mo_client->submit( is_request = is_request is_payload = ls_payload ).
    rs_result = mo_normalizer->from_protocol_response( is_response = ls_response is_request = is_request ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~query_status.
    ensure_bound( iv_operation = 'CPI_QUERY_STATUS' is_route = is_route ).
    DATA(ls_payload) = mo_payload->build_status_query_payload( is_request ).
    DATA(ls_response) = mo_client->query_status( is_request = is_request is_payload = ls_payload ).
    rs_result = mo_normalizer->from_protocol_response( is_response = ls_response ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~cancel.
    rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-final_failure.
    rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_business.
    rs_result-error-operator_text = |Integration Suite cancel is not enabled by the scaffold: { iv_reason }.|.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~validate_connection.
    IF mo_client IS BOUND.
      rs_result = mo_client->check_connection( is_profile ).
    ELSE.
      rs_result = VALUE #(
        target_id = is_profile-target_id
        target_adapter = is_profile-adapter_type
        destination_alias = is_profile-destination_alias
        reachable = abap_false
        health_state = /fcbp/if_glt_config_types=>c_health_state-blocked
        blocking = abap_true
        finding_code = 'CPI_CLIENT_NOT_BOUND'
        operator_text = 'Integration Suite adapter requires a middleware client binding.'
        capability = /fcbp/if_glt_transfer_adapter~get_capability_matrix( is_profile ) ).
      GET TIME STAMP FIELD rs_result-checked_at.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~get_capabilities.
    rv_capabilities = 'INTEGRATION_SUITE;SUBMIT;STATUS_QUERY;MATRIX_INCOMPLETE'.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~get_capability_matrix.
    rs_capability = NEW /fcbp/cl_glt_adapter_capability( )->/fcbp/if_glt_adapter_capability~get_by_adapter_type(
      /fcbp/if_glt_adapter_types=>c_adapter_type-integration_suite ).
  ENDMETHOD.

  METHOD ensure_bound.
    IF mo_client IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_adapter
        EXPORTING
          target_adapter    = is_route-target_adapter
          error_category    = /fcbp/if_glt_types=>c_error_category-config
          protocol_category = /fcbp/if_glt_adapter_types=>c_protocol_category-config
          operator_text     = |Adapter operation { iv_operation } requires an Integration Suite client binding.|.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
