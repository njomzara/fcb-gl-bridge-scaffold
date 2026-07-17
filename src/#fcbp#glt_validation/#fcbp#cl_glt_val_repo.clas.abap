"! Validation repository scaffold. Bind to /FCBP/GLT_VALRUN and /FCBP/GLT_VALFND before activation.
CLASS /fcbp/cl_glt_val_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_val_repo.

  PRIVATE SECTION.
    METHODS not_implemented
      IMPORTING
        iv_operation TYPE char40
      RAISING
        /fcbp/cx_glt_validation.

ENDCLASS.

CLASS /fcbp/cl_glt_val_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_val_repo~create_run.
    not_implemented( 'CREATE_RUN' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_repo~insert_findings.
    not_implemented( 'INSERT_FINDINGS' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_repo~close_run.
    not_implemented( 'CLOSE_RUN' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_val_repo~read_latest_run.
    not_implemented( 'READ_LATEST_RUN' ).
  ENDMETHOD.

  METHOD not_implemented.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_validation
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = |Validation repository operation { iv_operation } must be bound to /FCBP/GLT_VALRUN and /FCBP/GLT_VALFND.|.
  ENDMETHOD.

ENDCLASS.
