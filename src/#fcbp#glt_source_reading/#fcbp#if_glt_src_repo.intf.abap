"! Repository abstraction over released FCBP source projections/APIs.
INTERFACE /fcbp/if_glt_src_repo PUBLIC.

  METHODS read_recon_header
    IMPORTING
      iv_reconciliation_key TYPE char32
    RETURNING
      VALUE(rs_header)      TYPE /fcbp/if_glt_src_types=>ty_recon_header
    RAISING
      /fcbp/cx_glt_source_read.

  METHODS read_recon_items
    IMPORTING
      iv_reconciliation_key TYPE char32
      is_request            TYPE /fcbp/if_glt_src_types=>ty_source_read_request
    RETURNING
      VALUE(rt_item)        TYPE /fcbp/if_glt_src_types=>tt_source_projection_item
    RAISING
      /fcbp/cx_glt_source_read.

  METHODS read_document_header
    IMPORTING
      iv_source_reference TYPE char50
    RETURNING
      VALUE(rs_header)    TYPE /fcbp/if_glt_src_types=>ty_document_header
    RAISING
      /fcbp/cx_glt_source_read.

  METHODS read_document_items
    IMPORTING
      iv_source_reference TYPE char50
      is_request          TYPE /fcbp/if_glt_src_types=>ty_source_read_request
    RETURNING
      VALUE(rt_item)      TYPE /fcbp/if_glt_src_types=>tt_source_projection_item
    RAISING
      /fcbp/cx_glt_source_read.

ENDINTERFACE.
