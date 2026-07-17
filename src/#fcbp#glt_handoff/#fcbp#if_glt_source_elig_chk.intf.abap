"! Optional read-only eligibility check against released FCBP APIs/CDS.
INTERFACE /fcbp/if_glt_source_elig_chk PUBLIC.

  METHODS check_eligible
    IMPORTING
      is_request TYPE /fcbp/if_glt_types=>ty_handoff_request
    RAISING
      /fcbp/cx_glt_src_inelig.

ENDINTERFACE.

