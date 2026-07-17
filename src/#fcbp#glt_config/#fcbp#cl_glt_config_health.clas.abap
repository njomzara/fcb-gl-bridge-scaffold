"! Configuration health checks for target profile activation and runtime resolution.
CLASS /fcbp/cl_glt_config_health DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_config_health.

    METHODS constructor
      IMPORTING
        io_repository         TYPE REF TO /fcbp/if_glt_config_repo OPTIONAL
        io_adapter_capability TYPE REF TO /fcbp/if_glt_adapter_capability OPTIONAL
        io_agsp_check         TYPE REF TO /fcbp/if_glt_agsp_config_check OPTIONAL
        io_val_health         TYPE REF TO /fcbp/if_glt_val_health OPTIONAL
        io_map_health         TYPE REF TO /fcbp/if_glt_map_health OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_config_repo.
    DATA mo_adapter_capability TYPE REF TO /fcbp/if_glt_adapter_capability.
    DATA mo_agsp_check TYPE REF TO /fcbp/if_glt_agsp_config_check.
    DATA mo_val_health TYPE REF TO /fcbp/if_glt_val_health.
    DATA mo_map_health TYPE REF TO /fcbp/if_glt_map_health.

    METHODS add_finding
      IMPORTING
        iv_target_id          TYPE char20
        iv_config_object_type TYPE char30
        iv_config_object_key  TYPE char80
        iv_check_id           TYPE char30
        iv_severity           TYPE char10
        iv_blocking           TYPE abap_bool
        iv_code               TYPE char40
        iv_text               TYPE char220
      CHANGING
        ct_finding            TYPE /fcbp/if_glt_config_types=>tt_health_finding.

ENDCLASS.

