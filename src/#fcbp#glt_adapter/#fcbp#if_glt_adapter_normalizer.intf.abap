"! Converts target protocol responses and exceptions into stable adapter results.
INTERFACE /fcbp/if_glt_adapter_normalizer PUBLIC.

  METHODS from_protocol_response
    IMPORTING
      is_response      TYPE /fcbp/if_glt_adapter_types=>ty_protocol_response
      is_request       TYPE /fcbp/if_glt_adapter_types=>ty_submit_request OPTIONAL
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_types=>ty_adapter_result.

  METHODS from_exception
    IMPORTING
      ix_previous         TYPE REF TO cx_root OPTIONAL
      is_request          TYPE /fcbp/if_glt_adapter_types=>ty_submit_request OPTIONAL
      iv_may_have_been_sent TYPE abap_bool DEFAULT abap_true
      iv_protocol_category  TYPE char30 DEFAULT /fcbp/if_glt_adapter_types=>c_protocol_category-internal
    RETURNING
      VALUE(rs_result)    TYPE /fcbp/if_glt_types=>ty_adapter_result.

  METHODS assert_result_safe
    CHANGING
      cs_result TYPE /fcbp/if_glt_types=>ty_adapter_result.

ENDINTERFACE.
