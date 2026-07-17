"! Owns atomic reserve/activate/failed registration decisions.
CLASS /fcbp/cl_glt_source_registry DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_handoff_repo OPTIONAL.

    METHODS reserve
      IMPORTING
        is_registration    TYPE /fcbp/if_glt_types=>ty_registration
      RETURNING
        VALUE(rs_decision) TYPE /fcbp/if_glt_types=>ty_reg_decision
      RAISING
        /fcbp/cx_glt_handoff.

    METHODS read_existing
      IMPORTING
        iv_registration_key    TYPE /fcbp/if_glt_types=>ty_registration_key
      RETURNING
        VALUE(rs_registration) TYPE /fcbp/if_glt_types=>ty_registration
      RAISING
        /fcbp/cx_glt_handoff.

    METHODS activate
      IMPORTING
        iv_registration_key TYPE /fcbp/if_glt_types=>ty_registration_key
        iv_transfer_id      TYPE /fcbp/if_glt_types=>ty_transfer_id
      RAISING
        /fcbp/cx_glt_handoff.

    METHODS mark_failed
      IMPORTING
        iv_registration_key TYPE /fcbp/if_glt_types=>ty_registration_key
        iv_reason           TYPE char40
      RAISING
        /fcbp/cx_glt_handoff.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_handoff_repo.

ENDCLASS.

CLASS /fcbp/cl_glt_source_registry IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD reserve.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
        EXPORTING
          registration_key = is_registration-registration_key
          reason_code      = 'NO_REPOSITORY'
          error_category   = /fcbp/if_glt_types=>c_error_category-repository
          operator_text    = 'Source registry requires a handoff repository implementation.'.
    ENDIF.

    rs_decision = mo_repository->try_reserve_reg( is_registration ).

    IF rs_decision-conflict = abap_true.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
        EXPORTING
          registration_key = is_registration-registration_key
          reason_code      = 'GLT_HND_014'
          error_category   = /fcbp/if_glt_types=>c_error_category-conflict
          operator_text    = rs_decision-message.
    ENDIF.
  ENDMETHOD.

  METHOD read_existing.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
        EXPORTING
          registration_key = iv_registration_key
          reason_code      = 'NO_REPOSITORY'
          error_category   = /fcbp/if_glt_types=>c_error_category-repository
          operator_text    = 'Source registry requires a handoff repository implementation.'.
    ENDIF.

    rs_registration = mo_repository->read_reg( iv_registration_key ).
  ENDMETHOD.

  METHOD activate.
    mo_repository->activate_reg(
      iv_registration_key = iv_registration_key
      iv_transfer_id      = iv_transfer_id ).
  ENDMETHOD.

  METHOD mark_failed.
    IF mo_repository IS BOUND.
      mo_repository->mark_reg_failed(
        iv_registration_key = iv_registration_key
        iv_reason           = iv_reason ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.

