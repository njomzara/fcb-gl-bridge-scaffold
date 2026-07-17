"! Configuration health checks for validation rule profiles.
CLASS /fcbp/cl_glt_val_health DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_val_health.

  PRIVATE SECTION.
    METHODS add_finding
      IMPORTING
        iv_target_id TYPE char20
        iv_object_key TYPE char80
        iv_check_id TYPE char30
        iv_code TYPE char40
        iv_text TYPE char220
      CHANGING
        ct_finding TYPE /fcbp/if_glt_config_types=>tt_health_finding.

    METHODS is_known_category
      IMPORTING iv_category TYPE char30
      RETURNING VALUE(rv_known) TYPE abap_bool.

ENDCLASS.

CLASS /fcbp/cl_glt_val_health IMPLEMENTATION.

  METHOD /fcbp/if_glt_val_health~validate_effective_context.
    DATA(lv_active_rule_found) = abap_false.

    IF is_context-target_profile-validation_profile_id IS INITIAL.
      add_finding(
        EXPORTING iv_target_id = is_context-target_profile-target_id
                  iv_object_key = is_context-target_profile-target_id
                  iv_check_id = 'GLT_VAL_CFG_001'
                  iv_code = 'VALIDATION_PROFILE_MISSING'
                  iv_text = 'Target profile must reference a validation profile.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    LOOP AT is_context-validation_rules INTO DATA(ls_rule).
      IF ls_rule-active_flag = abap_false.
        CONTINUE.
      ENDIF.
      lv_active_rule_found = abap_true.

      IF ls_rule-config_hash IS INITIAL.
        add_finding(
          EXPORTING iv_target_id = is_context-target_profile-target_id
                    iv_object_key = ls_rule-rule_id
                    iv_check_id = 'GLT_VAL_CFG_002'
                    iv_code = 'VALIDATION_RULE_HASH_MISSING'
                    iv_text = 'Active validation rule requires a configuration hash.'
          CHANGING ct_finding = rt_finding ).
      ENDIF.

      IF is_known_category( ls_rule-rule_category ) = abap_false.
        add_finding(
          EXPORTING iv_target_id = is_context-target_profile-target_id
                    iv_object_key = ls_rule-rule_id
                    iv_check_id = 'GLT_VAL_CFG_003'
                    iv_code = 'VALIDATION_CATEGORY_UNKNOWN'
                    iv_text = 'Validation rule category is not supported by the scaffold.'
          CHANGING ct_finding = rt_finding ).
      ENDIF.

      IF ls_rule-severity <> /fcbp/if_glt_types=>c_severity-error AND
         ls_rule-severity <> /fcbp/if_glt_types=>c_severity-warning AND
         ls_rule-severity <> /fcbp/if_glt_types=>c_severity-info.
        add_finding(
          EXPORTING iv_target_id = is_context-target_profile-target_id
                    iv_object_key = ls_rule-rule_id
                    iv_check_id = 'GLT_VAL_CFG_004'
                    iv_code = 'VALIDATION_SEVERITY_UNKNOWN'
                    iv_text = 'Validation rule severity must be ERROR, WARNING, or INFO.'
          CHANGING ct_finding = rt_finding ).
      ENDIF.

      IF ls_rule-policy_expression_ref IS NOT INITIAL AND
         ls_rule-policy_expression_ref <> 'REQUIRE_FIELD' AND
         ls_rule-policy_expression_ref <> 'ALLOW_PASS_THROUGH' AND
         ls_rule-policy_expression_ref <> 'BALANCE_BY_CURRENCY'.
        add_finding(
          EXPORTING iv_target_id = is_context-target_profile-target_id
                    iv_object_key = ls_rule-rule_id
                    iv_check_id = 'GLT_VAL_CFG_005'
                    iv_code = 'VALIDATION_EXPRESSION_UNKNOWN'
                    iv_text = 'Validation policy expression reference is not registered.'
          CHANGING ct_finding = rt_finding ).
      ENDIF.
    ENDLOOP.

    IF is_context-target_profile-validation_profile_id IS NOT INITIAL AND
       lv_active_rule_found = abap_false.
      add_finding(
        EXPORTING iv_target_id = is_context-target_profile-target_id
                  iv_object_key = is_context-target_profile-validation_profile_id
                  iv_check_id = 'GLT_VAL_CFG_006'
                  iv_code = 'VALIDATION_RULES_MISSING'
                  iv_text = 'Validation profile must resolve at least one active validation rule.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.
  ENDMETHOD.

  METHOD is_known_category.
    CASE iv_category.
      WHEN /fcbp/if_glt_val_types=>c_category-structural
        OR /fcbp/if_glt_val_types=>c_category-accounting
        OR /fcbp/if_glt_val_types=>c_category-traceability
        OR /fcbp/if_glt_val_types=>c_category-target_compatibility
        OR /fcbp/if_glt_val_types=>c_category-mapping_prereq
        OR /fcbp/if_glt_val_types=>c_category-operational_state
        OR /fcbp/if_glt_val_types=>c_category-security
        OR /fcbp/if_glt_val_types=>c_category-advisory.
        rv_known = abap_true.
      WHEN OTHERS.
        rv_known = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD add_finding.
    DATA(ls_finding) = VALUE /fcbp/if_glt_config_types=>ty_health_finding(
      health_run_id = |VAL-{ sy-datum }-{ sy-uzeit }|
      target_id = iv_target_id
      config_object_type = /fcbp/if_glt_config_types=>c_object_type-validation_rule
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
