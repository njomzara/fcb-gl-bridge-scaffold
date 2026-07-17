"! Application service scaffold for governed configuration maintenance.
CLASS /fcbp/cl_glt_config_admin DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_config_admin.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_config_repo OPTIONAL
        io_hash       TYPE REF TO /fcbp/if_glt_config_hash OPTIONAL
        io_health     TYPE REF TO /fcbp/if_glt_config_health OPTIONAL
        io_audit      TYPE REF TO /fcbp/if_glt_config_audit OPTIONAL
        io_validator  TYPE REF TO /fcbp/cl_glt_config_validator OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_config_repo.
    DATA mo_hash TYPE REF TO /fcbp/if_glt_config_hash.
    DATA mo_health TYPE REF TO /fcbp/if_glt_config_health.
    DATA mo_audit TYPE REF TO /fcbp/if_glt_config_audit.
    DATA mo_validator TYPE REF TO /fcbp/cl_glt_config_validator.

    METHODS ensure_audit
      RAISING
        /fcbp/cx_glt_audit.

    METHODS build_change
      IMPORTING
        is_profile      TYPE /fcbp/if_glt_config_types=>ty_target_profile
        iv_activity     TYPE char30
        iv_old_hash     TYPE char64 OPTIONAL
        iv_new_hash     TYPE char64 OPTIONAL
      RETURNING
        VALUE(rs_change) TYPE /fcbp/if_glt_sec_types=>ty_config_change.

ENDCLASS.

CLASS /fcbp/cl_glt_config_admin IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    mo_audit = io_audit.

    IF io_hash IS BOUND.
      mo_hash = io_hash.
    ELSE.
      mo_hash = NEW /fcbp/cl_glt_config_hash( ).
    ENDIF.

    IF io_health IS BOUND.
      mo_health = io_health.
    ELSE.
      mo_health = NEW /fcbp/cl_glt_config_health( io_repository = io_repository ).
    ENDIF.

    IF io_validator IS BOUND.
      mo_validator = io_validator.
    ELSE.
      mo_validator = NEW /fcbp/cl_glt_config_validator( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_admin~validate_target_profile.
    mo_validator->validate_target_profile( is_profile ).
    rt_finding = mo_health->check_target_profile( is_profile ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_admin~check_target_health.
    rt_finding = mo_health->check_target_profile( is_profile ).

    IF mo_repository IS BOUND.
      LOOP AT rt_finding INTO DATA(ls_finding).
        mo_repository->insert_health_finding( ls_finding ).
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_admin~activate_target_profile.
    rs_profile = is_profile.
    DATA(lv_old_hash) = rs_profile-config_hash.

    IF rs_profile-config_hash IS INITIAL.
      rs_profile-config_hash = mo_hash->hash_target_profile( rs_profile ).
    ENDIF.

    DATA(lt_finding) = mo_health->check_target_profile( rs_profile ).
    mo_validator->assert_can_activate(
      is_profile = rs_profile
      it_finding = lt_finding ).

    rs_profile-active_flag = abap_true.
    rs_profile-lifecycle_state = /fcbp/if_glt_config_types=>c_lifecycle_state-active.
    rs_profile-health_state = /fcbp/if_glt_config_types=>c_health_state-ok.
    rs_profile-activated_by = sy-uname.
    GET TIME STAMP FIELD rs_profile-activated_at.

    ensure_audit( ).
    DATA(lv_audit_id) = mo_audit->record_config_activation(
      is_change = build_change(
        is_profile = rs_profile
        iv_activity = /fcbp/if_glt_sec_types=>c_event_type-config_activated
        iv_old_hash = lv_old_hash
        iv_new_hash = rs_profile-config_hash )
      is_context = is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_admin~deactivate_target_profile.
    rs_profile = is_profile.
    DATA(lv_old_hash) = rs_profile-config_hash.

    rs_profile-active_flag = abap_false.
    rs_profile-lifecycle_state = /fcbp/if_glt_config_types=>c_lifecycle_state-deactivated.
    rs_profile-changed_by = sy-uname.
    GET TIME STAMP FIELD rs_profile-changed_at.

    ensure_audit( ).
    DATA(lv_audit_id) = mo_audit->record_config_change(
      is_change = build_change(
        is_profile = rs_profile
        iv_activity = /fcbp/if_glt_sec_types=>c_event_type-config_deactivated
        iv_old_hash = lv_old_hash
        iv_new_hash = rs_profile-config_hash )
      is_context = is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_admin~copy_target_profile.
    IF iv_new_target_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = 'GLT_CFG_COPY_TARGET'
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          config_object_key  = is_profile-target_id
          target_id          = is_profile-target_id
          operator_text      = 'New target ID is required when copying a target profile.'.
    ENDIF.

    rs_profile = is_profile.
    rs_profile-target_id = iv_new_target_id.
    rs_profile-active_flag = abap_false.
    rs_profile-lifecycle_state = /fcbp/if_glt_config_types=>c_lifecycle_state-draft.
    rs_profile-health_state = /fcbp/if_glt_config_types=>c_health_state-unknown.
    rs_profile-config_version = 1.
    CLEAR: rs_profile-config_hash,
           rs_profile-activated_by,
           rs_profile-activated_at.
    rs_profile-created_by = sy-uname.
    rs_profile-changed_by = sy-uname.
    GET TIME STAMP FIELD rs_profile-created_at.
    rs_profile-changed_at = rs_profile-created_at.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_admin~create_new_version.
    rs_profile = is_profile.
    rs_profile-active_flag = abap_false.
    rs_profile-lifecycle_state = /fcbp/if_glt_config_types=>c_lifecycle_state-draft.
    rs_profile-health_state = /fcbp/if_glt_config_types=>c_health_state-unknown.
    rs_profile-config_version = rs_profile-config_version + 1.
    CLEAR: rs_profile-config_hash,
           rs_profile-activated_by,
           rs_profile-activated_at.
    rs_profile-changed_by = sy-uname.
    GET TIME STAMP FIELD rs_profile-changed_at.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_admin~display_usage_impact.
    IF iv_target_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = 'GLT_CFG_USAGE_TARGET'
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
          operator_text      = 'Target ID is required for configuration usage impact.'.
    ENDIF.

    "! TODO: Query /FCBP/GLT_POLCTX and package/transfer tables for where-used impact.
    CLEAR rt_context.
  ENDMETHOD.

  METHOD ensure_audit.
    IF mo_audit IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_audit
        EXPORTING
          event_category = /fcbp/if_glt_sec_types=>c_event_category-config
          operator_text  = 'Configuration audit service is required for activation and deactivation.'.
    ENDIF.
  ENDMETHOD.

  METHOD build_change.
    rs_change = VALUE #(
      config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
      config_object_key  = is_profile-target_id
      config_version     = is_profile-config_version
      activity           = iv_activity
      company_code       = is_profile-company_code
      target_id          = is_profile-target_id
      old_value_hash     = iv_old_hash
      new_value_hash     = iv_new_hash
      changed_by         = sy-uname ).
  ENDMETHOD.

ENDCLASS.
