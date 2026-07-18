"! Default database repository scaffold over the activated /FCBP/GLT_* tables.
CLASS /fcbp/cl_glt_repository DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_repository.

  PRIVATE SECTION.
    METHODS create_id
      IMPORTING
        iv_prefix       TYPE char8
      RETURNING
        VALUE(rv_value) TYPE char32.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

    METHODS raise_repository
      IMPORTING
        iv_text        TYPE char220
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      RAISING
        /fcbp/cx_glt_repository.

ENDCLASS.

CLASS /fcbp/cl_glt_repository IMPLEMENTATION.

  METHOD /fcbp/if_glt_repository~create_transfer.
    DATA(ls_header) = is_header.
    IF ls_header-transfer_id IS INITIAL.
      ls_header-transfer_id = create_id( 'TRF' ).
    ENDIF.
    IF ls_header-created_at IS INITIAL.
      ls_header-created_at = now( ).
    ENDIF.
    IF ls_header-changed_at IS INITIAL.
      ls_header-changed_at = ls_header-created_at.
    ENDIF.
    IF ls_header-created_by IS INITIAL.
      ls_header-created_by = sy-uname.
    ENDIF.
    IF ls_header-changed_by IS INITIAL.
      ls_header-changed_by = ls_header-created_by.
    ENDIF.

    TRY.
        INSERT /fcbp/glt_hdr FROM @ls_header.

        DATA(lv_item_no) = 0.
        LOOP AT it_item INTO DATA(ls_item).
          DATA(ls_db_item) = ls_item.
          ls_db_item-transfer_id = ls_header-transfer_id.
          IF ls_db_item-item_no IS INITIAL.
            lv_item_no = lv_item_no + 1.
            ls_db_item-item_no = lv_item_no.
          ENDIF.
          IF ls_db_item-created_at IS INITIAL.
            ls_db_item-created_at = ls_header-created_at.
          ENDIF.
          INSERT /fcbp/glt_item FROM @ls_db_item.
        ENDLOOP.
      CATCH cx_sy_open_sql_db INTO DATA(lx_sql).
        raise_repository(
          iv_transfer_id = ls_header-transfer_id
          iv_text        = |Transfer { ls_header-transfer_id } could not be persisted.| ).
    ENDTRY.

    rv_transfer_id = ls_header-transfer_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~read_transfer.
    SELECT SINGLE *
      FROM /fcbp/glt_hdr
      WHERE transfer_id = @iv_transfer_id
      INTO @DATA(ls_header).
    IF sy-subrc <> 0.
      raise_repository(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Transfer { iv_transfer_id } was not found.| ).
    ENDIF.

    rs_transfer-header = CORRESPONDING #( ls_header ).

    SELECT *
      FROM /fcbp/glt_item
      WHERE transfer_id = @iv_transfer_id
      ORDER BY item_no
      INTO TABLE @DATA(lt_item).
    rs_transfer-items = CORRESPONDING #( lt_item ).

    SELECT *
      FROM /fcbp/glt_stat
      WHERE transfer_id = @iv_transfer_id
      ORDER BY seq_no
      INTO TABLE @DATA(lt_status).
    rs_transfer-statuses = CORRESPONDING #( lt_status ).

    SELECT *
      FROM /fcbp/glt_err
      WHERE transfer_id = @iv_transfer_id
      ORDER BY created_at
      INTO TABLE @DATA(lt_error).
    rs_transfer-errors = CORRESPONDING #( lt_error ).

    SELECT *
      FROM /fcbp/glt_ref
      WHERE transfer_id = @iv_transfer_id
      ORDER BY created_at
      INTO TABLE @DATA(lt_ref).
    rs_transfer-target_refs = CORRESPONDING #( lt_ref ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~update_header.
    DATA(ls_header) = is_header.
    IF ls_header-changed_at IS INITIAL.
      ls_header-changed_at = now( ).
    ENDIF.
    IF ls_header-changed_by IS INITIAL.
      ls_header-changed_by = sy-uname.
    ENDIF.

    UPDATE /fcbp/glt_hdr FROM @ls_header.
    IF sy-subrc <> 0.
      raise_repository(
        iv_transfer_id = is_header-transfer_id
        iv_text        = |Transfer header { is_header-transfer_id } could not be updated.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_status.
    DATA(ls_status) = is_status.
    IF ls_status-seq_no IS INITIAL.
      SELECT MAX( seq_no )
        FROM /fcbp/glt_stat
        WHERE transfer_id = @ls_status-transfer_id
        INTO @DATA(lv_seq_no).
      ls_status-seq_no = lv_seq_no + 1.
    ENDIF.
    IF ls_status-created_at IS INITIAL.
      ls_status-created_at = now( ).
    ENDIF.

    INSERT /fcbp/glt_stat FROM @ls_status.
    IF sy-subrc <> 0.
      raise_repository(
        iv_transfer_id = ls_status-transfer_id
        iv_text        = |Status row for transfer { ls_status-transfer_id } could not be inserted.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_error.
    DATA(ls_error) = is_error.
    IF ls_error-error_id IS INITIAL.
      ls_error-error_id = create_id( 'ERR' ).
    ENDIF.
    IF ls_error-created_at IS INITIAL.
      ls_error-created_at = now( ).
    ENDIF.
    IF ls_error-created_by IS INITIAL.
      ls_error-created_by = sy-uname.
    ENDIF.

    INSERT /fcbp/glt_err FROM @ls_error.
    IF sy-subrc <> 0.
      raise_repository(
        iv_transfer_id = ls_error-transfer_id
        iv_text        = |Error row { ls_error-error_id } could not be inserted.| ).
    ENDIF.
    rv_error_id = ls_error-error_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~reserve_idempotency.
    SELECT SINGLE *
      FROM /fcbp/glt_idemp
      WHERE idempotency_key = @is_reservation-idempotency_key
      INTO @DATA(ls_existing).

    IF sy-subrc = 0.
      rs_decision = VALUE #(
        idempotency_key = ls_existing-idempotency_key
        transfer_id     = ls_existing-transfer_id
        status_code     = /fcbp/if_glt_types=>c_status-received
        external_status = /fcbp/if_glt_types=>c_ext_status-received
        existing_hash   = ls_existing-request_hash
        duplicate       = xsdbool( ls_existing-request_hash = is_reservation-request_hash AND ls_existing-transfer_id IS NOT INITIAL )
        conflict        = xsdbool( ls_existing-request_hash <> is_reservation-request_hash ) ).
      rs_decision-decision = COND #(
        WHEN rs_decision-conflict = abap_true THEN /fcbp/if_glt_types=>c_idemp_decision-conflict
        WHEN ls_existing-transfer_id IS INITIAL THEN /fcbp/if_glt_types=>c_idemp_decision-in_flight
        ELSE /fcbp/if_glt_types=>c_idemp_decision-duplicate ).
      RETURN.
    ENDIF.

    DATA(ls_idemp) = CORRESPONDING /fcbp/glt_idemp( is_reservation ).
    ls_idemp-reservation_status = /fcbp/if_glt_types=>c_idemp_status-reserved.
    ls_idemp-reserved_at = now( ).
    IF ls_idemp-reserved_by IS INITIAL.
      ls_idemp-reserved_by = sy-uname.
    ENDIF.

    INSERT /fcbp/glt_idemp FROM @ls_idemp.
    IF sy-subrc <> 0.
      raise_repository(
        iv_transfer_id = is_reservation-transfer_id
        iv_text        = |Idempotency key { is_reservation-idempotency_key } could not be reserved.| ).
    ENDIF.

    rs_decision = VALUE #(
      decision        = /fcbp/if_glt_types=>c_idemp_decision-created
      idempotency_key = is_reservation-idempotency_key
      transfer_id     = is_reservation-transfer_id
      status_code     = /fcbp/if_glt_types=>c_status-received
      external_status = /fcbp/if_glt_types=>c_ext_status-received ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~confirm_idempotency.
    DATA(lv_now) = now( ).
    UPDATE /fcbp/glt_idemp
      SET transfer_id = @iv_transfer_id,
          reservation_status = @iv_status,
          completed_at = @lv_now
      WHERE idempotency_key = @iv_idempotency_key.
    IF sy-subrc <> 0.
      raise_repository(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Idempotency key { iv_idempotency_key } could not be confirmed.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_retry.
    DATA(ls_retry) = is_retry.
    IF ls_retry-retry_id IS INITIAL.
      ls_retry-retry_id = create_id( 'RTY' ).
    ENDIF.
    IF ls_retry-created_at IS INITIAL.
      ls_retry-created_at = now( ).
    ENDIF.
    IF ls_retry-changed_at IS INITIAL.
      ls_retry-changed_at = ls_retry-created_at.
    ENDIF.
    INSERT /fcbp/glt_retry FROM @ls_retry.
    IF sy-subrc <> 0.
      raise_repository(
        iv_transfer_id = ls_retry-transfer_id
        iv_text        = |Retry row { ls_retry-retry_id } could not be inserted.| ).
    ENDIF.
    rv_retry_id = ls_retry-retry_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~insert_target_ref.
    DATA(ls_ref) = is_target_ref.
    IF ls_ref-ref_id IS INITIAL.
      ls_ref-ref_id = create_id( 'REF' ).
    ENDIF.
    IF ls_ref-created_at IS INITIAL.
      ls_ref-created_at = now( ).
    ENDIF.
    INSERT /fcbp/glt_ref FROM @ls_ref.
    IF sy-subrc <> 0.
      raise_repository(
        iv_transfer_id = ls_ref-transfer_id
        iv_text        = |Target reference { ls_ref-ref_id } could not be inserted.| ).
    ENDIF.
    rv_ref_id = ls_ref-ref_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~read_config.
    SELECT SINGLE *
      FROM /fcbp/glt_cfg
      WHERE transfer_type = @iv_transfer_type
      INTO @DATA(ls_config).
    IF sy-subrc <> 0.
      raise_repository( |Transfer configuration { iv_transfer_type } was not found.| ).
    ENDIF.
    rs_config = CORRESPONDING #( ls_config ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~resolve_route.
    SELECT *
      FROM /fcbp/glt_route
      WHERE transfer_type = @is_header-transfer_type
        AND source_system = @is_header-source_system
        AND active = @abap_true
        AND ( company_code = @is_header-company_code OR company_code = '' )
      ORDER BY priority ASCENDING, valid_from DESCENDING, route_id ASCENDING
      INTO TABLE @DATA(lt_route).
    READ TABLE lt_route INTO DATA(ls_route) INDEX 1.
    IF sy-subrc <> 0.
      raise_repository(
        iv_transfer_id = is_header-transfer_id
        iv_text        = |No route found for transfer type { is_header-transfer_type }.| ).
    ENDIF.
    rs_route = CORRESPONDING #( ls_route ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_repository~query_reconciliation.
    SELECT transfer_id
      FROM /fcbp/glt_hdr
      WHERE ( @is_filter-transfer_id IS INITIAL OR transfer_id = @is_filter-transfer_id )
        AND ( @is_filter-source_system IS INITIAL OR source_system = @is_filter-source_system )
        AND ( @is_filter-source_type IS INITIAL OR source_type = @is_filter-source_type )
        AND ( @is_filter-source_ref_id IS INITIAL OR source_ref_id = @is_filter-source_ref_id )
        AND ( @is_filter-idempotency_key IS INITIAL OR idempotency_key = @is_filter-idempotency_key )
        AND ( @is_filter-company_code IS INITIAL OR company_code = @is_filter-company_code )
        AND ( @is_filter-status_code IS INITIAL OR status_code = @is_filter-status_code )
      ORDER BY created_at DESCENDING
      INTO TABLE @DATA(lt_transfer_id).

    LOOP AT lt_transfer_id INTO DATA(lv_transfer_id).
      APPEND /fcbp/if_glt_repository~read_transfer( lv_transfer_id ) TO rt_transfer.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_id.
    TRY.
        rv_value = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        rv_value = |{ iv_prefix }{ sy-datum }{ sy-uzeit }|.
    ENDTRY.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

  METHOD raise_repository.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_repository
      EXPORTING
        transfer_id    = iv_transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = iv_text.
  ENDMETHOD.

ENDCLASS.
