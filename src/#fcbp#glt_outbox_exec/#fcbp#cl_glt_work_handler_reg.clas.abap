"! Work-type to handler registry for Outbox Execution.
CLASS /fcbp/cl_glt_work_handler_reg DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_dispatch     TYPE REF TO /fcbp/if_glt_work_handler OPTIONAL
        io_retry        TYPE REF TO /fcbp/if_glt_work_handler OPTIONAL
        io_rebuild      TYPE REF TO /fcbp/if_glt_work_handler OPTIONAL
        io_poll         TYPE REF TO /fcbp/if_glt_work_handler OPTIONAL
        io_status_query TYPE REF TO /fcbp/if_glt_work_handler OPTIONAL
        io_reprocess    TYPE REF TO /fcbp/if_glt_work_handler OPTIONAL.

    METHODS resolve
      IMPORTING
        iv_work_type       TYPE char20
      RETURNING
        VALUE(ro_handler)  TYPE REF TO /fcbp/if_glt_work_handler
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_dispatch     TYPE REF TO /fcbp/if_glt_work_handler.
    DATA mo_retry        TYPE REF TO /fcbp/if_glt_work_handler.
    DATA mo_rebuild      TYPE REF TO /fcbp/if_glt_work_handler.
    DATA mo_poll         TYPE REF TO /fcbp/if_glt_work_handler.
    DATA mo_status_query TYPE REF TO /fcbp/if_glt_work_handler.
    DATA mo_reprocess    TYPE REF TO /fcbp/if_glt_work_handler.

ENDCLASS.

CLASS /fcbp/cl_glt_work_handler_reg IMPLEMENTATION.

  METHOD constructor.
    mo_dispatch     = COND #( WHEN io_dispatch     IS BOUND THEN io_dispatch     ELSE NEW /fcbp/cl_glt_wh_dispatch( ) ).
    mo_retry        = COND #( WHEN io_retry        IS BOUND THEN io_retry        ELSE NEW /fcbp/cl_glt_wh_retry( ) ).
    mo_rebuild      = COND #( WHEN io_rebuild      IS BOUND THEN io_rebuild      ELSE NEW /fcbp/cl_glt_wh_rebuild( ) ).
    mo_poll         = COND #( WHEN io_poll         IS BOUND THEN io_poll         ELSE NEW /fcbp/cl_glt_wh_poll( ) ).
    mo_status_query = COND #( WHEN io_status_query IS BOUND THEN io_status_query ELSE NEW /fcbp/cl_glt_wh_status_qry( ) ).
    mo_reprocess    = COND #( WHEN io_reprocess    IS BOUND THEN io_reprocess    ELSE NEW /fcbp/cl_glt_wh_reprocess( ) ).
  ENDMETHOD.

  METHOD resolve.
    CASE iv_work_type.
      WHEN /fcbp/if_glt_types=>c_outbox_work_type-dispatch.
        ro_handler = mo_dispatch.
      WHEN /fcbp/if_glt_types=>c_outbox_work_type-retry.
        ro_handler = mo_retry.
      WHEN /fcbp/if_glt_types=>c_outbox_work_type-rebuild.
        ro_handler = mo_rebuild.
      WHEN /fcbp/if_glt_types=>c_outbox_work_type-poll.
        ro_handler = mo_poll.
      WHEN /fcbp/if_glt_types=>c_outbox_work_type-status_query.
        ro_handler = mo_status_query.
      WHEN /fcbp/if_glt_types=>c_outbox_work_type-reprocess.
        ro_handler = mo_reprocess.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_error
          EXPORTING
            error_category = /fcbp/if_glt_types=>c_error_category-config
            operator_text  = |No outbox work handler is registered for work type { iv_work_type }.|.
    ENDCASE.

    IF ro_handler IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = |Outbox work handler { iv_work_type } is not bound.|.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
