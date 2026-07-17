"! Default Outbox Execution repository scaffold. Fails closed until bound to /FCBP/GLT_OUTBOX.
CLASS /fcbp/cl_glt_outbox_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_outbox_repo.

  PRIVATE SECTION.
    METHODS not_implemented
      IMPORTING
        iv_operation TYPE char40
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_outbox_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_outbox_repo~select_due_work.
    not_implemented( 'SELECT_DUE_WORK' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~claim_work.
    not_implemented( 'CLAIM_WORK' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~complete_work.
    not_implemented( 'COMPLETE_WORK' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~fail_work.
    not_implemented( 'FAIL_WORK' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~release_work.
    not_implemented( 'RELEASE_WORK' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~supersede_work.
    not_implemented( 'SUPERSEDE_WORK' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~enqueue_work.
    not_implemented( 'ENQUEUE_WORK' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_repo~recover_expired_locks.
    not_implemented( 'RECOVER_EXPIRED_LOCKS' ).
  ENDMETHOD.

  METHOD not_implemented.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = |Outbox repository operation { iv_operation } is not implemented in the scaffold.|.
  ENDMETHOD.

ENDCLASS.
