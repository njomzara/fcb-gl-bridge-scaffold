"! Application job shell for package validation and revalidation.
CLASS /fcbp/cl_glt_validate_pkg_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_validator TYPE REF TO /fcbp/if_glt_pkg_validator OPTIONAL.

    METHODS execute
      IMPORTING
        is_context TYPE /fcbp/if_glt_val_types=>ty_package_context
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_val_types=>ty_result
      RAISING
        /fcbp/cx_glt_validation.

  PRIVATE SECTION.
    DATA mo_validator TYPE REF TO /fcbp/if_glt_pkg_validator.

ENDCLASS.

CLASS /fcbp/cl_glt_validate_pkg_job IMPLEMENTATION.

  METHOD constructor.
    IF io_validator IS BOUND.
      mo_validator = io_validator.
    ELSE.
      mo_validator = NEW /fcbp/cl_glt_pkg_validator( ).
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    rs_result = mo_validator->validate_package( is_context ).
  ENDMETHOD.

ENDCLASS.
