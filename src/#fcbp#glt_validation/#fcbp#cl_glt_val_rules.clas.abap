"! Deterministic package validation rule catalogue.
CLASS /fcbp/cl_glt_val_rules DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_val_rule_eval.

    METHODS constructor
      IMPORTING
        io_finding TYPE REF TO /fcbp/cl_glt_val_finding OPTIONAL.

  PRIVATE SECTION.
    DATA mo_finding TYPE REF TO /fcbp/cl_glt_val_finding.

    METHODS add_finding
      IMPORTING
        is_evidence          TYPE /fcbp/if_glt_val_types=>ty_package_evidence
        iv_rule_id           TYPE char30
        iv_category          TYPE char30
        iv_message_code      TYPE char40
        iv_operator_text     TYPE char220
        iv_field_name        TYPE char40 OPTIONAL
        iv_outdoc_id         TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id OPTIONAL
        iv_line_no           TYPE numc6 OPTIONAL
        iv_remediation_owner TYPE char20 OPTIONAL
        iv_severity          TYPE char10 DEFAULT /fcbp/if_glt_types=>c_severity-error
        iv_blocking          TYPE abap_bool DEFAULT abap_true
      CHANGING
        ct_finding           TYPE /fcbp/if_glt_val_types=>tt_finding.

    METHODS evaluate_operational
      IMPORTING is_evidence TYPE /fcbp/if_glt_val_types=>ty_package_evidence
      CHANGING  ct_finding  TYPE /fcbp/if_glt_val_types=>tt_finding.

    METHODS evaluate_structural
      IMPORTING is_evidence TYPE /fcbp/if_glt_val_types=>ty_package_evidence
      CHANGING  ct_finding  TYPE /fcbp/if_glt_val_types=>tt_finding.

    METHODS evaluate_target
      IMPORTING is_evidence TYPE /fcbp/if_glt_val_types=>ty_package_evidence
      CHANGING  ct_finding  TYPE /fcbp/if_glt_val_types=>tt_finding.

    METHODS evaluate_accounting
      IMPORTING is_evidence TYPE /fcbp/if_glt_val_types=>ty_package_evidence
      CHANGING  ct_finding  TYPE /fcbp/if_glt_val_types=>tt_finding.

    METHODS evaluate_traceability
      IMPORTING is_evidence TYPE /fcbp/if_glt_val_types=>ty_package_evidence
      CHANGING  ct_finding  TYPE /fcbp/if_glt_val_types=>tt_finding.

    METHODS evaluate_mapping
      IMPORTING is_evidence TYPE /fcbp/if_glt_val_types=>ty_package_evidence
      CHANGING  ct_finding  TYPE /fcbp/if_glt_val_types=>tt_finding.

    METHODS evaluate_configured_rules
      IMPORTING
        is_evidence TYPE /fcbp/if_glt_val_types=>ty_package_evidence
        it_rule     TYPE /fcbp/if_glt_config_types=>tt_validation_rule
      CHANGING
        ct_finding  TYPE /fcbp/if_glt_val_types=>tt_finding.

ENDCLASS.

