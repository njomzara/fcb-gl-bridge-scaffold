"! Test-only deterministic source reader.
CLASS /fcbp/cl_glt_src_read_mock DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_amount TYPE p LENGTH 16 DECIMALS 2.
    TYPES ty_currency TYPE c LENGTH 5.

    INTERFACES /fcbp/if_glt_src_type_reader.

    METHODS constructor
      IMPORTING
        io_hasher TYPE REF TO /fcbp/cl_glt_src_hasher OPTIONAL.

    METHODS seed_balanced_pair
      IMPORTING
        iv_source_reference TYPE char50
        iv_company_code     TYPE char4 DEFAULT '1000'
        iv_amount           TYPE ty_amount DEFAULT '100.00'
        iv_currency         TYPE ty_currency DEFAULT 'USD'
        iv_posting_date     TYPE dats DEFAULT '20260101'.

    METHODS clear_seed.

  PRIVATE SECTION.
    DATA mt_seeded_line TYPE /fcbp/if_glt_pkg_types=>tt_source_gl_line.
    DATA mo_hasher TYPE REF TO /fcbp/cl_glt_src_hasher.

    METHODS fill_hashes
      CHANGING
        cs_source_line TYPE /fcbp/if_glt_pkg_types=>ty_source_gl_line.

ENDCLASS.

CLASS /fcbp/cl_glt_src_read_mock IMPLEMENTATION.

  METHOD constructor.
    IF io_hasher IS BOUND.
      mo_hasher = io_hasher.
    ELSE.
      mo_hasher = NEW /fcbp/cl_glt_src_hasher( ).
    ENDIF.
  ENDMETHOD.

  METHOD seed_balanced_pair.
    CLEAR mt_seeded_line.

    DATA(ls_debit) = VALUE /fcbp/if_glt_pkg_types=>ty_source_gl_line(
      source_type       = /fcbp/if_glt_src_types=>c_source_type-mock
      source_reference  = iv_source_reference
      source_doc_no     = 'MOCKDOC001'
      source_item_no    = '000001'
      reconciliation_key = iv_source_reference
      company_code      = iv_company_code
      chart_of_accounts = 'FCBP'
      gl_account        = '0000400000'
      amount            = iv_amount
      currency          = iv_currency
      debit_credit      = 'S'
      posting_date      = iv_posting_date
      document_type     = 'MOCK'
      item_text         = 'Mock debit source line' ).
    fill_hashes( CHANGING cs_source_line = ls_debit ).
    APPEND ls_debit TO mt_seeded_line.

    DATA(ls_credit) = VALUE /fcbp/if_glt_pkg_types=>ty_source_gl_line(
      source_type       = /fcbp/if_glt_src_types=>c_source_type-mock
      source_reference  = iv_source_reference
      source_doc_no     = 'MOCKDOC001'
      source_item_no    = '000002'
      reconciliation_key = iv_source_reference
      company_code      = iv_company_code
      chart_of_accounts = 'FCBP'
      gl_account        = '0000200000'
      amount            = iv_amount
      currency          = iv_currency
      debit_credit      = 'H'
      posting_date      = iv_posting_date
      document_type     = 'MOCK'
      item_text         = 'Mock credit source line' ).
    fill_hashes( CHANGING cs_source_line = ls_credit ).
    APPEND ls_credit TO mt_seeded_line.
  ENDMETHOD.

  METHOD clear_seed.
    CLEAR mt_seeded_line.
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_type_reader~supports.
    rv_supported = xsdbool( iv_source_type = /fcbp/if_glt_src_types=>c_source_type-mock ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_type_reader~read.
    rt_source_line = mt_seeded_line.
    IF rt_source_line IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>no_lines( is_request ).
    ENDIF.

    DELETE rt_source_line WHERE source_reference <> is_request-source_reference.
    IF rt_source_line IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>not_found( is_request ).
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
