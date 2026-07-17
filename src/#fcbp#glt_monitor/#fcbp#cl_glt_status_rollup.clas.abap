"! Derives monitor-facing header state from timeline, attempts, and references.
CLASS /fcbp/cl_glt_status_rollup DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_monitor_repo OPTIONAL.

    METHODS derive_current_state
      IMPORTING
        iv_transfer_id    TYPE /fcbp/if_glt_types=>ty_transfer_id
      RETURNING
        VALUE(rs_header)  TYPE /fcbp/if_glt_types=>ty_header
      RAISING
        /fcbp/cx_glt_error.

    METHODS can_mark_posted
      IMPORTING
        is_transfer       TYPE /fcbp/if_glt_types=>ty_transfer
      RETURNING
        VALUE(rv_allowed) TYPE abap_bool.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_monitor_repo.

    METHODS ensure_repository
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_status_rollup IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD derive_current_state.
    ensure_repository( ).

    DATA(ls_transfer) = mo_repository->read_transfer( iv_transfer_id ).
    rs_header = ls_transfer-header.

    IF rs_header-status_code = /fcbp/if_glt_types=>c_status-unknown_confirmation.
      rs_header-confirmation_pending = abap_true.
      rs_header-operator_action_required = abap_true.
    ENDIF.

    IF rs_header-status_code = /fcbp/if_glt_types=>c_status-posted AND
       can_mark_posted( ls_transfer ) = abap_false.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = 'Posted rollup requires at least one target reference.'.
    ENDIF.
  ENDMETHOD.

  METHOD can_mark_posted.
    rv_allowed = xsdbool(
      is_transfer-target_refs IS NOT INITIAL AND
      is_transfer-header-status_code <> /fcbp/if_glt_types=>c_status-cancelled ).
  ENDMETHOD.

  METHOD ensure_repository.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Status rollup requires a monitoring repository implementation.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
