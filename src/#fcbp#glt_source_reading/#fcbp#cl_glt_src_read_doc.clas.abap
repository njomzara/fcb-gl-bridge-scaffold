"! DOCUMENT source-type reader.
CLASS /fcbp/cl_glt_src_read_doc DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_src_type_reader.

    METHODS constructor
      IMPORTING
        io_repo       TYPE REF TO /fcbp/if_glt_src_repo OPTIONAL
        io_normalizer TYPE REF TO /fcbp/cl_glt_src_normalizer OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repo TYPE REF TO /fcbp/if_glt_src_repo.
    DATA mo_normalizer TYPE REF TO /fcbp/cl_glt_src_normalizer.

ENDCLASS.

CLASS /fcbp/cl_glt_src_read_doc IMPLEMENTATION.

  METHOD constructor.
    IF io_repo IS BOUND.
      mo_repo = io_repo.
    ELSE.
      mo_repo = NEW /fcbp/cl_glt_src_repo_fcbp( ).
    ENDIF.

    IF io_normalizer IS BOUND.
      mo_normalizer = io_normalizer.
    ELSE.
      mo_normalizer = NEW /fcbp/cl_glt_src_normalizer( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_type_reader~supports.
    rv_supported = xsdbool(
      iv_source_type = /fcbp/if_glt_src_types=>c_source_type-document
      OR iv_source_type = /fcbp/if_glt_types=>c_source_type-document ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_type_reader~read.
    DATA(ls_header) = mo_repo->read_document_header( is_request-source_reference ).

    IF ls_header-source_reference IS INITIAL AND ls_header-source_doc_no IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>not_found( is_request ).
    ENDIF.

    IF ls_header-accounting_complete <> abap_true OR ls_header-immutable_flag <> abap_true.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>not_ready(
        is_request = is_request
        iv_detail  = |Document status { ls_header-source_status } is not accounting-complete and immutable.| ).
    ENDIF.

    DATA(lt_item) = mo_repo->read_document_items(
      iv_source_reference = is_request-source_reference
      is_request          = is_request ).

    rt_source_line = mo_normalizer->normalize_items(
      iv_source_type      = /fcbp/if_glt_src_types=>c_source_type-document
      iv_source_reference = is_request-source_reference
      is_request          = is_request
      it_item             = lt_item ).
  ENDMETHOD.

ENDCLASS.
