"! Package repository scaffold. Package publication must be atomic in the target tenant.
CLASS /fcbp/cl_glt_package_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_package_repo.

  PRIVATE SECTION.
    METHODS not_implemented
      IMPORTING
        iv_operation TYPE char40
      RAISING
        /fcbp/cx_glt_repository.

ENDCLASS.

CLASS /fcbp/cl_glt_package_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_package_repo~persist_graph.
    not_implemented( 'PERSIST_GRAPH' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~publish_current.
    not_implemented( 'PUBLISH_CURRENT' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~read_package.
    not_implemented( 'READ_PACKAGE' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~check_consistency.
    not_implemented( 'CHECK_CONSISTENCY' ).
  ENDMETHOD.

  METHOD not_implemented.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_repository
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = |Package repository operation { iv_operation } must be bound to /FCBP/GLT_PKG/DOC/LIN/SRC.|.
  ENDMETHOD.

ENDCLASS.
