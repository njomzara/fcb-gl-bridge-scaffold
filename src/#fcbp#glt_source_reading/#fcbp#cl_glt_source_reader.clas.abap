"! Source Reading facade and source-type router.
CLASS /fcbp/cl_glt_source_reader DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_source_reader.

    METHODS constructor
      IMPORTING
        io_recon_reader TYPE REF TO /fcbp/if_glt_src_type_reader OPTIONAL
        io_doc_reader   TYPE REF TO /fcbp/if_glt_src_type_reader OPTIONAL
        io_mock_reader  TYPE REF TO /fcbp/if_glt_src_type_reader OPTIONAL
        io_auth_check   TYPE REF TO /fcbp/if_glt_auth_check OPTIONAL.

  PRIVATE SECTION.
    TYPES tt_reader TYPE STANDARD TABLE OF REF TO /fcbp/if_glt_src_type_reader WITH EMPTY KEY.

    DATA mt_reader TYPE tt_reader.
    DATA mo_auth_check TYPE REF TO /fcbp/if_glt_auth_check.

    METHODS validate_request
      IMPORTING
        is_request TYPE /fcbp/if_glt_src_types=>ty_source_read_request
      RAISING
        /fcbp/cx_glt_source_read.

    METHODS check_authority
      IMPORTING
        is_request TYPE /fcbp/if_glt_src_types=>ty_source_read_request
      RAISING
        /fcbp/cx_glt_source_read.

    METHODS select_reader
      IMPORTING
        iv_source_type    TYPE char20
        is_request        TYPE /fcbp/if_glt_src_types=>ty_source_read_request
      RETURNING
        VALUE(ro_reader)  TYPE REF TO /fcbp/if_glt_src_type_reader
      RAISING
        /fcbp/cx_glt_source_read.

    METHODS verify_and_sort
      IMPORTING
        is_request TYPE /fcbp/if_glt_src_types=>ty_source_read_request
      CHANGING
        ct_source_line TYPE /fcbp/if_glt_pkg_types=>tt_source_gl_line
      RAISING
        /fcbp/cx_glt_source_read.

ENDCLASS.

