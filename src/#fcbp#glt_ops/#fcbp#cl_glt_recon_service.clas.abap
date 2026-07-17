"! Reconciliation/support query service.
CLASS /fcbp/cl_glt_recon_service DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_repository OPTIONAL
        io_auth_check TYPE REF TO /fcbp/if_glt_auth_check OPTIONAL.

    METHODS query
      IMPORTING
        is_filter          TYPE /fcbp/if_glt_types=>ty_recon_filter
      RETURNING
        VALUE(rt_transfer) TYPE /fcbp/if_glt_types=>tt_transfer
      RAISING
        /fcbp/cx_glt_error.

    METHODS get_transfer_trace
      IMPORTING
        iv_transfer_id    TYPE /fcbp/if_glt_types=>ty_transfer_id
      RETURNING
        VALUE(rs_transfer) TYPE /fcbp/if_glt_types=>ty_transfer
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_repository.
    DATA mo_auth_check TYPE REF TO /fcbp/if_glt_auth_check.

ENDCLASS.

CLASS /fcbp/cl_glt_recon_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    mo_auth_check = io_auth_check.
  ENDMETHOD.

  METHOD query.
    IF mo_auth_check IS BOUND AND is_filter-transfer_id IS NOT INITIAL.
      mo_auth_check->check_display( is_filter-transfer_id ).
    ENDIF.

    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-repository
                  operator_text  = 'Reconciliation service requires a repository implementation.'.
    ENDIF.

    rt_transfer = mo_repository->query_reconciliation( is_filter ).
  ENDMETHOD.

  METHOD get_transfer_trace.
    IF mo_auth_check IS BOUND.
      mo_auth_check->check_display( iv_transfer_id ).
    ENDIF.

    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-repository
                  operator_text  = 'Reconciliation service requires a repository implementation.'.
    ENDIF.

    rs_transfer = mo_repository->read_transfer( iv_transfer_id ).
  ENDMETHOD.

ENDCLASS.

