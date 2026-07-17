"! Source contribution trace builder scaffold.
CLASS /fcbp/cl_glt_source_trace_builder DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_source_trace_builder.

  PRIVATE SECTION.
    METHODS build_snapshot
      IMPORTING
        is_source_line TYPE /fcbp/if_glt_pkg_types=>ty_source_gl_line
      RETURNING
        VALUE(rv_snapshot) TYPE char255.

ENDCLASS.

CLASS /fcbp/cl_glt_source_trace_builder IMPLEMENTATION.

  METHOD /fcbp/if_glt_source_trace_builder~build_trace_for_source.
    IF is_source_line-source_reference IS INITIAL OR is_source_line-source_hash IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          error_category   = /fcbp/if_glt_types=>c_error_category-validation
          rule_id          = 'GLT_TRACE_001'
          source_reference = is_source_line-source_reference
          operator_text    = 'Source trace requires stable source reference and source hash.'.
    ENDIF.

    rs_trace = VALUE #(
      package_id = is_canonical-package_id
      outdoc_id = is_canonical-outdoc_id
      line_id = is_canonical-line_id
      line_no = is_canonical-line_no
      trace_id = |TRC-{ is_canonical-line_id }-{ iv_sequence }|
      trace_sequence = iv_sequence
      source_type = is_source_line-source_type
      source_reference = is_source_line-source_reference
      source_doc_no = is_source_line-source_doc_no
      source_item_no = is_source_line-source_item_no
      reconciliation_key = is_source_line-reconciliation_key
      company_code = is_source_line-company_code
      source_amount = is_source_line-amount
      source_currency = is_source_line-currency
      source_hash = is_source_line-source_hash
      contribution_amount = is_source_line-amount
      source_dimension_snapshot = build_snapshot( is_source_line ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_source_trace_builder~assert_complete.
    LOOP AT it_canonical INTO DATA(ls_line).
      READ TABLE it_trace TRANSPORTING NO FIELDS WITH KEY line_id = ls_line-line_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
          EXPORTING
            package_id     = ls_line-package_id
            outdoc_id      = ls_line-outdoc_id
            line_id        = ls_line-line_id
            error_category = /fcbp/if_glt_types=>c_error_category-validation
            rule_id        = 'GLT_TRACE_003'
            operator_text  = 'Canonical line has no source contribution trace.'.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_snapshot.
    rv_snapshot =
      |BUKRS={ is_source_line-company_code };HKONT={ is_source_line-gl_account };DC={ is_source_line-debit_credit };WAERS={ is_source_line-currency };PRCTR={ is_source_line-profit_center };SEG={ is_source_line-segment };KOSTL={ is_source_line-cost_center }|.
  ENDMETHOD.

ENDCLASS.
