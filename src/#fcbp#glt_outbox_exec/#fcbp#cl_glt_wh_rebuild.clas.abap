"! REBUILD work handler scaffold. Successor package creation stays in Package Builder.
CLASS /fcbp/cl_glt_wh_rebuild DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_work_handler.

ENDCLASS.

CLASS /fcbp/cl_glt_wh_rebuild IMPLEMENTATION.

  METHOD /fcbp/if_glt_work_handler~handle.
    IF is_work-work_type <> /fcbp/if_glt_types=>c_outbox_work_type-rebuild.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_work-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = |REBUILD handler received work type { is_work-work_type }.|.
    ENDIF.

    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        transfer_id    = is_work-transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-technical
        operator_text  = 'REBUILD handler pipeline is not implemented in the scaffold.'.
  ENDMETHOD.

ENDCLASS.
