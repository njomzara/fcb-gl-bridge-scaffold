"! Builds the deterministic source registration key.
"! TODO: Replace scaffold key material with released SHA-256 API in the target ABAP tenant.
CLASS /fcbp/cl_glt_reg_key_builder DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        is_request        TYPE /fcbp/if_glt_types=>ty_handoff_request
        is_route_context  TYPE /fcbp/if_glt_types=>ty_route_context
      RETURNING
        VALUE(rv_key)     TYPE /fcbp/if_glt_types=>ty_registration_key
      RAISING
        /fcbp/cx_glt_handoff.

    METHODS build_components
      IMPORTING
        is_request        TYPE /fcbp/if_glt_types=>ty_handoff_request
        is_route_context  TYPE /fcbp/if_glt_types=>ty_route_context
      RETURNING
        VALUE(rv_text)    TYPE string.

ENDCLASS.

CLASS /fcbp/cl_glt_reg_key_builder IMPLEMENTATION.

  METHOD build.
    DATA(lv_components) = build_components(
      is_request       = is_request
      is_route_context = is_route_context ).

    IF lv_components IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
        EXPORTING
          source_type      = is_request-source_type
          source_reference = is_request-source_reference
          reason_code      = 'GLT_HND_011'
          error_category   = /fcbp/if_glt_types=>c_error_category-validation
          operator_text    = 'Registration key components are incomplete.'.
    ENDIF.

    rv_key = |HND-{ sy-mandt }-{ is_request-source_type }-{ is_request-source_reference }-{ is_route_context-routing_bucket }-{ is_route_context-target_id }-{ is_request-processing_mode }|.
  ENDMETHOD.

  METHOD build_components.
    rv_text = |{ sy-mandt }| &&
              |;{ is_request-source_type }| &&
              |;{ is_request-source_reference }| &&
              |;{ is_route_context-routing_bucket }| &&
              |;{ is_route_context-target_id }| &&
              |;{ is_request-processing_mode }|.
  ENDMETHOD.

ENDCLASS.

