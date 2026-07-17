"! Application log wrapper scaffold. Persist only normalized, support-safe errors here.
CLASS /fcbp/cl_glt_app_logger DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_logger.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_repository OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_repository.

ENDCLASS.

CLASS /fcbp/cl_glt_app_logger IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD /fcbp/if_glt_logger~log_info.
    " TODO: Wrap released ABAP Cloud application log API for object /FCBP/GLT.
  ENDMETHOD.

  METHOD /fcbp/if_glt_logger~log_error.
    IF mo_repository IS BOUND.
      rv_error_id = mo_repository->insert_error( is_error ).
    ELSE.
      rv_error_id = |ERR-{ sy-datum }-{ sy-uzeit }|.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_logger~save_log.
    " TODO: Persist /FCBP/GLT_LOGREF with the released application log handle.
    rv_logref_id = |LOG-{ sy-datum }-{ sy-uzeit }|.
  ENDMETHOD.

ENDCLASS.

