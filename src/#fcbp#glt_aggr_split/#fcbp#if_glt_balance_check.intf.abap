"! Balance calculation and debit/credit validation for split output.
INTERFACE /fcbp/if_glt_balance_check PUBLIC.

  METHODS check_document
    IMPORTING
      is_outdoc       TYPE /fcbp/if_glt_pkg_types=>ty_outdoc
      it_line         TYPE /fcbp/if_glt_pkg_types=>tt_canonical_line
      is_split_policy TYPE /fcbp/if_glt_config_types=>ty_split_policy
    RETURNING
      VALUE(rs_balance) TYPE /fcbp/if_glt_aggr_types=>ty_balance_result.

ENDINTERFACE.
