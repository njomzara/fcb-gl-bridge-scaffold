"! Application job shell for /FCBP/GLT_RETRY.
CLASS /fcbp/cl_glt_retry_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_orchestrator  TYPE REF TO /fcbp/cl_glt_orchestrator OPTIONAL
        io_lock_manager  TYPE REF TO /fcbp/if_glt_lock_manager OPTIONAL.

    METHODS execute
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_orchestrator TYPE REF TO /fcbp/cl_glt_orchestrator.
    DATA mo_lock_manager TYPE REF TO /fcbp/if_glt_lock_manager.

ENDCLASS.

CLASS /fcbp/cl_glt_retry_job IMPLEMENTATION.

  METHOD constructor.
    mo_orchestrator = io_orchestrator.
    mo_lock_manager = io_lock_manager.
  ENDMETHOD.

  METHOD execute.
    " TODO: Claim due /FCBP/GLT_RETRY rows and dispatch/reprocess according to RETRY_TYPE.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-technical
                operator_text  = 'Retry job claim/dispatch loop is not implemented in the scaffold.'.
  ENDMETHOD.

ENDCLASS.

