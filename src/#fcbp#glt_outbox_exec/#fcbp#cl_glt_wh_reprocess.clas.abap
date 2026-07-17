"! REPROCESS work handler scaffold for controlled operator/policy reprocessing.
CLASS /fcbp/cl_glt_wh_reprocess DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_work_handler.

ENDCLASS.

CLASS /fcbp/cl_glt_wh_reprocess IMPLEMENTATION.

  METHOD /fcbp/if_glt_work_handler~handle.
    IF is_work-work_type <> /fcbp/if_glt_types=>c_outbox_work_type-reprocess.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_work-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = |REPROCESS handler received work type { is_work-work_type }.|.
    ENDIF.

    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        transfer_id    = is_work-transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-technical
        operator_text  = 'REPROCESS handler pipeline is not implemented in the scaffold.'.
  ENDMETHOD.

ENDCLASS.
