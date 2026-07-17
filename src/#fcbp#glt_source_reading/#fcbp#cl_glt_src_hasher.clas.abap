"! Canonical source-line hashing scaffold. Replace compact hash with approved hash API.
CLASS /fcbp/cl_glt_src_hasher DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS calculate_line_hash
      IMPORTING
        is_source_line TYPE /fcbp/if_glt_pkg_types=>ty_source_gl_line
      RETURNING
        VALUE(rv_hash) TYPE char64.

    METHODS calculate_source_hash
      IMPORTING
        it_source_line TYPE /fcbp/if_glt_pkg_types=>tt_source_gl_line
      RETURNING
        VALUE(rv_hash) TYPE char64.

  PRIVATE SECTION.
    METHODS canonicalize_line
      IMPORTING
        is_source_line TYPE /fcbp/if_glt_pkg_types=>ty_source_gl_line
      RETURNING
        VALUE(rv_input) TYPE string.

    METHODS add_part
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE string
      CHANGING
        cv_input TYPE string.

    METHODS compact_hash
      IMPORTING
        iv_prefix      TYPE string
        iv_input       TYPE string
      RETURNING
        VALUE(rv_hash) TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_src_hasher IMPLEMENTATION.

  METHOD calculate_line_hash.
    rv_hash = compact_hash(
      iv_prefix = 'SLH'
      iv_input  = canonicalize_line( is_source_line ) ).
  ENDMETHOD.

  METHOD calculate_source_hash.
    DATA(lt_source_line) = it_source_line.
    SORT lt_source_line BY source_type source_reference source_doc_no source_item_no
                           company_code gl_account debit_credit currency source_hash line_hash.
    DATA(lv_input) = ``.
    LOOP AT lt_source_line INTO DATA(ls_source_line).
      add_part(
        EXPORTING
          iv_name  = 'LINE'
          iv_value = COND string( WHEN ls_source_line-source_hash IS INITIAL
                                  THEN calculate_line_hash( ls_source_line )
                                  ELSE ls_source_line-source_hash )
        CHANGING
          cv_input = lv_input ).
    ENDLOOP.
    rv_hash = compact_hash(
      iv_prefix = 'SSH'
      iv_input  = lv_input ).
  ENDMETHOD.

  METHOD canonicalize_line.
    DATA(lv_amount) = |{ is_source_line-amount }|.
    CONDENSE lv_amount NO-GAPS.

    add_part( EXPORTING iv_name = 'SOURCE_TYPE' iv_value = is_source_line-source_type CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'SOURCE_REFERENCE' iv_value = is_source_line-source_reference CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'SOURCE_DOC_NO' iv_value = is_source_line-source_doc_no CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'SOURCE_ITEM_NO' iv_value = is_source_line-source_item_no CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'RECONCILIATION_KEY' iv_value = is_source_line-reconciliation_key CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'COMPANY_CODE' iv_value = is_source_line-company_code CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'CHART_OF_ACCOUNTS' iv_value = is_source_line-chart_of_accounts CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'GL_ACCOUNT' iv_value = is_source_line-gl_account CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'PROFIT_CENTER' iv_value = is_source_line-profit_center CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'SEGMENT' iv_value = is_source_line-segment CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'COST_CENTER' iv_value = is_source_line-cost_center CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'INTERNAL_ORDER' iv_value = is_source_line-internal_order CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'TRADING_PARTNER' iv_value = is_source_line-trading_partner CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'AMOUNT' iv_value = lv_amount CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'CURRENCY' iv_value = is_source_line-currency CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'DEBIT_CREDIT' iv_value = is_source_line-debit_credit CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'TAX_CODE' iv_value = is_source_line-tax_code CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'TAX_REPORT_DATE' iv_value = is_source_line-tax_report_date CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'POSTING_DATE' iv_value = is_source_line-posting_date CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'DOCUMENT_TYPE' iv_value = is_source_line-document_type CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'LEDGER_GROUP' iv_value = is_source_line-ledger_group CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'ASSIGNMENT' iv_value = is_source_line-assignment CHANGING cv_input = rv_input ).
    add_part( EXPORTING iv_name = 'ITEM_TEXT' iv_value = is_source_line-item_text CHANGING cv_input = rv_input ).
  ENDMETHOD.

  METHOD add_part.
    DATA(lv_value) = iv_value.
    DATA(lv_len) = strlen( lv_value ).
    cv_input = |{ cv_input }#{ iv_name }:{ lv_len }:{ lv_value }|.
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 40 THEN lv_len ELSE 40 ).
    rv_hash = |{ iv_prefix }-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

ENDCLASS.
