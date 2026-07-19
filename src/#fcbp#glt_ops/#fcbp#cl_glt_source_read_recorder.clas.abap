"! Caller-owned persistence for Source Reading operational diagnostics.
CLASS /fcbp/cl_glt_source_read_recorder DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS start
      IMPORTING
        is_request               TYPE /fcbp/if_glt_src_types=>ty_source_read_request
      RETURNING
        VALUE(rv_source_read_id) TYPE /fcbp/if_glt_src_types=>ty_source_read_id.

    METHODS complete
      IMPORTING
        iv_source_read_id TYPE /fcbp/if_glt_src_types=>ty_source_read_id
        is_result         TYPE /fcbp/if_glt_src_types=>ty_source_read_result.

    METHODS fail
      IMPORTING
        iv_source_read_id TYPE /fcbp/if_glt_src_types=>ty_source_read_id
        ix_error          TYPE REF TO /fcbp/cx_glt_source_read.

  PRIVATE SECTION.
    METHODS now RETURNING VALUE(rv_now) TYPE utclong.
ENDCLASS.

CLASS /fcbp/cl_glt_source_read_recorder IMPLEMENTATION.

  METHOD start.
    TRY.
        rv_source_read_id = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        GET TIME STAMP FIELD DATA(lv_timestamp).
        rv_source_read_id = |SR{ lv_timestamp }|.
    ENDTRY.

    DATA(lv_now) = now( ).
    DATA(ls_run) = VALUE /fcbp/glt_srcrun(
      source_read_id   = rv_source_read_id
      transfer_id      = is_request-transfer_id
      package_id       = is_request-package_id
      source_type      = is_request-source_type
      source_reference = is_request-source_reference
      routing_bucket   = is_request-routing_bucket
      target_id        = is_request-target_id
      policy_context_id = is_request-policy_context_id
      read_mode        = is_request-read_mode
      result_status    = /fcbp/if_glt_src_types=>c_diag_status-started
      requested_by     = COND #( WHEN is_request-requested_by IS NOT INITIAL
                                 THEN is_request-requested_by ELSE sy-uname )
      requested_at     = lv_now
      created_at       = lv_now ).
    INSERT /fcbp/glt_srcrun FROM @ls_run.
  ENDMETHOD.

  METHOD complete.
    DATA(lv_now) = now( ).
    UPDATE /fcbp/glt_srcrun
      SET result_status     = @/fcbp/if_glt_src_types=>c_diag_status-completed,
          completed_at     = @lv_now,
          source_line_count = @is_result-source_line_count,
          source_hash      = @is_result-source_hash,
          snapshot_id      = @is_result-snapshot_id,
          read_consistency = @is_result-read_consistency
      WHERE source_read_id = @iv_source_read_id.
  ENDMETHOD.

  METHOD fail.
    DATA(lv_now) = now( ).
    DATA(lv_technical_reference) = CONV char255( ix_error->technical_reference ).
    UPDATE /fcbp/glt_srcrun
      SET result_status      = @/fcbp/if_glt_src_types=>c_diag_status-failed,
          completed_at      = @lv_now,
          error_code        = @ix_error->error_code,
          retryable         = @ix_error->retryable,
          operator_text     = @ix_error->operator_text,
          technical_reference = @lv_technical_reference
      WHERE source_read_id = @iv_source_read_id.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

ENDCLASS.
