"! Split-time balance check scaffold.
CLASS /fcbp/cl_glt_balance_check DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_balance_check.

ENDCLASS.

CLASS /fcbp/cl_glt_balance_check IMPLEMENTATION.

  METHOD /fcbp/if_glt_balance_check~check_document.
    rs_balance = VALUE #(
      package_id = is_outdoc-package_id
      outdoc_id = is_outdoc-outdoc_id
      balance_scope = is_split_policy-balance_scope
      company_code = is_outdoc-company_code
      currency = is_outdoc-currency
      ledger_group = is_outdoc-ledger_group
      balance_status = /fcbp/if_glt_pkg_types=>c_balance_status-not_checked ).

    IF is_split_policy-balance_scope IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_line INTO DATA(ls_line).
      CASE ls_line-debit_credit.
        WHEN 'D' OR 'S'.
          rs_balance-debit_amount = rs_balance-debit_amount + ls_line-amount.
        WHEN 'C' OR 'H'.
          rs_balance-credit_amount = rs_balance-credit_amount + ls_line-amount.
        WHEN OTHERS.
          rs_balance-blocking = abap_true.
          rs_balance-balance_status = /fcbp/if_glt_pkg_types=>c_balance_status-unbalanced.
          rs_balance-message = VALUE #(
            rule_id = 'GLT_BAL_001'
            category = /fcbp/if_glt_aggr_types=>c_prep_category-balance
            severity = /fcbp/if_glt_types=>c_severity-error
            blocking = abap_true
            outdoc_id = is_outdoc-outdoc_id
            line_id = ls_line-line_id
            operator_text = 'Invalid debit/credit indicator before balance calculation.' ).
          RETURN.
      ENDCASE.
    ENDLOOP.

    rs_balance-difference_amount = rs_balance-debit_amount - rs_balance-credit_amount.
    IF rs_balance-difference_amount = 0.
      rs_balance-balance_status = /fcbp/if_glt_pkg_types=>c_balance_status-balanced.
    ELSE.
      rs_balance-balance_status = /fcbp/if_glt_pkg_types=>c_balance_status-unbalanced.
      rs_balance-blocking = abap_true.
      rs_balance-message = VALUE #(
        rule_id = 'GLT_BAL_002'
        category = /fcbp/if_glt_aggr_types=>c_prep_category-balance
        severity = /fcbp/if_glt_types=>c_severity-error
        blocking = abap_true
        outdoc_id = is_outdoc-outdoc_id
        operator_text = 'Debit and credit amounts do not balance in the configured split scope.' ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
