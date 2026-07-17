"! ABAP Cloud-compatible package id factory scaffold.
CLASS /fcbp/cl_glt_package_id_factory DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_package_id_factory.

ENDCLASS.

CLASS /fcbp/cl_glt_package_id_factory IMPLEMENTATION.

  METHOD /fcbp/if_glt_package_id_factory~create_package_id.
    TRY.
        rv_package_id = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_root INTO DATA(lx_uuid).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_error
          EXPORTING
            transfer_id    = iv_transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-technical
            operator_text  = |Package id generation failed for mode { iv_build_mode }.|
            previous       = lx_uuid.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
