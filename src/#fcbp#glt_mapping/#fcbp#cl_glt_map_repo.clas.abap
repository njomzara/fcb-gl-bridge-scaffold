"! Mapping evidence repository scaffold. Bind to /FCBP/GLT_MAPEV before activation.
CLASS /fcbp/cl_glt_map_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_map_repo.

  PRIVATE SECTION.
    METHODS not_implemented
      IMPORTING
        iv_operation TYPE char40
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_map_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_map_repo~insert_events.
    not_implemented( 'INSERT_EVENTS' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_map_repo~read_events_for_package.
    not_implemented( 'READ_EVENTS_FOR_PACKAGE' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_map_repo~mark_superseded.
    not_implemented( 'MARK_SUPERSEDED' ).
  ENDMETHOD.

  METHOD not_implemented.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_mapping
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = |Mapping repository operation { iv_operation } must be bound to /FCBP/GLT_MAPEV.|.
  ENDMETHOD.

ENDCLASS.
