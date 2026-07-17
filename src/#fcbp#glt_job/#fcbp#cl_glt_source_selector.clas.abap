"! Placeholder batch source selector. Productive discovery must bind released FCBP sources.
CLASS /fcbp/cl_glt_source_selector DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_source_selector.

ENDCLASS.

CLASS /fcbp/cl_glt_source_selector IMPLEMENTATION.

  METHOD /fcbp/if_glt_source_selector~select_eligible_scopes.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-technical
        operator_text  = |Source selector for source type { is_request-source_type } is not implemented in the scaffold.|.
  ENDMETHOD.

ENDCLASS.
