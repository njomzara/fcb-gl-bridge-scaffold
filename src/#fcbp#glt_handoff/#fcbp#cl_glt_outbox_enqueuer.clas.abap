"! Outbox enqueuer wrapper used by Source Handoff.
CLASS /fcbp/cl_glt_outbox_enqueuer DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_outbox_enqueuer.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_handoff_repo OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_handoff_repo.

ENDCLASS.

CLASS /fcbp/cl_glt_outbox_enqueuer IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD /fcbp/if_glt_outbox_enqueuer~enqueue_work.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
        EXPORTING
          transfer_id    = is_work-transfer_id
          reason_code    = 'NO_REPOSITORY'
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Outbox enqueuer requires a handoff repository implementation.'.
    ENDIF.

    rv_outbox_id = mo_repository->insert_outbox_work( is_work ).
  ENDMETHOD.

ENDCLASS.

