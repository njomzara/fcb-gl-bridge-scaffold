"! S/4HANA Private Cloud adapter scaffold. Connectivity/API decisions are open.
CLASS /fcbp/cl_glt_adapter_s4prv DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_transfer_adapter.

  PRIVATE SECTION.
    METHODS not_ready
      IMPORTING
        iv_operation TYPE char30
        is_route     TYPE /fcbp/if_glt_types=>ty_route OPTIONAL
      RAISING
        /fcbp/cx_glt_adapter.

ENDCLASS.

CLASS /fcbp/cl_glt_adapter_s4prv IMPLEMENTATION.

  METHOD /fcbp/if_glt_transfer_adapter~dispatch.
    not_ready( iv_operation = 'S4PRV_SUBMIT' is_route = is_route ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~query_status.
    not_ready( iv_operation = 'S4PRV_QUERY_STATUS' is_route = is_route ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~cancel.
    rs_result-outcome = /fcbp/if_glt_types=>c_adapter_outcome-final_failure.
    rs_result-error-category = /fcbp/if_glt_types=>c_error_category-adapter_business.
    rs_result-error-operator_text = |S/4 Private Cloud cancel is not enabled by the scaffold: { iv_reason }.|.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~validate_connection.
    rs_result = VALUE #(
      target_id = is_profile-target_id
      target_adapter = is_profile-adapter_type
      destination_alias = is_profile-destination_alias
      reachable = abap_false
      health_state = /fcbp/if_glt_config_types=>c_health_state-blocked
      blocking = abap_true
      finding_code = 'S4PRV_CLIENT_NOT_BOUND'
      operator_text = 'S/4 Private Cloud adapter requires approved API and connectivity binding.'
      capability = /fcbp/if_glt_transfer_adapter~get_capability_matrix( is_profile ) ).
    GET TIME STAMP FIELD rs_result-checked_at.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~get_capabilities.
    rv_capabilities = 'S4_PRIVATE_CLOUD;MATRIX_INCOMPLETE'.
  ENDMETHOD.

  METHOD /fcbp/if_glt_transfer_adapter~get_capability_matrix.
    rs_capability = NEW /fcbp/cl_glt_adapter_capability( )->/fcbp/if_glt_adapter_capability~get_by_adapter_type(
      /fcbp/if_glt_adapter_types=>c_adapter_type-s4_private_cloud ).
  ENDMETHOD.

  METHOD not_ready.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_adapter
      EXPORTING
        target_adapter    = is_route-target_adapter
        error_category    = /fcbp/if_glt_types=>c_error_category-config
        protocol_category = /fcbp/if_glt_adapter_types=>c_protocol_category-config
        operator_text     = |Adapter operation { iv_operation } is blocked until private-cloud route APIs are approved.|.
  ENDMETHOD.

ENDCLASS.
