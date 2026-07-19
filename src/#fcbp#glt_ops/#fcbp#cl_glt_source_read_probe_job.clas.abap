"! Read-only Source Reading probe for support and configuration-health checks.
CLASS /fcbp/cl_glt_source_read_probe_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_source_reader TYPE REF TO /fcbp/if_glt_source_reader OPTIONAL
        io_hasher        TYPE REF TO /fcbp/cl_glt_src_hasher OPTIONAL
        io_recorder      TYPE REF TO /fcbp/cl_glt_source_read_recorder OPTIONAL.

    METHODS execute
      IMPORTING
        is_request       TYPE /fcbp/if_glt_src_types=>ty_source_read_request
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_src_types=>ty_source_read_result
      RAISING
        /fcbp/cx_glt_source_read.

  PRIVATE SECTION.
    DATA mo_source_reader TYPE REF TO /fcbp/if_glt_source_reader.
    DATA mo_hasher TYPE REF TO /fcbp/cl_glt_src_hasher.
    DATA mo_recorder TYPE REF TO /fcbp/cl_glt_source_read_recorder.

ENDCLASS.

CLASS /fcbp/cl_glt_source_read_probe_job IMPLEMENTATION.

  METHOD constructor.
    IF io_source_reader IS BOUND.
      mo_source_reader = io_source_reader.
    ELSE.
      mo_source_reader = NEW /fcbp/cl_glt_source_reader( ).
    ENDIF.

    IF io_hasher IS BOUND.
      mo_hasher = io_hasher.
    ELSE.
      mo_hasher = NEW /fcbp/cl_glt_src_hasher( ).
    ENDIF.
    mo_recorder = COND #( WHEN io_recorder IS BOUND THEN io_recorder
                          ELSE NEW /fcbp/cl_glt_source_read_recorder( ) ).
  ENDMETHOD.

  METHOD execute.
    rs_result-request = is_request.
    DATA(lv_source_read_id) = mo_recorder->start( is_request ).
    TRY.
        rs_result-source_line = mo_source_reader->read_source_lines( is_request ).
        rs_result-source_line_count = lines( rs_result-source_line ).
        rs_result-source_hash = mo_hasher->calculate_source_hash( rs_result-source_line ).
        rs_result-read_consistency = /fcbp/if_glt_src_types=>c_read_consistency-stable.
        mo_recorder->complete(
          iv_source_read_id = lv_source_read_id
          is_result         = rs_result ).
      CATCH /fcbp/cx_glt_source_read INTO DATA(lx_source_read).
        mo_recorder->fail(
          iv_source_read_id = lv_source_read_id
          ix_error          = lx_source_read ).
        RAISE EXCEPTION lx_source_read.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
