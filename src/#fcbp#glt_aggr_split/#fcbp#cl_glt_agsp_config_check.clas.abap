"! Configuration health checks for aggregation/split policies.
CLASS /fcbp/cl_glt_agsp_config_check DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_agsp_config_check.

    METHODS constructor
      IMPORTING
        io_signature TYPE REF TO /fcbp/if_glt_aggr_signature OPTIONAL.

  PRIVATE SECTION.
    DATA mo_signature TYPE REF TO /fcbp/if_glt_aggr_signature.

    METHODS add_finding
      IMPORTING
        iv_target_id TYPE char20
        iv_object_type TYPE char30
        iv_object_key TYPE char80
        iv_check_id TYPE char30
        iv_code TYPE char40
        iv_text TYPE char220
      CHANGING
        ct_finding TYPE /fcbp/if_glt_config_types=>tt_health_finding.

ENDCLASS.

CLASS /fcbp/cl_glt_agsp_config_check IMPLEMENTATION.

  METHOD constructor.
    IF io_signature IS BOUND.
      mo_signature = io_signature.
    ELSE.
      mo_signature = NEW /fcbp/cl_glt_aggr_signature( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_agsp_config_check~validate_effective_context.
    IF is_context-aggregation_policy-aggregation_profile_id IS INITIAL.
      add_finding(
        EXPORTING iv_target_id = is_context-target_profile-target_id
                  iv_object_type = /fcbp/if_glt_config_types=>c_object_type-aggregation_policy
                  iv_object_key = is_context-target_profile-aggregation_profile_id
                  iv_check_id = 'GLT_AGSP_CFG_001'
                  iv_code = 'AGGR_POLICY_MISSING'
                  iv_text = 'Aggregation policy is required for package shaping.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF is_context-aggregation_policy-grouping_mode = /fcbp/if_glt_pkg_types=>c_grouping_mode-by_signature AND
       is_context-aggregation_fields IS INITIAL.
      add_finding(
        EXPORTING iv_target_id = is_context-target_profile-target_id
                  iv_object_type = /fcbp/if_glt_config_types=>c_object_type-aggregation_policy
                  iv_object_key = is_context-aggregation_policy-aggregation_profile_id
                  iv_check_id = 'GLT_AGSP_CFG_001'
                  iv_code = 'AGGR_FIELDS_EMPTY'
                  iv_text = 'BY_SIGNATURE aggregation requires at least one active field.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    LOOP AT is_context-aggregation_fields INTO DATA(ls_field).
      IF mo_signature->is_supported_field( ls_field-field_name ) = abap_false.
        add_finding(
          EXPORTING iv_target_id = is_context-target_profile-target_id
                    iv_object_type = /fcbp/if_glt_config_types=>c_object_type-aggregation_field
                    iv_object_key = ls_field-field_name
                    iv_check_id = 'GLT_AGSP_CFG_002'
                    iv_code = 'AGGR_FIELD_UNSUPPORTED'
                    iv_text = |Aggregation field { ls_field-field_name } is not supported.|
          CHANGING ct_finding = rt_finding ).
      ENDIF.
    ENDLOOP.

    IF is_context-aggregation_policy-netting_allowed = abap_true.
      add_finding(
        EXPORTING iv_target_id = is_context-target_profile-target_id
                  iv_object_type = /fcbp/if_glt_config_types=>c_object_type-aggregation_policy
                  iv_object_key = is_context-aggregation_policy-aggregation_profile_id
                  iv_check_id = 'GLT_AGSP_CFG_005'
                  iv_code = 'NETTING_NEEDS_POLICY'
                  iv_text = 'Netting is blocked until explicit trace/audit behavior is defined.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    CASE is_context-split_policy-balance_scope.
      WHEN '' OR /fcbp/if_glt_pkg_types=>c_balance_scope-document
        OR /fcbp/if_glt_pkg_types=>c_balance_scope-company_code_currency
        OR /fcbp/if_glt_pkg_types=>c_balance_scope-company_code_currency_ledger
        OR /fcbp/if_glt_pkg_types=>c_balance_scope-document_currency_ledger.
      WHEN OTHERS.
        add_finding(
          EXPORTING iv_target_id = is_context-target_profile-target_id
                    iv_object_type = /fcbp/if_glt_config_types=>c_object_type-split_policy
                    iv_object_key = is_context-split_policy-split_profile_id
                    iv_check_id = 'GLT_AGSP_CFG_003'
                    iv_code = 'BALANCE_SCOPE_UNSUPPORTED'
                    iv_text = 'Split balance scope is not supported.'
          CHANGING ct_finding = rt_finding ).
    ENDCASE.

    IF is_context-split_policy-max_lines_per_doc < 0 OR is_context-split_policy-max_amount < 0.
      add_finding(
        EXPORTING iv_target_id = is_context-target_profile-target_id
                  iv_object_type = /fcbp/if_glt_config_types=>c_object_type-split_policy
                  iv_object_key = is_context-split_policy-split_profile_id
                  iv_check_id = 'GLT_AGSP_CFG_004'
                  iv_code = 'SPLIT_LIMIT_INVALID'
                  iv_text = 'Split policy limits must not be negative.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.
  ENDMETHOD.

  METHOD add_finding.
    DATA(ls_finding) = VALUE /fcbp/if_glt_config_types=>ty_health_finding(
      health_run_id = |AGS-{ sy-datum }-{ sy-uzeit }|
      target_id = iv_target_id
      config_object_type = iv_object_type
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
