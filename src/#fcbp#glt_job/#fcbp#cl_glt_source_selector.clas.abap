"! Default batch source selector. Productive discovery must bind released FCBP sources.
CLASS /fcbp/cl_glt_source_selector DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_source_selector.

ENDCLASS.

CLASS /fcbp/cl_glt_source_selector IMPLEMENTATION.

  METHOD /fcbp/if_glt_source_selector~select_eligible_scopes.
    rt_candidate = VALUE #( ).
  ENDMETHOD.

ENDCLASS.
