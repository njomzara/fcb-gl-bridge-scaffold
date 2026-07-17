"! Deterministic mapping rule resolver.
CLASS /fcbp/cl_glt_map_resolver DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_map_resolver.

  PRIVATE SECTION.
    METHODS empty_success
      IMPORTING
        is_field_context TYPE /fcbp/if_glt_map_types=>ty_field_context
      RETURNING
        VALUE(rs_decision) TYPE /fcbp/if_glt_map_types=>ty_decision.

    METHODS failure
      IMPORTING
        is_field_context TYPE /fcbp/if_glt_map_types=>ty_field_context
        iv_code          TYPE char40
        iv_text          TYPE char220
      RETURNING
        VALUE(rs_decision) TYPE /fcbp/if_glt_map_types=>ty_decision.

    METHODS rule_matches
      IMPORTING
        is_field_context TYPE /fcbp/if_glt_map_types=>ty_field_context
        is_rule          TYPE /fcbp/if_glt_config_types=>ty_mapping_rule
      RETURNING
        VALUE(rv_matches) TYPE abap_bool.

    METHODS normalize_priority
      IMPORTING
        iv_priority TYPE i
      RETURNING
        VALUE(rv_priority) TYPE i.

ENDCLASS.

CLASS /fcbp/cl_glt_map_resolver IMPLEMENTATION.

  METHOD /fcbp/if_glt_map_resolver~resolve.
    IF is_field_context-field_name IS INITIAL.
      rs_decision = failure(
        is_field_context = is_field_context
        iv_code = 'MAPPING_FIELD_MISSING'
        iv_text = 'Mapping field name is required.' ).
      RETURN.
    ENDIF.

    IF is_field_context-source_value IS INITIAL AND is_field_context-required = abap_false.
      rs_decision = empty_success( is_field_context ).
      RETURN.
    ENDIF.

    DATA lv_best_priority TYPE i VALUE 999999.
    DATA lv_match_count TYPE i.
    DATA ls_best_rule TYPE /fcbp/if_glt_config_types=>ty_mapping_rule.

    LOOP AT it_rule INTO DATA(ls_rule)
      WHERE active_flag = abap_true
        AND field_name = is_field_context-field_name.
      IF rule_matches( is_field_context = is_field_context is_rule = ls_rule ) = abap_false.
        CONTINUE.
      ENDIF.

      DATA(lv_priority) = normalize_priority( ls_rule-priority ).
      IF lv_priority < lv_best_priority.
        lv_best_priority = lv_priority.
        lv_match_count = 1.
        ls_best_rule = ls_rule.
      ELSEIF lv_priority = lv_best_priority.
        lv_match_count = lv_match_count + 1.
      ENDIF.
    ENDLOOP.

    IF lv_match_count = 0.
      rs_decision = failure(
        is_field_context = is_field_context
        iv_code = 'MAPPING_RULE_MISSING'
        iv_text = |No active mapping rule resolved field { is_field_context-field_name }.| ).
      RETURN.
    ENDIF.

    IF lv_match_count > 1.
      rs_decision = failure(
        is_field_context = is_field_context
        iv_code = 'MAPPING_RULE_AMBIGUOUS'
        iv_text = |Multiple mapping rules resolved field { is_field_context-field_name } with the same priority.| ).
      RETURN.
    ENDIF.

    DATA(lv_decision_type) = ls_best_rule-decision_type.
    TRANSLATE lv_decision_type TO UPPER CASE.
    IF lv_decision_type = /fcbp/if_glt_map_types=>c_decision_type-pass_through AND
       ls_best_rule-pass_through_allowed = abap_false.
      rs_decision = failure(
        is_field_context = is_field_context
        iv_code = 'PASS_THROUGH_NOT_EXPLICIT'
        iv_text = |Pass-through mapping for field { is_field_context-field_name } is not explicitly allowed.| ).
      RETURN.
    ENDIF.

    rs_decision = VALUE #(
      field_context = is_field_context
      rule_id = ls_best_rule-mapping_rule_id
      rule_version = ls_best_rule-version
      config_hash = ls_best_rule-config_hash
      decision_type = lv_decision_type
      source_value = is_field_context-source_value
      target_value = ls_best_rule-target_value
      result_status = /fcbp/if_glt_map_types=>c_result_status-pending ).
  ENDMETHOD.

  METHOD rule_matches.
    IF is_rule-source_value IS NOT INITIAL AND is_rule-source_value = is_field_context-source_value.
      rv_matches = abap_true.
      RETURN.
    ENDIF.

    IF is_rule-source_pattern IS NOT INITIAL AND is_field_context-source_value CP is_rule-source_pattern.
      rv_matches = abap_true.
      RETURN.
    ENDIF.

    IF is_rule-source_value IS INITIAL AND is_rule-source_pattern IS INITIAL.
      rv_matches = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD normalize_priority.
    IF iv_priority IS INITIAL.
      rv_priority = 999999.
    ELSE.
      rv_priority = iv_priority.
    ENDIF.
  ENDMETHOD.

  METHOD empty_success.
    rs_decision = VALUE #(
      field_context = is_field_context
      decision_type = /fcbp/if_glt_map_types=>c_decision_type-cleared
      result_status = /fcbp/if_glt_map_types=>c_result_status-mapped
      source_value = is_field_context-source_value
      target_value = ''
      operator_text = |Field { is_field_context-field_name } is empty and not required.| ).
  ENDMETHOD.

  METHOD failure.
    rs_decision = VALUE #(
      field_context = is_field_context
      decision_type = /fcbp/if_glt_map_types=>c_decision_type-rejected
      result_status = /fcbp/if_glt_map_types=>c_result_status-failed
      source_value = is_field_context-source_value
      blocking = abap_true
      message_code = iv_code
      operator_text = iv_text ).
  ENDMETHOD.

ENDCLASS.
