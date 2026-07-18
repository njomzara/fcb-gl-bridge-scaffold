"! Logical lock manager over transfer and retry lock columns.
CLASS /fcbp/cl_glt_lock_manager DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_lock_manager.

  PRIVATE SECTION.
    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

    METHODS raise_lock
      IMPORTING
        iv_text        TYPE char220
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      RAISING
        /fcbp/cx_glt_lock.

ENDCLASS.

CLASS /fcbp/cl_glt_lock_manager IMPLEMENTATION.

  METHOD /fcbp/if_glt_lock_manager~try_lock_transfer.
    DATA(lv_now) = now( ).
    UPDATE /fcbp/glt_hdr
      SET lock_owner = @iv_owner,
          lock_until = @iv_lock_until
      WHERE transfer_id = @iv_transfer_id
        AND ( lock_owner = '' OR lock_until <= @lv_now ).
    IF sy-subrc = 0.
      rv_locked = abap_true.
      RETURN.
    ENDIF.

    SELECT SINGLE transfer_id
      FROM /fcbp/glt_hdr
      WHERE transfer_id = @iv_transfer_id
      INTO @DATA(lv_transfer_id).
    IF sy-subrc <> 0.
      raise_lock(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Transfer { iv_transfer_id } was not found for locking.| ).
    ENDIF.
    rv_locked = abap_false.
  ENDMETHOD.

  METHOD /fcbp/if_glt_lock_manager~release_transfer.
    DATA lv_initial_ts TYPE utclong.
    UPDATE /fcbp/glt_hdr
      SET lock_owner = '',
          lock_until = @lv_initial_ts
      WHERE transfer_id = @iv_transfer_id
        AND lock_owner = @iv_owner.
    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    SELECT SINGLE transfer_id
      FROM /fcbp/glt_hdr
      WHERE transfer_id = @iv_transfer_id
      INTO @DATA(lv_transfer_id).
    IF sy-subrc <> 0.
      raise_lock(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Transfer { iv_transfer_id } was not found for lock release.| ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_lock_manager~claim_retry.
    DATA(lv_now) = now( ).
    DATA lv_initial_ts TYPE utclong.
    SELECT *
      FROM /fcbp/glt_retry
      WHERE status_code = @/fcbp/if_glt_types=>c_retry_status-due
        AND ( due_at = @lv_initial_ts OR due_at <= @lv_now )
        AND ( lock_owner = '' OR lock_until <= @lv_now )
      ORDER BY due_at ASCENDING, retry_id ASCENDING
      INTO TABLE @DATA(lt_retry).

    LOOP AT lt_retry INTO DATA(ls_retry).
      UPDATE /fcbp/glt_retry
        SET status_code = @/fcbp/if_glt_types=>c_retry_status-claimed,
            lock_owner = @iv_owner,
            lock_until = @iv_lock_until,
            changed_at = @lv_now
        WHERE retry_id = @ls_retry-retry_id
          AND status_code = @/fcbp/if_glt_types=>c_retry_status-due
          AND ( lock_owner = '' OR lock_until <= @lv_now ).
      IF sy-subrc = 0.
        SELECT SINGLE *
          FROM /fcbp/glt_retry
          WHERE retry_id = @ls_retry-retry_id
          INTO @DATA(ls_claimed).
        rs_retry = CORRESPONDING #( ls_claimed ).
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

  METHOD raise_lock.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_lock
      EXPORTING
        transfer_id    = iv_transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-lock
        retryable      = abap_true
        operator_text  = iv_text.
  ENDMETHOD.

ENDCLASS.
