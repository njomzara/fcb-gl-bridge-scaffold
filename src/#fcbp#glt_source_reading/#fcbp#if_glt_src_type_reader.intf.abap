"! Delegate contract for one source type behind the source-reader facade.
INTERFACE /fcbp/if_glt_src_type_reader PUBLIC.

  METHODS supports
    IMPORTING
      iv_source_type       TYPE char20
    RETURNING
      VALUE(rv_supported)  TYPE abap_bool.

  METHODS read
    IMPORTING
      is_request              TYPE /fcbp/if_glt_src_types=>ty_source_read_request
    RETURNING
      VALUE(rt_source_line)   TYPE /fcbp/if_glt_pkg_types=>tt_source_gl_line
    RAISING
      /fcbp/cx_glt_source_read.

ENDINTERFACE.
