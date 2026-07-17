"! Mapping facade. Translates validated package evidence into target-normalized journals.
CLASS /fcbp/cl_glt_mapper DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_mapper.

    METHODS constructor
      IMPORTING
        io_map_repo     TYPE REF TO /fcbp/if_glt_map_repo OPTIONAL
        io_package_repo TYPE REF TO /fcbp/if_glt_package_repo OPTIONAL
        io_config_repo  TYPE REF TO /fcbp/if_glt_config_repo OPTIONAL
        io_val_repo     TYPE REF TO /fcbp/if_glt_val_repo OPTIONAL
        io_field_mapper TYPE REF TO /fcbp/cl_glt_map_field OPTIONAL
        io_event_builder TYPE REF TO /fcbp/cl_glt_map_event_builder OPTIONAL.

  PRIVATE SECTION.
    DATA mo_map_repo TYPE REF TO /fcbp/if_glt_map_repo.
    DATA mo_package_repo TYPE REF TO /fcbp/if_glt_package_repo.
    DATA mo_config_repo TYPE REF TO /fcbp/if_glt_config_repo.
    DATA mo_val_repo TYPE REF TO /fcbp/if_glt_val_repo.
    DATA mo_field_mapper TYPE REF TO /fcbp/cl_glt_map_field.
    DATA mo_event_builder TYPE REF TO /fcbp/cl_glt_map_event_builder.

    METHODS execute_journal
      IMPORTING
        is_context       TYPE /fcbp/if_glt_map_types=>ty_context
        is_journal       TYPE /fcbp/if_glt_map_types=>ty_canonical_journal
      RETURNING
        VALUE(rs_result) TYPE /fcbp/if_glt_map_types=>ty_result
      RAISING
        /fcbp/cx_glt_error.

    METHODS read_rules
      IMPORTING
        is_context      TYPE /fcbp/if_glt_map_types=>ty_context
      RETURNING
        VALUE(rt_rule)  TYPE /fcbp/if_glt_config_types=>tt_mapping_rule
      RAISING
        /fcbp/cx_glt_error.

    METHODS validate_prerequisites
      IMPORTING
        is_context TYPE /fcbp/if_glt_map_types=>ty_context
        it_rule    TYPE /fcbp/if_glt_config_types=>tt_mapping_rule
      CHANGING
        cs_result  TYPE /fcbp/if_glt_map_types=>ty_result.

    METHODS map_doc_field
      IMPORTING
        is_context  TYPE /fcbp/if_glt_map_types=>ty_context
        iv_outdoc_id TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id
        iv_field_name TYPE char40
        iv_required TYPE abap_bool
        iv_max_length TYPE i
        it_rule TYPE /fcbp/if_glt_config_types=>tt_mapping_rule
      CHANGING
        cv_value TYPE string
        cs_result TYPE /fcbp/if_glt_map_types=>ty_result
      RAISING
        /fcbp/cx_glt_error.

    METHODS map_line_field
      IMPORTING
        is_context  TYPE /fcbp/if_glt_map_types=>ty_context
        iv_outdoc_id TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id
        iv_line_no TYPE numc6
        iv_field_name TYPE char40
        iv_required TYPE abap_bool
        iv_max_length TYPE i
        it_rule TYPE /fcbp/if_glt_config_types=>tt_mapping_rule
      CHANGING
        cv_value TYPE string
        cs_result TYPE /fcbp/if_glt_map_types=>ty_result
      RAISING
        /fcbp/cx_glt_error.

    METHODS add_decision
      IMPORTING
        is_decision TYPE /fcbp/if_glt_map_types=>ty_decision
      CHANGING
        cv_value TYPE string
        cs_result TYPE /fcbp/if_glt_map_types=>ty_result.

    METHODS add_message
      IMPORTING
        iv_rule_id TYPE char30
        iv_field_name TYPE char40
        iv_text TYPE char220
      CHANGING
        cs_result TYPE /fcbp/if_glt_map_types=>ty_result.

    METHODS finalize_result
      CHANGING
        cs_result TYPE /fcbp/if_glt_map_types=>ty_result.

    METHODS compact_hash
      IMPORTING
        iv_input       TYPE string
      RETURNING
        VALUE(rv_hash) TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_mapper IMPLEMENTATION.

  METHOD constructor.
    IF io_map_repo IS BOUND.
      mo_map_repo = io_map_repo.
    ELSE.
      mo_map_repo = NEW /fcbp/cl_glt_map_repo( ).
    ENDIF.

    IF io_package_repo IS BOUND.
      mo_package_repo = io_package_repo.
    ELSE.
      mo_package_repo = NEW /fcbp/cl_glt_package_repo( ).
    ENDIF.

    IF io_config_repo IS BOUND.
      mo_config_repo = io_config_repo.
    ELSE.
      mo_config_repo = NEW /fcbp/cl_glt_config_repo( ).
    ENDIF.

    IF io_val_repo IS BOUND.
      mo_val_repo = io_val_repo.
    ELSE.
      mo_val_repo = NEW /fcbp/cl_glt_val_repo( ).
    ENDIF.

    IF io_field_mapper IS BOUND.
      mo_field_mapper = io_field_mapper.
    ELSE.
      mo_field_mapper = NEW /fcbp/cl_glt_map_field( ).
    ENDIF.

    IF io_event_builder IS BOUND.
      mo_event_builder = io_event_builder.
    ELSE.
      mo_event_builder = NEW /fcbp/cl_glt_map_event_builder( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_mapper~map_journal.
    rs_result = execute_journal(
      is_context = is_context
      is_journal = is_journal ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_mapper~map_package.
    DATA(ls_context) = is_context.

    IF ls_context-transfer_id IS INITIAL OR ls_context-package_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_mapping
        EXPORTING
          transfer_id    = ls_context-transfer_id
          package_id     = ls_context-package_id
          error_category = /fcbp/if_glt_types=>c_error_category-validation
          operator_text  = 'Package mapping requires transfer id and package id.'.
    ENDIF.

    DATA(ls_latest_run) = mo_val_repo->read_latest_run( ls_context-package_id ).
    IF ls_latest_run-result_status <> /fcbp/if_glt_val_types=>c_run_status-passed AND
       ls_latest_run-result_status <> /fcbp/if_glt_val_types=>c_run_status-waived.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_mapping
        EXPORTING
          transfer_id    = ls_context-transfer_id
          package_id     = ls_context-package_id
          error_category = /fcbp/if_glt_types=>c_error_category-validation
          operator_text  = 'Mapping requires a passed or waived validation run for the current package.'.
    ENDIF.
    IF ls_context-validation_run_id IS INITIAL.
      ls_context-validation_run_id = ls_latest_run-validation_run_id.
    ENDIF.

    DATA(ls_graph) = mo_package_repo->read_package( ls_context-package_id ).

    IF ls_context-policy_context_id IS INITIAL.
      ls_context-policy_context_id = ls_graph-package_header-policy_context_id.
    ENDIF.

    DATA(ls_policy_context) = mo_config_repo->read_policy_context( ls_context-policy_context_id ).
    IF ls_context-mapping_policy_id IS INITIAL.
      ls_context-mapping_policy_id = ls_policy_context-mapping_policy_id.
    ENDIF.
    IF ls_context-mapping_version IS INITIAL.
      ls_context-mapping_version = ls_policy_context-mapping_version.
    ENDIF.
    IF ls_context-mapping_hash IS INITIAL.
      ls_context-mapping_hash = ls_policy_context-mapping_hash.
    ENDIF.
    IF ls_context-target_id IS INITIAL.
      ls_context-target_id = ls_policy_context-target_id.
    ENDIF.
    IF ls_context-mapping_rules IS INITIAL.
      ls_context-mapping_rules = mo_config_repo->read_mapping_rules(
        iv_profile_id = ls_context-mapping_policy_id
        iv_version    = ls_context-mapping_version ).
    ENDIF.

    DATA(ls_journal) = VALUE /fcbp/if_glt_map_types=>ty_canonical_journal(
      transfer_id       = ls_graph-package_header-transfer_id
      package_id        = ls_graph-package_header-package_id
      target_id         = ls_graph-package_header-target_id
      policy_context_id = ls_graph-package_header-policy_context_id
      outdocs           = ls_graph-outdocs
      canonical_lines   = ls_graph-canonical_lines
      source_trace      = ls_graph-source_trace ).

    rs_result = execute_journal(
      is_context = ls_context
      is_journal = ls_journal ).
  ENDMETHOD.

  METHOD execute_journal.
    DATA(lt_rule) = read_rules( is_context ).

    rs_result = VALUE #(
      transfer_id = is_context-transfer_id
      package_id = is_context-package_id
      policy_context_id = is_context-policy_context_id
      mapping_run_id = compact_hash( |MAPRUN:{ is_context-package_id }:{ is_context-policy_context_id }:{ is_context-mapping_hash }| )
      mapped_journal = is_journal
      result_status = /fcbp/if_glt_map_types=>c_result_status-pending
      next_allowed_step = /fcbp/if_glt_map_types=>c_next_step-none ).

    validate_prerequisites(
      EXPORTING is_context = is_context it_rule = lt_rule
      CHANGING  cs_result = rs_result ).

    IF rs_result-blocking_count > 0.
      finalize_result( CHANGING cs_result = rs_result ).
      RETURN.
    ENDIF.

    LOOP AT rs_result-mapped_journal-outdocs ASSIGNING FIELD-SYMBOL(<ls_doc>).
      DATA(lv_doc_value) = CONV string( <ls_doc>-company_code ).
      map_doc_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_doc>-outdoc_id
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-company_code
                  iv_required = abap_true iv_max_length = 4 it_rule = lt_rule
        CHANGING cv_value = lv_doc_value cs_result = rs_result ).
      <ls_doc>-company_code = lv_doc_value.

      lv_doc_value = <ls_doc>-gl_doc_type.
      map_doc_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_doc>-outdoc_id
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-gl_doc_type
                  iv_required = abap_true iv_max_length = 10 it_rule = lt_rule
        CHANGING cv_value = lv_doc_value cs_result = rs_result ).
      <ls_doc>-gl_doc_type = lv_doc_value.

      lv_doc_value = <ls_doc>-ledger_group.
      map_doc_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_doc>-outdoc_id
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-ledger_group
                  iv_required = abap_false iv_max_length = 10 it_rule = lt_rule
        CHANGING cv_value = lv_doc_value cs_result = rs_result ).
      <ls_doc>-ledger_group = lv_doc_value.

      lv_doc_value = <ls_doc>-reference.
      map_doc_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_doc>-outdoc_id
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-reference
                  iv_required = abap_false iv_max_length = 50 it_rule = lt_rule
        CHANGING cv_value = lv_doc_value cs_result = rs_result ).
      <ls_doc>-reference = lv_doc_value.

      lv_doc_value = <ls_doc>-header_text.
      map_doc_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_doc>-outdoc_id
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-header_text
                  iv_required = abap_false iv_max_length = 80 it_rule = lt_rule
        CHANGING cv_value = lv_doc_value cs_result = rs_result ).
      <ls_doc>-header_text = lv_doc_value.
    ENDLOOP.

    LOOP AT rs_result-mapped_journal-canonical_lines ASSIGNING FIELD-SYMBOL(<ls_line>).
      DATA(lv_line_value) = CONV string( <ls_line>-company_code ).
      map_line_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_line>-outdoc_id iv_line_no = <ls_line>-line_no
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-company_code
                  iv_required = abap_true iv_max_length = 4 it_rule = lt_rule
        CHANGING cv_value = lv_line_value cs_result = rs_result ).
      <ls_line>-company_code = lv_line_value.

      lv_line_value = <ls_line>-gl_account.
      map_line_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_line>-outdoc_id iv_line_no = <ls_line>-line_no
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-gl_account
                  iv_required = abap_true iv_max_length = 10 it_rule = lt_rule
        CHANGING cv_value = lv_line_value cs_result = rs_result ).
      <ls_line>-gl_account = lv_line_value.

      lv_line_value = <ls_line>-profit_center.
      map_line_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_line>-outdoc_id iv_line_no = <ls_line>-line_no
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-profit_center
                  iv_required = abap_false iv_max_length = 10 it_rule = lt_rule
        CHANGING cv_value = lv_line_value cs_result = rs_result ).
      <ls_line>-profit_center = lv_line_value.

      lv_line_value = <ls_line>-cost_center.
      map_line_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_line>-outdoc_id iv_line_no = <ls_line>-line_no
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-cost_center
                  iv_required = abap_false iv_max_length = 10 it_rule = lt_rule
        CHANGING cv_value = lv_line_value cs_result = rs_result ).
      <ls_line>-cost_center = lv_line_value.

      lv_line_value = <ls_line>-segment.
      map_line_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_line>-outdoc_id iv_line_no = <ls_line>-line_no
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-segment
                  iv_required = abap_false iv_max_length = 10 it_rule = lt_rule
        CHANGING cv_value = lv_line_value cs_result = rs_result ).
      <ls_line>-segment = lv_line_value.

      lv_line_value = <ls_line>-internal_order.
      map_line_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_line>-outdoc_id iv_line_no = <ls_line>-line_no
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-internal_order
                  iv_required = abap_false iv_max_length = 12 it_rule = lt_rule
        CHANGING cv_value = lv_line_value cs_result = rs_result ).
      <ls_line>-internal_order = lv_line_value.

      lv_line_value = <ls_line>-trading_partner.
      map_line_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_line>-outdoc_id iv_line_no = <ls_line>-line_no
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-trading_partner
                  iv_required = abap_false iv_max_length = 10 it_rule = lt_rule
        CHANGING cv_value = lv_line_value cs_result = rs_result ).
      <ls_line>-trading_partner = lv_line_value.

      lv_line_value = <ls_line>-tax_code.
      map_line_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_line>-outdoc_id iv_line_no = <ls_line>-line_no
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-tax_code
                  iv_required = abap_false iv_max_length = 2 it_rule = lt_rule
        CHANGING cv_value = lv_line_value cs_result = rs_result ).
      <ls_line>-tax_code = lv_line_value.

      lv_line_value = <ls_line>-assignment.
      map_line_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_line>-outdoc_id iv_line_no = <ls_line>-line_no
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-assignment
                  iv_required = abap_false iv_max_length = 18 it_rule = lt_rule
        CHANGING cv_value = lv_line_value cs_result = rs_result ).
      <ls_line>-assignment = lv_line_value.

      lv_line_value = <ls_line>-item_text.
      map_line_field(
        EXPORTING is_context = is_context iv_outdoc_id = <ls_line>-outdoc_id iv_line_no = <ls_line>-line_no
                  iv_field_name = /fcbp/if_glt_map_types=>c_field-item_text
                  iv_required = abap_false iv_max_length = 50 it_rule = lt_rule
        CHANGING cv_value = lv_line_value cs_result = rs_result ).
      <ls_line>-item_text = lv_line_value.
    ENDLOOP.

    finalize_result( CHANGING cs_result = rs_result ).

    IF rs_result-events IS NOT INITIAL.
      mo_map_repo->insert_events( rs_result-events ).
    ENDIF.
  ENDMETHOD.

  METHOD read_rules.
    rt_rule = is_context-mapping_rules.
    IF rt_rule IS INITIAL AND mo_config_repo IS BOUND AND is_context-mapping_policy_id IS NOT INITIAL.
      TRY.
          rt_rule = mo_config_repo->read_mapping_rules(
            iv_profile_id = is_context-mapping_policy_id
            iv_version    = is_context-mapping_version ).
        CATCH /fcbp/cx_glt_config INTO DATA(lx_config).
          RAISE EXCEPTION TYPE /fcbp/cx_glt_mapping
            EXPORTING
              transfer_id    = is_context-transfer_id
              package_id     = is_context-package_id
              error_category = /fcbp/if_glt_types=>c_error_category-config
              operator_text  = 'Mapping rules could not be read from configuration repository.'
              previous       = lx_config.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD validate_prerequisites.
    IF is_context-mapping_policy_id IS INITIAL OR is_context-mapping_hash IS INITIAL.
      add_message(
        EXPORTING iv_rule_id = 'GLT_MAP_PRE_001'
                  iv_field_name = 'MAPPING_POLICY'
                  iv_text = 'Mapping policy id and hash are required before Mapping can start.'
        CHANGING cs_result = cs_result ).
    ENDIF.

    IF is_context-validation_run_id IS INITIAL.
      add_message(
        EXPORTING iv_rule_id = 'GLT_MAP_PRE_002'
                  iv_field_name = 'VALIDATION_RUN_ID'
                  iv_text = 'Mapping requires validation run evidence for the current package.'
        CHANGING cs_result = cs_result ).
    ENDIF.

    IF it_rule IS INITIAL.
      add_message(
        EXPORTING iv_rule_id = 'GLT_MAP_PRE_003'
                  iv_field_name = 'MAPPING_RULES'
                  iv_text = 'At least one active mapping rule is required.'
        CHANGING cs_result = cs_result ).
    ENDIF.
  ENDMETHOD.

  METHOD map_doc_field.
    DATA(ls_decision) = mo_field_mapper->map(
      is_field_context = VALUE #(
        transfer_id = is_context-transfer_id
        package_id = is_context-package_id
        outdoc_id = iv_outdoc_id
        target_id = is_context-target_id
        mapping_policy_id = is_context-mapping_policy_id
        mapping_version = is_context-mapping_version
        mapping_hash = is_context-mapping_hash
        field_name = iv_field_name
        source_value = cv_value
        required = iv_required
        max_length = iv_max_length )
      it_rule = it_rule ).

    add_decision(
      EXPORTING is_decision = ls_decision
      CHANGING  cv_value = cv_value cs_result = cs_result ).
  ENDMETHOD.

  METHOD map_line_field.
    DATA(ls_decision) = mo_field_mapper->map(
      is_field_context = VALUE #(
        transfer_id = is_context-transfer_id
        package_id = is_context-package_id
        outdoc_id = iv_outdoc_id
        line_no = iv_line_no
        target_id = is_context-target_id
        mapping_policy_id = is_context-mapping_policy_id
        mapping_version = is_context-mapping_version
        mapping_hash = is_context-mapping_hash
        field_name = iv_field_name
        source_value = cv_value
        required = iv_required
        max_length = iv_max_length )
      it_rule = it_rule ).

    add_decision(
      EXPORTING is_decision = ls_decision
      CHANGING  cv_value = cv_value cs_result = cs_result ).
  ENDMETHOD.

  METHOD add_decision.
    DATA(ls_event) = mo_event_builder->build_event( is_decision ).
    APPEND ls_event TO cs_result-events.

    IF is_decision-blocking = abap_true.
      cs_result-blocking_count = cs_result-blocking_count + 1.
      APPEND mo_event_builder->to_message( ls_event ) TO cs_result-messages.
    ELSE.
      cv_value = is_decision-target_value.
      IF is_decision-warning = abap_true.
        cs_result-warning_count = cs_result-warning_count + 1.
        APPEND mo_event_builder->to_message( ls_event ) TO cs_result-messages.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD add_message.
    cs_result-blocking_count = cs_result-blocking_count + 1.
    APPEND VALUE #(
      rule_id = iv_rule_id
      severity = /fcbp/if_glt_types=>c_severity-error
      blocking = abap_true
      entity_name = 'MAPPING'
      field_name = iv_field_name
      operator_text = iv_text ) TO cs_result-messages.
  ENDMETHOD.

  METHOD finalize_result.
    cs_result-mapping_hash = compact_hash(
      |MAPOUT:{ cs_result-package_id }:{ cs_result-policy_context_id }:{ lines( cs_result-events ) }:{ cs_result-blocking_count }| ).

    IF cs_result-blocking_count > 0.
      cs_result-result_status = /fcbp/if_glt_map_types=>c_result_status-failed.
      cs_result-next_allowed_step = /fcbp/if_glt_map_types=>c_next_step-operator_action.
    ELSE.
      cs_result-result_status = /fcbp/if_glt_map_types=>c_result_status-mapped.
      cs_result-next_allowed_step = /fcbp/if_glt_map_types=>c_next_step-adapter.
    ENDIF.
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 24 THEN lv_len ELSE 24 ).
    rv_hash = |MRH-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

ENDCLASS.
