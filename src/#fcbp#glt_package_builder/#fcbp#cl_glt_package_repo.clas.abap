"! Package Builder repository scaffold over /FCBP/GLT_PKG, /FCBP/GLT_DOC, /FCBP/GLT_LIN, and /FCBP/GLT_SRC.
CLASS /fcbp/cl_glt_package_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_package_repo.

  PRIVATE SECTION.
    METHODS validate_graph
      IMPORTING
        is_graph TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
      RAISING
        /fcbp/cx_glt_repository.

    METHODS package_exists
      IMPORTING
        iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      RETURNING
        VALUE(rv_exists) TYPE abap_bool.

    METHODS assert_package_exists
      IMPORTING
        iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      RAISING
        /fcbp/cx_glt_repository.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

    METHODS append_message
      IMPORTING
        iv_rule_id       TYPE char30
        iv_category      TYPE char30
        iv_severity      TYPE char10
        iv_blocking      TYPE abap_bool
        iv_field_name    TYPE char40 OPTIONAL
        iv_package_id    TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
        iv_outdoc_id     TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id OPTIONAL
        iv_line_id       TYPE /fcbp/if_glt_pkg_types=>ty_line_id OPTIONAL
        iv_operator_text TYPE char220
      CHANGING
        ct_message       TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message.

    METHODS raise_repository
      IMPORTING
        iv_text        TYPE char220
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
      RAISING
        /fcbp/cx_glt_repository.

ENDCLASS.

