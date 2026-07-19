"! Package Builder orchestration service.
CLASS /fcbp/cl_glt_package_preparer DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_package_preparer.

    METHODS constructor
      IMPORTING
        io_transfer_repo TYPE REF TO /fcbp/if_glt_repository OPTIONAL
        io_source_reader TYPE REF TO /fcbp/if_glt_source_reader OPTIONAL
        io_id_factory    TYPE REF TO /fcbp/if_glt_package_id_factory OPTIONAL
        io_builder       TYPE REF TO /fcbp/if_glt_package_builder OPTIONAL
        io_package_repo  TYPE REF TO /fcbp/if_glt_package_repo OPTIONAL
        io_lock          TYPE REF TO /fcbp/if_glt_package_lock OPTIONAL
        io_status        TYPE REF TO /fcbp/if_glt_package_status OPTIONAL
        io_consistency   TYPE REF TO /fcbp/cl_glt_package_consistency OPTIONAL
        io_source_read_recorder TYPE REF TO /fcbp/cl_glt_source_read_recorder OPTIONAL.

  PRIVATE SECTION.
    DATA mo_transfer_repo TYPE REF TO /fcbp/if_glt_repository.
    DATA mo_source_reader TYPE REF TO /fcbp/if_glt_source_reader.
    DATA mo_id_factory TYPE REF TO /fcbp/if_glt_package_id_factory.
    DATA mo_builder TYPE REF TO /fcbp/if_glt_package_builder.
    DATA mo_package_repo TYPE REF TO /fcbp/if_glt_package_repo.
    DATA mo_lock TYPE REF TO /fcbp/if_glt_package_lock.
    DATA mo_status TYPE REF TO /fcbp/if_glt_package_status.
    DATA mo_consistency TYPE REF TO /fcbp/cl_glt_package_consistency.
    DATA mo_source_read_recorder TYPE REF TO /fcbp/cl_glt_source_read_recorder.

    METHODS execute_prepare
      IMPORTING
        iv_transfer_id            TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_build_mode             TYPE char20
        iv_predecessor_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
        iv_reason_code            TYPE char30 OPTIONAL
        is_effective_context      TYPE /fcbp/if_glt_config_types=>ty_effective_context
        iv_outbox_id              TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
      RETURNING
        VALUE(rs_result)          TYPE /fcbp/if_glt_aggr_types=>ty_package_build_result
      RAISING
        /fcbp/cx_glt_error.

    METHODS validate_request
      IMPORTING
        iv_transfer_id            TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_build_mode             TYPE char20
        iv_predecessor_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
        iv_reason_code            TYPE char30 OPTIONAL
        is_effective_context      TYPE /fcbp/if_glt_config_types=>ty_effective_context
      RAISING
        /fcbp/cx_glt_error.

    METHODS validate_transfer
      IMPORTING
        is_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
      RAISING
        /fcbp/cx_glt_error.

    METHODS build_source_request
      IMPORTING
        is_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
        iv_package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id
        iv_build_mode        TYPE char20
      RETURNING
        VALUE(rs_request)    TYPE /fcbp/if_glt_src_types=>ty_source_read_request.

    METHODS read_current_candidate
      IMPORTING
        is_transfer           TYPE /fcbp/if_glt_types=>ty_transfer
      RETURNING
        VALUE(rs_graph)       TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
      RAISING
        /fcbp/cx_glt_error.

    METHODS current_package_reusable
      IMPORTING
        is_graph             TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
        is_transfer          TYPE /fcbp/if_glt_types=>ty_transfer
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
        iv_source_hash       TYPE char64
      RETURNING
        VALUE(rv_reusable)   TYPE abap_bool.

    METHODS calculate_source_hash
      IMPORTING
        it_source_line        TYPE /fcbp/if_glt_pkg_types=>tt_source_gl_line
      RETURNING
        VALUE(rv_source_hash) TYPE char64.

    METHODS compact_hash
      IMPORTING
        iv_input              TYPE string
      RETURNING
        VALUE(rv_hash)        TYPE char64.

    METHODS append_reuse_blocking
      IMPORTING
        is_graph         TYPE /fcbp/if_glt_pkg_types=>ty_package_graph
        iv_rule_id       TYPE char30
        iv_operator_text TYPE char220
      CHANGING
        ct_message       TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message.

    METHODS build_context
      IMPORTING
        is_transfer                 TYPE /fcbp/if_glt_types=>ty_transfer
        is_effective_context        TYPE /fcbp/if_glt_config_types=>ty_effective_context
        iv_package_id               TYPE /fcbp/if_glt_pkg_types=>ty_package_id
        iv_predecessor_package_id   TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
        iv_reason_code              TYPE char30 OPTIONAL
      RETURNING
        VALUE(rs_context)           TYPE /fcbp/if_glt_pkg_types=>ty_package_build_context
      RAISING
        /fcbp/cx_glt_error.

    METHODS source_reference
      IMPORTING
        is_transfer              TYPE /fcbp/if_glt_types=>ty_transfer
      RETURNING
        VALUE(rv_source_reference) TYPE char50.

    METHODS append_consistency
      CHANGING
        cs_result TYPE /fcbp/if_glt_aggr_types=>ty_package_build_result.

    METHODS raise_blocking
      IMPORTING
        it_message     TYPE /fcbp/if_glt_aggr_types=>tt_preparation_message
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
      RAISING
        /fcbp/cx_glt_error.

    METHODS release_lock_safely
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_outbox_id   TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
        iv_build_mode  TYPE char20 OPTIONAL.

    METHODS lock_owner
      IMPORTING
        iv_transfer_id          TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_outbox_id            TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
      RETURNING
        VALUE(rv_owner)         TYPE char40.