CLASS /fcbp/cl_glt_val_rules IMPLEMENTATION.

  METHOD constructor.
    IF io_finding IS BOUND.
      mo_finding = io_finding.
    ELSE.
      mo_finding = NEW /fcbp/cl_glt_val_finding( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_rule_eval~evaluate.
    DATA(lt_rule) = it_rule.
    SORT lt_rule BY rule_category rule_id version target_scope field_scope.

    evaluate_operational( EXPORTING is_evidence = is_evidence CHANGING ct_finding = rt_finding ).
    evaluate_structural( EXPORTING is_evidence = is_evidence CHANGING ct_finding = rt_finding ).
    evaluate_target( EXPORTING is_evidence = is_evidence CHANGING ct_finding = rt_finding ).
    evaluate_accounting( EXPORTING is_evidence = is_evidence CHANGING ct_finding = rt_finding ).
    evaluate_traceability( EXPORTING is_evidence = is_evidence CHANGING ct_finding = rt_finding ).
    evaluate_mapping( EXPORTING is_evidence = is_evidence CHANGING ct_finding = rt_finding ).
    evaluate_configured_rules( EXPORTING is_evidence = is_evidence it_rule = lt_rule CHANGING ct_finding = rt_finding ).
  ENDMETHOD.

  METHOD evaluate_operational.
    IF is_evidence-transfer_found = abap_false OR is_evidence-transfer-header-transfer_id IS INITIAL.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-transfer_exists
                  iv_category = /fcbp/if_glt_val_types=>c_category-structural
                  iv_message_code = 'TRANSFER_MISSING'
                  iv_operator_text = 'Transfer root must exist before package validation.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-operations
        CHANGING ct_finding = ct_finding ).
      RETURN.
    ENDIF.

    IF is_evidence-transfer-header-current_package_id IS INITIAL.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-current_package
                  iv_category = /fcbp/if_glt_val_types=>c_category-structural
                  iv_message_code = 'CURRENT_PACKAGE_MISSING'
                  iv_operator_text = 'Transfer root must reference the current package before validation.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-operations
        CHANGING ct_finding = ct_finding ).
    ENDIF.

    IF is_evidence-transfer-header-current_package_id IS NOT INITIAL AND
       is_evidence-package_graph-package_header-package_id IS NOT INITIAL AND
       is_evidence-transfer-header-current_package_id <> is_evidence-package_graph-package_header-package_id.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-package_current
                  iv_category = /fcbp/if_glt_val_types=>c_category-operational_state
                  iv_message_code = 'PACKAGE_NOT_CURRENT'
                  iv_operator_text = 'Validation package must be the current package on the transfer root.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-operations
        CHANGING ct_finding = ct_finding ).
    ENDIF.

    IF is_evidence-package_graph-package_header-package_id IS NOT INITIAL AND
       ( is_evidence-package_graph-package_header-current_flag = abap_false OR
         is_evidence-package_graph-package_header-superseded_by_package_id IS NOT INITIAL ).
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-package_current
                  iv_category = /fcbp/if_glt_val_types=>c_category-operational_state
                  iv_message_code = 'PACKAGE_SUPERSEDED'
                  iv_operator_text = 'Only current, non-superseded package evidence can be validated.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-operations
        CHANGING ct_finding = ct_finding ).
    ENDIF.

    IF is_evidence-target_refs IS NOT INITIAL.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-target_reference
                  iv_category = /fcbp/if_glt_val_types=>c_category-operational_state
                  iv_message_code = 'TARGET_REFERENCE_EXISTS'
                  iv_operator_text = 'Package validation must not authorize a package that already has target reference evidence.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-operations
        CHANGING ct_finding = ct_finding ).
    ENDIF.

    READ TABLE is_evidence-attempts TRANSPORTING NO FIELDS
      WITH KEY outcome = /fcbp/if_glt_types=>c_attempt_outcome-unknown.
    IF sy-subrc = 0.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-unknown_work
                  iv_category = /fcbp/if_glt_val_types=>c_category-operational_state
                  iv_message_code = 'UNKNOWN_CONFIRMATION_EXISTS'
                  iv_operator_text = 'Unknown confirmation evidence blocks package reuse until status is resolved.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-operations
        CHANGING ct_finding = ct_finding ).
    ENDIF.
  ENDMETHOD.

  METHOD evaluate_structural.
    IF is_evidence-package_found = abap_false OR is_evidence-package_graph-package_header-package_id IS INITIAL.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-current_package
                  iv_category = /fcbp/if_glt_val_types=>c_category-structural
                  iv_message_code = 'PACKAGE_MISSING'
                  iv_operator_text = 'Package header evidence is required before validation.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-operations
        CHANGING ct_finding = ct_finding ).
      RETURN.
    ENDIF.

    IF is_evidence-package_graph-package_header-transfer_id <> is_evidence-transfer-header-transfer_id.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-package_owner
                  iv_category = /fcbp/if_glt_val_types=>c_category-structural
                  iv_message_code = 'PACKAGE_TRANSFER_MISMATCH'
                  iv_operator_text = 'Package header transfer id must match the transfer root.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-operations
        CHANGING ct_finding = ct_finding ).
    ENDIF.

    IF is_evidence-package_graph-outdocs IS INITIAL.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-outdoc_exists
                  iv_category = /fcbp/if_glt_val_types=>c_category-structural
                  iv_message_code = 'OUTDOC_MISSING'
                  iv_operator_text = 'At least one outbound document is required.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-operations
        CHANGING ct_finding = ct_finding ).
    ENDIF.

    LOOP AT is_evidence-package_graph-outdocs INTO DATA(ls_doc).
      READ TABLE is_evidence-package_graph-canonical_lines TRANSPORTING NO FIELDS
        WITH KEY outdoc_id = ls_doc-outdoc_id.
      IF sy-subrc <> 0.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = /fcbp/if_glt_val_types=>c_rule-outdoc_has_lines
                    iv_category = /fcbp/if_glt_val_types=>c_category-structural
                    iv_message_code = 'OUTDOC_EMPTY'
                    iv_operator_text = 'Every outbound document must contain at least one canonical line.'
                    iv_outdoc_id = ls_doc-outdoc_id
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-operations
          CHANGING ct_finding = ct_finding ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD evaluate_target.
    IF is_evidence-target_profile_found = abap_false OR is_evidence-target_profile-target_id IS INITIAL.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-target_profile
                  iv_category = /fcbp/if_glt_val_types=>c_category-target_compatibility
                  iv_message_code = 'TARGET_PROFILE_MISSING'
                  iv_operator_text = 'Target profile evidence is required for package validation.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-config
        CHANGING ct_finding = ct_finding ).
      RETURN.
    ENDIF.

    IF is_evidence-target_profile-active_flag = abap_false OR
       is_evidence-target_profile-target_id <> is_evidence-package_graph-package_header-target_id.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-target_profile
                  iv_category = /fcbp/if_glt_val_types=>c_category-target_compatibility
                  iv_message_code = 'TARGET_PROFILE_INVALID'
                  iv_operator_text = 'Target profile must be active and match package target id.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-config
        CHANGING ct_finding = ct_finding ).
    ENDIF.

    IF is_evidence-target_profile-adapter_type IS INITIAL OR
       is_evidence-target_profile-transfer_mode IS INITIAL.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-adapter_compatibility
                  iv_category = /fcbp/if_glt_val_types=>c_category-target_compatibility
                  iv_message_code = 'ADAPTER_MODE_MISSING'
                  iv_operator_text = 'Adapter type and transfer mode are required before mapping and adapter execution.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-config
        CHANGING ct_finding = ct_finding ).
    ENDIF.

    IF is_evidence-target_profile-confirmation_mode = /fcbp/if_glt_types=>c_confirmation_mode-async_query AND
       is_evidence-policy_context-confirmation_policy_id IS INITIAL.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-confirmation_policy
                  iv_category = /fcbp/if_glt_val_types=>c_category-target_compatibility
                  iv_message_code = 'CONFIRMATION_POLICY_MISSING'
                  iv_operator_text = 'Asynchronous confirmation requires confirmation policy evidence.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-config
        CHANGING ct_finding = ct_finding ).
    ENDIF.
  ENDMETHOD.

  METHOD evaluate_accounting.
    LOOP AT is_evidence-package_graph-canonical_lines INTO DATA(ls_line).
      IF ls_line-amount <= 0.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = /fcbp/if_glt_val_types=>c_rule-positive_amount
                    iv_category = /fcbp/if_glt_val_types=>c_category-accounting
                    iv_message_code = 'AMOUNT_NOT_POSITIVE'
                    iv_operator_text = 'Canonical line amount must be greater than zero unless an explicit zero-line policy is implemented.'
                    iv_field_name = 'AMOUNT'
                    iv_outdoc_id = ls_line-outdoc_id
                    iv_line_no = ls_line-line_no
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-source
          CHANGING ct_finding = ct_finding ).
      ENDIF.

      IF ls_line-debit_credit <> 'S' AND ls_line-debit_credit <> 'H' AND
         ls_line-debit_credit <> 'D' AND ls_line-debit_credit <> 'C'.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = /fcbp/if_glt_val_types=>c_rule-debit_credit
                    iv_category = /fcbp/if_glt_val_types=>c_category-accounting
                    iv_message_code = 'DEBIT_CREDIT_INVALID'
                    iv_operator_text = 'Canonical line debit/credit indicator must be deterministic before mapping.'
                    iv_field_name = 'DEBIT_CREDIT'
                    iv_outdoc_id = ls_line-outdoc_id
                    iv_line_no = ls_line-line_no
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-source
          CHANGING ct_finding = ct_finding ).
      ENDIF.

      IF ls_line-currency IS INITIAL.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = /fcbp/if_glt_val_types=>c_rule-currency
                    iv_category = /fcbp/if_glt_val_types=>c_category-accounting
                    iv_message_code = 'CURRENCY_MISSING'
                    iv_operator_text = 'Canonical line currency is required.'
                    iv_field_name = 'CURRENCY'
                    iv_outdoc_id = ls_line-outdoc_id
                    iv_line_no = ls_line-line_no
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-source
          CHANGING ct_finding = ct_finding ).
      ENDIF.

      IF ls_line-company_code IS INITIAL.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = /fcbp/if_glt_val_types=>c_rule-company_code
                    iv_category = /fcbp/if_glt_val_types=>c_category-accounting
                    iv_message_code = 'COMPANY_CODE_MISSING'
                    iv_operator_text = 'Canonical line company code is required.'
                    iv_field_name = 'COMPANY_CODE'
                    iv_outdoc_id = ls_line-outdoc_id
                    iv_line_no = ls_line-line_no
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-source
          CHANGING ct_finding = ct_finding ).
      ENDIF.

      IF ls_line-gl_account IS INITIAL.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = /fcbp/if_glt_val_types=>c_rule-gl_account
                    iv_category = /fcbp/if_glt_val_types=>c_category-accounting
                    iv_message_code = 'GL_ACCOUNT_MISSING'
                    iv_operator_text = 'Canonical GL account or approved placeholder is required before mapping.'
                    iv_field_name = 'GL_ACCOUNT'
                    iv_outdoc_id = ls_line-outdoc_id
                    iv_line_no = ls_line-line_no
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-mapping
          CHANGING ct_finding = ct_finding ).
      ENDIF.
    ENDLOOP.

    LOOP AT is_evidence-package_graph-outdocs INTO DATA(ls_doc).
      IF ls_doc-balance_status = /fcbp/if_glt_pkg_types=>c_balance_status-unbalanced OR
         ls_doc-difference_amount <> 0.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = /fcbp/if_glt_val_types=>c_rule-balance
                    iv_category = /fcbp/if_glt_val_types=>c_category-accounting
                    iv_message_code = 'OUTDOC_UNBALANCED'
                    iv_operator_text = 'Outbound document debit and credit totals must balance before mapping.'
                    iv_outdoc_id = ls_doc-outdoc_id
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-source
          CHANGING ct_finding = ct_finding ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD evaluate_traceability.
    LOOP AT is_evidence-package_graph-canonical_lines INTO DATA(ls_line).
      DATA(lv_trace_count) = 0.
      LOOP AT is_evidence-package_graph-source_trace INTO DATA(ls_trace) WHERE line_id = ls_line-line_id.
        lv_trace_count = lv_trace_count + 1.
        IF ls_trace-source_type IS INITIAL OR
           ls_trace-source_reference IS INITIAL OR
           ls_trace-source_hash IS INITIAL.
          add_finding(
            EXPORTING is_evidence = is_evidence
                      iv_rule_id = /fcbp/if_glt_val_types=>c_rule-trace_identity
                      iv_category = /fcbp/if_glt_val_types=>c_category-traceability
                      iv_message_code = 'TRACE_IDENTITY_MISSING'
                      iv_operator_text = 'Source trace must preserve source type, source reference, and source hash.'
                      iv_outdoc_id = ls_line-outdoc_id
                      iv_line_no = ls_line-line_no
                      iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-source
            CHANGING ct_finding = ct_finding ).
        ENDIF.
      ENDLOOP.

      IF lv_trace_count = 0.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = /fcbp/if_glt_val_types=>c_rule-trace_exists
                    iv_category = /fcbp/if_glt_val_types=>c_category-traceability
                    iv_message_code = 'TRACE_MISSING'
                    iv_operator_text = 'Every canonical line must have at least one source trace row.'
                    iv_outdoc_id = ls_line-outdoc_id
                    iv_line_no = ls_line-line_no
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-source
          CHANGING ct_finding = ct_finding ).
      ELSEIF ls_line-source_count > 0 AND lv_trace_count <> ls_line-source_count.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = /fcbp/if_glt_val_types=>c_rule-trace_count
                    iv_category = /fcbp/if_glt_val_types=>c_category-traceability
                    iv_message_code = 'TRACE_COUNT_MISMATCH'
                    iv_operator_text = 'Source trace row count must match canonical line source count where available.'
                    iv_outdoc_id = ls_line-outdoc_id
                    iv_line_no = ls_line-line_no
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-source
          CHANGING ct_finding = ct_finding ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD evaluate_mapping.
    IF is_evidence-policy_context-mapping_policy_id IS INITIAL.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = /fcbp/if_glt_val_types=>c_rule-mapping_policy
                  iv_category = /fcbp/if_glt_val_types=>c_category-mapping_prereq
                  iv_message_code = 'MAPPING_POLICY_MISSING'
                  iv_operator_text = 'Mapping policy evidence is required before Mapping can start.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-config
        CHANGING ct_finding = ct_finding ).
    ENDIF.
  ENDMETHOD.

  METHOD evaluate_configured_rules.
    IF is_evidence-policy_context-validation_profile_id IS INITIAL.
      add_finding(
        EXPORTING is_evidence = is_evidence
                  iv_rule_id = 'GLT_PVAL_CFG'
                  iv_category = /fcbp/if_glt_val_types=>c_category-target_compatibility
                  iv_message_code = 'VALIDATION_PROFILE_MISSING'
                  iv_operator_text = 'Validation profile evidence is required in the policy context.'
                  iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-config
        CHANGING ct_finding = ct_finding ).
      RETURN.
    ENDIF.

    LOOP AT it_rule INTO DATA(ls_rule) WHERE active_flag = abap_true.
      IF ls_rule-policy_expression_ref IS NOT INITIAL AND
         ls_rule-policy_expression_ref <> 'REQUIRE_FIELD' AND
         ls_rule-policy_expression_ref <> 'ALLOW_PASS_THROUGH' AND
         ls_rule-policy_expression_ref <> 'BALANCE_BY_CURRENCY'.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = ls_rule-rule_id
                    iv_category = ls_rule-rule_category
                    iv_message_code = 'EXPRESSION_UNSUPPORTED'
                    iv_operator_text = 'Validation policy expression reference is not implemented in the scaffold.'
                    iv_field_name = ls_rule-field_scope
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-config
                    iv_severity = ls_rule-severity
                    iv_blocking = ls_rule-blocking_flag
          CHANGING ct_finding = ct_finding ).
      ENDIF.

      IF ls_rule-policy_expression_ref = 'REQUIRE_FIELD' AND ls_rule-field_scope IS INITIAL.
        add_finding(
          EXPORTING is_evidence = is_evidence
                    iv_rule_id = ls_rule-rule_id
                    iv_category = ls_rule-rule_category
                    iv_message_code = 'REQUIRE_FIELD_SCOPE_MISSING'
                    iv_operator_text = 'REQUIRE_FIELD validation rule must define FIELD_SCOPE.'
                    iv_remediation_owner = /fcbp/if_glt_val_types=>c_remediation_owner-config
                    iv_severity = ls_rule-severity
                    iv_blocking = ls_rule-blocking_flag
          CHANGING ct_finding = ct_finding ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_finding.
    APPEND mo_finding->build(
      iv_transfer_id       = is_evidence-transfer-header-transfer_id
      iv_package_id        = is_evidence-package_graph-package_header-package_id
      iv_target_id         = is_evidence-package_graph-package_header-target_id
      iv_rule_id           = iv_rule_id
      iv_rule_category     = iv_category
      iv_severity          = iv_severity
      iv_blocking          = iv_blocking
      iv_message_code      = iv_message_code
      iv_operator_text     = iv_operator_text
      iv_outdoc_id         = iv_outdoc_id
      iv_line_no           = iv_line_no
      iv_field_name        = iv_field_name
      iv_remediation_owner = iv_remediation_owner
      iv_policy_version    = is_evidence-policy_context-validation_version ) TO ct_finding.
  ENDMETHOD.

ENDCLASS.
