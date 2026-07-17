"! Outbox Execution shared vocabulary and DTOs.
"! Source: DTS GL Bridge Outbox Execution Layer, Sections 4, 5, 6, and 8.
INTERFACE /fcbp/if_glt_outbox_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_next_action,
      complete              TYPE char30 VALUE 'COMPLETE',
      mark_posted           TYPE char30 VALUE 'MARK_POSTED',
      mark_dispatched       TYPE char30 VALUE 'MARK_DISPATCHED',
      schedule_retry        TYPE char30 VALUE 'SCHEDULE_RETRY',
      schedule_poll         TYPE char30 VALUE 'SCHEDULE_POLL',
      schedule_status_query TYPE char30 VALUE 'SCHEDULE_STATUS_QUERY',
      schedule_rebuild      TYPE char30 VALUE 'SCHEDULE_REBUILD',
      fail_terminal         TYPE char30 VALUE 'FAIL_TERMINAL',
      operator_action       TYPE char30 VALUE 'OPERATOR_ACTION',
      release               TYPE char30 VALUE 'RELEASE',
      supersede             TYPE char30 VALUE 'SUPERSEDE',
      no_op                 TYPE char30 VALUE 'NO_OP',
    END OF c_next_action.

  TYPES: BEGIN OF ty_outbox_claim,
           claimed      TYPE abap_bool,
           outbox_id    TYPE /fcbp/if_glt_types=>ty_outbox_id,
           work         TYPE /fcbp/if_glt_types=>ty_outbox_work,
           claim_owner  TYPE char40,
           claim_token  TYPE char64,
           message_text TYPE char220,
         END OF ty_outbox_claim.

  TYPES: BEGIN OF ty_work_handler_result,
           outbox_id             TYPE /fcbp/if_glt_types=>ty_outbox_id,
           transfer_id           TYPE /fcbp/if_glt_types=>ty_transfer_id,
           next_action           TYPE char30,
           completion_status     TYPE char12,
           status_code           TYPE /fcbp/if_glt_types=>ty_status,
           attempt_id            TYPE /fcbp/if_glt_types=>ty_attempt_id,
           target_ref_id         TYPE /fcbp/if_glt_types=>ty_ref_id,
           error_id              TYPE /fcbp/if_glt_types=>ty_error_id,
           followup_work         TYPE /fcbp/if_glt_types=>ty_outbox_work,
           audit_id              TYPE /fcbp/if_glt_types=>ty_audit_id,
           retry_due_at          TYPE utclong,
           message_text          TYPE char220,
           retryable             TYPE abap_bool,
           unknown_confirmation  TYPE abap_bool,
         END OF ty_work_handler_result.

  TYPES: BEGIN OF ty_outcome_decision,
           next_action              TYPE char30,
           completion_status        TYPE char12,
           status_code              TYPE /fcbp/if_glt_types=>ty_status,
           followup_work_type       TYPE char20,
           followup_due_at          TYPE utclong,
           retryable                TYPE abap_bool,
           unknown_confirmation     TYPE abap_bool,
           operator_action_required TYPE abap_bool,
           message_text             TYPE char220,
         END OF ty_outcome_decision.

  TYPES: BEGIN OF ty_lock_recovery_request,
           target_id           TYPE char20,
           work_type           TYPE char20,
           lock_expired_before TYPE utclong,
           max_items           TYPE i,
           dry_run             TYPE abap_bool,
           actor_id            TYPE char40,
           jobrun_id           TYPE /fcbp/if_glt_types=>ty_jobrun_id,
         END OF ty_lock_recovery_request.

  TYPES: BEGIN OF ty_lock_recovery_result,
           selected_count   TYPE i,
           released_count   TYPE i,
           failed_count     TYPE i,
           skipped_count    TYPE i,
           stale_lock_count TYPE i,
           message_text     TYPE char220,
         END OF ty_lock_recovery_result.

ENDINTERFACE.
