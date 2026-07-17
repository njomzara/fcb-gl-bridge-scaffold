"! Read-side facade for transfer monitor lists and drilldowns.
CLASS /fcbp/cl_glt_monitor_query DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_monitor_repo OPTIONAL.

    METHODS query_transfers
      IMPORTING
        is_filter          TYPE /fcbp/if_glt_types=>ty_monitor_filter
      RETURNING
        VALUE(rt_transfer) TYPE /fcbp/if_glt_types=>tt_transfer
      RAISING
        /fcbp/cx_glt_error.

    METHODS get_transfer_detail
      IMPORTING
        iv_transfer_id     TYPE /fcbp/if_glt_types=>ty_transfer_id
      RETURNING
        VALUE(rs_transfer) TYPE /fcbp/if_glt_types=>ty_transfer
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_monitor_repo.

    METHODS ensure_repository
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_monitor_query IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD query_transfers.
    ensure_repository( ).
    rt_transfer = mo_repository->query_monitor( is_filter ).
  ENDMETHOD.

  METHOD get_transfer_detail.
    ensure_repository( ).
    rs_transfer = mo_repository->read_transfer( iv_transfer_id ).
  ENDMETHOD.

  METHOD ensure_repository.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Monitor query requires a monitoring repository implementation.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
