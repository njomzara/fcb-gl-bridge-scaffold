"! Reusable package graph consistency checks before publish and for jobs/tests.
CLASS /fcbp/cl_glt_package_consistency DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS check_graph
      IMPORTING
        is_graph          TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
      RETURNING
        VALUE(rt_message) TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message.

    METHODS has_blocking
      IMPORTING
        it_message          TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message
      RETURNING
        VALUE(rv_blocking)  TYPE abap_bool.

  PRIVATE SECTION.
    METHODS add_message
      IMPORTING
        iv_rule_id       TYPE char30
        iv_category      TYPE char30
        iv_field_name    TYPE char40 OPTIONAL
        iv_package_id    TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
        iv_outdoc_id     TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id OPTIONAL
        iv_line_id       TYPE /fcbp/if_glt_pkg_types=>ty_line_id OPTIONAL
        iv_operator_text TYPE char220
      CHANGING
        ct_message TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message.

ENDCLASS.

CLASS /fcbp/cl_glt_package_consistency IMPLEMENTATION.

  METHOD check_graph.
    DATA(lv_package_id) = is_graph-package_header-package_id.

    IF lv_package_id IS INITIAL.
      add_message(
        EXPORTING
          iv_rule_id       = /fcbp/if_glt_pkg_prep_types=>c_rule_id-graph_header
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
          iv_field_name    = 'PACKAGE_ID'
          iv_operator_text = 'Package graph is missing package header or package id.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.

    IF is_graph-outdocs IS INITIAL.
      add_message(
        EXPORTING
          iv_rule_id       = /fcbp/if_glt_pkg_prep_types=>c_rule_id-graph_outdoc
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-split
          iv_package_id    = lv_package_id
          iv_operator_text = 'Package graph has no outbound documents.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.

    IF is_graph-canonical_lines IS INITIAL.
      add_message(
        EXPORTING
          iv_rule_id       = /fcbp/if_glt_pkg_prep_types=>c_rule_id-graph_line
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-aggregation
          iv_package_id    = lv_package_id
          iv_operator_text = 'Package graph has no canonical lines.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.

    LOOP AT is_graph-outdocs INTO DATA(ls_outdoc).
      IF ls_outdoc-package_id <> lv_package_id.
        add_message(
          EXPORTING
            iv_rule_id       = /fcbp/if_glt_pkg_prep_types=>c_rule_id-graph_package_id
            iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
            iv_package_id    = lv_package_id
            iv_outdoc_id     = ls_outdoc-outdoc_id
            iv_field_name    = 'PACKAGE_ID'
            iv_operator_text = 'Outbound document package id does not match package header.'
          CHANGING
            ct_message       = rt_message ).
      ENDIF.

      DATA(lv_has_line) = abap_false.
      LOOP AT is_graph-canonical_lines TRANSPORTING NO FIELDS
        WHERE package_id = lv_package_id AND outdoc_id = ls_outdoc-outdoc_id.
        lv_has_line = abap_true.
        EXIT.
      ENDLOOP.
      IF lv_has_line = abap_false.
        add_message(
          EXPORTING
            iv_rule_id       = /fcbp/if_glt_pkg_prep_types=>c_rule_id-graph_line_outdoc
            iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-split
            iv_package_id    = lv_package_id
            iv_outdoc_id     = ls_outdoc-outdoc_id
            iv_operator_text = 'Outbound document has no canonical lines.'
          CHANGING
            ct_message       = rt_message ).
      ENDIF.
    ENDLOOP.

    LOOP AT is_graph-canonical_lines INTO DATA(ls_line).
      IF ls_line-package_id <> lv_package_id.
        add_message(
          EXPORTING
            iv_rule_id       = /fcbp/if_glt_pkg_prep_types=>c_rule_id-graph_package_id
            iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
            iv_package_id    = lv_package_id
            iv_line_id       = ls_line-line_id
            iv_field_name    = 'PACKAGE_ID'
            iv_operator_text = 'Canonical line package id does not match package header.'
          CHANGING
            ct_message       = rt_message ).
      ENDIF.

      READ TABLE is_graph-outdocs TRANSPORTING NO FIELDS
        WITH KEY package_id = ls_line-package_id outdoc_id = ls_line-outdoc_id.
      IF sy-subrc <> 0.
        add_message(
          EXPORTING
            iv_rule_id       = /fcbp/if_glt_pkg_prep_types=>c_rule_id-graph_line_outdoc
            iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-split
            iv_package_id    = lv_package_id
            iv_outdoc_id     = ls_line-outdoc_id
            iv_line_id       = ls_line-line_id
            iv_operator_text = 'Canonical line references an unknown outbound document.'
          CHANGING
            ct_message       = rt_message ).
      ENDIF.

      READ TABLE is_graph-source_trace TRANSPORTING NO FIELDS
        WITH KEY package_id = ls_line-package_id outdoc_id = ls_line-outdoc_id line_id = ls_line-line_id.
      IF sy-subrc <> 0.
        add_message(
          EXPORTING
            iv_rule_id       = /fcbp/if_glt_pkg_prep_types=>c_rule_id-graph_trace
            iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-trace
            iv_package_id    = lv_package_id
            iv_outdoc_id     = ls_line-outdoc_id
            iv_line_id       = ls_line-line_id
            iv_operator_text = 'Canonical line has no source trace.'
          CHANGING
            ct_message       = rt_message ).
      ENDIF.
    ENDLOOP.

    IF is_graph-package_header-outdoc_count <> lines( is_graph-outdocs )
       OR is_graph-package_header-canonical_line_count <> lines( is_graph-canonical_lines )
       OR is_graph-package_header-trace_count <> lines( is_graph-source_trace ).
      add_message(
        EXPORTING
          iv_rule_id       = /fcbp/if_glt_pkg_prep_types=>c_rule_id-graph_count
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
          iv_package_id    = lv_package_id
          iv_field_name    = 'COUNTS'
          iv_operator_text = 'Package header counts do not match package graph child counts.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.

    IF is_graph-package_header-source_hash IS INITIAL
       OR is_graph-package_header-aggregation_output_hash IS INITIAL
       OR is_graph-package_header-split_output_hash IS INITIAL
       OR is_graph-package_header-payload_hash IS INITIAL.
      add_message(
        EXPORTING
          iv_rule_id       = /fcbp/if_glt_pkg_prep_types=>c_rule_id-graph_hash
          iv_category      = /fcbp/if_glt_aggr_types=>c_prep_category-technical
          iv_package_id    = lv_package_id
          iv_field_name    = 'HASH'
          iv_operator_text = 'Package graph is missing required source/output/payload hashes.'
        CHANGING
          ct_message       = rt_message ).
    ENDIF.
  ENDMETHOD.

  METHOD has_blocking.
    LOOP AT it_message TRANSPORTING NO FIELDS WHERE blocking = abap_true.
      rv_blocking = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_message.
    APPEND VALUE #(
      rule_id       = iv_rule_id
      category      = iv_category
      severity      = /fcbp/if_glt_types=>c_severity-error
      blocking      = abap_true
      field_name    = iv_field_name
      package_id    = iv_package_id
      outdoc_id     = iv_outdoc_id
      line_id       = iv_line_id
      operator_text = iv_operator_text ) TO ct_message.
  ENDMETHOD.

ENDCLASS.
