"! Validation Layer DTOs and constants for package-level pre-submit validation.
INTERFACE /fcbp/if_glt_val_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_run_status,
      running TYPE char20 VALUE 'RUNNING',
      passed  TYPE char20 VALUE 'PASSED',
      failed  TYPE char20 VALUE 'FAILED',
      blocked TYPE char20 VALUE 'BLOCKED',
      waived  TYPE char20 VALUE 'WAIVED',
    END OF c_run_status.

  CONSTANTS:
    BEGIN OF c_category,
      structural           TYPE char30 VALUE 'STRUCTURAL',
      accounting           TYPE char30 VALUE 'ACCOUNTING',
      traceability         TYPE char30 VALUE 'TRACEABILITY',
      target_compatibility TYPE char30 VALUE 'TARGET_COMPATIBILITY',
      mapping_prereq       TYPE char30 VALUE 'MAPPING_PREREQ',
      operational_state    TYPE char30 VALUE 'OPERATIONAL_STATE',
      security             TYPE char30 VALUE 'SECURITY',
      advisory             TYPE char30 VALUE 'ADVISORY',
    END OF c_category.

  CONSTANTS:
    BEGIN OF c_next_step,
      mapping         TYPE char30 VALUE 'MAPPING',
      operator_action TYPE char30 VALUE 'OPERATOR_ACTION',
      revalidate      TYPE char30 VALUE 'REVALIDATE',
      none            TYPE char30 VALUE 'NONE',
    END OF c_next_step.

  CONSTANTS:
    BEGIN OF c_run_mode,
      dispatch     TYPE char20 VALUE 'DISPATCH',
      rebuild      TYPE char20 VALUE 'REBUILD',
      revalidate   TYPE char20 VALUE 'REVALIDATE',
      health_check TYPE char20 VALUE 'HEALTH_CHECK',
      support      TYPE char20 VALUE 'SUPPORT',
    END OF c_run_mode.

  CONSTANTS:
    BEGIN OF c_remediation_owner,
      source     TYPE char20 VALUE 'SOURCE',
      config     TYPE char20 VALUE 'CONFIG',
      mapping    TYPE char20 VALUE 'MAPPING',
      operations TYPE char20 VALUE 'OPERATIONS',
      support    TYPE char20 VALUE 'SUPPORT',
      security   TYPE char20 VALUE 'SECURITY',
    END OF c_remediation_owner.

  CONSTANTS:
    BEGIN OF c_rule,
      transfer_exists       TYPE char30 VALUE 'GLT_PVAL_001',
      current_package       TYPE char30 VALUE 'GLT_PVAL_002',
      package_owner         TYPE char30 VALUE 'GLT_PVAL_003',
      package_current       TYPE char30 VALUE 'GLT_PVAL_004',
      outdoc_exists         TYPE char30 VALUE 'GLT_PVAL_005',
      outdoc_has_lines      TYPE char30 VALUE 'GLT_PVAL_006',
      positive_amount       TYPE char30 VALUE 'GLT_PVAL_007',
      debit_credit          TYPE char30 VALUE 'GLT_PVAL_008',
      balance               TYPE char30 VALUE 'GLT_PVAL_009',
      currency              TYPE char30 VALUE 'GLT_PVAL_010',
      company_code          TYPE char30 VALUE 'GLT_PVAL_011',
      posting_date          TYPE char30 VALUE 'GLT_PVAL_012',
      gl_account            TYPE char30 VALUE 'GLT_PVAL_013',
      dimensions            TYPE char30 VALUE 'GLT_PVAL_014',
      trace_exists          TYPE char30 VALUE 'GLT_PVAL_015',
      trace_count           TYPE char30 VALUE 'GLT_PVAL_016',
      trace_identity        TYPE char30 VALUE 'GLT_PVAL_017',
      target_profile        TYPE char30 VALUE 'GLT_PVAL_018',
      adapter_compatibility TYPE char30 VALUE 'GLT_PVAL_019',
      confirmation_policy   TYPE char30 VALUE 'GLT_PVAL_020',
      mapping_policy        TYPE char30 VALUE 'GLT_PVAL_021',
      mapping_fields        TYPE char30 VALUE 'GLT_PVAL_022',
      target_reference      TYPE char30 VALUE 'GLT_PVAL_023',
      unknown_work          TYPE char30 VALUE 'GLT_PVAL_024',
      actor_scope           TYPE char30 VALUE 'GLT_PVAL_025',
    END OF c_rule.

  TYPES ty_validation_run_id TYPE char32.

  TYPES: BEGIN OF ty_package_context,
           transfer_id        TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id         TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           policy_context_id  TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           outbox_id          TYPE /fcbp/if_glt_types=>ty_outbox_id,
           jobrun_id          TYPE /fcbp/if_glt_types=>ty_jobrun_id,
           target_id          TYPE char20,
           actor_type         TYPE char12,
           actor_id           TYPE char40,
           allow_warnings     TYPE abap_bool,
           waiver_context_id  TYPE char32,
           run_mode           TYPE char20,
         END OF ty_package_context.

  TYPES: BEGIN OF ty_run,
           validation_run_id      TYPE ty_validation_run_id,
           transfer_id            TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id             TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           policy_context_id      TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           validation_profile_id  TYPE char20,
           validation_profile_version TYPE i,
           validation_hash        TYPE char64,
           started_at             TYPE utclong,
           ended_at               TYPE utclong,
           result_status          TYPE char20,
           blocking_count         TYPE i,
           warning_count          TYPE i,
           actor_type             TYPE char12,
           actor_id               TYPE char40,
           jobrun_id              TYPE /fcbp/if_glt_types=>ty_jobrun_id,
           outbox_id              TYPE /fcbp/if_glt_types=>ty_outbox_id,
           waiver_id              TYPE char32,
           created_at             TYPE utclong,
           created_by             TYPE syuname,
           changed_at             TYPE utclong,
           changed_by             TYPE syuname,
         END OF ty_run.
  TYPES tt_run TYPE STANDARD TABLE OF ty_run WITH EMPTY KEY.

  TYPES: BEGIN OF ty_finding,
           validation_run_id   TYPE ty_validation_run_id,
           finding_seq         TYPE i,
           transfer_id         TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id          TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           outdoc_id           TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id,
           line_no             TYPE numc6,
           field_name          TYPE char40,
           rule_id             TYPE char30,
           rule_category       TYPE char30,
           severity            TYPE char10,
           blocking_flag       TYPE abap_bool,
           message_code        TYPE char40,
           operator_text       TYPE char220,
           technical_detail_ref TYPE string,
           remediation_owner   TYPE char20,
           target_id           TYPE char20,
           policy_version      TYPE i,
           message_id          TYPE /fcbp/if_glt_types=>ty_message_id,
           created_at          TYPE utclong,
           created_by          TYPE syuname,
         END OF ty_finding.
  TYPES tt_finding TYPE STANDARD TABLE OF ty_finding WITH EMPTY KEY.

  TYPES: BEGIN OF ty_package_evidence,
           transfer              TYPE /fcbp/if_glt_types=>ty_transfer,
           package_graph         TYPE /fcbp/if_glt_pkg_types=>ty_package_graph,
           target_profile        TYPE /fcbp/if_glt_config_types=>ty_target_profile,
           policy_context        TYPE /fcbp/if_glt_config_types=>ty_policy_context,
           validation_rules      TYPE /fcbp/if_glt_config_types=>tt_validation_rule,
           target_refs           TYPE /fcbp/if_glt_types=>tt_target_ref,
           attempts              TYPE /fcbp/if_glt_types=>tt_attempt,
           transfer_found        TYPE abap_bool,
           package_found         TYPE abap_bool,
           policy_context_found  TYPE abap_bool,
           target_profile_found  TYPE abap_bool,
         END OF ty_package_evidence.

  TYPES: BEGIN OF ty_result,
           validation_run_id TYPE ty_validation_run_id,
           transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           policy_context_id TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           result_status     TYPE char20,
           passed            TYPE abap_bool,
           blocking_count    TYPE i,
           warning_count     TYPE i,
           findings          TYPE tt_finding,
           messages          TYPE /fcbp/if_glt_types=>tt_message,
           next_allowed_step TYPE char30,
         END OF ty_result.

ENDINTERFACE.
