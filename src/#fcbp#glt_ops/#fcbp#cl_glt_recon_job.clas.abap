"! Application job shell for /FCBP/GLT_RECON.
CLASS /fcbp/cl_glt_recon_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS execute
      IMPORTING
        is_filter TYPE /fcbp/if_glt_types=>ty_recon_filter OPTIONAL
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_recon_job IMPLEMENTATION.

  METHOD execute.
    " TODO: Cross-check posted/dispatched transfers with target references or adapter status query.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-technical
                operator_text  = 'Reconciliation job is not implemented in the scaffold.'.
  ENDMETHOD.

ENDCLASS.