CLASS /fcbp/cl_glt_config_health IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    IF io_adapter_capability IS BOUND.
      mo_adapter_capability = io_adapter_capability.
    ELSE.
      mo_adapter_capability = NEW /fcbp/cl_glt_adapter_capability( ).
    ENDIF.
    IF io_agsp_check IS BOUND.
      mo_agsp_check = io_agsp_check.
    ELSE.
      mo_agsp_check = NEW /fcbp/cl_glt_agsp_config_check( ).
    ENDIF.
    IF io_val_health IS BOUND.
      mo_val_health = io_val_health.
    ELSE.
      mo_val_health = NEW /fcbp/cl_glt_val_health( ).
    ENDIF.
    IF io_map_health IS BOUND.
      mo_map_health = io_map_health.
    ELSE.
      mo_map_health = NEW /fcbp/cl_glt_map_health( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_health~check_target_profile.
    IF is_profile-target_id IS INITIAL.
      add_finding(
        EXPORTING iv_target_id = is_profile-target_id
                  iv_config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
                  iv_config_object_key = is_profile-target_id
                  iv_check_id = 'GLT_CFG_001'
                  iv_severity = /fcbp/if_glt_types=>c_severity-error
                  iv_blocking = abap_true
                  iv_code = 'TARGET_ID_MISSING'
                  iv_text = 'Target ID is required.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF is_profile-target_type IS INITIAL OR is_profile-adapter_type IS INITIAL.
      add_finding(
        EXPORTING iv_target_id = is_profile-target_id
                  iv_config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
                  iv_config_object_key = is_profile-target_id
                  iv_check_id = 'GLT_CFG_003'
                  iv_severity = /fcbp/if_glt_types=>c_severity-error
                  iv_blocking = abap_true
                  iv_code = 'ADAPTER_MISSING'
                  iv_text = 'Target type and adapter type are required.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF is_profile-target_type <> /fcbp/if_glt_config_types=>c_target_type-mock AND
       is_profile-destination_alias IS INITIAL.
      add_finding(
        EXPORTING iv_target_id = is_profile-target_id
                  iv_config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
                  iv_config_object_key = is_profile-target_id
                  iv_check_id = 'GLT_CFG_004'
                  iv_severity = /fcbp/if_glt_types=>c_severity-error
                  iv_blocking = abap_true
                  iv_code = 'DESTINATION_MISSING'
                  iv_text = 'Destination alias is required for non-mock targets.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF is_profile-confirmation_mode IS INITIAL OR is_profile-transfer_mode IS INITIAL.
      add_finding(
        EXPORTING iv_target_id = is_profile-target_id
                  iv_config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
                  iv_config_object_key = is_profile-target_id
                  iv_check_id = 'GLT_CFG_005'
                  iv_severity = /fcbp/if_glt_types=>c_severity-error
                  iv_blocking = abap_true
                  iv_code = 'MODE_MISSING'
                  iv_text = 'Transfer and confirmation modes are required.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF is_profile-config_hash IS INITIAL AND is_profile-active_flag = abap_true.
      add_finding(
        EXPORTING iv_target_id = is_profile-target_id
                  iv_config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
                  iv_config_object_key = is_profile-target_id
                  iv_check_id = 'GLT_CFG_010'
                  iv_severity = /fcbp/if_glt_types=>c_severity-error
                  iv_blocking = abap_true
                  iv_code = 'HASH_MISSING'
                  iv_text = 'Active target profile requires a configuration hash.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF mo_adapter_capability IS BOUND.
      DATA(lt_adapter_finding) = mo_adapter_capability->validate_profile( is_profile ).
      APPEND LINES OF lt_adapter_finding TO rt_finding.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_health~check_effective_context.
    rt_finding = /fcbp/if_glt_config_health~check_target_profile( is_context-target_profile ).

    IF is_context-target_profile-health_state <> /fcbp/if_glt_config_types=>c_health_state-ok.
      add_finding(
        EXPORTING iv_target_id = is_context-target_profile-target_id
                  iv_config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
                  iv_config_object_key = is_context-target_profile-target_id
                  iv_check_id = 'GLT_RES_004'
                  iv_severity = /fcbp/if_glt_types=>c_severity-error
                  iv_blocking = abap_true
                  iv_code = 'PROFILE_UNHEALTHY'
                  iv_text = 'Selected target profile is not healthy.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF is_context-confirmation_policy-unknown_behavior = 'RETRY'.
      add_finding(
        EXPORTING iv_target_id = is_context-target_profile-target_id
                  iv_config_object_type = /fcbp/if_glt_config_types=>c_object_type-confirmation_policy
                  iv_config_object_key = is_context-target_profile-confirmation_policy_id
                  iv_check_id = 'GLT_CFG_019'
                  iv_severity = /fcbp/if_glt_types=>c_severity-error
                  iv_blocking = abap_true
                  iv_code = 'BLIND_RETRY_FOR_UNKNOWN'
                  iv_text = 'Unknown-confirmation behavior must not allow blind retry.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF mo_agsp_check IS BOUND.
      DATA(lt_agsp_finding) = mo_agsp_check->validate_effective_context( is_context ).
      APPEND LINES OF lt_agsp_finding TO rt_finding.
    ENDIF.

    IF mo_val_health IS BOUND.
      DATA(lt_val_finding) = mo_val_health->validate_effective_context( is_context ).
      APPEND LINES OF lt_val_finding TO rt_finding.
    ENDIF.

    IF mo_map_health IS BOUND.
      DATA(lt_map_finding) = mo_map_health->validate_effective_context( is_context ).
      APPEND LINES OF lt_map_finding TO rt_finding.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_health~assert_healthy.
    LOOP AT it_finding INTO DATA(ls_finding) WHERE blocking_flag = abap_true.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-unhealthy
          config_object_type = ls_finding-config_object_type
          config_object_key  = ls_finding-config_object_key
          target_id          = ls_finding-target_id
          operator_text      = ls_finding-operator_text.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_finding.
    DATA(ls_finding) = VALUE /fcbp/if_glt_config_types=>ty_health_finding(
      health_run_id      = |HLT-{ sy-datum }-{ sy-uzeit }|
      target_id          = iv_target_id
      config_object_type = iv_config_object_type
      config_object_key  = iv_config_object_key
      check_id           = iv_check_id
      severity           = iv_severity
      blocking_flag      = iv_blocking
      finding_code       = iv_code
      operator_text      = iv_text
      checked_by         = sy-uname ).
    GET TIME STAMP FIELD ls_finding-checked_at.
    APPEND ls_finding TO ct_finding.
  ENDMETHOD.

ENDCLASS.
