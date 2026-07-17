"! Runtime configuration provider over /FCBP/GLT_CFG and /FCBP/GLT_ROUTE.
CLASS /fcbp/cl_glt_config_provider DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_config_provider.

    METHODS constructor
      IMPORTING
        io_repository     TYPE REF TO /fcbp/if_glt_repository OPTIONAL
        io_config_repo    TYPE REF TO /fcbp/if_glt_config_repo OPTIONAL
        io_health         TYPE REF TO /fcbp/if_glt_config_health OPTIONAL
        io_policy_context TYPE REF TO /fcbp/if_glt_policy_context OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_repository.
    DATA mo_config_repo TYPE REF TO /fcbp/if_glt_config_repo.
    DATA mo_health TYPE REF TO /fcbp/if_glt_config_health.
    DATA mo_policy_context TYPE REF TO /fcbp/if_glt_policy_context.

    METHODS ensure_config_repo
      RAISING
        /fcbp/cx_glt_config.

    METHODS select_single_profile
      IMPORTING
        it_profile        TYPE /fcbp/if_glt_config_types=>tt_target_profile
        is_scope          TYPE /fcbp/if_glt_config_types=>ty_routing_scope
      RETURNING
        VALUE(rs_profile) TYPE /fcbp/if_glt_config_types=>ty_target_profile
      RAISING
        /fcbp/cx_glt_config.

ENDCLASS.

CLASS /fcbp/cl_glt_config_provider IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    mo_config_repo = io_config_repo.
    mo_health = io_health.
    mo_policy_context = io_policy_context.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_provider~get_transfer_config.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-config
                  operator_text  = 'Configuration provider requires a repository implementation.'.
    ENDIF.

    TRY.
        rs_config = mo_repository->read_config( iv_transfer_type ).
      CATCH /fcbp/cx_glt_repository INTO DATA(lx_read).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_config
          EXPORTING
            error_category = /fcbp/if_glt_types=>c_error_category-config
            operator_text  = |Configuration read failed for transfer type { iv_transfer_type }.|
            previous       = lx_read.
    ENDTRY.

    IF rs_config-active = abap_false.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-config
                  operator_text  = |Transfer type { iv_transfer_type } is not active.|.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_provider~resolve_route.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-config
                  operator_text  = 'Configuration provider requires a repository implementation.'.
    ENDIF.

    TRY.
        rs_route = mo_repository->resolve_route( is_header ).
      CATCH /fcbp/cx_glt_repository INTO DATA(lx_route).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_config
          EXPORTING
            error_category = /fcbp/if_glt_types=>c_error_category-config
            operator_text  = |Route resolution failed for transfer type { is_header-transfer_type }.|
            previous       = lx_route.
    ENDTRY.

    IF rs_route-active = abap_false OR rs_route-target_adapter IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING error_category = /fcbp/if_glt_types=>c_error_category-config
                  operator_text  = |No active route found for transfer type { is_header-transfer_type }.|.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_provider~read_target_profile.
    ensure_config_repo( ).
    rs_profile = mo_config_repo->read_target_profile( iv_target_id ).

    IF rs_profile-active_flag = abap_false.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-inactive
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          config_object_key  = iv_target_id
          target_id          = iv_target_id
          operator_text      = |Target profile { iv_target_id } is not active.|.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_provider~resolve_effective_context.
    ensure_config_repo( ).

    DATA(lt_profile) = mo_config_repo->query_target_profiles( is_scope ).
    DATA(ls_profile) = select_single_profile(
      it_profile = lt_profile
      is_scope   = is_scope ).

    rs_context-routing_scope = is_scope.
    rs_context-target_profile = ls_profile.

    IF ls_profile-retry_policy_id IS NOT INITIAL.
      rs_context-retry_policy = mo_config_repo->read_retry_policy( ls_profile-retry_policy_id ).
    ENDIF.
    IF ls_profile-aggregation_profile_id IS NOT INITIAL.
      rs_context-aggregation_policy = mo_config_repo->read_aggregation_policy( ls_profile-aggregation_profile_id ).
      rs_context-aggregation_fields = mo_config_repo->read_aggregation_fields( ls_profile-aggregation_profile_id ).
    ENDIF.
    IF ls_profile-split_profile_id IS NOT INITIAL.
      rs_context-split_policy = mo_config_repo->read_split_policy( ls_profile-split_profile_id ).
    ENDIF.
    IF ls_profile-validation_profile_id IS NOT INITIAL.
      rs_context-validation_rules = mo_config_repo->read_validation_rules( ls_profile-validation_profile_id ).
    ENDIF.
    IF ls_profile-mapping_policy_id IS NOT INITIAL.
      rs_context-mapping_rules = mo_config_repo->read_mapping_rules( ls_profile-mapping_policy_id ).
    ENDIF.
    IF ls_profile-throttle_policy_id IS NOT INITIAL.
      rs_context-throttle_policy = mo_config_repo->read_throttle_policy( ls_profile-throttle_policy_id ).
    ENDIF.
    IF ls_profile-confirmation_policy_id IS NOT INITIAL.
      rs_context-confirmation_policy = mo_config_repo->read_confirmation_policy( ls_profile-confirmation_policy_id ).
    ENDIF.

    GET TIME STAMP FIELD rs_context-resolved_at.
    rs_context-resolved_by = sy-uname.

    IF mo_health IS BOUND.
      DATA(lt_finding) = mo_health->check_effective_context( rs_context ).
      mo_health->assert_healthy( lt_finding ).
    ENDIF.

    IF mo_policy_context IS BOUND.
      rs_context-policy_context_id = mo_policy_context->create_context(
        is_effective_context = rs_context
        iv_transfer_id       = is_scope-transfer_id ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_provider~read_policy_context.
    IF mo_policy_context IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-missing
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-policy_context
          config_object_key  = iv_context_id
          operator_text      = 'Policy context reader is not injected.'.
    ENDIF.

    rs_context = mo_policy_context->read_context( iv_context_id ).
  ENDMETHOD.

  METHOD ensure_config_repo.
    IF mo_config_repo IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-missing
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          operator_text      = 'Target-profile configuration requires a configuration repository implementation.'.
    ENDIF.
  ENDMETHOD.

  METHOD select_single_profile.
    DATA(lt_active) = it_profile.
    DELETE lt_active WHERE active_flag = abap_false.
    DELETE lt_active WHERE health_state = /fcbp/if_glt_config_types=>c_health_state-blocked.

    IF lt_active IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          transfer_id        = is_scope-transfer_id
          correlation_id     = is_scope-correlation_id
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-missing
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          operator_text      = 'No active target profile matches the routing scope.'.
    ENDIF.

    SORT lt_active BY priority ASCENDING valid_from DESCENDING target_id ASCENDING.
    READ TABLE lt_active INTO rs_profile INDEX 1.

    IF lines( lt_active ) > 1.
      READ TABLE lt_active INTO DATA(ls_second) INDEX 2.
      IF ls_second-priority = rs_profile-priority.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_config
          EXPORTING
            transfer_id        = is_scope-transfer_id
            correlation_id     = is_scope-correlation_id
            error_category     = /fcbp/if_glt_types=>c_error_category-config
            reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-ambiguous
            config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
            routing_bucket     = |{ is_scope-company_code }-{ is_scope-processing_mode }|
            operator_text      = 'Multiple target profiles match the routing scope with equal priority.'.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
