"! Policy-context snapshot writer. Runtime evidence is append-only.
CLASS /fcbp/cl_glt_policy_context DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_policy_context.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_config_repo OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_config_repo.

    METHODS ensure_repository
      RAISING
        /fcbp/cx_glt_config.

    METHODS build_context_row
      IMPORTING
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context
        iv_transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
        iv_package_id        TYPE char32 OPTIONAL
        iv_outbox_id         TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
      RETURNING
        VALUE(rs_context)    TYPE /fcbp/if_glt_config_types=>ty_policy_context
      RAISING
        /fcbp/cx_glt_config.

    METHODS create_context_id
      RETURNING
        VALUE(rv_context_id) TYPE /fcbp/if_glt_config_types=>ty_policy_context_id
      RAISING
        /fcbp/cx_glt_config.

    METHODS derive_validation_version
      IMPORTING
        it_rule           TYPE /fcbp/if_glt_config_types=>tt_validation_rule
      RETURNING
        VALUE(rv_version) TYPE i.

    METHODS derive_validation_hash
      IMPORTING
        it_rule        TYPE /fcbp/if_glt_config_types=>tt_validation_rule
      RETURNING
        VALUE(rv_hash) TYPE char64.

    METHODS derive_mapping_version
      IMPORTING
        it_rule           TYPE /fcbp/if_glt_config_types=>tt_mapping_rule
      RETURNING
        VALUE(rv_version) TYPE i.

    METHODS derive_mapping_hash
      IMPORTING
        it_rule        TYPE /fcbp/if_glt_config_types=>tt_mapping_rule
      RETURNING
        VALUE(rv_hash) TYPE char64.

    METHODS compact_hash
      IMPORTING
        iv_prefix      TYPE string
        iv_input       TYPE string
      RETURNING
        VALUE(rv_hash) TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_policy_context IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD /fcbp/if_glt_policy_context~create_context.
    ensure_repository( ).
    DATA(ls_context) = build_context_row(
      is_effective_context = is_effective_context
      iv_transfer_id       = iv_transfer_id
      iv_package_id        = iv_package_id
      iv_outbox_id         = iv_outbox_id ).
    rv_context_id = mo_repository->insert_policy_context( ls_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_policy_context~read_context.
    ensure_repository( ).
    rs_context = mo_repository->read_policy_context( iv_context_id ).
  ENDMETHOD.

  METHOD ensure_repository.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-missing
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-policy_context
          operator_text      = 'Policy context service requires a configuration repository implementation.'.
    ENDIF.
  ENDMETHOD.

  METHOD build_context_row.
    rs_context = VALUE #(
      policy_context_id      = create_context_id( )
      transfer_id            = iv_transfer_id
      package_id             = iv_package_id
      outbox_id              = iv_outbox_id
      target_id              = is_effective_context-target_profile-target_id
      target_profile_version = is_effective_context-target_profile-config_version
      target_profile_hash    = is_effective_context-target_profile-config_hash
      aggregation_profile_id = is_effective_context-target_profile-aggregation_profile_id
      aggregation_version    = is_effective_context-aggregation_policy-version
      aggregation_hash       = is_effective_context-aggregation_policy-config_hash
      split_profile_id       = is_effective_context-target_profile-split_profile_id
      split_version          = is_effective_context-split_policy-version
      split_hash             = is_effective_context-split_policy-config_hash
      validation_profile_id  = is_effective_context-target_profile-validation_profile_id
      validation_version     = derive_validation_version( is_effective_context-validation_rules )
      validation_hash        = derive_validation_hash( is_effective_context-validation_rules )
      mapping_policy_id      = is_effective_context-target_profile-mapping_policy_id
      mapping_version        = derive_mapping_version( is_effective_context-mapping_rules )
      mapping_hash           = derive_mapping_hash( is_effective_context-mapping_rules )
      retry_policy_id        = is_effective_context-target_profile-retry_policy_id
      retry_version          = is_effective_context-retry_policy-version
      retry_hash             = is_effective_context-retry_policy-config_hash
      throttle_policy_id     = is_effective_context-target_profile-throttle_policy_id
      throttle_version       = is_effective_context-throttle_policy-version
      throttle_hash          = is_effective_context-throttle_policy-config_hash
      confirmation_policy_id = is_effective_context-target_profile-confirmation_policy_id
      confirmation_version   = is_effective_context-confirmation_policy-version
      confirmation_hash      = is_effective_context-confirmation_policy-config_hash
      resolved_by            = sy-uname
      validity_from          = is_effective_context-target_profile-valid_from
      validity_to            = is_effective_context-target_profile-valid_to ).
    GET TIME STAMP FIELD rs_context-resolved_at.
  ENDMETHOD.

  METHOD create_context_id.
    TRY.
        rv_context_id = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_root INTO DATA(lx_uuid).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_config
          EXPORTING
            error_category     = /fcbp/if_glt_types=>c_error_category-technical
            reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-inconsistent
            config_object_type = /fcbp/if_glt_config_types=>c_object_type-policy_context
            operator_text      = 'Policy context id generation failed.'
            previous           = lx_uuid.
    ENDTRY.
  ENDMETHOD.

  METHOD derive_validation_version.
    LOOP AT it_rule INTO DATA(ls_rule).
      IF ls_rule-version > rv_version.
        rv_version = ls_rule-version.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD derive_validation_hash.
    DATA(lt_rule) = it_rule.
    IF lt_rule IS INITIAL.
      rv_hash = compact_hash(
        iv_prefix = 'VAL'
        iv_input  = 'NO_RULES' ).
      RETURN.
    ENDIF.

    SORT lt_rule BY validation_profile_id rule_id version rule_category field_scope target_scope config_hash.
    DATA(lv_input) = ``.
    LOOP AT lt_rule INTO DATA(ls_rule).
      lv_input = |{ lv_input }VAL:{ ls_rule-validation_profile_id }:{ ls_rule-rule_id }:{ ls_rule-version }:{ ls_rule-active_flag }:{ ls_rule-rule_category }:{ ls_rule-severity }:{ ls_rule-blocking_flag }:{ ls_rule-target_scope }:{ ls_rule-field_scope }:{ ls_rule-config_hash };|.
    ENDLOOP.
    rv_hash = compact_hash(
      iv_prefix = 'VAL'
      iv_input  = lv_input ).
  ENDMETHOD.

  METHOD derive_mapping_version.
    LOOP AT it_rule INTO DATA(ls_rule).
      IF ls_rule-version > rv_version.
        rv_version = ls_rule-version.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD derive_mapping_hash.
    DATA(lt_rule) = it_rule.
    IF lt_rule IS INITIAL.
      rv_hash = compact_hash(
        iv_prefix = 'MAP'
        iv_input  = 'NO_RULES' ).
      RETURN.
    ENDIF.

    SORT lt_rule BY mapping_policy_id mapping_rule_id version field_name source_value source_pattern target_value decision_type priority config_hash.
    DATA(lv_input) = ``.
    LOOP AT lt_rule INTO DATA(ls_rule).
      lv_input = |{ lv_input }MAP:{ ls_rule-mapping_policy_id }:{ ls_rule-mapping_rule_id }:{ ls_rule-version }:{ ls_rule-active_flag }:{ ls_rule-field_name }:{ ls_rule-source_value }:{ ls_rule-source_pattern }:{ ls_rule-target_value }:{ ls_rule-decision_type }:{ ls_rule-priority }:{ ls_rule-config_hash };|.
    ENDLOOP.
    rv_hash = compact_hash(
      iv_prefix = 'MAP'
      iv_input  = lv_input ).
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 40 THEN lv_len ELSE 40 ).
    rv_hash = |{ iv_prefix }-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

ENDCLASS.
