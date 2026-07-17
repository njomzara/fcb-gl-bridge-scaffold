"! Default Monitoring and Status repository scaffold.
"! TODO: Implement against activated /FCBP/GLT_* tables and released ABAP Cloud SQL APIs.
CLASS /fcbp/cl_glt_monitor_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_monitor_repo.

  PRIVATE SECTION.
    METHODS not_implemented
      IMPORTING
        iv_operation TYPE char40
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_monitor_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_monitor_repo~read_transfer.
    not_implemented( 'READ_TRANSFER' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~query_monitor.
    not_implemented( 'QUERY_MONITOR' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_error.
    not_implemented( 'INSERT_ERROR' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_message.
    not_implemented( 'INSERT_MESSAGE' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_target_ref.
    not_implemented( 'INSERT_TARGET_REF' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_attempt.
    not_implemented( 'INSERT_ATTEMPT' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_jobrun.
    not_implemented( 'INSERT_JOBRUN' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~update_jobrun.
    not_implemented( 'UPDATE_JOBRUN' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~insert_outbox_work.
    not_implemented( 'INSERT_OUTBOX_WORK' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~cancel_open_work.
    not_implemented( 'CANCEL_OPEN_WORK' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~has_started_attempt.
    not_implemented( 'HAS_STARTED_ATTEMPT' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_monitor_repo~write_audit_event.
    not_implemented( 'WRITE_AUDIT_EVENT' ).
  ENDMETHOD.

  METHOD not_implemented.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = |Monitoring repository operation { iv_operation } is not implemented in the scaffold.|.
  ENDMETHOD.

ENDCLASS.
