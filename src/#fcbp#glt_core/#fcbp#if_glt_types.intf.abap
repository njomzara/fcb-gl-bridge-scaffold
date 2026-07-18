"! Transfer Core shared vocabulary and runtime contracts.
"! Source: DTS GL Bridge Transfer Core Layer, Sections 4, 6, 8, 9, 12, and 13.
INTERFACE /fcbp/if_glt_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_source_type,
      posting   TYPE char20 VALUE 'POSTING',
      recon_key TYPE char20 VALUE 'RECONCILIATION_KEY',
      document  TYPE char20 VALUE 'DOCUMENT',
      reversal  TYPE char20 VALUE 'REVERSAL',
      event     TYPE char20 VALUE 'EVENT',
      batch     TYPE char20 VALUE 'BATCH',
    END OF c_source_type.

  CONSTANTS:
    BEGIN OF c_processing_mode,
      realtime TYPE char10 VALUE 'REALTIME',
      batch    TYPE char10 VALUE 'BATCH',
    END OF c_processing_mode.

  CONSTANTS:
    BEGIN OF c_status,
      received             TYPE char24 VALUE 'RECEIVED',
      validating           TYPE char24 VALUE 'VALIDATING',
      validation_failed    TYPE char24 VALUE 'VALIDATION_FAILED',
      ready                TYPE char24 VALUE 'READY',
      processing           TYPE char24 VALUE 'PROCESSING',
      dispatched           TYPE char24 VALUE 'DISPATCHED',
      posted               TYPE char24 VALUE 'POSTED',
      failed_retryable     TYPE char24 VALUE 'FAILED_RETRYABLE',
      unknown_confirmation TYPE char24 VALUE 'UNKNOWN_CONFIRMATION',
      failed_final         TYPE char24 VALUE 'FAILED_FINAL',
      reprocess_requested  TYPE char24 VALUE 'REPROCESS_REQUESTED',
      cancelled            TYPE char24 VALUE 'CANCELLED',
      reversed             TYPE char24 VALUE 'REVERSED',
    END OF c_status.

  CONSTANTS:
    BEGIN OF c_ext_status,
      received TYPE char10 VALUE 'RECEIVED',
      failed   TYPE char10 VALUE 'FAILED',
      posted   TYPE char10 VALUE 'POSTED',
    END OF c_ext_status.

  CONSTANTS:
    BEGIN OF c_severity,
      info    TYPE char10 VALUE 'INFO',
      warning TYPE char10 VALUE 'WARNING',
      error   TYPE char10 VALUE 'ERROR',
    END OF c_severity.

  CONSTANTS:
    BEGIN OF c_error_category,
      validation           TYPE char24 VALUE 'VALIDATION',
      config               TYPE char24 VALUE 'CONFIG',
      duplicate            TYPE char24 VALUE 'DUPLICATE',
      conflict             TYPE char24 VALUE 'CONFLICT',
      adapter_business     TYPE char24 VALUE 'ADAPTER_BUSINESS',
      adapter_technical    TYPE char24 VALUE 'ADAPTER_TECHNICAL',
      unknown_confirmation TYPE char24 VALUE 'UNKNOWN_CONFIRMATION',
      repository           TYPE char24 VALUE 'REPOSITORY',
      authorization        TYPE char24 VALUE 'AUTHORIZATION',
      lock                 TYPE char24 VALUE 'LOCK',
      technical            TYPE char24 VALUE 'TECHNICAL',
    END OF c_error_category.

  CONSTANTS:
    BEGIN OF c_adapter_outcome,
      posted               TYPE char24 VALUE 'POSTED',
      dispatched           TYPE char24 VALUE 'DISPATCHED',
      retryable_failure    TYPE char24 VALUE 'RETRYABLE_FAILURE',
      final_failure        TYPE char24 VALUE 'FINAL_FAILURE',
      unknown_confirmation TYPE char24 VALUE 'UNKNOWN_CONFIRMATION',
      not_found            TYPE char24 VALUE 'NOT_FOUND',
      unsupported          TYPE char24 VALUE 'UNSUPPORTED',
    END OF c_adapter_outcome.

  CONSTANTS:
    BEGIN OF c_idemp_status,
      reserved  TYPE char12 VALUE 'RESERVED',
      active    TYPE char12 VALUE 'ACTIVE',
      completed TYPE char12 VALUE 'COMPLETED',
      failed    TYPE char12 VALUE 'FAILED',
      expired   TYPE char12 VALUE 'EXPIRED',
    END OF c_idemp_status.

  CONSTANTS:
    BEGIN OF c_idemp_decision,
      created   TYPE char12 VALUE 'CREATED',
      duplicate TYPE char12 VALUE 'DUPLICATE',
      conflict  TYPE char12 VALUE 'CONFLICT',
      in_flight TYPE char12 VALUE 'IN_FLIGHT',
    END OF c_idemp_decision.

  CONSTANTS:
    BEGIN OF c_retry_type,
      dispatch     TYPE char20 VALUE 'DISPATCH',
      retry        TYPE char20 VALUE 'RETRY',
      status_query TYPE char20 VALUE 'STATUS_QUERY',
      reprocess    TYPE char20 VALUE 'REPROCESS',
    END OF c_retry_type.

  CONSTANTS:
    BEGIN OF c_retry_status,
      due        TYPE char12 VALUE 'DUE',
      claimed    TYPE char12 VALUE 'CLAIMED',
      completed  TYPE char12 VALUE 'COMPLETED',
      exhausted  TYPE char12 VALUE 'EXHAUSTED',
      cancelled  TYPE char12 VALUE 'CANCELLED',
    END OF c_retry_status.

  CONSTANTS:
    BEGIN OF c_reg_status,
      reserved    TYPE char12 VALUE 'RESERVED',
      active      TYPE char12 VALUE 'ACTIVE',
      duplicate   TYPE char12 VALUE 'DUPLICATE',
      failed      TYPE char12 VALUE 'FAILED',
      superseded  TYPE char12 VALUE 'SUPERSEDED',
      in_progress TYPE char12 VALUE 'IN_PROGRESS',
    END OF c_reg_status.

  CONSTANTS:
    BEGIN OF c_outbox_work_type,
      dispatch     TYPE char20 VALUE 'DISPATCH',
      retry        TYPE char20 VALUE 'RETRY',
      rebuild      TYPE char20 VALUE 'REBUILD',
      poll         TYPE char20 VALUE 'POLL',
      status_query TYPE char20 VALUE 'STATUS_QUERY',
    END OF c_outbox_work_type.

  CONSTANTS:
    BEGIN OF c_outbox_status,
      open       TYPE char12 VALUE 'OPEN',
      in_process TYPE char12 VALUE 'IN_PROCESS',
      done       TYPE char12 VALUE 'DONE',
      failed     TYPE char12 VALUE 'FAILED',
      cancelled  TYPE char12 VALUE 'CANCELLED',
      superseded TYPE char12 VALUE 'SUPERSEDED',
    END OF c_outbox_status.

  CONSTANTS:
    BEGIN OF c_monitor_action,
      request_reprocess        TYPE char30 VALUE 'REQUEST_REPROCESS',
      query_status             TYPE char30 VALUE 'QUERY_STATUS',
      cancel_transfer          TYPE char30 VALUE 'CANCEL_TRANSFER',
      retry_now                TYPE char30 VALUE 'RETRY_NOW',
      rebuild_after_correction TYPE char30 VALUE 'REBUILD_AFTER_CORRECTION',
      mark_duplicate_resolved  TYPE char30 VALUE 'MARK_DUPLICATE_RESOLVED',
    END OF c_monitor_action.

  CONSTANTS:
    BEGIN OF c_attempt_type,
      submit       TYPE char20 VALUE 'SUBMIT',
      status_query TYPE char20 VALUE 'STATUS_QUERY',
      poll         TYPE char20 VALUE 'POLL',
      retry        TYPE char20 VALUE 'RETRY',
      rebuild      TYPE char20 VALUE 'REBUILD',
    END OF c_attempt_type.

  CONSTANTS:
    BEGIN OF c_attempt_outcome,
      started  TYPE char20 VALUE 'STARTED',
      succeeded TYPE char20 VALUE 'SUCCEEDED',
      failed   TYPE char20 VALUE 'FAILED',
      unknown  TYPE char20 VALUE 'UNKNOWN',
    END OF c_attempt_outcome.

  CONSTANTS:
    BEGIN OF c_job_status,
      running   TYPE char12 VALUE 'RUNNING',
      completed TYPE char12 VALUE 'COMPLETED',
      failed    TYPE char12 VALUE 'FAILED',
      partial   TYPE char12 VALUE 'PARTIAL',
      cancelled TYPE char12 VALUE 'CANCELLED',
    END OF c_job_status.

  CONSTANTS:
    BEGIN OF c_lock_status,
      free    TYPE char10 VALUE 'FREE',
      locked  TYPE char10 VALUE 'LOCKED',
      expired TYPE char10 VALUE 'EXPIRED',
    END OF c_lock_status.

  CONSTANTS:
    BEGIN OF c_internal_state,
      new                  TYPE char25 VALUE 'NEW',
      prepared             TYPE char25 VALUE 'PREPARED',
      validated            TYPE char25 VALUE 'VALIDATED',
      submitted            TYPE char25 VALUE 'SUBMITTED',
      prepare_error        TYPE char25 VALUE 'PREPARE_ERROR',
      validation_error     TYPE char25 VALUE 'VALIDATION_ERROR',
      submit_error         TYPE char25 VALUE 'SUBMIT_ERROR',
      unknown_confirmation TYPE char25 VALUE 'UNKNOWN_CONFIRMATION',
      functional_rejected  TYPE char25 VALUE 'FUNCTIONAL_REJECTED',
      transferred          TYPE char25 VALUE 'TRANSFERRED',
    END OF c_internal_state.

  CONSTANTS:
    BEGIN OF c_actor_type,
      system   TYPE char12 VALUE 'SYSTEM',
      job      TYPE char12 VALUE 'JOB',
      user     TYPE char12 VALUE 'USER',
      adapter  TYPE char12 VALUE 'ADAPTER',
      support  TYPE char12 VALUE 'SUPPORT',
    END OF c_actor_type.

  CONSTANTS:
    BEGIN OF c_confirmation_mode,
      sync_confirm TYPE char20 VALUE 'SYNC_CONFIRM',
      async_query  TYPE char20 VALUE 'ASYNC_QUERY',
      export_only  TYPE char20 VALUE 'EXPORT_ONLY',
    END OF c_confirmation_mode.

  TYPES ty_transfer_id TYPE char32.
  TYPES ty_error_id TYPE char32.
  TYPES ty_retry_id TYPE char32.
  TYPES ty_ref_id TYPE char32.
  TYPES ty_audit_id TYPE char32.
  TYPES ty_message_id TYPE char32.
  TYPES ty_attempt_id TYPE char32.
  TYPES ty_jobrun_id TYPE char32.
  TYPES ty_status TYPE char24.
  TYPES ty_ext_status TYPE char10.
  TYPES ty_request_hash TYPE char64.
  TYPES ty_idempotency_key TYPE char64.
  TYPES ty_correlation_id TYPE char64.
  TYPES ty_registration_key TYPE char64.
  TYPES ty_outbox_id TYPE char32.
  TYPES ty_event_id TYPE char32.

  TYPES: BEGIN OF ty_header,
           transfer_id       TYPE ty_transfer_id,
           transfer_type     TYPE char20,
           source_system     TYPE char30,
           source_type       TYPE char20,
           source_ref_id     TYPE char50,
           source_doc_no     TYPE char20,
           reconciliation_key TYPE char32,
           bus_event_id      TYPE char50,
           bus_event_ver     TYPE numc6,
           source_registration_key TYPE ty_registration_key,
           routing_bucket    TYPE char32,
           target_id         TYPE char20,
           processing_mode   TYPE char10,
           company_code      TYPE char4,
           posting_date      TYPE dats,
           document_date     TYPE dats,
           currency          TYPE c LENGTH 5,
           total_debit_amt   TYPE p LENGTH 16 DECIMALS 2,
           total_credit_amt  TYPE p LENGTH 16 DECIMALS 2,
           external_corr_id  TYPE char80,
           correlation_id    TYPE ty_correlation_id,
           idempotency_key   TYPE ty_idempotency_key,
           request_hash      TYPE ty_request_hash,
           status_code       TYPE ty_status,
           external_status   TYPE ty_ext_status,
           internal_state    TYPE char25,
           retry_count       TYPE i,
           max_retry_count   TYPE i,
           last_error_id     TYPE ty_error_id,
           target_system     TYPE char30,
           target_adapter    TYPE char30,
           current_package_id TYPE char32,
           confirmation_pending TYPE abap_bool,
           operator_action_required TYPE abap_bool,
           lock_owner        TYPE char40,
           lock_until        TYPE utclong,
           created_by        TYPE syuname,
           created_at        TYPE utclong,
           changed_by        TYPE syuname,
           changed_at        TYPE utclong,
           version_no        TYPE i,
         END OF ty_header.

  TYPES: BEGIN OF ty_item,
           transfer_id   TYPE ty_transfer_id,
           item_no       TYPE numc6,
           source_line_id TYPE char50,
           gl_account    TYPE char10,
           debit_credit  TYPE char1,
           amount        TYPE p LENGTH 16 DECIMALS 2,
           currency      TYPE c LENGTH 5,
           company_code  TYPE char4,
           profit_center TYPE char10,
           cost_center   TYPE char10,
           segment       TYPE char10,
           tax_code      TYPE char2,
           assignment    TYPE char18,
           item_text     TYPE char50,
           source_hash   TYPE char64,
           line_hash     TYPE char64,
           created_at    TYPE utclong,
         END OF ty_item.
  TYPES tt_item TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

  TYPES: BEGIN OF ty_message,
           rule_id       TYPE char20,
           severity      TYPE char10,
           blocking      TYPE abap_bool,
           entity_name   TYPE char30,
           field_name    TYPE char30,
           item_no       TYPE numc6,
           msgid         TYPE symsgid,
           msgno         TYPE symsgno,
           msgv1         TYPE symsgv,
           msgv2         TYPE symsgv,
           msgv3         TYPE symsgv,
           msgv4         TYPE symsgv,
           operator_text TYPE char220,
         END OF ty_message.
  TYPES tt_message TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.

  TYPES: BEGIN OF ty_error,
           error_id             TYPE ty_error_id,
           transfer_id          TYPE ty_transfer_id,
           item_no              TYPE numc6,
           severity             TYPE char10,
           category             TYPE char24,
           retryable            TYPE abap_bool,
           unknown_confirmation TYPE abap_bool,
           msgid                TYPE symsgid,
           msgno                TYPE symsgno,
           msgv1                TYPE symsgv,
           msgv2                TYPE symsgv,
           msgv3                TYPE symsgv,
           msgv4                TYPE symsgv,
           operator_text        TYPE char220,
           technical_ref        TYPE string,
           created_at           TYPE utclong,
           created_by           TYPE syuname,
         END OF ty_error.
  TYPES tt_error TYPE STANDARD TABLE OF ty_error WITH EMPTY KEY.

  TYPES: BEGIN OF ty_monitor_message,
           message_id    TYPE ty_message_id,
           transfer_id   TYPE ty_transfer_id,
           error_id      TYPE ty_error_id,
           severity      TYPE char10,
           category      TYPE char24,
           msgid         TYPE symsgid,
           msgno         TYPE symsgno,
           msgv1         TYPE symsgv,
           msgv2         TYPE symsgv,
           msgv3         TYPE symsgv,
           msgv4         TYPE symsgv,
           operator_text TYPE char220,
           context_ref   TYPE char255,
           created_at    TYPE utclong,
           created_by    TYPE syuname,
         END OF ty_monitor_message.
  TYPES tt_monitor_message TYPE STANDARD TABLE OF ty_monitor_message WITH EMPTY KEY.

  TYPES: BEGIN OF ty_status_row,
           transfer_id         TYPE ty_transfer_id,
           seq_no              TYPE i,
           old_status_code     TYPE ty_status,
           new_status_code     TYPE ty_status,
           old_external_status TYPE ty_ext_status,
           new_external_status TYPE ty_ext_status,
           reason_code         TYPE char30,
           error_id            TYPE ty_error_id,
           attempt_no          TYPE i,
           actor_type          TYPE char12,
           actor_id            TYPE char40,
           correlation_id      TYPE ty_correlation_id,
           created_at          TYPE utclong,
         END OF ty_status_row.
  TYPES tt_status_row TYPE STANDARD TABLE OF ty_status_row WITH EMPTY KEY.

  TYPES: BEGIN OF ty_target_ref,
           ref_id              TYPE ty_ref_id,
           transfer_id         TYPE ty_transfer_id,
           target_system       TYPE char30,
           target_adapter      TYPE char30,
           target_doc_no       TYPE char30,
           target_company_code TYPE char4,
           target_fiscal_year  TYPE numc4,
           target_corr_id      TYPE char64,
           confirmation_mode   TYPE char20,
           confirmed_at        TYPE utclong,
           raw_ref_hash        TYPE char64,
           created_at          TYPE utclong,
         END OF ty_target_ref.
  TYPES tt_target_ref TYPE STANDARD TABLE OF ty_target_ref WITH EMPTY KEY.

  TYPES: BEGIN OF ty_attempt,
           attempt_id              TYPE ty_attempt_id,
           transfer_id             TYPE ty_transfer_id,
           outbox_id               TYPE ty_outbox_id,
           jobrun_id               TYPE ty_jobrun_id,
           attempt_no              TYPE i,
           attempt_type            TYPE char20,
           package_id              TYPE char32,
           outdoc_id               TYPE char32,
           policy_context_id       TYPE char32,
           target_system           TYPE char30,
           target_adapter          TYPE char30,
           destination_alias       TYPE char40,
           correlation_id          TYPE ty_correlation_id,
           idempotency_key_hash    TYPE char64,
           middleware_message_id   TYPE char80,
           target_status_handle    TYPE char80,
           outcome                 TYPE char20,
           retryable               TYPE abap_bool,
           unknown_confirmation    TYPE abap_bool,
           request_hash            TYPE char64,
           response_hash           TYPE char64,
           raw_request_ref         TYPE string,
           raw_response_ref        TYPE string,
           error_id                TYPE ty_error_id,
           started_at              TYPE utclong,
           finished_at             TYPE utclong,
           created_by              TYPE syuname,
         END OF ty_attempt.
  TYPES tt_attempt TYPE STANDARD TABLE OF ty_attempt WITH EMPTY KEY.

  TYPES: BEGIN OF ty_jobrun,
           jobrun_id       TYPE ty_jobrun_id,
           job_name        TYPE char40,
           job_type        TYPE char30,
           status_code     TYPE char12,
           target_id       TYPE char20,
           selected_count  TYPE i,
           processed_count TYPE i,
           success_count   TYPE i,
           failed_count    TYPE i,
           actor_id        TYPE char40,
           message_text    TYPE char220,
           started_at      TYPE utclong,
           finished_at     TYPE utclong,
         END OF ty_jobrun.
  TYPES tt_jobrun TYPE STANDARD TABLE OF ty_jobrun WITH EMPTY KEY.

  TYPES: BEGIN OF ty_retry,
           retry_id       TYPE ty_retry_id,
           transfer_id    TYPE ty_transfer_id,
           attempt_no     TYPE i,
           retry_type     TYPE char20,
           status_code    TYPE char12,
           due_at         TYPE utclong,
           lock_owner     TYPE char40,
           lock_until     TYPE utclong,
           last_error_id  TYPE ty_error_id,
           max_attempts   TYPE i,
           created_at     TYPE utclong,
           changed_at     TYPE utclong,
         END OF ty_retry.
  TYPES tt_retry TYPE STANDARD TABLE OF ty_retry WITH EMPTY KEY.

  TYPES: BEGIN OF ty_audit_event,
           audit_id       TYPE ty_audit_id,
           transfer_id    TYPE ty_transfer_id,
           event_type     TYPE char30,
           event_subtype  TYPE char30,
           event_category TYPE char30,
           source_type    TYPE char20,
           source_reference TYPE char50,
           company_code   TYPE char4,
           target_id      TYPE char20,
           routing_bucket TYPE char32,
           package_id     TYPE char32,
           outbox_id      TYPE ty_outbox_id,
           attempt_id     TYPE ty_attempt_id,
           ref_id         TYPE ty_ref_id,
           jobrun_id      TYPE ty_jobrun_id,
           config_object_type TYPE char30,
           config_object_key TYPE char80,
           config_version TYPE char20,
           support_ticket_id TYPE char40,
           support_session_id TYPE char40,
           correlation_id TYPE ty_correlation_id,
           request_id     TYPE char64,
           decision_outcome TYPE char30,
           actor_type     TYPE char12,
           actor_id       TYPE char40,
           reason_code    TYPE char30,
           message_id     TYPE char32,
           old_value_hash TYPE char64,
           new_value_hash TYPE char64,
           evidence_ref   TYPE string,
           retention_class TYPE char20,
           legal_hold     TYPE abap_bool,
           criticality    TYPE char20,
           redaction_profile TYPE char30,
           created_at     TYPE utclong,
         END OF ty_audit_event.
  TYPES tt_audit_event TYPE STANDARD TABLE OF ty_audit_event WITH EMPTY KEY.

  TYPES: BEGIN OF ty_registration,
           registration_key          TYPE ty_registration_key,
           source_type               TYPE char20,
           source_reference          TYPE char50,
           source_doc_no             TYPE char20,
           reconciliation_key        TYPE char32,
           event_type                TYPE char30,
           event_id                  TYPE char50,
           routing_bucket            TYPE char32,
           target_id                 TYPE char20,
           processing_mode           TYPE char10,
           transfer_id               TYPE ty_transfer_id,
           registration_status       TYPE char12,
           reserved_by               TYPE char40,
           reserved_at               TYPE utclong,
           completed_at              TYPE utclong,
           expires_at                TYPE utclong,
           duplicate_of_transfer_id  TYPE ty_transfer_id,
           last_error_code           TYPE char40,
           created_at                TYPE utclong,
           changed_at                TYPE utclong,
         END OF ty_registration.
  TYPES tt_registration TYPE STANDARD TABLE OF ty_registration WITH EMPTY KEY.

  TYPES: BEGIN OF ty_reg_decision,
           decision             TYPE char12,
           registration_key     TYPE ty_registration_key,
           transfer_id          TYPE ty_transfer_id,
           registration_status  TYPE char12,
           already_registered   TYPE abap_bool,
           in_progress          TYPE abap_bool,
           conflict             TYPE abap_bool,
           message              TYPE char255,
         END OF ty_reg_decision.

  TYPES: BEGIN OF ty_route_context,
           routing_bucket       TYPE char32,
           target_id            TYPE char20,
           target_type          TYPE char30,
           target_system        TYPE char30,
           target_adapter       TYPE char30,
           transfer_mode        TYPE char10,
           confirmation_mode    TYPE char20,
           priority             TYPE i,
           retry_profile        TYPE char30,
           policy_reference     TYPE char80,
         END OF ty_route_context.

  TYPES: BEGIN OF ty_outbox_work,
           outbox_id          TYPE ty_outbox_id,
           transfer_id        TYPE ty_transfer_id,
           work_type          TYPE char20,
           due_at             TYPE utclong,
           priority           TYPE i,
           target_id          TYPE char20,
           processing_mode    TYPE char10,
           processing_status  TYPE char12,
           lock_status        TYPE char10,
           lock_owner         TYPE char40,
           locked_at          TYPE utclong,
           lock_until         TYPE utclong,
           attempt_no         TYPE i,
           created_at         TYPE utclong,
           created_by         TYPE syuname,
         END OF ty_outbox_work.
  TYPES tt_outbox_work TYPE STANDARD TABLE OF ty_outbox_work WITH EMPTY KEY.

  TYPES: BEGIN OF ty_handoff_request,
           source_type          TYPE char20,
           source_reference     TYPE char50,
           source_doc_no        TYPE char20,
           reconciliation_key   TYPE char32,
           event_type           TYPE char30,
           event_id             TYPE char50,
           company_code         TYPE char4,
           ledger_group         TYPE char10,
           processing_mode      TYPE char10,
           requested_by         TYPE char40,
           requested_at         TYPE utclong,
           external_corr_id     TYPE char80,
           source_payload_hash  TYPE char64,
           routing_hint         TYPE char40,
         END OF ty_handoff_request.

  TYPES: BEGIN OF ty_handoff_result,
           transfer_id          TYPE ty_transfer_id,
           registration_key     TYPE ty_registration_key,
           already_registered   TYPE abap_bool,
           registration_status  TYPE char12,
           external_status      TYPE ty_ext_status,
           internal_state       TYPE char25,
           target_id            TYPE char20,
           routing_bucket       TYPE char32,
           message              TYPE char255,
         END OF ty_handoff_result.

  TYPES: BEGIN OF ty_config,
           transfer_type           TYPE char20,
           active                  TYPE abap_bool,
           description             TYPE char80,
           balance_required        TYPE abap_bool,
           period_check_mode       TYPE char20,
           default_max_retry       TYPE i,
           default_backoff_sec     TYPE i,
           allow_manual_reprocess  TYPE abap_bool,
           redaction_profile       TYPE char30,
           valid_from              TYPE dats,
           valid_to                TYPE dats,
           changed_by              TYPE syuname,
           changed_at              TYPE utclong,
         END OF ty_config.

  TYPES: BEGIN OF ty_route,
           route_id           TYPE char30,
           transfer_type      TYPE char20,
           source_system      TYPE char30,
           company_code       TYPE char4,
           target_system      TYPE char30,
           target_adapter     TYPE char30,
           priority           TYPE i,
           active             TYPE abap_bool,
           confirmation_mode  TYPE char20,
           retry_profile      TYPE char30,
           feature_switch_set TYPE char80,
           valid_from         TYPE dats,
           valid_to           TYPE dats,
           changed_by         TYPE syuname,
           changed_at         TYPE utclong,
         END OF ty_route.
  TYPES tt_route TYPE STANDARD TABLE OF ty_route WITH EMPTY KEY.

  TYPES: BEGIN OF ty_request,
           header TYPE ty_header,
           items  TYPE tt_item,
         END OF ty_request.

  TYPES: BEGIN OF ty_transfer,
           header      TYPE ty_header,
           items       TYPE tt_item,
           statuses    TYPE tt_status_row,
           errors      TYPE tt_error,
           target_refs TYPE tt_target_ref,
         END OF ty_transfer.
  TYPES tt_transfer TYPE STANDARD TABLE OF ty_transfer WITH EMPTY KEY.

  TYPES: BEGIN OF ty_result,
           transfer_id      TYPE ty_transfer_id,
           status_code      TYPE ty_status,
           external_status  TYPE ty_ext_status,
           duplicate        TYPE abap_bool,
           conflict         TYPE abap_bool,
           target_ref       TYPE ty_target_ref,
           messages         TYPE tt_message,
         END OF ty_result.

  TYPES: BEGIN OF ty_status_result,
           transfer_id       TYPE ty_transfer_id,
           status_code       TYPE ty_status,
           external_status   TYPE ty_ext_status,
           correlation_id    TYPE ty_correlation_id,
           idempotency_key   TYPE ty_idempotency_key,
           last_error_id     TYPE ty_error_id,
           target_refs       TYPE tt_target_ref,
         END OF ty_status_result.

  TYPES: BEGIN OF ty_adapter_result,
           outcome              TYPE char24,
           retryable            TYPE abap_bool,
           unknown_confirmation TYPE abap_bool,
           target_ref           TYPE ty_target_ref,
           error                TYPE ty_error,
           response_hash        TYPE char64,
           raw_request_ref      TYPE string,
           raw_response_ref     TYPE string,
           target_message_code  TYPE char40,
           target_message_text_safe TYPE char220,
           http_status          TYPE i,
           protocol_category    TYPE char30,
           middleware_message_id TYPE char80,
           target_correlation_id TYPE ty_correlation_id,
           idempotency_status   TYPE char30,
           capability_used      TYPE char80,
           confirmed_at         TYPE utclong,
           query_handle_type    TYPE char30,
         END OF ty_adapter_result.

  TYPES: BEGIN OF ty_idemp_reservation,
           idempotency_key TYPE ty_idempotency_key,
           transfer_type   TYPE char20,
           source_system   TYPE char30,
           request_hash    TYPE ty_request_hash,
           transfer_id     TYPE ty_transfer_id,
           reserved_by     TYPE syuname,
           expires_at      TYPE utclong,
         END OF ty_idemp_reservation.

  TYPES: BEGIN OF ty_idemp_decision,
           decision          TYPE char12,
           idempotency_key   TYPE ty_idempotency_key,
           transfer_id       TYPE ty_transfer_id,
           status_code       TYPE ty_status,
           external_status   TYPE ty_ext_status,
           existing_hash     TYPE ty_request_hash,
           duplicate         TYPE abap_bool,
           conflict          TYPE abap_bool,
         END OF ty_idemp_decision.

  TYPES: BEGIN OF ty_reprocess_request,
           transfer_id    TYPE ty_transfer_id,
           reason_code    TYPE char30,
           reason_text    TYPE char220,
           override       TYPE abap_bool,
           status_query   TYPE abap_bool,
         END OF ty_reprocess_request.

  TYPES: BEGIN OF ty_monitor_action_request,
           transfer_id TYPE ty_transfer_id,
           action_id   TYPE char30,
           reason_code TYPE char30,
           reason_text TYPE char220,
           override    TYPE abap_bool,
         END OF ty_monitor_action_request.

  TYPES: BEGIN OF ty_monitor_action_result,
           transfer_id     TYPE ty_transfer_id,
           action_id       TYPE char30,
           accepted        TYPE abap_bool,
           status_code     TYPE ty_status,
           external_status TYPE ty_ext_status,
           outbox_id       TYPE ty_outbox_id,
           audit_id        TYPE ty_audit_id,
           message         TYPE char255,
         END OF ty_monitor_action_result.

  TYPES: BEGIN OF ty_monitor_filter,
           transfer_id              TYPE ty_transfer_id,
           external_status          TYPE ty_ext_status,
           status_code              TYPE ty_status,
           internal_state           TYPE char25,
           source_type              TYPE char20,
           source_ref_id            TYPE char50,
           target_id                TYPE char20,
           company_code             TYPE char4,
           created_from             TYPE dats,
           created_to               TYPE dats,
           confirmation_pending     TYPE abap_bool,
           operator_action_required TYPE abap_bool,
         END OF ty_monitor_filter.

  TYPES: BEGIN OF ty_recon_filter,
           transfer_id      TYPE ty_transfer_id,
           source_system    TYPE char30,
           source_type      TYPE char20,
           source_ref_id    TYPE char50,
           target_doc_no    TYPE char30,
           target_corr_id   TYPE char64,
           idempotency_key  TYPE ty_idempotency_key,
           company_code     TYPE char4,
           posting_date_from TYPE dats,
           posting_date_to   TYPE dats,
           status_code       TYPE ty_status,
         END OF ty_recon_filter.

ENDINTERFACE.
