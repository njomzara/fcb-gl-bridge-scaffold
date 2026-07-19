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

    DATA(lv_eligible_count) = 0.
    LOOP AT lt_item INTO DATA(ls_item) WHERE exclude_flag = abap_false.
      lv_eligible_count += 1.
      IF ls_item-source_snapshot_id <> ls_header-source_snapshot_id
         OR ls_item-company_code <> ls_header-company_code
         OR ls_item-currency <> ls_header-currency
         OR ls_item-source_doc_no <> ls_header-source_doc_no.
        RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
          is_request    = is_request
          iv_field_name = 'HEADER_ITEM_CONSISTENCY'
          iv_detail     = |Source item { ls_item-source_doc_no }/{ ls_item-source_item_no } does not match document header identity, snapshot, company code, or currency.| ).
      ENDIF.
    ENDLOOP.

    IF lv_eligible_count <> ls_header-item_count.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
        is_request    = is_request
        iv_field_name = 'ITEM_COUNT'
        iv_detail     = |Header item count { ls_header-item_count } differs from eligible row count { lv_eligible_count }.| ).
    ENDIF.

    rt_source_line = mo_normalizer->normalize_items(
      iv_source_type      = /fcbp/if_glt_src_types=>c_source_type-document
      iv_source_reference = is_request-source_reference
      is_request          = is_request
      it_item             = lt_item ).
  ENDMETHOD.

ENDCLASS.
