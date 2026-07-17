"! Mapping Layer DTOs and constants for target-normalized canonical journals.
INTERFACE /fcbp/if_glt_map_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_result_status,
      pending    TYPE char20 VALUE 'PENDING',
      mapped     TYPE char20 VALUE 'MAPPED',
      failed     TYPE char20 VALUE 'FAILED',
      replayed   TYPE char20 VALUE 'REPLAYED',
      superseded TYPE char20 VALUE 'SUPERSEDED',
    END OF c_result_status.

  CONSTANTS:
    BEGIN OF c_decision_type,
      map          TYPE char20 VALUE 'MAP',
      mapped       TYPE char20 VALUE 'MAPPED',
      derive       TYPE char20 VALUE 'DERIVE',
      derived      TYPE char20 VALUE 'DERIVED',
      clear        TYPE char20 VALUE 'CLEAR',
      cleared      TYPE char20 VALUE 'CLEARED',
      truncate     TYPE char20 VALUE 'TRUNCATE',
      truncated    TYPE char20 VALUE 'TRUNCATED',
      reject       TYPE char20 VALUE 'REJECT',
      rejected     TYPE char20 VALUE 'REJECTED',
      pass_through TYPE char20 VALUE 'PASS_THROUGH',
    END OF c_decision_type.

  CONSTANTS:
    BEGIN OF c_next_step,
      adapter         TYPE char30 VALUE 'ADAPTER',
      operator_action TYPE char30 VALUE 'OPERATOR_ACTION',
      remap           TYPE char30 VALUE 'REMAP',
      rebuild         TYPE char30 VALUE 'REBUILD',
      none            TYPE char30 VALUE 'NONE',
    END OF c_next_step.

  CONSTANTS:
    BEGIN OF c_run_mode,
      dispatch TYPE char20 VALUE 'DISPATCH',
      rebuild  TYPE char20 VALUE 'REBUILD',
      retry    TYPE char20 VALUE 'RETRY',
      remap    TYPE char20 VALUE 'REMAP',
      support  TYPE char20 VALUE 'SUPPORT',
    END OF c_run_mode.

  CONSTANTS:
    BEGIN OF c_field,
      company_code      TYPE char40 VALUE 'COMPANY_CODE',
      gl_doc_type       TYPE char40 VALUE 'GL_DOC_TYPE',
      gl_account        TYPE char40 VALUE 'GL_ACCOUNT',
      chart_of_accounts TYPE char40 VALUE 'CHART_OF_ACCOUNTS',
      ledger_group      TYPE char40 VALUE 'LEDGER_GROUP',
      profit_center     TYPE char40 VALUE 'PROFIT_CENTER',
      cost_center       TYPE char40 VALUE 'COST_CENTER',
      segment           TYPE char40 VALUE 'SEGMENT',
      internal_order    TYPE char40 VALUE 'INTERNAL_ORDER',
      trading_partner   TYPE char40 VALUE 'TRADING_PARTNER',
      tax_code          TYPE char40 VALUE 'TAX_CODE',
      assignment        TYPE char40 VALUE 'ASSIGNMENT',
      item_text         TYPE char40 VALUE 'ITEM_TEXT',
      header_text       TYPE char40 VALUE 'HEADER_TEXT',
      reference         TYPE char40 VALUE 'REFERENCE',
    END OF c_field.

  TYPES ty_mapping_event_id TYPE char32.

  TYPES: BEGIN OF ty_context,
           transfer_id        TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id         TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           policy_context_id  TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           validation_run_id  TYPE /fcbp/if_glt_val_types=>ty_validation_run_id,
           target_id          TYPE char20,
           mapping_policy_id  TYPE char20,
           mapping_version    TYPE i,
           mapping_hash       TYPE char64,
           outbox_id          TYPE /fcbp/if_glt_types=>ty_outbox_id,
           jobrun_id          TYPE /fcbp/if_glt_types=>ty_jobrun_id,
           actor_type         TYPE char12,
           actor_id           TYPE char40,
           run_mode           TYPE char20,
           mapping_rules      TYPE /fcbp/if_glt_config_types=>tt_mapping_rule,
         END OF ty_context.

  TYPES: BEGIN OF ty_canonical_journal,
           transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           target_id         TYPE char20,
           policy_context_id TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           correlation_id    TYPE /fcbp/if_glt_types=>ty_correlation_id,
           idempotency_key   TYPE /fcbp/if_glt_types=>ty_idempotency_key,
           outdocs           TYPE /fcbp/if_glt_pkg_types=>tt_outdoc,
           canonical_lines   TYPE /fcbp/if_glt_pkg_types=>tt_canonical_line,
           source_trace      TYPE /fcbp/if_glt_pkg_types=>tt_source_trace,
         END OF ty_canonical_journal.

  TYPES: BEGIN OF ty_field_context,
           transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           outdoc_id         TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id,
           line_no           TYPE numc6,
           target_id         TYPE char20,
           mapping_policy_id TYPE char20,
           mapping_version   TYPE i,
           mapping_hash      TYPE char64,
           field_name        TYPE char40,
           source_value      TYPE string,
           required          TYPE abap_bool,
           max_length        TYPE i,
         END OF ty_field_context.

  TYPES: BEGIN OF ty_decision,
           field_context     TYPE ty_field_context,
           rule_id           TYPE char30,
           rule_version      TYPE i,
           config_hash       TYPE char64,
           decision_type     TYPE char20,
           result_status     TYPE char20,
           source_value      TYPE string,
           target_value      TYPE string,
           blocking          TYPE abap_bool,
           warning           TYPE abap_bool,
           message_code      TYPE char40,
           operator_text     TYPE char220,
         END OF ty_decision.

  TYPES: BEGIN OF ty_event,
           mapping_event_id      TYPE ty_mapping_event_id,
           transfer_id           TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id            TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           outdoc_id             TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id,
           line_no               TYPE numc6,
           field_name            TYPE char40,
           source_value_hash     TYPE char64,
           source_value_safe     TYPE char80,
           target_value_hash     TYPE char64,
           target_value_safe     TYPE char80,
           target_id             TYPE char20,
           mapping_policy_id     TYPE char20,
           mapping_policy_version TYPE i,
           mapping_hash          TYPE char64,
           rule_id               TYPE char30,
           rule_version          TYPE i,
           decision_type         TYPE char20,
           result_status         TYPE char20,
           message_id            TYPE /fcbp/if_glt_types=>ty_message_id,
           operator_text         TYPE char220,
           created_at            TYPE utclong,
           created_by            TYPE syuname,
         END OF ty_event.
  TYPES tt_event TYPE STANDARD TABLE OF ty_event WITH EMPTY KEY.

  TYPES: BEGIN OF ty_result,
           transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           policy_context_id TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           mapping_run_id    TYPE char32,
           mapped_journal    TYPE ty_canonical_journal,
           events            TYPE tt_event,
           messages          TYPE /fcbp/if_glt_types=>tt_message,
           result_status     TYPE char20,
           blocking_count    TYPE i,
           warning_count     TYPE i,
           next_allowed_step TYPE char30,
           mapping_hash      TYPE char64,
         END OF ty_result.

ENDINTERFACE.
