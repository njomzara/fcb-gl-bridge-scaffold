"! Converts released source projection rows into package-builder source lines.
CLASS /fcbp/cl_glt_src_normalizer DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_hasher TYPE REF TO /fcbp/cl_glt_src_hasher OPTIONAL.

    METHODS normalize_items
      IMPORTING
        iv_source_type        TYPE char20
        iv_source_reference   TYPE char50
        is_request            TYPE /fcbp/if_glt_src_types=>ty_source_read_request
        it_item               TYPE /fcbp/if_glt_src_types=>tt_source_projection_item
      RETURNING
        VALUE(rt_source_line) TYPE /fcbp/if_glt_pkg_types=>tt_source_gl_line
      RAISING
        /fcbp/cx_glt_source_read.

    METHODS validate_source_line
      IMPORTING
        is_request     TYPE /fcbp/if_glt_src_types=>ty_source_read_request
        is_source_line TYPE /fcbp/if_glt_pkg_types=>ty_source_gl_line
      RAISING
        /fcbp/cx_glt_source_read.

  PRIVATE SECTION.
    DATA mo_hasher TYPE REF TO /fcbp/cl_glt_src_hasher.

    METHODS fill_hashes
      CHANGING
        cs_source_line TYPE /fcbp/if_glt_pkg_types=>ty_source_gl_line.

ENDCLASS.

CLASS /fcbp/cl_glt_src_normalizer IMPLEMENTATION.

  METHOD constructor.
    IF io_hasher IS BOUND.
      mo_hasher = io_hasher.
    ELSE.
      mo_hasher = NEW /fcbp/cl_glt_src_hasher( ).
    ENDIF.
  ENDMETHOD.

  METHOD normalize_items.
    LOOP AT it_item INTO DATA(ls_item) WHERE exclude_flag = abap_false.
      DATA(ls_source_line) = VALUE /fcbp/if_glt_pkg_types=>ty_source_gl_line(
        source_type       = COND #( WHEN ls_item-source_type IS INITIAL THEN iv_source_type ELSE ls_item-source_type )
        source_reference  = COND #( WHEN ls_item-source_reference IS INITIAL THEN iv_source_reference ELSE ls_item-source_reference )
        source_doc_no     = ls_item-source_doc_no
        source_item_no    = ls_item-source_item_no
        reconciliation_key = ls_item-reconciliation_key
        company_code      = ls_item-company_code
        chart_of_accounts = ls_item-chart_of_accounts
        gl_account        = ls_item-gl_account
        profit_center     = ls_item-profit_center
        segment           = ls_item-segment
        cost_center       = ls_item-cost_center
        internal_order    = ls_item-internal_order
        trading_partner   = ls_item-trading_partner
        amount            = abs( ls_item-amount )
        currency          = ls_item-currency
        debit_credit      = ls_item-debit_credit
        tax_code          = ls_item-tax_code
        tax_report_date   = ls_item-tax_report_date
        posting_date      = ls_item-posting_date
        document_type     = ls_item-document_type
        ledger_group      = ls_item-ledger_group
        assignment        = ls_item-assignment
        item_text         = ls_item-item_text
        source_hash       = ls_item-immutable_source_hash ).

      fill_hashes( CHANGING cs_source_line = ls_source_line ).
      validate_source_line(
        is_request     = is_request
        is_source_line = ls_source_line ).
      APPEND ls_source_line TO rt_source_line.
    ENDLOOP.

    SORT rt_source_line BY source_type source_reference source_doc_no source_item_no
                           company_code gl_account debit_credit currency source_hash line_hash.
  ENDMETHOD.

  METHOD validate_source_line.
    IF is_source_line-source_type IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
        is_request    = is_request
        iv_field_name = 'SOURCE_TYPE' ).
    ENDIF.
    IF is_source_line-source_reference IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
        is_request    = is_request
        iv_field_name = 'SOURCE_REFERENCE' ).
    ENDIF.
    IF is_source_line-source_doc_no IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
        is_request    = is_request
        iv_field_name = 'SOURCE_DOC_NO' ).
    ENDIF.
    IF is_source_line-source_item_no IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
        is_request    = is_request
        iv_field_name = 'SOURCE_ITEM_NO' ).
    ENDIF.
    IF is_source_line-company_code IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
        is_request    = is_request
        iv_field_name = 'COMPANY_CODE' ).
    ENDIF.
    IF is_source_line-gl_account IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
        is_request    = is_request
        iv_field_name = 'GL_ACCOUNT' ).
    ENDIF.
    IF is_source_line-currency IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
        is_request    = is_request
        iv_field_name = 'CURRENCY' ).
    ENDIF.
    IF is_source_line-debit_credit IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
        is_request    = is_request
        iv_field_name = 'DEBIT_CREDIT' ).
    ENDIF.
    IF is_source_line-source_hash IS INITIAL OR is_source_line-line_hash IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>from_request(
        is_request       = is_request
        iv_error_code    = /fcbp/if_glt_src_types=>c_error_code-hash_missing
        iv_field_name    = 'SOURCE_HASH'
        iv_operator_text = |Source line hash evidence is missing for { is_source_line-source_doc_no }/{ is_source_line-source_item_no }.| ).
    ENDIF.
  ENDMETHOD.

  METHOD fill_hashes.
    IF cs_source_line-source_hash IS INITIAL.
      cs_source_line-source_hash = mo_hasher->calculate_line_hash( cs_source_line ).
    ENDIF.
    IF cs_source_line-line_hash IS INITIAL.
      cs_source_line-line_hash = mo_hasher->calculate_line_hash( cs_source_line ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
