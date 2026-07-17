"! Normalizes upstream payloads and derives scaffold IDs/hashes.
"! TODO: Replace placeholder hash/UUID logic with released tenant APIs.
CLASS /fcbp/cl_glt_request_factory DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS create_from_request
      IMPORTING
        is_request         TYPE /fcbp/if_glt_types=>ty_request
      RETURNING
        VALUE(rs_transfer) TYPE /fcbp/if_glt_types=>ty_transfer
      RAISING
        /fcbp/cx_glt_error.

    METHODS calculate_request_hash
      IMPORTING
        is_header           TYPE /fcbp/if_glt_types=>ty_header
        it_item             TYPE /fcbp/if_glt_types=>tt_item
      RETURNING
        VALUE(rv_hash)      TYPE /fcbp/if_glt_types=>ty_request_hash.

    METHODS derive_idempotency_key
      IMPORTING
        is_header           TYPE /fcbp/if_glt_types=>ty_header
        it_item             TYPE /fcbp/if_glt_types=>tt_item
      RETURNING
        VALUE(rv_key)       TYPE /fcbp/if_glt_types=>ty_idempotency_key.

  PRIVATE SECTION.
    METHODS next_scaffold_id
      IMPORTING
        iv_prefix           TYPE char8
      RETURNING
        VALUE(rv_id)        TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_request_factory IMPLEMENTATION.

  METHOD create_from_request.
    DATA lv_item_no TYPE i.
    DATA lv_debit   TYPE p LENGTH 16 DECIMALS 2.
    DATA lv_credit  TYPE p LENGTH 16 DECIMALS 2.

    rs_transfer-header = is_request-header.
    rs_transfer-items  = is_request-items.

    IF rs_transfer-header-transfer_id IS INITIAL.
      rs_transfer-header-transfer_id = next_scaffold_id( 'TRF' ).
    ENDIF.

    IF rs_transfer-header-correlation_id IS INITIAL.
      rs_transfer-header-correlation_id = next_scaffold_id( 'CORR' ).
    ENDIF.

    LOOP AT rs_transfer-items ASSIGNING FIELD-SYMBOL(<ls_item>).
      <ls_item>-transfer_id = rs_transfer-header-transfer_id.
      IF <ls_item>-item_no IS INITIAL.
        lv_item_no = lv_item_no + 10.
        <ls_item>-item_no = lv_item_no.
      ENDIF.
      IF <ls_item>-line_hash IS INITIAL.
        <ls_item>-line_hash = |LINE-{ rs_transfer-header-source_system }-{ rs_transfer-header-source_ref_id }-{ <ls_item>-item_no }|.
      ENDIF.

      CASE <ls_item>-debit_credit.
        WHEN 'S'.
          lv_debit = lv_debit + <ls_item>-amount.
        WHEN 'H'.
          lv_credit = lv_credit + <ls_item>-amount.
      ENDCASE.
    ENDLOOP.

    IF rs_transfer-header-total_debit_amt IS INITIAL.
      rs_transfer-header-total_debit_amt = lv_debit.
    ENDIF.
    IF rs_transfer-header-total_credit_amt IS INITIAL.
      rs_transfer-header-total_credit_amt = lv_credit.
    ENDIF.

    IF rs_transfer-header-idempotency_key IS INITIAL.
      rs_transfer-header-idempotency_key = derive_idempotency_key(
        is_header = rs_transfer-header
        it_item   = rs_transfer-items ).
    ENDIF.

    rs_transfer-header-request_hash = calculate_request_hash(
      is_header = rs_transfer-header
      it_item   = rs_transfer-items ).

    IF rs_transfer-header-status_code IS INITIAL.
      rs_transfer-header-status_code = /fcbp/if_glt_types=>c_status-received.
    ENDIF.
    IF rs_transfer-header-external_status IS INITIAL.
      rs_transfer-header-external_status = /fcbp/if_glt_types=>c_ext_status-received.
    ENDIF.
    IF rs_transfer-header-max_retry_count IS INITIAL.
      rs_transfer-header-max_retry_count = 5.
    ENDIF.
    IF rs_transfer-header-created_by IS INITIAL.
      rs_transfer-header-created_by = sy-uname.
    ENDIF.
    IF rs_transfer-header-changed_by IS INITIAL.
      rs_transfer-header-changed_by = sy-uname.
    ENDIF.
    IF rs_transfer-header-version_no IS INITIAL.
      rs_transfer-header-version_no = 1.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_request_hash.
    rv_hash = |REQ-{ is_header-source_system }-{ is_header-source_type }-{ is_header-source_ref_id }-{ is_header-transfer_type }-{ is_header-company_code }-{ lines( it_item ) }|.
  ENDMETHOD.

  METHOD derive_idempotency_key.
    rv_key = |IDEMP-{ is_header-source_system }-{ is_header-source_type }-{ is_header-source_ref_id }-{ is_header-bus_event_id }-{ is_header-bus_event_ver }-{ is_header-transfer_type }-{ is_header-company_code }-{ lines( it_item ) }|.
  ENDMETHOD.

  METHOD next_scaffold_id.
    rv_id = |{ iv_prefix }-{ sy-datum }-{ sy-uzeit }|.
  ENDMETHOD.

ENDCLASS.