CLASS /fcbp/cl_glt_source_reader IMPLEMENTATION.

  METHOD constructor.
    APPEND COND #( WHEN io_recon_reader IS BOUND THEN io_recon_reader ELSE NEW /fcbp/cl_glt_src_read_recon( ) ) TO mt_reader.
    APPEND COND #( WHEN io_doc_reader IS BOUND THEN io_doc_reader ELSE NEW /fcbp/cl_glt_src_read_doc( ) ) TO mt_reader.
    APPEND COND #( WHEN io_mock_reader IS BOUND THEN io_mock_reader ELSE NEW /fcbp/cl_glt_src_read_mock( ) ) TO mt_reader.
    mo_auth_check = io_auth_check.
  ENDMETHOD.

  METHOD /fcbp/if_glt_source_reader~read_source_lines.
    validate_request( is_request ).
    check_authority( is_request ).

    DATA(lo_reader) = select_reader(
      iv_source_type = is_request-source_type
      is_request     = is_request ).

    rt_source_line = lo_reader->read( is_request ).
    verify_and_sort(
      EXPORTING is_request = is_request
      CHANGING  ct_source_line = rt_source_line ).
  ENDMETHOD.

  METHOD validate_request.
    IF is_request-source_type IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>from_request(
        is_request       = is_request
        iv_error_code    = /fcbp/if_glt_src_types=>c_error_code-request_invalid
        iv_field_name    = 'SOURCE_TYPE'
        iv_operator_text = 'Source-read request is missing source type.' ).
    ENDIF.

    IF is_request-source_reference IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>from_request(
        is_request       = is_request
        iv_error_code    = /fcbp/if_glt_src_types=>c_error_code-request_invalid
        iv_field_name    = 'SOURCE_REFERENCE'
        iv_operator_text = 'Source-read request is missing source reference.' ).
    ENDIF.

    IF is_request-read_mode IS INITIAL.
      RETURN.
    ENDIF.

    CASE is_request-read_mode.
      WHEN /fcbp/if_glt_src_types=>c_read_mode-dispatch
        OR /fcbp/if_glt_src_types=>c_read_mode-rebuild
        OR /fcbp/if_glt_src_types=>c_read_mode-replay
        OR /fcbp/if_glt_src_types=>c_read_mode-support
        OR /fcbp/if_glt_src_types=>c_read_mode-dry_run.
      WHEN OTHERS.
        RAISE EXCEPTION /fcbp/cx_glt_source_read=>from_request(
          is_request       = is_request
          iv_error_code    = /fcbp/if_glt_src_types=>c_error_code-request_invalid
          iv_field_name    = 'READ_MODE'
          iv_operator_text = |Source-read mode { is_request-read_mode } is not supported.| ).
    ENDCASE.
  ENDMETHOD.

  METHOD check_authority.
    IF mo_auth_check IS NOT BOUND OR is_request-transfer_id IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        mo_auth_check->check_display( iv_transfer_id = is_request-transfer_id ).
      CATCH /fcbp/cx_glt_auth INTO DATA(lx_auth).
        RAISE EXCEPTION /fcbp/cx_glt_source_read=>not_authorized(
          is_request  = is_request
          ix_previous = lx_auth ).
    ENDTRY.
  ENDMETHOD.

  METHOD select_reader.
    LOOP AT mt_reader INTO ro_reader.
      IF ro_reader->supports( iv_source_type ) = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    RAISE EXCEPTION /fcbp/cx_glt_source_read=>unsupported_type( is_request ).
  ENDMETHOD.

  METHOD verify_and_sort.
    IF ct_source_line IS INITIAL.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>no_lines( is_request ).
    ENDIF.

    LOOP AT ct_source_line INTO DATA(ls_source_line).
      IF ls_source_line-source_type IS INITIAL
         OR ls_source_line-source_reference IS INITIAL
         OR ls_source_line-source_doc_no IS INITIAL
         OR ls_source_line-source_item_no IS INITIAL
         OR ls_source_line-source_hash IS INITIAL
         OR ls_source_line-line_hash IS INITIAL.
        RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
          is_request    = is_request
          iv_field_name = 'SOURCE_IDENTITY'
          iv_detail     = |Incomplete source identity for item { sy-tabix }.| ).
      ENDIF.

      IF ls_source_line-source_type <> is_request-source_type.
        RAISE EXCEPTION /fcbp/cx_glt_source_read=>from_request(
          is_request       = is_request
          iv_error_code    = /fcbp/if_glt_src_types=>c_error_code-conflict
          iv_field_name    = 'SOURCE_TYPE'
          iv_operator_text = 'Returned source line does not match the requested source type.' ).
      ENDIF.

      IF ls_source_line-source_reference <> is_request-source_reference.
        RAISE EXCEPTION /fcbp/cx_glt_source_read=>from_request(
          is_request       = is_request
          iv_error_code    = /fcbp/if_glt_src_types=>c_error_code-conflict
          iv_field_name    = 'SOURCE_REFERENCE'
          iv_operator_text = 'Returned source line does not match the requested source reference.' ).
      ENDIF.
    ENDLOOP.

    IF is_request-max_line_count > 0
       AND lines( ct_source_line ) > is_request-max_line_count.
      RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
        is_request    = is_request
        iv_field_name = 'MAX_LINE_COUNT'
        iv_detail     = |Source returned { lines( ct_source_line ) } eligible lines; configured maximum is { is_request-max_line_count }.| ).
    ENDIF.

    SORT ct_source_line BY source_type source_reference source_doc_no source_item_no
                           company_code gl_account debit_credit currency source_hash line_hash.

    LOOP AT ct_source_line INTO ls_source_line.
      IF sy-tabix > 1.
        DATA(lv_previous_index) = sy-tabix - 1.
        DATA(ls_previous) = ct_source_line[ lv_previous_index ].
        IF ls_previous-source_doc_no = ls_source_line-source_doc_no
           AND ls_previous-source_item_no = ls_source_line-source_item_no.
          RAISE EXCEPTION /fcbp/cx_glt_source_read=>inconsistent(
            is_request    = is_request
            iv_field_name = 'SOURCE_IDENTITY'
            iv_detail     = |Duplicate source identity { ls_source_line-source_doc_no }/{ ls_source_line-source_item_no }.| ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
