"! Default validation catalogue scaffold.
CLASS /fcbp/cl_glt_validator DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_validator.

  PRIVATE SECTION.
    METHODS append_message
      IMPORTING
        iv_rule_id       TYPE char20
        iv_field_name    TYPE char30 OPTIONAL
        iv_item_no       TYPE numc6 OPTIONAL
        iv_operator_text TYPE char220
      CHANGING
        ct_message       TYPE /fcbp/if_glt_types=>tt_message.

ENDCLASS.

CLASS /fcbp/cl_glt_validator IMPLEMENTATION.

  METHOD /fcbp/if_glt_validator~validate_request.
    DATA lv_debit  TYPE p LENGTH 16 DECIMALS 2.
    DATA lv_credit TYPE p LENGTH 16 DECIMALS 2.

    IF is_transfer-header-source_ref_id IS INITIAL.
      append_message(
        EXPORTING iv_rule_id = 'GLT_VAL_001' iv_field_name = 'SOURCE_REF_ID' iv_operator_text = 'Source reference is required.'
        CHANGING  ct_message = rt_message ).
    ENDIF.

    IF is_transfer-header-idempotency_key IS INITIAL.
      append_message(
        EXPORTING iv_rule_id = 'GLT_VAL_002' iv_field_name = 'IDEMPOTENCY_KEY' iv_operator_text = 'Idempotency key is required or must be derivable.'
        CHANGING  ct_message = rt_message ).
    ENDIF.

    IF is_transfer-header-company_code IS INITIAL.
      append_message(
        EXPORTING iv_rule_id = 'GLT_VAL_005' iv_field_name = 'COMPANY_CODE' iv_operator_text = 'Company code is required.'
        CHANGING  ct_message = rt_message ).
    ENDIF.

    IF is_transfer-header-transfer_type IS INITIAL.
      append_message(
        EXPORTING iv_rule_id = 'GLT_VAL_006' iv_field_name = 'TRANSFER_TYPE' iv_operator_text = 'Transfer type is required.'
        CHANGING  ct_message = rt_message ).
    ENDIF.

    IF lines( is_transfer-items ) = 0.
      append_message(
        EXPORTING iv_rule_id = 'GLT_VAL_009' iv_field_name = 'ITEMS' iv_operator_text = 'At least one transfer line is required.'
        CHANGING  ct_message = rt_message ).
    ENDIF.

    LOOP AT is_transfer-items INTO DATA(ls_item).
      IF ls_item-amount <= 0.
        append_message(
          EXPORTING iv_rule_id = 'GLT_VAL_007' iv_field_name = 'AMOUNT' iv_item_no = ls_item-item_no iv_operator_text = 'Item amount must be greater than zero.'
          CHANGING  ct_message = rt_message ).
      ENDIF.

      IF ls_item-company_code IS INITIAL.
        append_message(
          EXPORTING iv_rule_id = 'GLT_VAL_005' iv_field_name = 'COMPANY_CODE' iv_item_no = ls_item-item_no iv_operator_text = 'Item company code is required.'
          CHANGING  ct_message = rt_message ).
      ENDIF.

      IF is_transfer-header-currency IS NOT INITIAL
         AND ls_item-currency IS NOT INITIAL
         AND ls_item-currency <> is_transfer-header-currency.
        append_message(
          EXPORTING iv_rule_id = 'GLT_VAL_008' iv_field_name = 'CURRENCY' iv_item_no = ls_item-item_no iv_operator_text = 'Item currency differs from header currency.'
          CHANGING  ct_message = rt_message ).
      ENDIF.

      CASE ls_item-debit_credit.
        WHEN 'S'.
          lv_debit = lv_debit + ls_item-amount.
        WHEN 'H'.
          lv_credit = lv_credit + ls_item-amount.
        WHEN OTHERS.
          append_message(
            EXPORTING iv_rule_id = 'GLT_VAL_007' iv_field_name = 'DEBIT_CREDIT' iv_item_no = ls_item-item_no iv_operator_text = 'Debit/credit indicator must be S or H.'
            CHANGING  ct_message = rt_message ).
      ENDCASE.
    ENDLOOP.

    IF lines( is_transfer-items ) > 0 AND lv_debit <> lv_credit.
      append_message(
        EXPORTING iv_rule_id = 'GLT_VAL_010' iv_field_name = 'TOTAL_DEBIT_AMT' iv_operator_text = 'Debit and credit totals are not balanced.'
        CHANGING  ct_message = rt_message ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_validator~validate_reprocess.
    IF iv_transfer_id IS INITIAL.
      append_message(
        EXPORTING iv_rule_id = 'GLT_VAL_001' iv_field_name = 'TRANSFER_ID' iv_operator_text = 'Transfer ID is required for reprocess validation.'
        CHANGING  ct_message = rt_message ).
    ENDIF.
  ENDMETHOD.

  METHOD append_message.
    APPEND VALUE #(
      rule_id       = iv_rule_id
      severity      = /fcbp/if_glt_types=>c_severity-error
      blocking      = abap_true
      entity_name   = 'TRANSFER'
      field_name    = iv_field_name
      item_no       = iv_item_no
      operator_text = iv_operator_text ) TO ct_message.
  ENDMETHOD.

ENDCLASS.

