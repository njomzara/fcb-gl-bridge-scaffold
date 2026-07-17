"! Policy-driven aggregation scaffold. It is deterministic and side-effect-free.
CLASS /fcbp/cl_glt_aggregator DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_aggregator.

    METHODS constructor
      IMPORTING
        io_signature TYPE REF TO /fcbp/if_glt_aggr_signature OPTIONAL
        io_trace     TYPE REF TO /fcbp/if_glt_source_trace_builder OPTIONAL.

  PRIVATE SECTION.
    DATA mo_signature TYPE REF TO /fcbp/if_glt_aggr_signature.
    DATA mo_trace TYPE REF TO /fcbp/if_glt_source_trace_builder.

    METHODS validate_policy
      IMPORTING
        is_policy TYPE /fcbp/if_glt_config_types=>ty_aggregation_policy
        it_field  TYPE /fcbp/if_glt_config_types=>tt_aggregation_field
      RAISING
        /fcbp/cx_glt_preparation.

    METHODS compact_hash
      IMPORTING
        iv_input       TYPE string
      RETURNING
        VALUE(rv_hash) TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_aggregator IMPLEMENTATION.

  METHOD constructor.
    IF io_signature IS BOUND.
      mo_signature = io_signature.
    ELSE.
      mo_signature = NEW /fcbp/cl_glt_aggr_signature( ).
    ENDIF.

    IF io_trace IS BOUND.
      mo_trace = io_trace.
    ELSE.
      mo_trace = NEW /fcbp/cl_glt_source_trace_builder( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_aggregator~aggregate.
    validate_policy(
      is_policy = is_aggr_policy
      it_field  = it_aggr_field ).

    DATA(lt_source) = it_source_line.
    SORT lt_source BY source_type source_reference source_doc_no source_item_no source_hash.

    LOOP AT lt_source INTO DATA(ls_source).
      DATA(ls_signature) = mo_signature->build_signature(
        is_source_line = ls_source
        is_policy      = is_aggr_policy
        it_field       = it_aggr_field ).

      IF ls_signature-blocking = abap_true.
        APPEND ls_signature-message TO rs_result-messages.
        CONTINUE.
      ENDIF.

      READ TABLE rs_result-canonical_lines ASSIGNING FIELD-SYMBOL(<ls_canon>)
        WITH KEY aggr_signature_hash = ls_signature-signature_hash
                 currency = ls_source-currency
                 debit_credit = ls_source-debit_credit.

      IF sy-subrc <> 0.
        DATA(lv_seq) = lines( rs_result-canonical_lines ) + 1.
        DATA(ls_new_line) = VALUE /fcbp/if_glt_pkg_types=>ty_canonical_line(
          package_id = is_policy_context-package_id
          line_id = |CLN-{ lv_seq }|
          line_no = lv_seq
          company_code = ls_source-company_code
          gl_account = ls_source-gl_account
          debit_credit = ls_source-debit_credit
          amount = ls_source-amount
          currency = ls_source-currency
          profit_center = ls_source-profit_center
          segment = ls_source-segment
          cost_center = ls_source-cost_center
          internal_order = ls_source-internal_order
          trading_partner = ls_source-trading_partner
          tax_code = ls_source-tax_code
          tax_report_date = ls_source-tax_report_date
          posting_date = ls_source-posting_date
          document_type = ls_source-document_type
          ledger_group = ls_source-ledger_group
          assignment = ls_source-assignment
          item_text = ls_source-item_text
          aggr_signature_hash = ls_signature-signature_hash
          source_count = 1
          line_hash = compact_hash( |CLN:{ ls_signature-signature_hash }:{ ls_source-debit_credit }:{ ls_source-currency }:{ ls_source-amount }| ) ).
        APPEND ls_new_line TO rs_result-canonical_lines ASSIGNING <ls_canon>.
      ELSE.
        <ls_canon>-amount = <ls_canon>-amount + ls_source-amount.
        <ls_canon>-source_count = <ls_canon>-source_count + 1.
        <ls_canon>-line_hash = compact_hash( |CLN:{ <ls_canon>-aggr_signature_hash }:{ <ls_canon>-source_count }:{ <ls_canon>-amount }| ).
      ENDIF.

      DATA(ls_trace) = mo_trace->build_trace_for_source(
        is_source_line = ls_source
        is_canonical   = <ls_canon>
        iv_sequence    = <ls_canon>-source_count ).
      APPEND ls_trace TO rs_result-source_trace.

      rs_result-source_hash = compact_hash( |SRC:{ rs_result-source_hash }:{ ls_source-source_hash }| ).
    ENDLOOP.

    mo_trace->assert_complete(
      it_canonical = rs_result-canonical_lines
      it_trace     = rs_result-source_trace ).

    LOOP AT rs_result-source_trace ASSIGNING FIELD-SYMBOL(<ls_trace>).
      READ TABLE rs_result-canonical_lines INTO DATA(ls_final_line)
        WITH KEY line_id = <ls_trace>-line_id.
      IF sy-subrc = 0 AND ls_final_line-amount <> 0.
        <ls_trace>-contribution_ratio = <ls_trace>-contribution_amount / ls_final_line-amount.
      ENDIF.
    ENDLOOP.

    rs_result-signature_count = lines( rs_result-canonical_lines ).
    rs_result-aggregation_output_hash = compact_hash(
      |AGGOUT:{ is_policy_context-policy_context_id }:{ rs_result-source_hash }:{ rs_result-signature_count }| ).
  ENDMETHOD.

  METHOD validate_policy.
    IF is_policy-aggregation_profile_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          rule_id        = 'GLT_AGG_001'
          operator_text  = 'Aggregation policy is missing.'.
    ENDIF.

    IF is_policy-active_flag = abap_false OR is_policy-config_hash IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          profile_id     = is_policy-aggregation_profile_id
          rule_id        = 'GLT_AGG_002'
          operator_text  = 'Aggregation policy is not active or lacks config hash.'.
    ENDIF.

    IF is_policy-grouping_mode = /fcbp/if_glt_pkg_types=>c_grouping_mode-by_signature AND
       it_field IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          profile_id     = is_policy-aggregation_profile_id
          rule_id        = 'GLT_AGG_004'
          operator_text  = 'BY_SIGNATURE aggregation requires an ordered field set.'.
    ENDIF.
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 24 THEN lv_len ELSE 24 ).
    rv_hash = |AGG-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

ENDCLASS.
