"! Configuration health checks for mapping policies and rules.
CLASS /fcbp/cl_glt_map_health DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_map_health.

  PRIVATE SECTION.
    METHODS add_finding
      IMPORTING
        iv_target_id  TYPE char20
        iv_object_key TYPE char80
        iv_check_id   TYPE char30
        iv_code       TYPE char40
        iv_text       TYPE char220
      CHANGING
        ct_finding    TYPE /fcbp/if_glt_config_types=>tt_health_finding.

    METHODS is_supported_field
      IMPORTING
        iv_field_name TYPE char40
      RETURNING
        VALUE(rv_supported) TYPE abap_bool.

    METHODS is_supported_decision
      IMPORTING
        iv_decision TYPE char20
      RETURNING
        VALUE(rv_supported) TYPE abap_bool.

ENDCLASS.

CLASS /fcbp/cl_glt_map_health IMPLEMENTATION.

  METHOD /fcbp/if_glt_map_health~validate_effective_context.
    DATA(lv_active_rule_found) = abap_false.

    IF is_context-target_profile-mapping_policy_id IS INITIAL.
      add_finding(
        EXPORTING iv_target_id = is_context-target_profile-target_id
                  iv_object_key = is_context-target_profile-target_id
                  iv_check_id = 'GLT_MAP_CFG_001'
                  iv_code = 'MAPPING_POLICY_MISSING'
                  iv_text = 'Target profile must reference a mapping policy before dispatch.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    LOOP AT is_context-mapping_rules INTO DATA(ls_rule).
      IF ls_rule-active_flag = abap_false.
        CONTINUE.
      ENDIF.
      lv_active_rule_found = abap_true.

      IF ls_rule-config_hash IS INITIAL.
        add_finding(
          EXPORTING iv_target_id = is_context-target_profile-target_id
                    iv_object_key = ls_rule-mapping_rule_id
                    iv_check_id = 'GLT_MAP_CFG_002'
                    iv_code = 'MAPPING_RULE_HASH_MISSING'
                    iv_text = 'Active mapping rule requires a configuration hash.'
          CHANGING ct_finding = rt_finding ).
      ENDIF.

      IF is_supported_field( ls_rule-field_name ) = abap_false.
        add_finding(
          EXPORTING iv_target_id = is_context-target_profile-target_id
                    iv_object_key = ls_rule-mapping_rule_id
                    iv_check_id = 'GLT_MAP_CFG_003'
                    iv_code = 'MAPPING_FIELD_UNSUPPORTED'
                    iv_text = 'Mapping rule field is not in the supported field catalogue.'
          CHANGING ct_finding = rt_finding ).
      ENDIF.

      DATA(lv_rule_decision) = ls_rule-decision_type.
      TRANSLATE lv_rule_decision TO UPPER CASE.

      IF is_supported_decision( lv_rule_decision ) = abap_false.
        add_finding(
          EXPORTING iv_target_id = is_context-target_profile-target_id
                    iv_object_key = ls_rule-mapping_rule_id
                    iv_check_id = 'GLT_MAP_CFG_004'
                    iv_code = 'MAPPING_DECISION_UNSUPPORTED'
                    iv_text = 'Mapping rule decision type is not supported.'
          CHANGING ct_finding = rt_finding ).
      ENDIF.

      IF lv_rule_decision = /fcbp/if_glt_map_types=>c_decision_type-pass_through AND
         ls_rule-pass_through_allowed = abap_false.
        add_finding(
          EXPORTING iv_target_id = is_context-target_profile-target_id
                    iv_object_key = ls_rule-mapping_rule_id
                    iv_check_id = 'GLT_MAP_CFG_005'
                    iv_code = 'PASS_THROUGH_NOT_EXPLICIT'
                    iv_text = 'PASS_THROUGH decision requires pass-through flag.'
          CHANGING ct_finding = rt_finding ).
      ENDIF.
    ENDLOOP.

    IF is_context-target_profile-mapping_policy_id IS NOT INITIAL AND lv_active_rule_found = abap_false.
      add_finding(
        EXPORTING iv_target_id = is_context-target_profile-target_id
                  iv_object_key = is_context-target_profile-mapping_policy_id
                  iv_check_id = 'GLT_MAP_CFG_006'
                  iv_code = 'MAPPING_RULES_MISSING'
                  iv_text = 'Mapping policy must resolve at least one active mapping rule.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.
  ENDMETHOD.

  METHOD is_supported_field.
    CASE iv_field_name.
      WHEN /fcbp/if_glt_map_types=>c_field-company_code
        OR /fcbp/if_glt_map_types=>c_field-gl_doc_type
        OR /fcbp/if_glt_map_types=>c_field-gl_account
        OR /fcbp/if_glt_map_types=>c_field-chart_of_accounts
        OR /fcbp/if_glt_map_types=>c_field-ledger_group
        OR /fcbp/if_glt_map_types=>c_field-profit_center
        OR /fcbp/if_glt_map_types=>c_field-cost_center
        OR /fcbp/if_glt_map_types=>c_field-segment
        OR /fcbp/if_glt_map_types=>c_field-internal_order
        OR /fcbp/if_glt_map_types=>c_field-trading_partner
        OR /fcbp/if_glt_map_types=>c_field-tax_code
        OR /fcbp/if_glt_map_types=>c_field-assignment
        OR /fcbp/if_glt_map_types=>c_field-item_text
        OR /fcbp/if_glt_map_types=>c_field-header_text
        OR /fcbp/if_glt_map_types=>c_field-reference.
        rv_supported = abap_true.
      WHEN OTHERS.
        rv_supported = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD is_supported_decision.
    DATA(lv_decision) = iv_decision.
    TRANSLATE lv_decision TO UPPER CASE.
    CASE lv_decision.
      WHEN /fcbp/if_glt_map_types=>c_decision_type-map
        OR /fcbp/if_glt_map_types=>c_decision_type-mapped
        OR /fcbp/if_glt_map_types=>c_decision_type-derive
        OR /fcbp/if_glt_map_types=>c_decision_type-derived
        OR /fcbp/if_glt_map_types=>c_decision_type-clear
        OR /fcbp/if_glt_map_types=>c_decision_type-cleared
        OR /fcbp/if_glt_map_types=>c_decision_type-truncate
        OR /fcbp/if_glt_map_types=>c_decision_type-truncated
        OR /fcbp/if_glt_map_types=>c_decision_type-reject
        OR /fcbp/if_glt_map_types=>c_decision_type-rejected
        OR /fcbp/if_glt_map_types=>c_decision_type-pass_through.
        rv_supported = abap_true.
      WHEN OTHERS.
        rv_supported = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD add_finding.
    DATA(ls_finding) = VALUE /fcbp/if_glt_config_types=>ty_health_finding(
      health_run_id = |MAP-{ sy-datum }-{ sy-uzeit }|
      target_id = iv_target_id
      config_object_type = /fcbp/if_glt_config_types=>c_object_type-mapping_rule
      config_object_key = iv_object_key
      check_id = iv_check_id
      severity = /fcbp/if_glt_types=>c_severity-error
      blocking_flag = abap_true
      finding_code = iv_code
      operator_text = iv_text
      checked_by = sy-uname ).
    GET TIME STAMP FIELD ls_finding-checked_at.
    APPEND ls_finding TO ct_finding.
  ENDMETHOD.

ENDCLASS.
