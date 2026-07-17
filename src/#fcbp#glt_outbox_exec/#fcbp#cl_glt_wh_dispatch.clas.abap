"! DISPATCH work handler scaffold. Full package/validation/mapping/adapter pipeline is delegated.
CLASS /fcbp/cl_glt_wh_dispatch DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_work_handler.

  PRIVATE SECTION.
    METHODS assert_work_type
      IMPORTING
        is_work TYPE /fcbp/if_glt_types=>ty_outbox_work
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_wh_dispatch IMPLEMENTATION.

  METHOD /fcbp/if_glt_work_handler~handle.
    assert_work_type( is_work ).
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        transfer_id    = is_work-transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-technical
        operator_text  = 'DISPATCH handler pipeline is not implemented in the scaffold.'.
  ENDMETHOD.

  METHOD assert_work_type.
    IF is_work-work_type <> /fcbp/if_glt_types=>c_outbox_work_type-dispatch.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_work-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = |DISPATCH handler received work type { is_work-work_type }.|.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
