"! STATUS_QUERY work handler scaffold. It must query target status without blind resubmission.
CLASS /fcbp/cl_glt_wh_status_qry DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_work_handler.

ENDCLASS.

CLASS /fcbp/cl_glt_wh_status_qry IMPLEMENTATION.

  METHOD /fcbp/if_glt_work_handler~handle.
    IF is_work-work_type <> /fcbp/if_glt_types=>c_outbox_work_type-status_query.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_work-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = |STATUS_QUERY handler received work type { is_work-work_type }.|.
    ENDIF.

    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        transfer_id    = is_work-transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-unknown_confirmation
        retryable      = abap_true
        unknown_confirmation = abap_true
        operator_text  = 'STATUS_QUERY handler pipeline is not implemented in the scaffold.'.
  ENDMETHOD.

ENDCLASS.
