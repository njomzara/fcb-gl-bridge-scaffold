"! Stale lock recovery wrapper for Outbox Execution.
CLASS /fcbp/cl_glt_lock_recovery DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_lock_recovery.

    METHODS constructor
      IMPORTING
        io_repo TYPE REF TO /fcbp/if_glt_outbox_repo OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repo TYPE REF TO /fcbp/if_glt_outbox_repo.

ENDCLASS.

CLASS /fcbp/cl_glt_lock_recovery IMPLEMENTATION.

  METHOD constructor.
    mo_repo = COND #( WHEN io_repo IS BOUND THEN io_repo ELSE NEW /fcbp/cl_glt_outbox_repo( ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_lock_recovery~recover_expired_locks.
    IF mo_repo IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Lock recovery requires an outbox repository.'.
    ENDIF.

    rs_result = mo_repo->recover_expired_locks( is_request ).
  ENDMETHOD.

ENDCLASS.
