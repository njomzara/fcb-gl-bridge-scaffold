"! Default audit repository scaffold.
"! TODO: Implement append-only insert and secured query using released ABAP Cloud SQL/RAP APIs.
CLASS /fcbp/cl_glt_audit_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_audit_repo.

  PRIVATE SECTION.
    METHODS not_implemented
      IMPORTING
        iv_operation TYPE char40
      RAISING
        /fcbp/cx_glt_audit.

ENDCLASS.

CLASS /fcbp/cl_glt_audit_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_audit_repo~insert_audit_event.
    not_implemented( 'INSERT_AUDIT_EVENT' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_repo~query_audit.
    not_implemented( 'QUERY_AUDIT' ).
  ENDMETHOD.

  METHOD not_implemented.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_audit
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = |Audit repository operation { iv_operation } is not implemented in the scaffold.|.
  ENDMETHOD.

ENDCLASS.
