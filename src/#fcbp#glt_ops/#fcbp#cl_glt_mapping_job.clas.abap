"! Application job shell for package mapping after validation.
CLASS /fcbp/cl_glt_mapping_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_mapper TYPE REF TO /fcbp/if_glt_mapper OPTIONAL.

    METHODS execute
      IMPORTING
        is_context TYPE /fcbp/if_glt_map_types=>ty_context
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_map_types=>ty_result
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_mapper TYPE REF TO /fcbp/if_glt_mapper.

ENDCLASS.

CLASS /fcbp/cl_glt_mapping_job IMPLEMENTATION.

  METHOD constructor.
    IF io_mapper IS BOUND.
      mo_mapper = io_mapper.
    ELSE.
      mo_mapper = NEW /fcbp/cl_glt_mapper( ).
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    rs_result = mo_mapper->map_package( is_context ).
  ENDMETHOD.

ENDCLASS.
