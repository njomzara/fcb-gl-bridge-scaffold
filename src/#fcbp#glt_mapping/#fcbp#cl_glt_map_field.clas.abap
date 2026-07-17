"! Applies mapping decisions for a single field.
CLASS /fcbp/cl_glt_map_field DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_resolver TYPE REF TO /fcbp/if_glt_map_resolver OPTIONAL.

    METHODS map
      IMPORTING
        is_field_context TYPE /fcbp/if_glt_map_types=>ty_field_context
        it_rule          TYPE /fcbp/if_glt_config_types=>tt_mapping_rule
      RETURNING
        VALUE(rs_decision) TYPE /fcbp/if_glt_map_types=>ty_decision
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_resolver TYPE REF TO /fcbp/if_glt_map_resolver.

    METHODS apply_truncation
      IMPORTING
        is_field_context TYPE /fcbp/if_glt_map_types=>ty_field_context
        is_decision      TYPE /fcbp/if_glt_map_types=>ty_decision
      RETURNING
        VALUE(rs_decision) TYPE /fcbp/if_glt_map_types=>ty_decision.

ENDCLASS.

CLASS /fcbp/cl_glt_map_field IMPLEMENTATION.

  METHOD constructor.
    IF io_resolver IS BOUND.
      mo_resolver = io_resolver.
    ELSE.
      mo_resolver = NEW /fcbp/cl_glt_map_resolver( ).
    ENDIF.
  ENDMETHOD.

  METHOD map.
    rs_decision = mo_resolver->resolve(
      is_field_context = is_field_context
      it_rule          = it_rule ).

    IF rs_decision-blocking = abap_true.
      RETURN.
    ENDIF.

    DATA(lv_decision_type) = rs_decision-decision_type.
    TRANSLATE lv_decision_type TO UPPER CASE.

    CASE lv_decision_type.
      WHEN /fcbp/if_glt_map_types=>c_decision_type-map
        OR /fcbp/if_glt_map_types=>c_decision_type-mapped.
        IF rs_decision-target_value IS INITIAL AND is_field_context-required = abap_true.
          rs_decision-blocking = abap_true.
          rs_decision-result_status = /fcbp/if_glt_map_types=>c_result_status-failed.
          rs_decision-message_code = 'MAPPING_TARGET_MISSING'.
          rs_decision-operator_text = 'Mapped target value is required but empty.'.
        ELSE.
          rs_decision-decision_type = /fcbp/if_glt_map_types=>c_decision_type-mapped.
          rs_decision-result_status = /fcbp/if_glt_map_types=>c_result_status-mapped.
        ENDIF.

      WHEN /fcbp/if_glt_map_types=>c_decision_type-pass_through.
        rs_decision-target_value = rs_decision-source_value.
        rs_decision-decision_type = /fcbp/if_glt_map_types=>c_decision_type-pass_through.
        rs_decision-result_status = /fcbp/if_glt_map_types=>c_result_status-mapped.

      WHEN /fcbp/if_glt_map_types=>c_decision_type-clear
        OR /fcbp/if_glt_map_types=>c_decision_type-cleared.
        rs_decision-target_value = ''.
        rs_decision-decision_type = /fcbp/if_glt_map_types=>c_decision_type-cleared.
        rs_decision-result_status = /fcbp/if_glt_map_types=>c_result_status-mapped.

      WHEN /fcbp/if_glt_map_types=>c_decision_type-truncate
        OR /fcbp/if_glt_map_types=>c_decision_type-truncated.
        rs_decision = apply_truncation(
          is_field_context = is_field_context
          is_decision      = rs_decision ).

      WHEN /fcbp/if_glt_map_types=>c_decision_type-derive
        OR /fcbp/if_glt_map_types=>c_decision_type-derived.
        IF rs_decision-target_value IS INITIAL.
          rs_decision-target_value = |DRV:{ rs_decision-rule_id }|.
        ENDIF.
        rs_decision-decision_type = /fcbp/if_glt_map_types=>c_decision_type-derived.
        rs_decision-result_status = /fcbp/if_glt_map_types=>c_result_status-mapped.

      WHEN /fcbp/if_glt_map_types=>c_decision_type-reject
        OR /fcbp/if_glt_map_types=>c_decision_type-rejected.
        rs_decision-blocking = abap_true.
        rs_decision-decision_type = /fcbp/if_glt_map_types=>c_decision_type-rejected.
        rs_decision-result_status = /fcbp/if_glt_map_types=>c_result_status-failed.
        rs_decision-message_code = 'MAPPING_REJECTED'.
        IF rs_decision-operator_text IS INITIAL.
          rs_decision-operator_text = 'Mapping rule rejected the source value for the target context.'.
        ENDIF.

      WHEN OTHERS.
        rs_decision-blocking = abap_true.
        rs_decision-result_status = /fcbp/if_glt_map_types=>c_result_status-failed.
        rs_decision-message_code = 'MAPPING_DECISION_UNSUPPORTED'.
        rs_decision-operator_text = |Mapping decision { lv_decision_type } is not supported.|.
    ENDCASE.

    IF rs_decision-operator_text IS INITIAL.
      rs_decision-operator_text = |Mapped field { is_field_context-field_name }.|.
    ENDIF.
  ENDMETHOD.

  METHOD apply_truncation.
    rs_decision = is_decision.
    DATA(lv_len) = strlen( rs_decision-source_value ).
    DATA(lv_max) = is_field_context-max_length.
    IF lv_max <= 0.
      lv_max = 50.
    ENDIF.
    DATA(lv_take) = COND i( WHEN lv_len < lv_max THEN lv_len ELSE lv_max ).
    rs_decision-target_value = rs_decision-source_value(lv_take).
    rs_decision-decision_type = /fcbp/if_glt_map_types=>c_decision_type-truncated.
    rs_decision-result_status = /fcbp/if_glt_map_types=>c_result_status-mapped.
    rs_decision-warning = abap_true.
    rs_decision-operator_text = 'Source value was truncated by explicit mapping policy.'.
  ENDMETHOD.

ENDCLASS.
