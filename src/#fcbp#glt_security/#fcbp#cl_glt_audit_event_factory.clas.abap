"! Canonical audit event factory for bridge runtime services.
CLASS /fcbp/cl_glt_audit_event_factory DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_audit_event_factory.

  PRIVATE SECTION.
    METHODS base_transfer_event
      IMPORTING
        is_transfer       TYPE /fcbp/if_glt_types=>ty_transfer
        is_context        TYPE /fcbp/if_glt_sec_types=>ty_security_context
        iv_event_category TYPE char30
        iv_event_type     TYPE char30
        iv_event_subtype  TYPE char30 OPTIONAL
        iv_outcome        TYPE char30 OPTIONAL
        iv_evidence_ref   TYPE string OPTIONAL
      RETURNING
        VALUE(rs_event)   TYPE /fcbp/if_glt_types=>ty_audit_event.

ENDCLASS.

CLASS /fcbp/cl_glt_audit_event_factory IMPLEMENTATION.

  METHOD /fcbp/if_glt_audit_event_factory~for_transfer_event.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = iv_event_category
      iv_event_type     = iv_event_type
      iv_event_subtype  = iv_event_subtype
      iv_outcome        = iv_outcome
      iv_evidence_ref   = iv_evidence_ref ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_receive.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-lifecycle
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-receive
      iv_outcome        = 'ACCEPTED' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_duplicate_handoff.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-lifecycle
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-duplicate_handoff
      iv_outcome        = 'DUPLICATE' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_package_created.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-package
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-package_created
      iv_outcome        = 'CREATED'
      iv_evidence_ref   = |GLTPKG:{ iv_package_id }| ).
    rs_event-package_id = iv_package_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_package_rebuilt.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-package
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-package_rebuilt
      iv_outcome        = 'REBUILT'
      iv_evidence_ref   = |GLTPKG:{ iv_package_id }| ).
    rs_event-package_id = iv_package_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_validation_result.
    DATA(lv_event_type) = COND char30(
      WHEN iv_passed = abap_true
      THEN /fcbp/if_glt_sec_types=>c_event_type-validation_passed
      ELSE /fcbp/if_glt_sec_types=>c_event_type-validation_failed ).
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-validation
      iv_event_type     = lv_event_type
      iv_outcome        = lv_event_type ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_mapping_result.
    DATA(lv_event_type) = COND char30(
      WHEN iv_passed = abap_true
      THEN /fcbp/if_glt_sec_types=>c_event_type-mapping_completed
      ELSE /fcbp/if_glt_sec_types=>c_event_type-mapping_failed ).
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-mapping
      iv_event_type     = lv_event_type
      iv_outcome        = lv_event_type ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_submit_started.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-adapter
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-submit_started
      iv_outcome        = 'STARTED'
      iv_evidence_ref   = |GLTATT:{ iv_attempt_id }| ).
    rs_event-attempt_id = iv_attempt_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_submit_accepted.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-adapter
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-submit_accepted
      iv_outcome        = 'ACCEPTED'
      iv_evidence_ref   = |GLTATT:{ iv_attempt_id }| ).
    rs_event-attempt_id = iv_attempt_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_submit_failed.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-adapter
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-submit_failed
      iv_outcome        = 'FAILED'
      iv_evidence_ref   = |GLTATT:{ iv_attempt_id }| ).
    rs_event-attempt_id = iv_attempt_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_posted.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-lifecycle
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-posted
      iv_outcome        = 'POSTED'
      iv_evidence_ref   = |GLTREF:{ iv_ref_id }| ).
    rs_event-ref_id = iv_ref_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_unknown_confirmation.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-retry
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-confirmation_pending
      iv_outcome        = 'PENDING' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_retry_scheduled.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-retry
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-retry_scheduled
      iv_outcome        = 'SCHEDULED' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_retry_exhausted.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-retry
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-retry_exhausted
      iv_outcome        = 'EXHAUSTED' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_status_query.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-operator
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-status_query_requested
      iv_outcome        = 'REQUESTED' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_cancelled.
    rs_event = base_transfer_event(
      is_transfer       = is_transfer
      is_context        = is_context
      iv_event_category = /fcbp/if_glt_sec_types=>c_event_category-lifecycle
      iv_event_type     = /fcbp/if_glt_sec_types=>c_event_type-cancelled
      iv_outcome        = 'CANCELLED' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_config_changed.
    rs_event = VALUE #(
      event_category     = /fcbp/if_glt_sec_types=>c_event_category-config
      event_type         = /fcbp/if_glt_sec_types=>c_event_type-config_changed
      event_subtype      = is_change-activity
      company_code       = is_change-company_code
      target_id          = is_change-target_id
      config_object_type = is_change-config_object_type
      config_object_key  = is_change-config_object_key
      config_version     = is_change-config_version
      decision_outcome   = 'CHANGED'
      actor_type         = is_context-actor_type
      actor_id           = is_context-actor_id
      reason_code        = is_change-reason_code
      old_value_hash     = is_change-old_value_hash
      new_value_hash     = is_change-new_value_hash
      evidence_ref       = |CONFIG:{ is_change-config_object_type }:{ is_change-config_object_key }:{ is_change-config_version }|
      correlation_id     = is_context-correlation_id
      request_id         = is_context-request_id
      criticality        = /fcbp/if_glt_sec_types=>c_criticality-business_critical
      redaction_profile  = is_context-redaction_profile ).
    GET TIME STAMP FIELD rs_event-created_at.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_config_activated.
    rs_event = /fcbp/if_glt_audit_event_factory~for_config_changed(
      is_change  = is_change
      is_context = is_context ).
    rs_event-event_type = /fcbp/if_glt_sec_types=>c_event_type-config_activated.
    rs_event-decision_outcome = 'ACTIVATED'.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_auth_denied.
    rs_event = VALUE #(
      transfer_id      = is_decision-transfer_id
      event_category   = /fcbp/if_glt_sec_types=>c_event_category-security
      event_type       = /fcbp/if_glt_sec_types=>c_event_type-auth_denied_action
      event_subtype    = is_decision-action
      company_code     = is_decision-company_code
      target_id        = is_decision-target_id
      decision_outcome = is_decision-decision_outcome
      actor_type       = is_context-actor_type
      actor_id         = is_context-actor_id
      reason_code      = is_decision-denial_reason
      evidence_ref     = is_decision-evidence_ref
      support_ticket_id = is_context-support_ticket_id
      support_session_id = is_context-support_session_id
      correlation_id   = is_context-correlation_id
      request_id       = is_context-request_id
      criticality      = /fcbp/if_glt_sec_types=>c_criticality-security
      redaction_profile = is_context-redaction_profile ).
    GET TIME STAMP FIELD rs_event-created_at.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_event_factory~for_support_access.
    rs_event = VALUE #(
      transfer_id        = is_scope-transfer_id
      event_category     = /fcbp/if_glt_sec_types=>c_event_category-support
      event_type         = /fcbp/if_glt_sec_types=>c_event_type-support_access
      event_subtype      = iv_outcome
      company_code       = is_scope-company_code
      target_id          = is_scope-target_id
      decision_outcome   = iv_outcome
      actor_type         = is_context-actor_type
      actor_id           = is_context-actor_id
      reason_code        = is_scope-reason_code
      support_ticket_id  = is_scope-support_ticket_id
      support_session_id = is_scope-support_session_id
      correlation_id     = is_context-correlation_id
      request_id         = is_context-request_id
      criticality        = /fcbp/if_glt_sec_types=>c_criticality-security
      redaction_profile  = is_context-redaction_profile ).
    GET TIME STAMP FIELD rs_event-created_at.
  ENDMETHOD.

  METHOD base_transfer_event.
    rs_event = VALUE #(
      transfer_id        = is_transfer-header-transfer_id
      event_category     = iv_event_category
      event_type         = iv_event_type
      event_subtype      = iv_event_subtype
      source_type        = is_transfer-header-source_type
      source_reference   = is_transfer-header-source_ref_id
      company_code       = is_transfer-header-company_code
      target_id          = is_transfer-header-target_id
      routing_bucket     = is_transfer-header-routing_bucket
      package_id         = is_transfer-header-current_package_id
      decision_outcome   = iv_outcome
      actor_type         = is_context-actor_type
      actor_id           = is_context-actor_id
      evidence_ref       = iv_evidence_ref
      correlation_id     = is_context-correlation_id
      request_id         = is_context-request_id
      support_ticket_id  = is_context-support_ticket_id
      support_session_id = is_context-support_session_id
      criticality        = /fcbp/if_glt_sec_types=>c_criticality-business_critical
      redaction_profile  = is_context-redaction_profile ).
    GET TIME STAMP FIELD rs_event-created_at.
  ENDMETHOD.

ENDCLASS.
