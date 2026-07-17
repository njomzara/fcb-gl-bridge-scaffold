"! RECONCILIATION_KEY source-type reader.
CLASS /fcbp/cl_glt_src_read_recon DEFINITION PUBLIC FINAL CREATE PUBLIC.

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

CLASS /fcbp/cl_glt_src_read_recon IMPLEMENTATION.

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
      iv_source_type = /fcbp/if_glt_src_types=>c_source_type-reconciliation_key
      OR iv_source_type = /fcbp/if_glt_types=>c_source_type-recon_key ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_src_type_reader~read.
    DATA lv_reconciliation_key TYPE char32.
    lv_reconciliation_key = is_request-source_reference.

    DATA(ls_header) = mo_repo->read_recon_header( lv_reconciliation_key ).

    IF ls_header-reconciliation_key IS INITIAL AND ls_header-source_reference IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>not_found( is_request ).
    ENDIF.

    IF ls_header-closed_flag <> abap_true
       AND ls_header-frozen_flag <> abap_true
       AND ls_header-immutable_flag <> abap_true.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>not_ready(
        is_request = is_request
        iv_detail  = |Reconciliation key status { ls_header-source_status } is not closed, frozen, or immutable.| ).
    ENDIF.

    DATA(lt_item) = mo_repo->read_recon_items(
      iv_reconciliation_key = lv_reconciliation_key
      is_request            = is_request ).

    rt_source_line = mo_normalizer->normalize_items(
      iv_source_type      = /fcbp/if_glt_src_types=>c_source_type-reconciliation_key
      iv_source_reference = is_request-source_reference
      is_request          = is_request
      it_item             = lt_item ).
  ENDMETHOD.

ENDCLASS.
