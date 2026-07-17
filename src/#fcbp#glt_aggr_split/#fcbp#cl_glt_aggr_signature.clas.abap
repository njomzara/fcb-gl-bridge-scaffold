"! Signature scaffold. Replace compact hash with released tenant-approved hash API.
CLASS /fcbp/cl_glt_aggr_signature DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_aggr_signature.

  PRIVATE SECTION.
    METHODS read_field
      IMPORTING
        is_source_line TYPE /fcbp/if_glt_pkg_types=>ty_source_gl_line
        iv_field_name  TYPE char40
      RETURNING
        VALUE(rv_value) TYPE string.

    METHODS normalize_value
      IMPORTING
        iv_value TYPE string
        iv_rule  TYPE char30
      RETURNING
        VALUE(rv_value) TYPE string.

    METHODS compact_hash
      IMPORTING
        iv_input       TYPE string
      RETURNING
        VALUE(rv_hash) TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_aggr_signature IMPLEMENTATION.

  METHOD /fcbp/if_glt_aggr_signature~build_signature.
    IF is_policy-grouping_mode IS INITIAL OR
       is_policy-grouping_mode = /fcbp/if_glt_pkg_types=>c_grouping_mode-none.
      rs_signature-signature_string = |NONE:{ is_source_line-source_type }:{ is_source_line-source_reference }:{ is_source_line-source_doc_no }:{ is_source_line-source_item_no }:{ is_source_line-source_hash }|.
      rs_signature-signature_hash = compact_hash( rs_signature-signature_string ).
      RETURN.
    ENDIF.

    LOOP AT it_field INTO DATA(ls_field) WHERE include_in_signature = abap_true.
      IF /fcbp/if_glt_aggr_signature~is_supported_field( ls_field-field_name ) = abap_false.
        rs_signature-blocking = abap_true.
        rs_signature-message = VALUE #(
          rule_id = 'GLT_AGG_005'
          category = /fcbp/if_glt_aggr_types=>c_prep_category-aggregation
          severity = /fcbp/if_glt_types=>c_severity-error
          blocking = abap_true
          field_name = ls_field-field_name
          source_reference = is_source_line-source_reference
          operator_text = |Aggregation field { ls_field-field_name } is not supported.| ).
        RETURN.
      ENDIF.

      IF /fcbp/if_glt_aggr_signature~is_supported_normalize_rule( ls_field-normalize_rule ) = abap_false.
        rs_signature-blocking = abap_true.
        rs_signature-message = VALUE #(
          rule_id = 'GLT_AGG_006'
          category = /fcbp/if_glt_aggr_types=>c_prep_category-aggregation
          severity = /fcbp/if_glt_types=>c_severity-error
          blocking = abap_true
          field_name = ls_field-field_name
          source_reference = is_source_line-source_reference
          operator_text = |Normalization rule { ls_field-normalize_rule } is not supported.| ).
        RETURN.
      ENDIF.

      DATA(lv_raw) = read_field(
        is_source_line = is_source_line
        iv_field_name  = ls_field-field_name ).
      DATA(lv_value) = normalize_value(
        iv_value = lv_raw
        iv_rule  = ls_field-normalize_rule ).

      IF ls_field-required_flag = abap_true AND lv_value IS INITIAL.
        rs_signature-blocking = abap_true.
        rs_signature-message = VALUE #(
          rule_id = 'GLT_AGG_007'
          category = /fcbp/if_glt_aggr_types=>c_prep_category-aggregation
          severity = /fcbp/if_glt_types=>c_severity-error
          blocking = abap_true
          field_name = ls_field-field_name
          source_reference = is_source_line-source_reference
          operator_text = |Required aggregation field { ls_field-field_name } is missing.| ).
        RETURN.
      ENDIF.

      DATA(lv_len) = strlen( lv_value ).
      rs_signature-signature_string =
        |{ rs_signature-signature_string }#{ ls_field-field_sequence }:{ ls_field-field_name }={ lv_len }:{ lv_value }|.
    ENDLOOP.

    IF rs_signature-signature_string IS INITIAL.
      rs_signature-blocking = abap_true.
      rs_signature-message = VALUE #(
        rule_id = 'GLT_AGG_004'
        category = /fcbp/if_glt_aggr_types=>c_prep_category-config
        severity = /fcbp/if_glt_types=>c_severity-error
        blocking = abap_true
        operator_text = 'Aggregation profile has no active signature fields.' ).
      RETURN.
    ENDIF.

    rs_signature-signature_hash = compact_hash(
      |AGG:{ is_policy-aggregation_profile_id }:{ is_policy-version }:{ is_policy-config_hash }:{ rs_signature-signature_string }| ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_aggr_signature~is_supported_field.
    CASE iv_field_name.
      WHEN 'COMPANY_CODE' OR 'CHART_OF_ACCOUNTS' OR 'GL_ACCOUNT'
        OR 'DEBIT_CREDIT' OR 'CURRENCY' OR 'PROFIT_CENTER'
        OR 'SEGMENT' OR 'COST_CENTER' OR 'INTERNAL_ORDER'
        OR 'TRADING_PARTNER' OR 'TAX_CODE' OR 'TAX_REPORT_DATE'
        OR 'POSTING_DATE' OR 'DOCUMENT_TYPE' OR 'LEDGER_GROUP'
        OR 'ASSIGNMENT'.
        rv_supported = abap_true.
      WHEN OTHERS.
        rv_supported = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD /fcbp/if_glt_aggr_signature~is_supported_normalize_rule.
    CASE iv_rule.
      WHEN '' OR /fcbp/if_glt_pkg_types=>c_normalize_rule-none
        OR /fcbp/if_glt_pkg_types=>c_normalize_rule-upper_trim
        OR /fcbp/if_glt_pkg_types=>c_normalize_rule-alpha
        OR /fcbp/if_glt_pkg_types=>c_normalize_rule-blank
        OR /fcbp/if_glt_pkg_types=>c_normalize_rule-date.
        rv_supported = abap_true.
      WHEN OTHERS.
        rv_supported = abap_false.
    ENDCASE.
  ENDMETHOD.

  METHOD read_field.
    CASE iv_field_name.
      WHEN 'COMPANY_CODE'. rv_value = is_source_line-company_code.
      WHEN 'CHART_OF_ACCOUNTS'. rv_value = is_source_line-chart_of_accounts.
      WHEN 'GL_ACCOUNT'. rv_value = is_source_line-gl_account.
      WHEN 'DEBIT_CREDIT'. rv_value = is_source_line-debit_credit.
      WHEN 'CURRENCY'. rv_value = is_source_line-currency.
      WHEN 'PROFIT_CENTER'. rv_value = is_source_line-profit_center.
      WHEN 'SEGMENT'. rv_value = is_source_line-segment.
      WHEN 'COST_CENTER'. rv_value = is_source_line-cost_center.
      WHEN 'INTERNAL_ORDER'. rv_value = is_source_line-internal_order.
      WHEN 'TRADING_PARTNER'. rv_value = is_source_line-trading_partner.
      WHEN 'TAX_CODE'. rv_value = is_source_line-tax_code.
      WHEN 'TAX_REPORT_DATE'. rv_value = is_source_line-tax_report_date.
      WHEN 'POSTING_DATE'. rv_value = is_source_line-posting_date.
      WHEN 'DOCUMENT_TYPE'. rv_value = is_source_line-document_type.
      WHEN 'LEDGER_GROUP'. rv_value = is_source_line-ledger_group.
      WHEN 'ASSIGNMENT'. rv_value = is_source_line-assignment.
      WHEN OTHERS. CLEAR rv_value.
    ENDCASE.
  ENDMETHOD.

  METHOD normalize_value.
    rv_value = iv_value.
    CONDENSE rv_value.
    CASE iv_rule.
      WHEN /fcbp/if_glt_pkg_types=>c_normalize_rule-upper_trim.
        TRANSLATE rv_value TO UPPER CASE.
      WHEN /fcbp/if_glt_pkg_types=>c_normalize_rule-alpha.
        TRANSLATE rv_value TO UPPER CASE.
      WHEN /fcbp/if_glt_pkg_types=>c_normalize_rule-blank.
        IF rv_value IS INITIAL.
          rv_value = '<BLANK>'.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 24 THEN lv_len ELSE 24 ).
    rv_hash = |AGH-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

ENDCLASS.
