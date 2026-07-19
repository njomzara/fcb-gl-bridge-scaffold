"! Policy-driven splitter scaffold. Package Builder owns persistence.
CLASS /fcbp/cl_glt_splitter DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_splitter.

    METHODS constructor
      IMPORTING
        io_key_builder TYPE REF TO /fcbp/if_glt_split_key_builder OPTIONAL
        io_balance     TYPE REF TO /fcbp/if_glt_balance_check OPTIONAL.

  PRIVATE SECTION.
    DATA mo_key_builder TYPE REF TO /fcbp/if_glt_split_key_builder.
    DATA mo_balance TYPE REF TO /fcbp/if_glt_balance_check.

    METHODS validate_policy
      IMPORTING
        is_policy TYPE /fcbp/if_glt_config_types=>ty_split_policy
      RAISING
        /fcbp/cx_glt_preparation.

    METHODS validate_required_dimensions
      IMPORTING
        is_line   TYPE /fcbp/if_glt_pkg_types=>ty_canonical_line
        is_policy TYPE /fcbp/if_glt_config_types=>ty_split_policy
      RAISING
        /fcbp/cx_glt_preparation.

    METHODS compact_hash
      IMPORTING
        iv_input       TYPE string
      RETURNING
        VALUE(rv_hash) TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_splitter IMPLEMENTATION.

  METHOD constructor.
    IF io_key_builder IS BOUND.
      mo_key_builder = io_key_builder.
    ELSE.
      mo_key_builder = NEW /fcbp/cl_glt_split_key_builder( ).
    ENDIF.

    IF io_balance IS BOUND.
      mo_balance = io_balance.
    ELSE.
      mo_balance = NEW /fcbp/cl_glt_balance_check( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_splitter~split.
    validate_policy( is_split_policy ).

    DATA(lt_line) = it_canonical_line.
    SORT lt_line BY company_code currency posting_date document_type ledger_group aggr_signature_hash line_id.
    DATA lv_last_split_key TYPE char64.
    DATA lv_last_outdoc_id TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id.

    LOOP AT lt_line INTO DATA(ls_line).
      validate_required_dimensions( is_line = ls_line is_policy = is_split_policy ).

      DATA(ls_key) = mo_key_builder->build_key(
        is_line         = ls_line
        is_split_policy = is_split_policy ).

      IF ls_key-split_key_hash <> lv_last_split_key.
        CLEAR lv_last_outdoc_id.
      ENDIF.
      READ TABLE rs_result-outdocs ASSIGNING FIELD-SYMBOL(<ls_doc>)
        WITH KEY outdoc_id = lv_last_outdoc_id.
      IF sy-subrc <> 0.
        DATA(lv_doc_seq) = lines( rs_result-outdocs ) + 1.
        DATA(ls_doc) = VALUE /fcbp/if_glt_pkg_types=>ty_outdoc(
          package_id = is_policy_context-package_id
          outdoc_id = |DOC-{ lv_doc_seq }|
          document_sequence = lv_doc_seq
          company_code = ls_line-company_code
          posting_date = ls_line-posting_date
          document_date = ls_line-posting_date
          gl_doc_type = ls_line-document_type
          currency = ls_line-currency
          ledger_group = ls_line-ledger_group
          reference = ls_key-split_key_hash
          header_text = |GL Bridge package split { lv_doc_seq }|
          balance_status = /fcbp/if_glt_pkg_types=>c_balance_status-not_checked ).
        APPEND ls_doc TO rs_result-outdocs ASSIGNING <ls_doc>.
        lv_last_split_key = ls_key-split_key_hash.
        lv_last_outdoc_id = <ls_doc>-outdoc_id.
      ELSE.
        DATA lv_current_debit TYPE p LENGTH 16 DECIMALS 2.
        DATA lv_current_credit TYPE p LENGTH 16 DECIMALS 2.
        CLEAR: lv_current_debit, lv_current_credit.
        LOOP AT rs_result-canonical_lines INTO DATA(ls_current_line)
          WHERE outdoc_id = <ls_doc>-outdoc_id.
          CASE ls_current_line-debit_credit.
            WHEN 'D' OR 'S'.
              lv_current_debit = lv_current_debit + ls_current_line-amount.
            WHEN 'C' OR 'H'.
              lv_current_credit = lv_current_credit + ls_current_line-amount.
          ENDCASE.
        ENDLOOP.

        DATA(lv_next_debit) = lv_current_debit.
        DATA(lv_next_credit) = lv_current_credit.
        CASE ls_line-debit_credit.
          WHEN 'D' OR 'S'.
            lv_next_debit = lv_next_debit + ls_line-amount.
          WHEN 'C' OR 'H'.
            lv_next_credit = lv_next_credit + ls_line-amount.
        ENDCASE.

        DATA(lv_line_limit_reached) = xsdbool(
          is_split_policy-max_lines_per_doc > 0 AND
          <ls_doc>-line_count + 1 > is_split_policy-max_lines_per_doc ).
        DATA(lv_amount_limit_reached) = xsdbool(
          is_split_policy-max_amount > 0 AND
          ( lv_next_debit > is_split_policy-max_amount OR
            lv_next_credit > is_split_policy-max_amount ) ).

        IF lv_current_debit = lv_current_credit AND
           ( lv_line_limit_reached = abap_true OR lv_amount_limit_reached = abap_true ).
          lv_doc_seq = lines( rs_result-outdocs ) + 1.
          ls_doc = VALUE #(
            package_id = is_policy_context-package_id
            outdoc_id = |DOC-{ lv_doc_seq }|
            document_sequence = lv_doc_seq
            company_code = ls_line-company_code
            posting_date = ls_line-posting_date
            document_date = ls_line-posting_date
            gl_doc_type = ls_line-document_type
            currency = ls_line-currency
            ledger_group = ls_line-ledger_group
            reference = compact_hash( |{ ls_key-split_key_hash }:CONT:{ lv_doc_seq }| )
            header_text = |GL Bridge package split { lv_doc_seq }|
            balance_status = /fcbp/if_glt_pkg_types=>c_balance_status-not_checked ).
          APPEND ls_doc TO rs_result-outdocs ASSIGNING <ls_doc>.
          lv_last_outdoc_id = <ls_doc>-outdoc_id.
        ENDIF.
      ENDIF.

      <ls_doc>-line_count = <ls_doc>-line_count + 1.
      ls_line-package_id = is_policy_context-package_id.
      ls_line-outdoc_id = <ls_doc>-outdoc_id.
      ls_line-line_no = <ls_doc>-line_count.

      APPEND ls_line TO rs_result-canonical_lines.
    ENDLOOP.

    LOOP AT it_source_trace INTO DATA(ls_trace).
      READ TABLE rs_result-canonical_lines INTO DATA(ls_assigned) WITH KEY line_id = ls_trace-line_id.
      IF sy-subrc = 0.
        ls_trace-package_id = is_policy_context-package_id.
        ls_trace-outdoc_id = ls_assigned-outdoc_id.
        ls_trace-line_no = ls_assigned-line_no.
      ENDIF.
      APPEND ls_trace TO rs_result-source_trace.
    ENDLOOP.

    LOOP AT rs_result-outdocs ASSIGNING <ls_doc>.
      DATA(lt_doc_line) = VALUE /fcbp/if_glt_pkg_types=>tt_canonical_line( ).
      LOOP AT rs_result-canonical_lines INTO DATA(ls_doc_line) WHERE outdoc_id = <ls_doc>-outdoc_id.
        APPEND ls_doc_line TO lt_doc_line.
      ENDLOOP.

      DATA(ls_balance) = mo_balance->check_document(
        is_outdoc       = <ls_doc>
        it_line         = lt_doc_line
        is_split_policy = is_split_policy ).
      <ls_doc>-debit_amount = ls_balance-debit_amount.
      <ls_doc>-credit_amount = ls_balance-credit_amount.
      <ls_doc>-difference_amount = ls_balance-difference_amount.
      <ls_doc>-balance_status = ls_balance-balance_status.
      IF is_split_policy-max_lines_per_doc > 0 AND
         <ls_doc>-line_count > is_split_policy-max_lines_per_doc.
        APPEND VALUE #(
          rule_id = 'GLT_SPL_007'
          category = /fcbp/if_glt_aggr_types=>c_prep_category-split
          severity = /fcbp/if_glt_types=>c_severity-error
          blocking = abap_true
          outdoc_id = <ls_doc>-outdoc_id
          operator_text = 'Line-count limit cannot be satisfied without breaking document balance.' ) TO rs_result-messages.
      ENDIF.
      IF is_split_policy-max_amount > 0 AND
         ( ls_balance-debit_amount > is_split_policy-max_amount OR
           ls_balance-credit_amount > is_split_policy-max_amount ).
        APPEND VALUE #(
          rule_id = 'GLT_SPL_008'
          category = /fcbp/if_glt_aggr_types=>c_prep_category-split
          severity = /fcbp/if_glt_types=>c_severity-error
          blocking = abap_true
          outdoc_id = <ls_doc>-outdoc_id
          operator_text = 'Amount limit cannot be satisfied without breaking document balance.' ) TO rs_result-messages.
      ENDIF.
      <ls_doc>-payload_hash = compact_hash(
        |DOC:{ <ls_doc>-outdoc_id }:{ <ls_doc>-line_count }:{ <ls_doc>-debit_amount }:{ <ls_doc>-credit_amount }:{ <ls_doc>-difference_amount }| ).
      APPEND ls_balance TO rs_result-balance_results.
      IF ls_balance-blocking = abap_true.
        APPEND ls_balance-message TO rs_result-messages.
      ENDIF.
    ENDLOOP.

    IF rs_result-outdocs IS INITIAL.
      APPEND VALUE /fcbp/if_glt_aggr_types=>ty_preparation_message(
        rule_id = 'GLT_SPL_010'
        category = /fcbp/if_glt_aggr_types=>c_prep_category-split
        severity = /fcbp/if_glt_types=>c_severity-error
        blocking = abap_true
        operator_text = 'Split result created no outbound document.' ) TO rs_result-messages.
    ENDIF.

    rs_result-split_output_hash = compact_hash(
      |SPLIT:{ is_policy_context-policy_context_id }:{ is_split_policy-split_profile_id }:{ lines( rs_result-outdocs ) }:{ lines( rs_result-canonical_lines ) }| ).
  ENDMETHOD.

  METHOD validate_policy.
    IF is_policy-split_profile_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          rule_id        = 'GLT_SPL_001'
          operator_text  = 'Split policy is missing.'.
    ENDIF.

    IF is_policy-active_flag = abap_false OR is_policy-config_hash IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          profile_id     = is_policy-split_profile_id
          rule_id        = 'GLT_SPL_002'
          operator_text  = 'Split policy is not active or lacks config hash.'.
    ENDIF.

    IF is_policy-max_lines_per_doc < 0 OR is_policy-max_amount < 0.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          profile_id     = is_policy-split_profile_id
          rule_id        = 'GLT_SPL_003'
          operator_text  = 'Split limits must not be negative.'.
    ENDIF.

    CASE is_policy-balance_scope.
      WHEN /fcbp/if_glt_pkg_types=>c_balance_scope-document.
      WHEN /fcbp/if_glt_pkg_types=>c_balance_scope-company_code_currency.
        IF is_policy-split_by_company_code = abap_false OR is_policy-split_by_currency = abap_false.
          RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation EXPORTING
            error_category = /fcbp/if_glt_types=>c_error_category-config profile_id = is_policy-split_profile_id
            rule_id = 'GLT_AGSP_CFG_003' field_name = 'BALANCE_SCOPE'
            operator_text = 'Company/currency balance requires both split dimensions.'.
        ENDIF.
      WHEN /fcbp/if_glt_pkg_types=>c_balance_scope-company_code_currency_ledger.
        IF is_policy-split_by_company_code = abap_false OR is_policy-split_by_currency = abap_false OR is_policy-split_by_ledger_group = abap_false.
          RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation EXPORTING
            error_category = /fcbp/if_glt_types=>c_error_category-config profile_id = is_policy-split_profile_id
            rule_id = 'GLT_AGSP_CFG_003' field_name = 'BALANCE_SCOPE'
            operator_text = 'Company/currency/ledger balance requires all matching split dimensions.'.
        ENDIF.
      WHEN /fcbp/if_glt_pkg_types=>c_balance_scope-document_currency_ledger.
        IF is_policy-split_by_currency = abap_false OR is_policy-split_by_ledger_group = abap_false.
          RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation EXPORTING
            error_category = /fcbp/if_glt_types=>c_error_category-config profile_id = is_policy-split_profile_id
            rule_id = 'GLT_AGSP_CFG_003' field_name = 'BALANCE_SCOPE'
            operator_text = 'Document/currency/ledger balance requires currency and ledger split dimensions.'.
        ENDIF.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config profile_id = is_policy-split_profile_id
          rule_id = 'GLT_AGSP_CFG_003' field_name = 'BALANCE_SCOPE'
          operator_text = 'Split balance scope is required and must be supported.'.
    ENDCASE.
  ENDMETHOD.

  METHOD validate_required_dimensions.
    DATA lv_field_name TYPE char40.
    IF is_policy-split_by_company_code = abap_true AND is_line-company_code IS INITIAL.
      lv_field_name = 'COMPANY_CODE'.
    ELSEIF is_policy-split_by_currency = abap_true AND is_line-currency IS INITIAL.
      lv_field_name = 'CURRENCY'.
    ELSEIF is_policy-split_by_posting_date = abap_true AND is_line-posting_date IS INITIAL.
      lv_field_name = 'POSTING_DATE'.
    ELSEIF is_policy-split_by_gl_doc_type = abap_true AND is_line-document_type IS INITIAL.
      lv_field_name = 'DOCUMENT_TYPE'.
    ELSEIF is_policy-split_by_ledger_group = abap_true AND is_line-ledger_group IS INITIAL.
      lv_field_name = 'LEDGER_GROUP'.
    ENDIF.

    IF lv_field_name IS NOT INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-validation
        profile_id = is_policy-split_profile_id line_id = is_line-line_id
        rule_id = COND #( WHEN lv_field_name = 'LEDGER_GROUP' THEN 'GLT_BAL_004' ELSE 'GLT_SPL_005' )
        field_name = lv_field_name
        operator_text = |Required split field { lv_field_name } is missing from canonical line.|.
    ENDIF.
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 24 THEN lv_len ELSE 24 ).
    rv_hash = |SPL-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

ENDCLASS.
