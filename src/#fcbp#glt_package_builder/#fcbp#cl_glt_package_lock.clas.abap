"! Transfer-header backed lock for package preparation and current publication.
CLASS /fcbp/cl_glt_package_lock DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_package_lock.

  PRIVATE SECTION.
    CONSTANTS c_lock_ttl_seconds TYPE i VALUE 600.

    METHODS lock_owner
      IMPORTING
        iv_transfer_id             TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_outbox_id               TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
      RETURNING
        VALUE(rv_owner)            TYPE char40.

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

CLASS /fcbp/cl_glt_package_lock IMPLEMENTATION.

  METHOD /fcbp/if_glt_package_lock~acquire.
    DATA(lv_now) = now( ).
    DATA(lv_until) = utclong_add(
      val     = lv_now
      seconds = c_lock_ttl_seconds ).
    DATA(lv_owner) = lock_owner(
      iv_transfer_id = iv_transfer_id
      iv_outbox_id   = iv_outbox_id ).

    UPDATE /fcbp/glt_hdr
      SET lock_owner = @lv_owner,
          lock_until = @lv_until
      WHERE transfer_id = @iv_transfer_id
        AND ( lock_owner = '' OR lock_owner = @lv_owner OR lock_until <= @lv_now ).

    IF sy-subrc = 0.
      rv_acquired = abap_true.
      RETURN.
    ENDIF.

    SELECT SINGLE transfer_id
      FROM /fcbp/glt_hdr
      WHERE transfer_id = @iv_transfer_id
      INTO @DATA(lv_transfer_id).
    IF sy-subrc <> 0.
      raise_lock(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Transfer { iv_transfer_id } was not found for package locking.| ).
    ENDIF.

    rv_acquired = abap_false.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_lock~release.
    DATA lv_initial_ts TYPE utclong.
    DATA(lv_owner) = lock_owner(
      iv_transfer_id = iv_transfer_id
      iv_outbox_id   = iv_outbox_id ).

    UPDATE /fcbp/glt_hdr
      SET lock_owner = '',
          lock_until = @lv_initial_ts
      WHERE transfer_id = @iv_transfer_id
        AND lock_owner = @lv_owner.

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
        iv_text        = |Transfer { iv_transfer_id } was not found for package lock release.| ).
    ENDIF.
  ENDMETHOD.

  METHOD lock_owner.
    rv_owner = COND #(
      WHEN iv_outbox_id IS NOT INITIAL THEN |PKG:{ iv_outbox_id }|
      ELSE |PKG:{ iv_transfer_id }| ).
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
