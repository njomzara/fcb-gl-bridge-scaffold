"! Logical lock manager scaffold. Prefer atomic DB/RAP claim patterns in ABAP Cloud.
CLASS /fcbp/cl_glt_lock_manager DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_lock_manager.

ENDCLASS.

CLASS /fcbp/cl_glt_lock_manager IMPLEMENTATION.

  METHOD /fcbp/if_glt_lock_manager~try_lock_transfer.
    " TODO: Atomically set LOCK_OWNER/LOCK_UNTIL where current lock is empty or expired.
    rv_locked = abap_false.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_lock
      EXPORTING
        transfer_id    = iv_transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-lock
        retryable      = abap_true
        operator_text  = 'Lock manager is not implemented in the scaffold.'.
  ENDMETHOD.

  METHOD /fcbp/if_glt_lock_manager~release_transfer.
    " TODO: Clear LOCK_OWNER/LOCK_UNTIL only for matching owner.
  ENDMETHOD.

  METHOD /fcbp/if_glt_lock_manager~claim_retry.
    " TODO: Atomically claim the oldest due retry row.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_lock
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-lock
        retryable      = abap_true
        operator_text  = 'Retry claim is not implemented in the scaffold.'.
  ENDMETHOD.

ENDCLASS.

