"! Configuration repository over /FCBP/CC_* customizing and /FCBP/GLT_POLCTX evidence.
CLASS /fcbp/cl_glt_config_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_config_repo.

  PRIVATE SECTION.
    METHODS create_id
      IMPORTING
        iv_prefix       TYPE char8
      RETURNING
        VALUE(rv_value) TYPE char32.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

    METHODS raise_config
      IMPORTING
        iv_object_type TYPE char30
        iv_object_key  TYPE char80
        iv_text        TYPE char220
        iv_policy_id   TYPE char20 OPTIONAL
        iv_target_id   TYPE char20 OPTIONAL
      RAISING
        /fcbp/cx_glt_config.

ENDCLASS.

CLASS /fcbp/cl_glt_config_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_config_repo~query_target_profiles.
    DATA(lv_date) = is_scope-resolution_date.
    IF lv_date IS INITIAL.
      lv_date = sy-datum.
    ENDIF.

    SELECT *
      FROM /fcbp/cc_gltgt
      WHERE active_flag = @abap_true
        AND ( lifecycle_state = @/fcbp/if_glt_config_types=>c_lifecycle_state-active OR lifecycle_state = '' )
        AND ( @is_scope-transfer_type IS INITIAL OR transfer_type = @is_scope-transfer_type OR transfer_type = '' )
        AND ( @is_scope-source_system IS INITIAL OR source_system = @is_scope-source_system OR source_system = '' )
        AND ( @is_scope-source_type IS INITIAL OR source_type = @is_scope-source_type OR source_type = '' )
        AND ( @is_scope-company_code IS INITIAL OR company_code = @is_scope-company_code OR company_code = '' )
        AND ( @is_scope-ledger_group IS INITIAL OR ledger_group = @is_scope-ledger_group OR ledger_group = '' )
        AND ( @is_scope-processing_mode IS INITIAL OR processing_mode = @is_scope-processing_mode OR processing_mode = '' )
        AND ( valid_from = '' OR valid_from <= @lv_date )
        AND ( valid_to = '' OR valid_to >= @lv_date )
      ORDER BY priority ASCENDING, target_id ASCENDING
      INTO TABLE @DATA(lt_profile).
    rt_profile = CORRESPONDING #( lt_profile ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_target_profile.
    SELECT SINGLE *
      FROM /fcbp/cc_gltgt
      WHERE target_id = @iv_target_id
      INTO @DATA(ls_profile).
    IF sy-subrc <> 0.
      raise_config(
        iv_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
        iv_object_key  = iv_target_id
        iv_target_id   = iv_target_id
        iv_text        = |Target profile { iv_target_id } was not found.| ).
    ENDIF.
    rs_profile = CORRESPONDING #( ls_profile ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_retry_policy.
    IF iv_version IS INITIAL.
      SELECT *
        FROM /fcbp/cc_glretry
        WHERE retry_policy_id = @iv_policy_id
          AND active_flag = @abap_true
        ORDER BY version DESCENDING
        INTO TABLE @DATA(lt_policy).
      READ TABLE lt_policy INTO DATA(ls_policy) INDEX 1.
    ELSE.
      SELECT SINGLE *
        FROM /fcbp/cc_glretry
        WHERE retry_policy_id = @iv_policy_id
          AND version = @iv_version
        INTO @ls_policy.
    ENDIF.
    IF sy-subrc <> 0.
      raise_config(
        iv_object_type = /fcbp/if_glt_config_types=>c_object_type-retry_policy
        iv_object_key  = iv_policy_id
        iv_policy_id   = iv_policy_id
        iv_text        = |Retry policy { iv_policy_id } was not found.| ).
    ENDIF.
    rs_policy = CORRESPONDING #( ls_policy ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_aggregation_policy.
    IF iv_version IS INITIAL.
      SELECT *
        FROM /fcbp/cc_glaggr
        WHERE aggregation_profile_id = @iv_profile_id
          AND active_flag = @abap_true
        ORDER BY version DESCENDING
        INTO TABLE @DATA(lt_policy).
      READ TABLE lt_policy INTO DATA(ls_policy) INDEX 1.
    ELSE.
      SELECT SINGLE *
        FROM /fcbp/cc_glaggr
        WHERE aggregation_profile_id = @iv_profile_id
          AND version = @iv_version
        INTO @ls_policy.
    ENDIF.
    IF sy-subrc <> 0.
      raise_config(
        iv_object_type = /fcbp/if_glt_config_types=>c_object_type-aggregation_policy
        iv_object_key  = iv_profile_id
        iv_policy_id   = iv_profile_id
        iv_text        = |Aggregation policy { iv_profile_id } was not found.| ).
    ENDIF.
    rs_policy = CORRESPONDING #( ls_policy ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_aggregation_fields.
    DATA(lv_version) = iv_version.
    IF lv_version IS INITIAL.
      DATA(ls_policy) = /fcbp/if_glt_config_repo~read_aggregation_policy( iv_profile_id ).
      lv_version = ls_policy-version.
    ENDIF.

    SELECT *
      FROM /fcbp/cc_glaggrf
      WHERE aggregation_profile_id = @iv_profile_id
        AND version = @lv_version
      ORDER BY field_sequence ASCENDING
      INTO TABLE @DATA(lt_field).
    rt_field = CORRESPONDING #( lt_field ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_split_policy.
    IF iv_version IS INITIAL.
      SELECT *
        FROM /fcbp/cc_glsplit
        WHERE split_profile_id = @iv_profile_id
          AND active_flag = @abap_true
        ORDER BY version DESCENDING
        INTO TABLE @DATA(lt_policy).
      READ TABLE lt_policy INTO DATA(ls_policy) INDEX 1.
    ELSE.
      SELECT SINGLE *
        FROM /fcbp/cc_glsplit
        WHERE split_profile_id = @iv_profile_id
          AND version = @iv_version
        INTO @ls_policy.
    ENDIF.
    IF sy-subrc <> 0.
      raise_config(
        iv_object_type = /fcbp/if_glt_config_types=>c_object_type-split_policy
        iv_object_key  = iv_profile_id
        iv_policy_id   = iv_profile_id
        iv_text        = |Split policy { iv_profile_id } was not found.| ).
    ENDIF.
    rs_policy = CORRESPONDING #( ls_policy ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_validation_rules.
    IF iv_version IS INITIAL.
      SELECT *
        FROM /fcbp/cc_glval
        WHERE validation_profile_id = @iv_profile_id
          AND active_flag = @abap_true
        ORDER BY rule_id ASCENDING, version DESCENDING
        INTO TABLE @DATA(lt_rule).
    ELSE.
      SELECT *
        FROM /fcbp/cc_glval
        WHERE validation_profile_id = @iv_profile_id
          AND version = @iv_version
        ORDER BY rule_id ASCENDING
        INTO TABLE @lt_rule.
    ENDIF.
    rt_rule = CORRESPONDING #( lt_rule ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_mapping_rules.
    IF iv_version IS INITIAL.
      SELECT *
        FROM /fcbp/cc_glmap
        WHERE mapping_policy_id = @iv_policy_id
          AND active_flag = @abap_true
        ORDER BY priority ASCENDING, mapping_rule_id ASCENDING, version DESCENDING
        INTO TABLE @DATA(lt_rule).
    ELSE.
      SELECT *
        FROM /fcbp/cc_glmap
        WHERE mapping_policy_id = @iv_policy_id
          AND version = @iv_version
        ORDER BY priority ASCENDING, mapping_rule_id ASCENDING
        INTO TABLE @lt_rule.
    ENDIF.
    rt_rule = CORRESPONDING #( lt_rule ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_throttle_policy.
    IF iv_version IS INITIAL.
      SELECT *
        FROM /fcbp/cc_glthrot
        WHERE throttle_policy_id = @iv_policy_id
          AND active_flag = @abap_true
        ORDER BY version DESCENDING
        INTO TABLE @DATA(lt_policy).
      READ TABLE lt_policy INTO DATA(ls_policy) INDEX 1.
    ELSE.
      SELECT SINGLE *
        FROM /fcbp/cc_glthrot
        WHERE throttle_policy_id = @iv_policy_id
          AND version = @iv_version
        INTO @ls_policy.
    ENDIF.
    IF sy-subrc <> 0.
      raise_config(
        iv_object_type = /fcbp/if_glt_config_types=>c_object_type-throttle_policy
        iv_object_key  = iv_policy_id
        iv_policy_id   = iv_policy_id
        iv_text        = |Throttle policy { iv_policy_id } was not found.| ).
    ENDIF.
    rs_policy = CORRESPONDING #( ls_policy ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_confirmation_policy.
    IF iv_version IS INITIAL.
      SELECT *
        FROM /fcbp/cc_glconf
        WHERE confirmation_policy_id = @iv_policy_id
          AND active_flag = @abap_true
        ORDER BY version DESCENDING
        INTO TABLE @DATA(lt_policy).
      READ TABLE lt_policy INTO DATA(ls_policy) INDEX 1.
    ELSE.
      SELECT SINGLE *
        FROM /fcbp/cc_glconf
        WHERE confirmation_policy_id = @iv_policy_id
          AND version = @iv_version
        INTO @ls_policy.
    ENDIF.
    IF sy-subrc <> 0.
      raise_config(
        iv_object_type = /fcbp/if_glt_config_types=>c_object_type-confirmation_policy
        iv_object_key  = iv_policy_id
        iv_policy_id   = iv_policy_id
        iv_text        = |Confirmation policy { iv_policy_id } was not found.| ).
    ENDIF.
    rs_policy = CORRESPONDING #( ls_policy ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~insert_policy_context.
    DATA(ls_context) = is_context.
    IF ls_context-policy_context_id IS INITIAL.
      ls_context-policy_context_id = create_id( 'PCTX' ).
    ENDIF.
    IF ls_context-resolved_at IS INITIAL.
      ls_context-resolved_at = now( ).
    ENDIF.
    IF ls_context-resolved_by IS INITIAL.
      ls_context-resolved_by = sy-uname.
    ENDIF.

    INSERT /fcbp/glt_polctx FROM @ls_context.
    IF sy-subrc <> 0.
      raise_config(
        iv_object_type = /fcbp/if_glt_config_types=>c_object_type-policy_context
        iv_object_key  = ls_context-policy_context_id
        iv_target_id   = ls_context-target_id
        iv_text        = |Policy context { ls_context-policy_context_id } could not be inserted.| ).
    ENDIF.
    rv_context_id = ls_context-policy_context_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_policy_context.
    SELECT SINGLE *
      FROM /fcbp/glt_polctx
      WHERE policy_context_id = @iv_context_id
      INTO @DATA(ls_context).
    IF sy-subrc <> 0.
      raise_config(
        iv_object_type = /fcbp/if_glt_config_types=>c_object_type-policy_context
        iv_object_key  = iv_context_id
        iv_text        = |Policy context { iv_context_id } was not found.| ).
    ENDIF.
    rs_context = CORRESPONDING #( ls_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~insert_health_finding.
    DATA(ls_finding) = is_finding.
    IF ls_finding-health_run_id IS INITIAL.
      ls_finding-health_run_id = create_id( 'HLTH' ).
    ENDIF.
    IF ls_finding-check_id IS INITIAL.
      ls_finding-check_id = 'UNSPECIFIED'.
    ENDIF.
    IF ls_finding-checked_at IS INITIAL.
      ls_finding-checked_at = now( ).
    ENDIF.
    IF ls_finding-checked_by IS INITIAL.
      ls_finding-checked_by = sy-uname.
    ENDIF.

    INSERT /fcbp/glt_cfghlth FROM @ls_finding.
    IF sy-subrc <> 0.
      raise_config(
        iv_object_type = ls_finding-config_object_type
        iv_object_key  = ls_finding-config_object_key
        iv_target_id   = ls_finding-target_id
        iv_text        = |Configuration health finding { ls_finding-check_id } could not be inserted.| ).
    ENDIF.
  ENDMETHOD.

  METHOD create_id.
    TRY.
        rv_value = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        rv_value = |{ iv_prefix }{ sy-datum }{ sy-uzeit }|.
    ENDTRY.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

  METHOD raise_config.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_config
      EXPORTING
        config_object_type = iv_object_type
        config_object_key  = iv_object_key
        target_id          = iv_target_id
        policy_id          = iv_policy_id
        error_category     = /fcbp/if_glt_types=>c_error_category-config
        reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-missing
        operator_text      = iv_text.
  ENDMETHOD.

ENDCLASS.
