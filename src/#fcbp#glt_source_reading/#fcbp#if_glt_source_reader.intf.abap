"! Public Source Reading contract used by Transfer Core and package preparation.
INTERFACE /fcbp/if_glt_source_reader PUBLIC.

  METHODS read_source_lines
    IMPORTING
      is_request              TYPE /fcbp/if_glt_src_types=>ty_source_read_request
    RETURNING
      VALUE(rt_source_line)   TYPE /fcbp/if_glt_pkg_types=>tt_source_gl_line
    RAISING
      /fcbp/cx_glt_source_read.

ENDINTERFACE.
