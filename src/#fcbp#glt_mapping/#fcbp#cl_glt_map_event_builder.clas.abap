"! Builds append-only mapping event evidence rows.
CLASS /fcbp/cl_glt_map_event_builder DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build_event
      IMPORTING
        is_decision    TYPE /fcbp/if_glt_map_types=>ty_decision
      RETURNING
        VALUE(rs_event) TYPE /fcbp/if_glt_map_types=>ty_event.

    METHODS to_message
      IMPORTING
        is_event         TYPE /fcbp/if_glt_map_types=>ty_event
      RETURNING
        VALUE(rs_message) TYPE /fcbp/if_glt_types=>ty_message.

  PRIVATE SECTION.
    METHODS compact_hash
      IMPORTING
        iv_input       TYPE string
      RETURNING
        VALUE(rv_hash) TYPE char64.

    METHODS safe_value
      IMPORTING
        iv_value       TYPE string
      RETURNING
        VALUE(rv_value) TYPE char80.

ENDCLASS.

CLASS /fcbp/cl_glt_map_event_builder IMPLEMENTATION.

  METHOD build_event.
    DATA(ls_context) = is_decision-field_context.
    rs_event = VALUE #(
      mapping_event_id = compact_hash( |MEV:{ ls_context-package_id }:{ ls_context-outdoc_id }:{ ls_context-line_no }:{ ls_context-field_name }:{ is_decision-rule_id }:{ is_decision-target_value }| )
      transfer_id = ls_context-transfer_id
      package_id = ls_context-package_id
      outdoc_id = ls_context-outdoc_id
      line_no = ls_context-line_no
      field_name = ls_context-field_name
      source_value_hash = compact_hash( is_decision-source_value )
      source_value_safe = safe_value( is_decision-source_value )
      target_value_hash = compact_hash( is_decision-target_value )
      target_value_safe = safe_value( is_decision-target_value )
      target_id = ls_context-target_id
      mapping_policy_id = ls_context-mapping_policy_id
      mapping_policy_version = ls_context-mapping_version
      mapping_hash = ls_context-mapping_hash
      rule_id = is_decision-rule_id
      rule_version = is_decision-rule_version
      decision_type = is_decision-decision_type
      result_status = is_decision-result_status
      operator_text = is_decision-operator_text
      created_by = sy-uname ).
    GET TIME STAMP FIELD rs_event-created_at.
  ENDMETHOD.

  METHOD to_message.
    rs_message = VALUE #(
      rule_id = is_event-rule_id
      severity = COND #( WHEN is_event-result_status = /fcbp/if_glt_map_types=>c_result_status-failed
                         THEN /fcbp/if_glt_types=>c_severity-error
                         ELSE /fcbp/if_glt_types=>c_severity-warning )
      blocking = COND #( WHEN is_event-result_status = /fcbp/if_glt_map_types=>c_result_status-failed
                         THEN abap_true
                         ELSE abap_false )
      entity_name = 'MAPPING'
      field_name = is_event-field_name
      item_no = is_event-line_no
      operator_text = is_event-operator_text ).
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 24 THEN lv_len ELSE 24 ).
    rv_hash = |MAP-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

  METHOD safe_value.
    DATA(lv_len) = strlen( iv_value ).
    DATA(lv_take) = COND i( WHEN lv_len < 80 THEN lv_len ELSE 80 ).
    rv_value = iv_value(lv_take).
  ENDMETHOD.

ENDCLASS.
