"! Builds source contribution trace for canonical lines.
INTERFACE /fcbp/if_glt_source_trace_builder PUBLIC.

  METHODS build_trace_for_source
    IMPORTING
      is_source_line   TYPE /fcbp/if_glt_pkg_types=>ty_source_gl_line
      is_canonical     TYPE /fcbp/if_glt_pkg_types=>ty_canonical_line
      iv_sequence      TYPE i
    RETURNING
      VALUE(rs_trace)  TYPE /fcbp/if_glt_pkg_types=>ty_source_trace
    RAISING
      /fcbp/cx_glt_preparation.

  METHODS assert_complete
    IMPORTING
      it_canonical TYPE /fcbp/if_glt_pkg_types=>tt_canonical_line
      it_trace     TYPE /fcbp/if_glt_pkg_types=>tt_source_trace
    RAISING
      /fcbp/cx_glt_preparation.

ENDINTERFACE.
