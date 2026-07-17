"! Application job shell for /FCBP/GLT_RETENTION.
CLASS /fcbp/cl_glt_retention_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS execute
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_retention_job IMPLEMENTATION.

  METHOD execute.
    " TODO: Apply customer retention/archive policy; never delete audit evidence casually.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-technical
                operator_text  = 'Retention job is not implemented in the scaffold.'.
  ENDMETHOD.

ENDCLASS.

