"! Default database repository scaffold.
"! TODO: Implement against activated /FCBP/GLT_* tables using ABAP Cloud released SQL/RAP patterns.
CLASS /fcbp/cl_glt_repository DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_repository.

  PRIVATE SECTION.
    METHODS not_implemented
      IMPORTING
        iv_operation TYPE char40
      RAISING
        /fcbp/cx_glt_repository.

ENDCLASS.

CLASS /fcbp/cl_glt_repository IMPLEMENTATION.

  METHOD /fcbp/if_glt_repository~create_transfer.
    not_implemented( 'CREATE_TRANSFER' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~read_transfer.
    not_implemented( 'READ_TRANSFER' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~update_header.
    not_implemented( 'UPDATE_HEADER' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_status.
    not_implemented( 'INSERT_STATUS' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_error.
    not_implemented( 'INSERT_ERROR' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~reserve_idempotency.
    not_implemented( 'RESERVE_IDEMPOTENCY' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~confirm_idempotency.
    not_implemented( 'CONFIRM_IDEMPOTENCY' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_retry.
    not_implemented( 'INSERT_RETRY' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_target_ref.
    not_implemented( 'INSERT_TARGET_REF' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~read_config.
    not_implemented( 'READ_CONFIG' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~resolve_route.
    not_implemented( 'RESOLVE_ROUTE' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~query_reconciliation.
    not_implemented( 'QUERY_RECONCILIATION' ).
  ENDMETHOD.

  METHOD not_implemented.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_repository
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = |Repository operation { iv_operation } is not implemented in the scaffold.|.
  ENDMETHOD.

ENDCLASS.

