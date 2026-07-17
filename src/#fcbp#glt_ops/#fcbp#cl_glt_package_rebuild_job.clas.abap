"! Application job shell for approved package rebuild.
CLASS /fcbp/cl_glt_package_rebuild_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_preparer TYPE REF TO /fcbp/if_glt_package_preparer OPTIONAL.

    METHODS execute
      IMPORTING
        iv_transfer_id            TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_predecessor_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id
        iv_reason_code            TYPE char30
        is_effective_context      TYPE /fcbp/if_glt_config_types=>ty_effective_context
      RETURNING
        VALUE(rs_result)          TYPE /fcbp/if_glt_aggr_types=>ty_package_build_result
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_preparer TYPE REF TO /fcbp/if_glt_package_preparer.

ENDCLASS.

CLASS /fcbp/cl_glt_package_rebuild_job IMPLEMENTATION.

  METHOD constructor.
    IF io_preparer IS BOUND.
      mo_preparer = io_preparer.
    ELSE.
      mo_preparer = NEW /fcbp/cl_glt_package_preparer( ).
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    rs_result = mo_preparer->rebuild_package(
      iv_transfer_id            = iv_transfer_id
      iv_predecessor_package_id = iv_predecessor_package_id
      iv_reason_code            = iv_reason_code
      is_effective_context      = is_effective_context ).
  ENDMETHOD.

ENDCLASS.
