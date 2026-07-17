"! Application job shell for /FCBP/GLT_DISPATCH.
CLASS /fcbp/cl_glt_dispatch_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_orchestrator TYPE REF TO /fcbp/cl_glt_orchestrator OPTIONAL.

    METHODS execute
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_orchestrator TYPE REF TO /fcbp/cl_glt_orchestrator.

ENDCLASS.

CLASS /fcbp/cl_glt_dispatch_job IMPLEMENTATION.

  METHOD constructor.
    IF io_orchestrator IS BOUND.
      mo_orchestrator = io_orchestrator.
    ELSE.
      mo_orchestrator = NEW /fcbp/cl_glt_orchestrator( ).
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    " TODO: Select due READY transfers, claim one transfer per LUW, then dispatch.
    IF mo_orchestrator IS BOUND AND iv_transfer_id IS NOT INITIAL.
      DATA(ls_result) = mo_orchestrator->dispatch( iv_transfer_id ).
    ELSE.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-technical
                  operator_text  = 'Dispatch job requires selection logic or an explicit transfer ID.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