CLASS /fcbp/cl_glt_package_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_package_repo~persist_graph.
    validate_graph( is_graph ).

    IF package_exists( is_graph-package_header-package_id ) = abap_true.
      raise_repository(
        iv_transfer_id = is_graph-package_header-transfer_id
        iv_text        = |Package { is_graph-package_header-package_id } already exists; package persistence is not idempotent in this scaffold.| ).
    ENDIF.

    DATA(ls_header) = is_graph-package_header.
    IF ls_header-created_by IS INITIAL.
      ls_header-created_by = sy-uname.
    ENDIF.
    IF ls_header-created_at IS INITIAL.
      GET TIME STAMP FIELD ls_header-created_at.
    ENDIF.

    TRY.
        INSERT /fcbp/glt_pkg FROM @ls_header.

        LOOP AT is_graph-outdocs INTO DATA(ls_outdoc).
          DATA(ls_doc) = CORRESPONDING /fcbp/glt_doc( ls_outdoc ).
          IF ls_doc-created_at IS INITIAL.
            ls_doc-created_at = ls_header-created_at.
          ENDIF.
          INSERT /fcbp/glt_doc FROM @ls_doc.
        ENDLOOP.

        LOOP AT is_graph-canonical_lines INTO DATA(ls_line).
          DATA(ls_db_line) = CORRESPONDING /fcbp/glt_lin( ls_line ).
          IF ls_db_line-created_at IS INITIAL.
            ls_db_line-created_at = ls_header-created_at.
          ENDIF.
          INSERT /fcbp/glt_lin FROM @ls_db_line.
        ENDLOOP.

        LOOP AT is_graph-source_trace INTO DATA(ls_trace).
          DATA(ls_db_trace) = CORRESPONDING /fcbp/glt_src( ls_trace ).
          IF ls_db_trace-created_at IS INITIAL.
            ls_db_trace-created_at = ls_header-created_at.
          ENDIF.
          INSERT /fcbp/glt_src FROM @ls_db_trace.
        ENDLOOP.
      CATCH cx_sy_open_sql_db INTO DATA(lx_sql).
        raise_repository(
          iv_transfer_id = is_graph-package_header-transfer_id
          iv_text        = |Package graph persistence failed for package { is_graph-package_header-package_id }.| ).
    ENDTRY.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~publish_current.
    IF iv_lock_owner IS INITIAL.
      raise_repository(
        iv_transfer_id = iv_transfer_id
        iv_text        = 'Package publication requires a package lock owner.' ).
    ENDIF.

    SELECT SINGLE *
      FROM /fcbp/glt_pkg
      WHERE package_id = @iv_package_id
      INTO @DATA(ls_target_pkg).
    IF sy-subrc <> 0 OR ls_target_pkg-transfer_id <> iv_transfer_id.
      raise_repository(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Package { iv_package_id } does not belong to transfer { iv_transfer_id }.| ).
    ENDIF.

    DATA(lv_now) = now( ).
    SELECT SINGLE *
      FROM /fcbp/glt_hdr
      WHERE transfer_id = @iv_transfer_id
      INTO @DATA(ls_transfer_header).
    IF sy-subrc <> 0.
      raise_repository(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Transfer { iv_transfer_id } was not found for package publication.| ).
    ENDIF.

    IF ls_transfer_header-lock_owner <> iv_lock_owner OR ls_transfer_header-lock_until <= lv_now.
      raise_repository(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Package publication for transfer { iv_transfer_id } is not owned by lock owner { iv_lock_owner }.| ).
    ENDIF.

    IF ls_transfer_header-current_package_id IS NOT INITIAL
       AND ls_transfer_header-current_package_id <> iv_expected_current_package_id
       AND ls_transfer_header-current_package_id <> iv_package_id.
      raise_repository(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Transfer current package changed from expected { iv_expected_current_package_id } to { ls_transfer_header-current_package_id }.| ).
    ENDIF.

    IF ls_target_pkg-package_id <> iv_expected_current_package_id
       AND ls_target_pkg-predecessor_package_id IS NOT INITIAL
       AND ls_target_pkg-predecessor_package_id <> iv_expected_current_package_id.
      raise_repository(
        iv_transfer_id = iv_transfer_id
        iv_text        = |Package { iv_package_id } does not follow expected predecessor { iv_expected_current_package_id }.| ).
    ENDIF.

    SELECT *
      FROM /fcbp/glt_pkg
      WHERE transfer_id = @iv_transfer_id
        AND current_flag = @abap_true
      INTO TABLE @DATA(lt_current_pkg).

    LOOP AT lt_current_pkg INTO DATA(ls_current_pkg).
      IF ls_current_pkg-package_id <> iv_package_id
         AND ls_current_pkg-package_id <> iv_expected_current_package_id.
        raise_repository(
          iv_transfer_id = iv_transfer_id
          iv_text        = |Unexpected current package { ls_current_pkg-package_id } exists for transfer { iv_transfer_id }.| ).
      ENDIF.
    ENDLOOP.

    TRY.
        UPDATE /fcbp/glt_pkg
          SET current_flag = @abap_false,
              package_status = @/fcbp/if_glt_pkg_types=>c_package_status-superseded,
              superseded_by_package_id = @iv_package_id
          WHERE transfer_id = @iv_transfer_id
            AND current_flag = @abap_true
            AND package_id <> @iv_package_id.

        UPDATE /fcbp/glt_pkg
          SET current_flag = @abap_true,
              package_status = @/fcbp/if_glt_pkg_types=>c_package_status-current,
              superseded_by_package_id = ''
          WHERE package_id = @iv_package_id
            AND transfer_id = @iv_transfer_id.
        IF sy-subrc <> 0.
          raise_repository(
            iv_transfer_id = iv_transfer_id
            iv_text        = |Package { iv_package_id } could not be marked current.| ).
        ENDIF.

        IF iv_expected_current_package_id IS INITIAL.
          UPDATE /fcbp/glt_hdr
            SET current_package_id = @iv_package_id,
                changed_by = @sy-uname,
                changed_at = @lv_now,
                version_no = version_no + 1
            WHERE transfer_id = @iv_transfer_id
              AND lock_owner = @iv_lock_owner
              AND ( current_package_id = '' OR current_package_id = @iv_package_id ).
        ELSE.
          UPDATE /fcbp/glt_hdr
            SET current_package_id = @iv_package_id,
                changed_by = @sy-uname,
                changed_at = @lv_now,
                version_no = version_no + 1
            WHERE transfer_id = @iv_transfer_id
              AND lock_owner = @iv_lock_owner
              AND ( current_package_id = @iv_expected_current_package_id
                    OR current_package_id = ''
                    OR current_package_id = @iv_package_id ).
        ENDIF.
        IF sy-subrc <> 0.
          raise_repository(
            iv_transfer_id = iv_transfer_id
            iv_text        = |Transfer current package pointer could not be updated for package { iv_package_id }.| ).
        ENDIF.
      CATCH cx_sy_open_sql_db INTO DATA(lx_sql).
        raise_repository(
          iv_transfer_id = iv_transfer_id
          iv_text        = |Package { iv_package_id } publication failed.| ).
    ENDTRY.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~read_package.
    SELECT SINGLE *
      FROM /fcbp/glt_pkg
      WHERE package_id = @iv_package_id
      INTO @DATA(ls_header).

    IF sy-subrc <> 0.
      raise_repository( iv_text = |Package { iv_package_id } was not found.| ).
    ENDIF.

    rs_graph-package_header = CORRESPONDING #( ls_header ).

    SELECT *
      FROM /fcbp/glt_doc
      WHERE package_id = @iv_package_id
      ORDER BY document_sequence, outdoc_id
      INTO TABLE @DATA(lt_doc).
    rs_graph-outdocs = CORRESPONDING #( lt_doc ).

    SELECT *
      FROM /fcbp/glt_lin
      WHERE package_id = @iv_package_id
      ORDER BY outdoc_id, line_no, line_id
      INTO TABLE @DATA(lt_line).
    rs_graph-canonical_lines = CORRESPONDING #( lt_line ).

    SELECT *
      FROM /fcbp/glt_src
      WHERE package_id = @iv_package_id
      ORDER BY outdoc_id, line_no, trace_sequence, trace_id
      INTO TABLE @DATA(lt_trace).
    rs_graph-source_trace = CORRESPONDING #( lt_trace ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~read_current_package.
    SELECT *
      FROM /fcbp/glt_pkg
      WHERE transfer_id = @iv_transfer_id
        AND current_flag = @abap_true
      INTO TABLE @DATA(lt_header).

    IF lt_header IS INITIAL.
      RETURN.
    ENDIF.

    SORT lt_header BY package_version DESCENDING package_id.
    READ TABLE lt_header INTO DATA(ls_header) INDEX 1.
    rs_graph = /fcbp/if_glt_package_repo~read_package( ls_header-package_id ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_repo~check_consistency.
    DATA(ls_graph) = /fcbp/if_glt_package_repo~read_package( iv_package_id ).

    IF ls_graph-outdocs IS INITIAL.
      append_message(
        EXPORTING
          iv_rule_id       = 'PKG_REPO_DOC_MISSING'
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
          iv_severity      = /fcbp/if_glt_types=>c_severity-error
          iv_blocking      = abap_true
          iv_package_id    = iv_package_id
          iv_operator_text = 'Package has no persisted outbound document rows.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.

    IF ls_graph-canonical_lines IS INITIAL.
      append_message(
        EXPORTING
          iv_rule_id       = 'PKG_REPO_LINE_MISSING'
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
          iv_severity      = /fcbp/if_glt_types=>c_severity-error
          iv_blocking      = abap_true
          iv_package_id    = iv_package_id
          iv_operator_text = 'Package has no persisted canonical line rows.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.

    IF ls_graph-source_trace IS INITIAL.
      append_message(
        EXPORTING
          iv_rule_id       = 'PKG_REPO_TRACE_MISSING'
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-trace
          iv_severity      = /fcbp/if_glt_types=>c_severity-error
          iv_blocking      = abap_true
          iv_package_id    = iv_package_id
          iv_operator_text = 'Package has no persisted source trace rows.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.

    IF ls_graph-package_header-outdoc_count <> lines( ls_graph-outdocs ).
      append_message(
        EXPORTING
          iv_rule_id       = 'PKG_REPO_DOC_COUNT'
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
          iv_severity      = /fcbp/if_glt_types=>c_severity-error
          iv_blocking      = abap_true
          iv_field_name    = 'OUTDOC_COUNT'
          iv_package_id    = iv_package_id
          iv_operator_text = 'Package header outbound-document count does not match persisted document rows.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.

    IF ls_graph-package_header-canonical_line_count <> lines( ls_graph-canonical_lines ).
      append_message(
        EXPORTING
          iv_rule_id       = 'PKG_REPO_LINE_COUNT'
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
          iv_severity      = /fcbp/if_glt_types=>c_severity-error
          iv_blocking      = abap_true
          iv_field_name    = 'CANONICAL_LINE_COUNT'
          iv_package_id    = iv_package_id
          iv_operator_text = 'Package header canonical-line count does not match persisted line rows.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.

    IF ls_graph-package_header-trace_count <> lines( ls_graph-source_trace ).
      append_message(
        EXPORTING
          iv_rule_id       = 'PKG_REPO_TRACE_COUNT'
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-trace
          iv_severity      = /fcbp/if_glt_types=>c_severity-error
          iv_blocking      = abap_true
          iv_field_name    = 'TRACE_COUNT'
          iv_package_id    = iv_package_id
          iv_operator_text = 'Package header source-trace count does not match persisted trace rows.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.

    LOOP AT ls_graph-outdocs INTO DATA(ls_outdoc).
      IF ls_outdoc-balance_status = /fcbp/if_glt_pkg_types=>c_balance_status-unbalanced
         OR ls_outdoc-difference_amount <> 0.
        append_message(
          EXPORTING
            iv_rule_id       = 'PKG_REPO_DOC_UNBALANCED'
            iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-balance
            iv_severity      = /fcbp/if_glt_types=>c_severity-error
            iv_blocking      = abap_true
            iv_package_id    = iv_package_id
            iv_outdoc_id     = ls_outdoc-outdoc_id
            iv_operator_text = 'Persisted outbound document is not balanced.'
          CHANGING
            ct_message       = rt_message ).
      ENDIF.

      DATA(lv_doc_line_count) = 0.
      LOOP AT ls_graph-canonical_lines TRANSPORTING NO FIELDS
        WHERE outdoc_id = ls_outdoc-outdoc_id.
        lv_doc_line_count = lv_doc_line_count + 1.
      ENDLOOP.
      IF ls_outdoc-line_count <> lv_doc_line_count.
        append_message(
          EXPORTING
            iv_rule_id       = 'PKG_REPO_DOC_LINE_COUNT'
            iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
            iv_severity      = /fcbp/if_glt_types=>c_severity-error
            iv_blocking      = abap_true
            iv_field_name    = 'LINE_COUNT'
            iv_package_id    = iv_package_id
            iv_outdoc_id     = ls_outdoc-outdoc_id
            iv_operator_text = 'Outbound-document line count does not match persisted canonical lines.'
          CHANGING
            ct_message       = rt_message ).
      ENDIF.
    ENDLOOP.

    LOOP AT ls_graph-canonical_lines INTO DATA(ls_line).
      READ TABLE ls_graph-outdocs TRANSPORTING NO FIELDS
        WITH KEY outdoc_id = ls_line-outdoc_id.
      IF sy-subrc <> 0.
        append_message(
          EXPORTING
            iv_rule_id       = 'PKG_REPO_ORPHAN_LINE'
            iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
            iv_severity      = /fcbp/if_glt_types=>c_severity-error
            iv_blocking      = abap_true
            iv_package_id    = iv_package_id
            iv_outdoc_id     = ls_line-outdoc_id
            iv_line_id       = ls_line-line_id
            iv_operator_text = 'Canonical line references a missing outbound document.'
          CHANGING
            ct_message       = rt_message ).
      ENDIF.

      READ TABLE ls_graph-source_trace TRANSPORTING NO FIELDS
        WITH KEY outdoc_id = ls_line-outdoc_id
                 line_id   = ls_line-line_id.
      IF sy-subrc <> 0.
        append_message(
          EXPORTING
            iv_rule_id       = 'PKG_REPO_LINE_TRACE_MISSING'
            iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-trace
            iv_severity      = /fcbp/if_glt_types=>c_severity-error
            iv_blocking      = abap_true
            iv_package_id    = iv_package_id
            iv_outdoc_id     = ls_line-outdoc_id
            iv_line_id       = ls_line-line_id
            iv_operator_text = 'Canonical line has no source trace evidence.'
          CHANGING
            ct_message       = rt_message ).
      ENDIF.
    ENDLOOP.

    LOOP AT ls_graph-source_trace INTO DATA(ls_trace).
      READ TABLE ls_graph-canonical_lines TRANSPORTING NO FIELDS
        WITH KEY outdoc_id = ls_trace-outdoc_id
                 line_id   = ls_trace-line_id.
      IF sy-subrc <> 0.
        append_message(
          EXPORTING
            iv_rule_id       = 'PKG_REPO_ORPHAN_TRACE'
            iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-trace
            iv_severity      = /fcbp/if_glt_types=>c_severity-error
            iv_blocking      = abap_true
            iv_package_id    = iv_package_id
            iv_outdoc_id     = ls_trace-outdoc_id
            iv_line_id       = ls_trace-line_id
            iv_operator_text = 'Source trace references a missing canonical line.'
          CHANGING
            ct_message       = rt_message ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_graph.
    IF is_graph-package_header-package_id IS INITIAL.
      raise_repository( 'Package graph requires PACKAGE_ID before persistence.' ).
    ENDIF.

    IF is_graph-package_header-transfer_id IS INITIAL.
      raise_repository( 'Package graph requires TRANSFER_ID before persistence.' ).
    ENDIF.

    IF is_graph-outdocs IS INITIAL.
      raise_repository(
        iv_transfer_id = is_graph-package_header-transfer_id
        iv_text        = 'Package graph requires at least one outbound document.' ).
    ENDIF.

    IF is_graph-canonical_lines IS INITIAL.
      raise_repository(
        iv_transfer_id = is_graph-package_header-transfer_id
        iv_text        = 'Package graph requires at least one canonical line.' ).
    ENDIF.

    IF is_graph-source_trace IS INITIAL.
      raise_repository(
        iv_transfer_id = is_graph-package_header-transfer_id
        iv_text        = 'Package graph requires source trace evidence.' ).
    ENDIF.

    LOOP AT is_graph-outdocs INTO DATA(ls_outdoc).
      IF ls_outdoc-package_id <> is_graph-package_header-package_id OR ls_outdoc-outdoc_id IS INITIAL.
        raise_repository(
          iv_transfer_id = is_graph-package_header-transfer_id
          iv_text        = 'Package graph contains an outbound document with invalid package or document identity.' ).
      ENDIF.
    ENDLOOP.

    LOOP AT is_graph-canonical_lines INTO DATA(ls_line).
      IF ls_line-package_id <> is_graph-package_header-package_id
         OR ls_line-outdoc_id IS INITIAL
         OR ls_line-line_id IS INITIAL.
        raise_repository(
          iv_transfer_id = is_graph-package_header-transfer_id
          iv_text        = 'Package graph contains a canonical line with invalid package, document, or line identity.' ).
      ENDIF.
    ENDLOOP.

    LOOP AT is_graph-source_trace INTO DATA(ls_trace).
      IF ls_trace-package_id <> is_graph-package_header-package_id
         OR ls_trace-outdoc_id IS INITIAL
         OR ls_trace-line_id IS INITIAL
         OR ls_trace-trace_id IS INITIAL.
        raise_repository(
          iv_transfer_id = is_graph-package_header-transfer_id
          iv_text        = 'Package graph contains source trace with invalid package, document, line, or trace identity.' ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD package_exists.
    SELECT SINGLE package_id
      FROM /fcbp/glt_pkg
      WHERE package_id = @iv_package_id
      INTO @DATA(lv_package_id).
    rv_exists = xsdbool( sy-subrc = 0 AND lv_package_id IS NOT INITIAL ).
  ENDMETHOD.

  METHOD assert_package_exists.
    IF package_exists( iv_package_id ) = abap_false.
      raise_repository( |Package { iv_package_id } was not found.| ).
    ENDIF.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

  METHOD append_message.
    APPEND VALUE #(
      rule_id       = iv_rule_id
      category      = iv_category
      severity      = iv_severity
      blocking      = iv_blocking
      field_name    = iv_field_name
      package_id    = iv_package_id
      outdoc_id     = iv_outdoc_id
      line_id       = iv_line_id
      operator_text = iv_operator_text ) TO ct_message.
  ENDMETHOD.

  METHOD raise_repository.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_repository
      EXPORTING
        transfer_id    = iv_transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = iv_text.
  ENDMETHOD.

ENDCLASS.
