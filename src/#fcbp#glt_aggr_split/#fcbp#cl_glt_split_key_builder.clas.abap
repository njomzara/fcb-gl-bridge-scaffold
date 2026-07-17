"! Deterministic split key builder scaffold.
CLASS /fcbp/cl_glt_split_key_builder DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_split_key_builder.

  PRIVATE SECTION.
    METHODS compact_hash
      IMPORTING
        iv_input       TYPE string
      RETURNING
        VALUE(rv_hash) TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_split_key_builder IMPLEMENTATION.

  METHOD /fcbp/if_glt_split_key_builder~build_key.
    rs_key-company_code = COND #( WHEN is_split_policy-split_by_company_code = abap_true THEN is_line-company_code ELSE '' ).
    rs_key-currency = COND #( WHEN is_split_policy-split_by_currency = abap_true THEN is_line-currency ELSE '' ).
    rs_key-posting_date = COND #( WHEN is_split_policy-split_by_posting_date = abap_true THEN is_line-posting_date ELSE '00000000' ).
    rs_key-document_type = COND #( WHEN is_split_policy-split_by_gl_doc_type = abap_true THEN is_line-document_type ELSE '' ).
    rs_key-ledger_group = COND #( WHEN is_split_policy-split_by_ledger_group = abap_true THEN is_line-ledger_group ELSE '' ).
    rs_key-split_key =
      |BUKRS={ rs_key-company_code };WAERS={ rs_key-currency };BUDAT={ rs_key-posting_date };BLART={ rs_key-document_type };LDGRP={ rs_key-ledger_group }|.
    rs_key-split_key_hash = compact_hash( rs_key-split_key ).
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 24 THEN lv_len ELSE 24 ).
    rv_hash = |SPH-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

ENDCLASS.
