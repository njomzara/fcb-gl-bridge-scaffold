"! SAP Integration Suite wrapper payload builder scaffold.
CLASS /fcbp/cl_glt_payload_cpi DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_adapter_payload.

ENDCLASS.

CLASS /fcbp/cl_glt_payload_cpi IMPLEMENTATION.

  METHOD /fcbp/if_glt_adapter_payload~build_submit_payload.
    rs_payload = VALUE #(
      payload_hash = is_request-journal_hash
      raw_payload_ref = is_request-raw_request_ref
      content_type = 'application/json'
      header_names = 'BridgeCorrelation;BridgeIdempotency'
      body_ref = |CPI-WRAPPER-{ is_transfer-header-transfer_id }|
      contains_payload = abap_true ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_payload~build_status_query_payload.
    rs_payload = VALUE #(
      payload_hash = is_request-status_handles-raw_ref_hash
      content_type = 'application/json'
      header_names = 'BridgeCorrelation'
      body_ref = |CPI-QUERY-{ is_request-status_handles-middleware_message_id }|
      contains_payload = abap_false ).
  ENDMETHOD.

ENDCLASS.
