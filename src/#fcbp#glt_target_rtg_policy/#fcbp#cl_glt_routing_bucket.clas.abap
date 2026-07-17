"! Stable routing-bucket builder. Keep format versioned and deterministic.
CLASS /fcbp/cl_glt_routing_bucket DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_routing_bucket.

  PRIVATE SECTION.
    METHODS normalize
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.

    METHODS compact_bucket
      IMPORTING
        iv_input         TYPE string
      RETURNING
        VALUE(rv_bucket) TYPE char32.

ENDCLASS.

CLASS /fcbp/cl_glt_routing_bucket IMPLEMENTATION.

  METHOD /fcbp/if_glt_routing_bucket~build_bucket.
    IF is_scope-source_type IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-missing
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          operator_text      = 'Routing bucket requires source type.'.
    ENDIF.

    IF is_scope-company_code IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-missing
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          operator_text      = 'Routing bucket requires company code or an equivalent routing dimension.'.
    ENDIF.

    IF is_profile-target_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-inconsistent
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          operator_text      = 'Routing bucket requires selected target id.'.
    ENDIF.

    DATA(lv_processing_mode) = COND string(
      WHEN is_scope-processing_mode IS INITIAL THEN /fcbp/if_glt_types=>c_processing_mode-batch
      ELSE is_scope-processing_mode ).

    DATA(lv_input) =
      |RB1| &&
      |#SRC={ normalize( is_scope-source_type ) }| &&
      |#REF={ normalize( is_scope-source_reference ) }| &&
      |#BUKRS={ normalize( is_scope-company_code ) }| &&
      |#LEDGER={ normalize( is_scope-ledger_group ) }| &&
      |#MODE={ normalize( lv_processing_mode ) }| &&
      |#TARGET={ normalize( is_profile-target_id ) }|.

    rv_bucket = compact_bucket( lv_input ).
  ENDMETHOD.

  METHOD normalize.
    rv_value = iv_value.
    CONDENSE rv_value.
    TRANSLATE rv_value TO UPPER CASE.
    IF rv_value IS INITIAL.
      rv_value = '<BLANK>'.
    ENDIF.
  ENDMETHOD.

  METHOD compact_bucket.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 20 THEN lv_len ELSE 20 ).
    rv_bucket = |RB1-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

ENDCLASS.