ENDCLASS.

CLASS /fcbp/cl_glt_package_preparer IMPLEMENTATION.

  METHOD constructor.
    IF io_transfer_repo IS BOUND.
      mo_transfer_repo = io_transfer_repo.
    ELSE.
      mo_transfer_repo = NEW /fcbp/cl_glt_repository( ).
    ENDIF.

    IF io_source_reader IS BOUND.
      mo_source_reader = io_source_reader.
    ELSE.
      mo_source_reader = NEW /fcbp/cl_glt_source_reader( ).
    ENDIF.

    IF io_id_factory IS BOUND.
      mo_id_factory = io_id_factory.
    ELSE.
      mo_id_factory = NEW /fcbp/cl_glt_package_id_factory( ).
    ENDIF.

    IF io_builder IS BOUND.
      mo_builder = io_builder.
    ELSE.
      mo_builder = NEW /fcbp/cl_glt_package_builder( ).
    ENDIF.

    IF io_package_repo IS BOUND.
      mo_package_repo = io_package_repo.
    ELSE.
      mo_package_repo = NEW /fcbp/cl_glt_package_repo( ).
    ENDIF.

    IF io_lock IS BOUND.
      mo_lock = io_lock.
    ELSE.
      mo_lock = NEW /fcbp/cl_glt_package_lock( ).
    ENDIF.

    IF io_status IS BOUND.
      mo_status = io_status.
    ELSE.
      mo_status = NEW /fcbp/cl_glt_package_status( ).
    ENDIF.

    IF io_consistency IS BOUND.
      mo_consistency = io_consistency.
    ELSE.
      mo_consistency = NEW /fcbp/cl_glt_package_consistency( ).
    ENDIF.
    mo_source_read_recorder = COND #(
      WHEN io_source_read_recorder IS BOUND THEN io_source_read_recorder
      ELSE NEW /fcbp/cl_glt_source_read_recorder( ) ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_preparer~prepare_for_dispatch.
    rs_result = execute_prepare(
      iv_transfer_id       = iv_transfer_id
      iv_build_mode        = /fcbp/if_glt_pkg_prep_types=>c_build_mode-dispatch
      is_effective_context = is_effective_context
      iv_outbox_id         = iv_outbox_id ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_preparer~rebuild_package.
    rs_result = execute_prepare(
      iv_transfer_id            = iv_transfer_id
      iv_build_mode             = /fcbp/if_glt_pkg_prep_types=>c_build_mode-rebuild
      iv_predecessor_package_id = iv_predecessor_package_id
      iv_reason_code            = iv_reason_code
      is_effective_context      = is_effective_context ).
  ENDMETHOD.

  METHOD execute_prepare.
    validate_request(
      iv_transfer_id            = iv_transfer_id
      iv_build_mode             = iv_build_mode
      iv_predecessor_package_id = iv_predecessor_package_id
      iv_reason_code            = iv_reason_code
      is_effective_context      = is_effective_context ).

    DATA(ls_transfer) = mo_transfer_repo->read_transfer( iv_transfer_id ).
    validate_transfer(
      is_transfer          = ls_transfer
      is_effective_context = is_effective_context ).

    DATA(lv_locked) = mo_lock->acquire(
      iv_transfer_id = iv_transfer_id
      iv_outbox_id   = iv_outbox_id
      iv_build_mode  = iv_build_mode ).
    IF lv_locked <> abap_true.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-lock
          rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-req_lock
          operator_text  = 'Package preparation lock could not be acquired.'.
    ENDIF.

    TRY.
        ls_transfer = mo_transfer_repo->read_transfer( iv_transfer_id ).
        validate_transfer(
          is_transfer          = ls_transfer
          is_effective_context = is_effective_context ).

        DATA(lv_lock_owner) = lock_owner(
          iv_transfer_id = iv_transfer_id
          iv_outbox_id   = iv_outbox_id ).
        DATA(lv_expected_current_package_id) = COND /fcbp/if_glt_pkg_types=>ty_package_id(
          WHEN iv_predecessor_package_id IS NOT INITIAL THEN iv_predecessor_package_id
          ELSE ls_transfer-header-current_package_id ).

        mo_status->preparation_started(
          is_transfer   = ls_transfer
          iv_outbox_id  = iv_outbox_id
          iv_build_mode = iv_build_mode ).

        DATA(lv_package_id) = COND /fcbp/if_glt_pkg_types=>ty_package_id(
          WHEN iv_build_mode = /fcbp/if_glt_pkg_prep_types=>c_build_mode-dispatch
          THEN ls_transfer-header-current_package_id
          ELSE mo_id_factory->create_package_id(
                 iv_transfer_id = iv_transfer_id
                 iv_build_mode  = iv_build_mode ) ).

        DATA(ls_source_request) = build_source_request(
          is_transfer          = ls_transfer
          is_effective_context = is_effective_context
          iv_package_id        = lv_package_id
          iv_build_mode        = iv_build_mode ).

        DATA(lv_source_read_id) = mo_source_read_recorder->start( ls_source_request ).
        TRY.
            DATA(lt_source_line) = mo_source_reader->read_source_lines( ls_source_request ).
            DATA(ls_source_result) = VALUE /fcbp/if_glt_src_types=>ty_source_read_result(
              request           = ls_source_request
              source_line       = lt_source_line
              source_line_count = lines( lt_source_line )
              source_hash       = calculate_source_hash( lt_source_line )
              read_consistency  = /fcbp/if_glt_src_types=>c_read_consistency-stable ).
            mo_source_read_recorder->complete(
              iv_source_read_id = lv_source_read_id
              is_result         = ls_source_result ).
          CATCH /fcbp/cx_glt_source_read INTO DATA(lx_source_read).
            mo_source_read_recorder->fail(
              iv_source_read_id = lv_source_read_id
              ix_error          = lx_source_read ).
            RAISE EXCEPTION lx_source_read.
        ENDTRY.

        IF iv_build_mode = /fcbp/if_glt_pkg_prep_types=>c_build_mode-dispatch.
          DATA(ls_current_graph) = read_current_candidate( ls_transfer ).
          IF ls_current_graph-package_header-package_id IS NOT INITIAL.
            DATA(lt_current_message) = mo_package_repo->check_consistency( ls_current_graph-package_header-package_id ).
            IF mo_consistency->has_blocking( lt_current_message ) = abap_true.
              rs_result = VALUE #(
                graph            = ls_current_graph
                messages         = lt_current_message
                accepted         = abap_false
                reusable_package = abap_false
                package_hash     = ls_current_graph-package_header-payload_hash ).
              mo_status->preparation_blocked(
                is_transfer   = ls_transfer
                iv_package_id = ls_current_graph-package_header-package_id
                it_message    = rs_result-messages
                iv_build_mode = iv_build_mode ).
              mo_lock->release(
                iv_transfer_id = iv_transfer_id
                iv_outbox_id   = iv_outbox_id
                iv_build_mode  = iv_build_mode ).
              RETURN.
            ENDIF.

            DATA(lv_source_hash) = calculate_source_hash( lt_source_line ).
            IF current_package_reusable(
                 is_graph             = ls_current_graph
                 is_transfer          = ls_transfer
                 is_effective_context = is_effective_context
                 iv_source_hash       = lv_source_hash ) = abap_true.
              rs_result = VALUE #(
                graph            = ls_current_graph
                messages         = lt_current_message
                accepted         = abap_true
                reusable_package = abap_true
                package_hash     = ls_current_graph-package_header-payload_hash ).
              mo_package_repo->publish_current(
                iv_transfer_id                 = iv_transfer_id
                iv_package_id                  = ls_current_graph-package_header-package_id
                iv_expected_current_package_id = ls_current_graph-package_header-package_id
                iv_lock_owner                  = lv_lock_owner ).
              mo_status->preparation_succeeded(
                is_transfer   = ls_transfer
                iv_package_id = ls_current_graph-package_header-package_id
                it_message    = rs_result-messages
                iv_build_mode = iv_build_mode ).
              mo_lock->release(
                iv_transfer_id = iv_transfer_id
                iv_outbox_id   = iv_outbox_id
                iv_build_mode  = iv_build_mode ).
              RETURN.
            ENDIF.

            DATA(lt_reuse_message) = lt_current_message.
            append_reuse_blocking(
              EXPORTING
                is_graph         = ls_current_graph
                iv_rule_id       = 'PKG_REUSE_MISMATCH'
                iv_operator_text = 'Current package evidence no longer matches source or package-shaping policy; request rebuild instead of dispatch.'
              CHANGING
                ct_message       = lt_reuse_message ).
            rs_result = VALUE #(
              graph            = ls_current_graph
              messages         = lt_reuse_message
              accepted         = abap_false
              reusable_package = abap_false
              package_hash     = ls_current_graph-package_header-payload_hash ).
            mo_status->preparation_blocked(
              is_transfer   = ls_transfer
              iv_package_id = ls_current_graph-package_header-package_id
              it_message    = rs_result-messages
              iv_build_mode = iv_build_mode ).
            mo_lock->release(
              iv_transfer_id = iv_transfer_id
              iv_outbox_id   = iv_outbox_id
              iv_build_mode  = iv_build_mode ).
            RETURN.
          ENDIF.

          lv_package_id = mo_id_factory->create_package_id(
            iv_transfer_id = iv_transfer_id
            iv_build_mode  = iv_build_mode ).
        ENDIF.

        DATA(ls_context) = build_context(
          is_transfer               = ls_transfer
          is_effective_context      = is_effective_context
          iv_package_id             = lv_package_id
          iv_predecessor_package_id = iv_predecessor_package_id
          iv_reason_code            = iv_reason_code ).

        rs_result = mo_builder->build_package(
          is_context           = ls_context
          it_source_line       = lt_source_line
          is_effective_context = is_effective_context ).

        append_consistency( CHANGING cs_result = rs_result ).

        IF rs_result-accepted <> abap_true
           OR mo_consistency->has_blocking( rs_result-messages ) = abap_true.
          rs_result-accepted = abap_false.
          mo_status->preparation_blocked(
            is_transfer   = ls_transfer
            iv_package_id = lv_package_id
            it_message    = rs_result-messages
            iv_build_mode = iv_build_mode ).
          mo_lock->release(
            iv_transfer_id = iv_transfer_id
            iv_outbox_id   = iv_outbox_id
            iv_build_mode  = iv_build_mode ).
          RETURN.
        ENDIF.

        mo_package_repo->persist_graph( rs_result-graph ).

        DATA(lt_repo_message) = mo_package_repo->check_consistency( lv_package_id ).
        APPEND LINES OF lt_repo_message TO rs_result-messages.
        IF mo_consistency->has_blocking( lt_repo_message ) = abap_true.
          rs_result-accepted = abap_false.
          mo_status->preparation_blocked(
            is_transfer   = ls_transfer
            iv_package_id = lv_package_id
            it_message    = rs_result-messages
            iv_build_mode = iv_build_mode ).
          mo_lock->release(
            iv_transfer_id = iv_transfer_id
            iv_outbox_id   = iv_outbox_id
            iv_build_mode  = iv_build_mode ).
          RETURN.
        ENDIF.

        mo_package_repo->publish_current(
          iv_transfer_id                 = iv_transfer_id
          iv_package_id                  = lv_package_id
          iv_expected_current_package_id = lv_expected_current_package_id
          iv_lock_owner                  = lv_lock_owner ).

        mo_status->preparation_succeeded(
          is_transfer   = ls_transfer
          iv_package_id = lv_package_id
          it_message    = rs_result-messages
          iv_build_mode = iv_build_mode ).

        mo_lock->release(
          iv_transfer_id = iv_transfer_id
          iv_outbox_id   = iv_outbox_id
          iv_build_mode  = iv_build_mode ).
      CATCH /fcbp/cx_glt_error INTO DATA(lx_error).
        release_lock_safely(
          iv_transfer_id = iv_transfer_id
          iv_outbox_id   = iv_outbox_id
          iv_build_mode  = iv_build_mode ).
        RAISE EXCEPTION lx_error.
    ENDTRY.
  ENDMETHOD.

  METHOD validate_request.
    IF iv_transfer_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-req_transfer_id
          operator_text  = 'Package preparation request is missing transfer id.'.
    ENDIF.

    CASE iv_build_mode.
      WHEN /fcbp/if_glt_pkg_prep_types=>c_build_mode-dispatch
        OR /fcbp/if_glt_pkg_prep_types=>c_build_mode-rebuild.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
          EXPORTING
            transfer_id    = iv_transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-technical
            rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-req_build_mode
            operator_text  = |Unsupported package build mode { iv_build_mode }.|.
    ENDCASE.

    IF is_effective_context-policy_context_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          transfer_id       = iv_transfer_id
          policy_context_id = is_effective_context-policy_context_id
          error_category    = /fcbp/if_glt_types=>c_error_category-config
          rule_id           = /fcbp/if_glt_pkg_prep_types=>c_rule_id-req_policy_context
          operator_text     = 'Effective policy context id is required for package preparation.'.
    ENDIF.

    IF is_effective_context-target_profile-target_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-config
          rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-req_target_context
          operator_text  = 'Effective target profile is required for package preparation.'.
    ENDIF.

    IF is_effective_context-aggregation_policy-aggregation_profile_id IS INITIAL
       OR is_effective_context-split_policy-split_profile_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-config
          rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-pol_aggregation
          operator_text  = 'Aggregation and split policies must be resolved before package preparation.'.
    ENDIF.

    IF is_effective_context-aggregation_policy-config_hash IS INITIAL
       OR is_effective_context-split_policy-config_hash IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-config
          rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-pol_hash
          operator_text  = 'Aggregation and split policy hashes must be present before package preparation.'.
    ENDIF.

    IF iv_build_mode = /fcbp/if_glt_pkg_prep_types=>c_build_mode-rebuild.
      IF iv_predecessor_package_id IS INITIAL.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
          EXPORTING
            transfer_id    = iv_transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-technical
            rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-reb_predecessor
            operator_text  = 'Rebuild request is missing predecessor package id.'.
      ENDIF.
      IF iv_reason_code IS INITIAL.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
          EXPORTING
            transfer_id    = iv_transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-technical
            rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-reb_reason
            operator_text  = 'Rebuild request is missing reason code.'.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validate_transfer.
    IF is_transfer-header-transfer_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-req_transfer_exists
          operator_text  = 'Transfer root was not found for package preparation.'.
    ENDIF.

    IF is_transfer-header-source_type IS INITIAL OR source_reference( is_transfer ) IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          transfer_id      = is_transfer-header-transfer_id
          error_category   = /fcbp/if_glt_types=>c_error_category-technical
          rule_id          = /fcbp/if_glt_pkg_prep_types=>c_rule_id-req_source_scope
          source_reference = source_reference( is_transfer )
          operator_text    = 'Transfer source type/reference is required for package preparation.'.
    ENDIF.

    IF is_transfer-header-target_id IS NOT INITIAL
       AND is_transfer-header-target_id <> is_effective_context-target_profile-target_id.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-config
          rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-req_target_context
          operator_text  = 'Effective target profile does not match transfer target.'.
    ENDIF.
  ENDMETHOD.

  METHOD build_source_request.
    rs_request = VALUE #(
      transfer_id       = is_transfer-header-transfer_id
      package_id        = iv_package_id
      source_type       = is_transfer-header-source_type
      source_reference  = source_reference( is_transfer )
      routing_bucket    = is_transfer-header-routing_bucket
      target_id         = is_effective_context-target_profile-target_id
      policy_context_id = is_effective_context-policy_context_id
      read_mode         = iv_build_mode
      requested_by      = sy-uname ).
  ENDMETHOD.

  METHOD read_current_candidate.
    IF is_transfer-header-current_package_id IS NOT INITIAL.
      rs_graph = mo_package_repo->read_package( is_transfer-header-current_package_id ).
      RETURN.
    ENDIF.

    rs_graph = mo_package_repo->read_current_package( is_transfer-header-transfer_id ).
  ENDMETHOD.

  METHOD current_package_reusable.
    DATA(ls_header) = is_graph-package_header.
    DATA(lv_is_current) = xsdbool(
      ls_header-current_flag = abap_true OR
      ls_header-package_id = is_transfer-header-current_package_id ).

    rv_reusable = xsdbool(
      lv_is_current = abap_true AND
      ( ls_header-package_status = /fcbp/if_glt_pkg_types=>c_package_status-current OR
        ls_header-package_status = /fcbp/if_glt_pkg_types=>c_package_status-prepared ) AND
      ls_header-transfer_id = is_transfer-header-transfer_id AND
      ls_header-source_type = is_transfer-header-source_type AND
      ls_header-source_reference = source_reference( is_transfer ) AND
      ls_header-target_id = is_effective_context-target_profile-target_id AND
      ls_header-aggregation_profile_id = is_effective_context-aggregation_policy-aggregation_profile_id AND
      ls_header-aggregation_version = is_effective_context-aggregation_policy-version AND
      ls_header-aggregation_hash = is_effective_context-aggregation_policy-config_hash AND
      ls_header-split_profile_id = is_effective_context-split_policy-split_profile_id AND
      ls_header-split_version = is_effective_context-split_policy-version AND
      ls_header-split_hash = is_effective_context-split_policy-config_hash AND
      ls_header-source_hash IS NOT INITIAL AND
      ls_header-source_hash = iv_source_hash ).
  ENDMETHOD.

  METHOD calculate_source_hash.
    DATA(lt_source) = it_source_line.
    SORT lt_source BY source_type source_reference source_doc_no source_item_no source_hash.

    LOOP AT lt_source INTO DATA(ls_source).
      rv_source_hash = compact_hash( |SRC:{ rv_source_hash }:{ ls_source-source_hash }| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 24 THEN lv_len ELSE 24 ).
    rv_hash = |AGG-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

  METHOD append_reuse_blocking.
    APPEND VALUE #(
      rule_id          = iv_rule_id
      category         = /fcbp/if_glt_aggr_types=>c_prep_category-technical
      severity         = /fcbp/if_glt_types=>c_severity-error
      blocking         = abap_true
      package_id       = is_graph-package_header-package_id
      source_reference = is_graph-package_header-source_reference
      operator_text    = iv_operator_text ) TO ct_message.
  ENDMETHOD.

  METHOD build_context.
    DATA(lv_version) = 1.
    IF iv_predecessor_package_id IS NOT INITIAL.
      DATA(ls_predecessor) = mo_package_repo->read_package( iv_predecessor_package_id ).
      IF ls_predecessor-package_header-transfer_id <> is_transfer-header-transfer_id.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
          EXPORTING
            transfer_id    = is_transfer-header-transfer_id
            package_id     = iv_predecessor_package_id
            error_category = /fcbp/if_glt_types=>c_error_category-conflict
            rule_id        = /fcbp/if_glt_pkg_prep_types=>c_rule_id-reb_ownership
            operator_text  = 'Predecessor package does not belong to the transfer being rebuilt.'.
      ENDIF.
      lv_version = ls_predecessor-package_header-package_version + 1.
    ENDIF.

    rs_context = VALUE #(
      transfer_id            = is_transfer-header-transfer_id
      package_id             = iv_package_id
      predecessor_package_id = iv_predecessor_package_id
      package_version        = lv_version
      source_type            = is_transfer-header-source_type
      source_reference       = source_reference( is_transfer )
      target_id              = is_effective_context-target_profile-target_id
      policy_context_id      = is_effective_context-policy_context_id
      posting_date           = is_transfer-header-posting_date
      document_date          = is_transfer-header-document_date
      gl_doc_type            = is_effective_context-target_profile-transfer_type
      ledger_group           = is_effective_context-target_profile-ledger_group
      requested_by           = sy-uname
      rebuild_reason         = iv_reason_code ).
  ENDMETHOD.

  METHOD source_reference.
    rv_source_reference = is_transfer-header-source_ref_id.
    IF rv_source_reference IS INITIAL AND is_transfer-header-reconciliation_key IS NOT INITIAL.
      rv_source_reference = is_transfer-header-reconciliation_key.
    ENDIF.
    IF rv_source_reference IS INITIAL AND is_transfer-header-source_doc_no IS NOT INITIAL.
      rv_source_reference = is_transfer-header-source_doc_no.
    ENDIF.
  ENDMETHOD.

  METHOD append_consistency.
    DATA(lt_message) = mo_consistency->check_graph( cs_result-graph ).
    APPEND LINES OF lt_message TO cs_result-messages.
    IF mo_consistency->has_blocking( lt_message ) = abap_true.
      cs_result-accepted = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD raise_blocking.
    LOOP AT it_message INTO DATA(ls_message) WHERE blocking = abap_true.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_preparation
        EXPORTING
          transfer_id     = iv_transfer_id
          package_id      = ls_message-package_id
          outdoc_id       = ls_message-outdoc_id
          line_id         = ls_message-line_id
          rule_id         = ls_message-rule_id
          field_name      = ls_message-field_name
          source_reference = ls_message-source_reference
          error_category  = /fcbp/if_glt_types=>c_error_category-validation
          operator_text   = ls_message-operator_text
          technical_reference = ls_message-technical_ref.
    ENDLOOP.
  ENDMETHOD.

  METHOD release_lock_safely.
    TRY.
        mo_lock->release(
          iv_transfer_id = iv_transfer_id
          iv_outbox_id   = iv_outbox_id
          iv_build_mode  = iv_build_mode ).
      CATCH /fcbp/cx_glt_error.
        " Keep the original failure path when lock cleanup also fails.
    ENDTRY.
  ENDMETHOD.

  METHOD lock_owner.
    rv_owner = COND #(
      WHEN iv_outbox_id IS NOT INITIAL THEN |PKG:{ iv_outbox_id }|
      ELSE |PKG:{ iv_transfer_id }| ).
  ENDMETHOD.

ENDCLASS.
