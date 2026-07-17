"! Package Builder shell. Persistence/current-package publication belongs to a repository implementation.
CLASS /fcbp/cl_glt_package_builder DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_package_builder.

    METHODS constructor
      IMPORTING
        io_aggregator TYPE REF TO /fcbp/if_glt_aggregator OPTIONAL
        io_splitter   TYPE REF TO /fcbp/if_glt_splitter OPTIONAL.

  PRIVATE SECTION.
    DATA mo_aggregator TYPE REF TO /fcbp/if_glt_aggregator.
    DATA mo_splitter TYPE REF TO /fcbp/if_glt_splitter.

    METHODS has_blocking
      IMPORTING
        it_message TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message
      RETURNING
        VALUE(rv_blocking) TYPE abap_bool.

ENDCLASS.

CLASS /fcbp/cl_glt_package_builder IMPLEMENTATION.

  METHOD constructor.
    IF io_aggregator IS BOUND.
      mo_aggregator = io_aggregator.
    ELSE.
      mo_aggregator = NEW /fcbp/cl_glt_aggregator( ).
    ENDIF.

    IF io_splitter IS BOUND.
      mo_splitter = io_splitter.
    ELSE.
      mo_splitter = NEW /fcbp/cl_glt_splitter( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_builder~build_package.
    DATA(ls_policy_context) = VALUE /fcbp/if_glt_config_types=>ty_policy_context(
      policy_context_id = is_effective_context-policy_context_id
      transfer_id = is_context-transfer_id
      package_id = is_context-package_id
      target_id = is_effective_context-target_profile-target_id
      aggregation_profile_id = is_effective_context-aggregation_policy-aggregation_profile_id
      aggregation_version = is_effective_context-aggregation_policy-version
      aggregation_hash = is_effective_context-aggregation_policy-config_hash
      split_profile_id = is_effective_context-split_policy-split_profile_id
      split_version = is_effective_context-split_policy-version
      split_hash = is_effective_context-split_policy-config_hash ).

    DATA(ls_aggr) = mo_aggregator->aggregate(
      it_source_line     = it_source_line
      is_aggr_policy    = is_effective_context-aggregation_policy
      it_aggr_field     = is_effective_context-aggregation_fields
      is_policy_context = ls_policy_context ).
    APPEND LINES OF ls_aggr-messages TO rs_result-messages.

    IF has_blocking( rs_result-messages ) = abap_true.
      rs_result-accepted = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_split) = mo_splitter->split(
      it_canonical_line = ls_aggr-canonical_lines
      it_source_trace   = ls_aggr-source_trace
      is_split_policy   = is_effective_context-split_policy
      is_policy_context = ls_policy_context ).
    APPEND LINES OF ls_split-messages TO rs_result-messages.

    IF has_blocking( rs_result-messages ) = abap_false.
      rs_result-accepted = abap_true.
    ELSE.
      rs_result-accepted = abap_false.
    ENDIF.
    rs_result-graph-package_header = VALUE #(
      package_id = is_context-package_id
      transfer_id = is_context-transfer_id
      package_version = is_context-package_version
      current_flag = abap_false
      package_status = COND #( WHEN rs_result-accepted = abap_true
                               THEN /fcbp/if_glt_pkg_types=>c_package_status-prepared
                               ELSE /fcbp/if_glt_pkg_types=>c_package_status-failed )
      predecessor_package_id = is_context-predecessor_package_id
      source_type = is_context-source_type
      source_reference = is_context-source_reference
      target_id = is_effective_context-target_profile-target_id
      policy_context_id = is_effective_context-policy_context_id
      aggregation_profile_id = is_effective_context-aggregation_policy-aggregation_profile_id
      aggregation_version = is_effective_context-aggregation_policy-version
      aggregation_hash = is_effective_context-aggregation_policy-config_hash
      split_profile_id = is_effective_context-split_policy-split_profile_id
      split_version = is_effective_context-split_policy-version
      split_hash = is_effective_context-split_policy-config_hash
      source_hash = ls_aggr-source_hash
      aggregation_output_hash = ls_aggr-aggregation_output_hash
      split_output_hash = ls_split-split_output_hash
      outdoc_count = lines( ls_split-outdocs )
      canonical_line_count = lines( ls_split-canonical_lines )
      trace_count = lines( ls_split-source_trace )
      created_by = sy-uname ).
    GET TIME STAMP FIELD rs_result-graph-package_header-created_at.

    rs_result-graph-outdocs = ls_split-outdocs.
    rs_result-graph-canonical_lines = ls_split-canonical_lines.
    rs_result-graph-source_trace = ls_split-source_trace.
    rs_result-package_hash =
      |PKG-{ rs_result-graph-package_header-source_hash }-{ rs_result-graph-package_header-aggregation_output_hash }-{ rs_result-graph-package_header-split_output_hash }|.
    rs_result-graph-package_header-payload_hash = rs_result-package_hash.
  ENDMETHOD.

  METHOD has_blocking.
    LOOP AT it_message TRANSPORTING NO FIELDS WHERE blocking = abap_true.
      rv_blocking = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
