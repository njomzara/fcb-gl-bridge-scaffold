"! Optional source eligibility check.
"! TODO: Bind this to released FCBP APIs/CDS views in the target ABAP tenant.
CLASS /fcbp/cl_glt_source_elig_chk DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_source_elig_chk.

ENDCLASS.

CLASS /fcbp/cl_glt_source_elig_chk IMPLEMENTATION.

  METHOD /fcbp/if_glt_source_elig_chk~check_eligible.
    " Scaffold default is permissive after request-shape validation.
    " Productive implementation must prove the source scope is accepted/closed/frozen/eligible.
  ENDMETHOD.

ENDCLASS.

