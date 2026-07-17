"! Converts raw Application Job parameters into a typed Job Layer context.
CLASS /fcbp/cl_glt_job_context_builder DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_parameter       TYPE /fcbp/if_glt_job_types=>tt_job_parameter
      RETURNING
        VALUE(rs_context)  TYPE /fcbp/if_glt_job_types=>ty_job_context
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    METHODS read_param
      IMPORTING
        it_parameter      TYPE /fcbp/if_glt_job_types=>tt_job_parameter
        iv_name           TYPE char40
      RETURNING
        VALUE(rv_value)   TYPE char120.

    METHODS parse_bool
      IMPORTING
        iv_value        TYPE char120
      RETURNING
        VALUE(rv_value) TYPE abap_bool.

    METHODS parse_int
      IMPORTING
        iv_value        TYPE char120
        iv_parameter    TYPE char40
      RETURNING
        VALUE(rv_value) TYPE i
      RAISING
        /fcbp/cx_glt_error.

    METHODS apply_defaults
      CHANGING
        cs_context TYPE /fcbp/if_glt_job_types=>ty_job_context.

    METHODS validate
      IMPORTING
        is_context TYPE /fcbp/if_glt_job_types=>ty_job_context
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_job_context_builder IMPLEMENTATION.

  METHOD build.
    rs_context-job_name            = read_param( it_parameter = it_parameter iv_name = 'JOB_NAME' ).
    rs_context-job_type            = read_param( it_parameter = it_parameter iv_name = 'JOB_TYPE' ).
    rs_context-trigger_type        = read_param( it_parameter = it_parameter iv_name = 'TRIGGER_TYPE' ).
    rs_context-actor_id            = read_param( it_parameter = it_parameter iv_name = 'ACTOR_ID' ).
    rs_context-correlation_id      = read_param( it_parameter = it_parameter iv_name = 'CORRELATION_ID' ).
    rs_context-target_id           = read_param( it_parameter = it_parameter iv_name = 'TARGET_ID' ).
    rs_context-source_system       = read_param( it_parameter = it_parameter iv_name = 'SOURCE_SYSTEM' ).
    rs_context-source_type         = read_param( it_parameter = it_parameter iv_name = 'SOURCE_TYPE' ).
    rs_context-source_reference    = read_param( it_parameter = it_parameter iv_name = 'SOURCE_REFERENCE' ).
    rs_context-source_doc_no       = read_param( it_parameter = it_parameter iv_name = 'SOURCE_DOC_NO' ).
    rs_context-reconciliation_key  = read_param( it_parameter = it_parameter iv_name = 'RECONCILIATION_KEY' ).
    rs_context-event_type          = read_param( it_parameter = it_parameter iv_name = 'EVENT_TYPE' ).
    rs_context-event_id            = read_param( it_parameter = it_parameter iv_name = 'EVENT_ID' ).
    rs_context-company_code        = read_param( it_parameter = it_parameter iv_name = 'COMPANY_CODE' ).
    rs_context-ledger_group        = read_param( it_parameter = it_parameter iv_name = 'LEDGER_GROUP' ).
    rs_context-fiscal_year         = read_param( it_parameter = it_parameter iv_name = 'FISCAL_YEAR' ).
    rs_context-posting_period      = read_param( it_parameter = it_parameter iv_name = 'POSTING_PERIOD' ).
    rs_context-date_from           = read_param( it_parameter = it_parameter iv_name = 'DATE_FROM' ).
    rs_context-date_to             = read_param( it_parameter = it_parameter iv_name = 'DATE_TO' ).
    rs_context-transfer_id         = read_param( it_parameter = it_parameter iv_name = 'TRANSFER_ID' ).
    rs_context-package_id          = read_param( it_parameter = it_parameter iv_name = 'PACKAGE_ID' ).
    rs_context-outbox_id           = read_param( it_parameter = it_parameter iv_name = 'OUTBOX_ID' ).
    rs_context-policy_context_id   = read_param( it_parameter = it_parameter iv_name = 'POLICY_CONTEXT_ID' ).
    rs_context-work_type           = read_param( it_parameter = it_parameter iv_name = 'WORK_TYPE' ).
    rs_context-retry_type          = read_param( it_parameter = it_parameter iv_name = 'RETRY_TYPE' ).
    rs_context-processing_mode     = read_param( it_parameter = it_parameter iv_name = 'PROCESSING_MODE' ).
    rs_context-reason_code         = read_param( it_parameter = it_parameter iv_name = 'REASON_CODE' ).
    rs_context-approval_reference  = read_param( it_parameter = it_parameter iv_name = 'APPROVAL_REFERENCE' ).
    rs_context-selection_mode      = read_param( it_parameter = it_parameter iv_name = 'SELECTION_MODE' ).
    rs_context-retention_mode      = read_param( it_parameter = it_parameter iv_name = 'RETENTION_MODE' ).
    rs_context-action_mode         = read_param( it_parameter = it_parameter iv_name = 'ACTION_MODE' ).
    rs_context-health_mode         = read_param( it_parameter = it_parameter iv_name = 'HEALTH_MODE' ).
    rs_context-rule_profile        = read_param( it_parameter = it_parameter iv_name = 'RULE_PROFILE' ).
    rs_context-mapping_profile     = read_param( it_parameter = it_parameter iv_name = 'MAPPING_PROFILE' ).
    rs_context-policy_family       = read_param( it_parameter = it_parameter iv_name = 'POLICY_FAMILY' ).

    DATA(lv_due_before) = read_param( it_parameter = it_parameter iv_name = 'DUE_BEFORE' ).
    IF lv_due_before IS NOT INITIAL.
      rs_context-due_before = lv_due_before.
    ENDIF.

    rs_context-max_items           = parse_int( iv_value = read_param( it_parameter = it_parameter iv_name = 'MAX_ITEMS' ) iv_parameter = 'MAX_ITEMS' ).
    rs_context-max_scopes          = parse_int( iv_value = read_param( it_parameter = it_parameter iv_name = 'MAX_SCOPES' ) iv_parameter = 'MAX_SCOPES' ).
    rs_context-max_runtime_seconds = parse_int( iv_value = read_param( it_parameter = it_parameter iv_name = 'MAX_RUNTIME_SECONDS' ) iv_parameter = 'MAX_RUNTIME_SECONDS' ).
    rs_context-max_attempts        = parse_int( iv_value = read_param( it_parameter = it_parameter iv_name = 'MAX_ATTEMPTS' ) iv_parameter = 'MAX_ATTEMPTS' ).
    rs_context-priority_max        = parse_int( iv_value = read_param( it_parameter = it_parameter iv_name = 'PRIORITY_MAX' ) iv_parameter = 'PRIORITY_MAX' ).

    rs_context-fail_fast          = parse_bool( read_param( it_parameter = it_parameter iv_name = 'FAIL_FAST' ) ).
    rs_context-dry_run            = parse_bool( read_param( it_parameter = it_parameter iv_name = 'DRY_RUN' ) ).
    rs_context-immediate_dispatch = parse_bool( read_param( it_parameter = it_parameter iv_name = 'IMMEDIATE_DISPATCH' ) ).
    rs_context-persist_findings   = parse_bool( read_param( it_parameter = it_parameter iv_name = 'PERSIST_FINDINGS' ) ).

    apply_defaults( CHANGING cs_context = rs_context ).
    validate( rs_context ).
  ENDMETHOD.

  METHOD read_param.
    LOOP AT it_parameter INTO DATA(ls_parameter).
      DATA(lv_name) = ls_parameter-name.
      TRANSLATE lv_name TO UPPER CASE.
      IF lv_name = iv_name.
        rv_value = ls_parameter-value.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD parse_bool.
    DATA(lv_value) = iv_value.
    TRANSLATE lv_value TO UPPER CASE.
    rv_value = xsdbool(
      lv_value = 'X'
      OR lv_value = 'TRUE'
      OR lv_value = 'ABAP_TRUE'
      OR lv_value = '1'
      OR lv_value = 'Y'
      OR lv_value = 'YES' ).
  ENDMETHOD.

  METHOD parse_int.
    IF iv_value IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        rv_value = CONV i( iv_value ).
      CATCH cx_sy_conversion_no_number cx_sy_conversion_overflow INTO DATA(lx_conversion).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_error
          EXPORTING
            error_category      = /fcbp/if_glt_types=>c_error_category-config
            operator_text       = |Job parameter { iv_parameter } must be numeric.|
            technical_reference = lx_conversion->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD apply_defaults.
    IF cs_context-job_type IS INITIAL.
      cs_context-job_type = /fcbp/if_glt_job_types=>c_job_type-dispatch_due_work.
    ENDIF.

    IF cs_context-job_name IS INITIAL.
      cs_context-job_name = cs_context-job_type.
    ENDIF.

    IF cs_context-trigger_type IS INITIAL.
      cs_context-trigger_type = /fcbp/if_glt_job_types=>c_trigger_type-scheduled.
    ENDIF.

    IF cs_context-actor_id IS INITIAL.
      cs_context-actor_id = sy-uname.
    ENDIF.

    IF cs_context-processing_mode IS INITIAL.
      cs_context-processing_mode = /fcbp/if_glt_types=>c_processing_mode-realtime.
    ENDIF.

    IF cs_context-work_type IS INITIAL.
      CASE cs_context-job_type.
        WHEN /fcbp/if_glt_job_types=>c_job_type-retry_due_work.
          cs_context-work_type = /fcbp/if_glt_types=>c_outbox_work_type-retry.
        WHEN /fcbp/if_glt_job_types=>c_job_type-poll_confirmation.
          cs_context-work_type = /fcbp/if_glt_types=>c_outbox_work_type-poll.
        WHEN /fcbp/if_glt_job_types=>c_job_type-status_query.
          cs_context-work_type = /fcbp/if_glt_types=>c_outbox_work_type-status_query.
        WHEN OTHERS.
          cs_context-work_type = /fcbp/if_glt_types=>c_outbox_work_type-dispatch.
      ENDCASE.
    ENDIF.

    IF cs_context-due_before IS INITIAL.
      GET TIME STAMP FIELD cs_context-due_before.
    ENDIF.

    IF cs_context-max_items IS INITIAL.
      cs_context-max_items = 100.
    ENDIF.

    IF cs_context-max_scopes IS INITIAL.
      cs_context-max_scopes = cs_context-max_items.
    ENDIF.

    IF cs_context-selection_mode IS INITIAL.
      cs_context-selection_mode = /fcbp/if_glt_job_types=>c_selection_mode-explicit_scope.
    ENDIF.

    IF cs_context-job_type = /fcbp/if_glt_job_types=>c_job_type-retention
       AND cs_context-retention_mode IS INITIAL.
      cs_context-retention_mode = /fcbp/if_glt_job_types=>c_retention_mode-dry_run.
      cs_context-dry_run = abap_true.
    ENDIF.

    IF cs_context-job_type = /fcbp/if_glt_job_types=>c_job_type-registration_recovery
       AND cs_context-action_mode IS INITIAL.
      cs_context-dry_run = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD validate.
    IF is_context-max_items < 0 OR is_context-max_scopes < 0.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = 'Job item and scope limits must not be negative.'.
    ENDIF.

    IF is_context-date_from IS NOT INITIAL
       AND is_context-date_to IS NOT INITIAL
       AND is_context-date_from > is_context-date_to.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = 'Job date_from must not be after date_to.'.
    ENDIF.

    IF is_context-job_type = /fcbp/if_glt_job_types=>c_job_type-package_rebuild
       AND is_context-dry_run = abap_false
       AND ( is_context-reason_code IS INITIAL OR is_context-approval_reference IS INITIAL ).
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = 'Productive package rebuild requires reason code and approval reference.'.
    ENDIF.

    IF is_context-job_type = /fcbp/if_glt_job_types=>c_job_type-retention
       AND is_context-dry_run = abap_false
       AND is_context-approval_reference IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = 'Productive retention requires approval reference.'.
    ENDIF.

    IF is_context-job_type = /fcbp/if_glt_job_types=>c_job_type-adapter_health
       AND is_context-target_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = 'Adapter health job requires target ID.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
