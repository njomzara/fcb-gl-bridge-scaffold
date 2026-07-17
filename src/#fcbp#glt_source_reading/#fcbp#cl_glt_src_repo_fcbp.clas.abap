"! Productive repository seam. Bind to released FCBP CDS/API projections per tenant.
CLASS /fcbp/cl_glt_src_repo_fcbp DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_src_repo.

ENDCLASS.

CLASS /fcbp/cl_glt_src_repo_fcbp IMPLEMENTATION.

  METHOD /fcbp/if_glt_src_repo~read_recon_header.
    DATA(ls_request) = VALUE /fcbp/if_glt_src_types=>ty_source_read_request(
      source_type      = /fcbp/if_glt_src_types=>c_source_type-reconciliation_key
      source_reference = iv_reconciliation_key ).
    RAISE EXCEPTION /fcbp/cx_glt_source_read=>technical_failure(
      is_request = ls_request
      iv_detail  = 'Released reconciliation-key source projection is not bound yet.' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_repo~read_recon_items.
    RAISE EXCEPTION /fcbp/cx_glt_source_read=>technical_failure(
      is_request = is_request
      iv_detail  = |Released reconciliation-key item projection is not bound for { iv_reconciliation_key }.| ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_repo~read_document_header.
    DATA(ls_request) = VALUE /fcbp/if_glt_src_types=>ty_source_read_request(
      source_type      = /fcbp/if_glt_src_types=>c_source_type-document
      source_reference = iv_source_reference ).
    RAISE EXCEPTION /fcbp/cx_glt_source_read=>technical_failure(
      is_request = ls_request
      iv_detail  = 'Released posting-document source projection is not bound yet.' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_repo~read_document_items.
    RAISE EXCEPTION /fcbp/cx_glt_source_read=>technical_failure(
      is_request = is_request
      iv_detail  = |Released posting-document item projection is not bound for { iv_source_reference }.| ).
  ENDMETHOD.

ENDCLASS.
