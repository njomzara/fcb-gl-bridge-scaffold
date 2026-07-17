"! S/4 Public Cloud payload builder scaffold.
CLASS /fcbp/cl_glt_payload_s4pub DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_adapter_payload.

ENDCLASS.

CLASS /fcbp/cl_glt_payload_s4pub IMPLEMENTATION.

  METHOD /fcbp/if_glt_adapter_payload~build_submit_payload.
    rs_payload = VALUE #(
      payload_hash = is_request-journal_hash
      raw_payload_ref = is_request-raw_request_ref
      content_type = 'application/json'
      header_names = 'CorrelationId;IdempotencyKey'
      body_ref = |S4PUB-PAYLOAD-{ is_transfer-header-transfer_id }|
      contains_payload = abap_true ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_payload~build_status_query_payload.
    rs_payload = VALUE #(
      payload_hash = is_request-status_handles-raw_ref_hash
      content_type = 'application/json'
      header_names = 'CorrelationId'
      body_ref = |S4PUB-QUERY-{ is_request-transfer_id }|
      contains_payload = abap_false ).
  ENDMETHOD.

ENDCLASS.
