"! Idempotency service wrapper around atomic repository reservation.
CLASS /fcbp/cl_glt_idempotency DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_idempotency.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_repository OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_repository.

ENDCLASS.

CLASS /fcbp/cl_glt_idempotency IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD /fcbp/if_glt_idempotency~reserve.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-repository
                  operator_text  = 'Idempotency service requires a repository implementation.'.
    ENDIF.

    rs_decision = mo_repository->reserve_idempotency( is_reservation ).

    IF rs_decision-conflict = abap_true
       OR rs_decision-decision = /fcbp/if_glt_types=>c_idemp_decision-conflict.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_duplicate
        EXPORTING
          transfer_id     = rs_decision-transfer_id
          idempotency_key = is_reservation-idempotency_key
          error_category  = /fcbp/if_glt_types=>c_error_category-conflict
          operator_text   = 'Idempotency key exists with a different request hash.'.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_idempotency~confirm_completed.
    mo_repository->confirm_idempotency(
      iv_idempotency_key = iv_idempotency_key
      iv_transfer_id     = iv_transfer_id
      iv_status          = /fcbp/if_glt_types=>c_idemp_status-completed ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_idempotency~mark_failed.
    mo_repository->confirm_idempotency(
      iv_idempotency_key = iv_idempotency_key
      iv_transfer_id     = iv_transfer_id
      iv_status          = /fcbp/if_glt_types=>c_idemp_status-failed ).
  ENDMETHOD.

ENDCLASS.

