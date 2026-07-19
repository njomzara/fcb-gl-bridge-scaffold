"! Builds the five evidence objects required by a successful handoff.
CLASS /fcbp/cl_glt_handoff_factory DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS create_registration
      IMPORTING
        is_request           TYPE /fcbp/if_glt_types=>ty_handoff_request
        is_route_context     TYPE /fcbp/if_glt_types=>ty_route_context
        iv_registration_key  TYPE /fcbp/if_glt_types=>ty_registration_key
      RETURNING
        VALUE(rs_registration) TYPE /fcbp/if_glt_types=>ty_registration.

    METHODS create_header
      IMPORTING
        is_request           TYPE /fcbp/if_glt_types=>ty_handoff_request
        is_route_context     TYPE /fcbp/if_glt_types=>ty_route_context
        iv_registration_key  TYPE /fcbp/if_glt_types=>ty_registration_key
      RETURNING
        VALUE(rs_header)     TYPE /fcbp/if_glt_types=>ty_header.

    METHODS create_initial_status
      IMPORTING
        is_header            TYPE /fcbp/if_glt_types=>ty_header
      RETURNING
        VALUE(rs_status)     TYPE /fcbp/if_glt_types=>ty_status_row.

    METHODS create_outbox
      IMPORTING
        is_header            TYPE /fcbp/if_glt_types=>ty_header
        is_route_context     TYPE /fcbp/if_glt_types=>ty_route_context
      RETURNING
        VALUE(rs_work)       TYPE /fcbp/if_glt_types=>ty_outbox_work.

    METHODS create_audit_event
      IMPORTING
        is_request           TYPE /fcbp/if_glt_types=>ty_handoff_request
        is_header            TYPE /fcbp/if_glt_types=>ty_header
        is_route_context     TYPE /fcbp/if_glt_types=>ty_route_context
        iv_outcome           TYPE char30
      RETURNING
        VALUE(rs_event)      TYPE /fcbp/if_glt_types=>ty_audit_event.

    METHODS create_result
      IMPORTING
        is_header              TYPE /fcbp/if_glt_types=>ty_header
        iv_registration_key    TYPE /fcbp/if_glt_types=>ty_registration_key
        iv_registration_status TYPE char12
        iv_already_registered  TYPE abap_bool DEFAULT abap_false
        iv_message             TYPE char255 OPTIONAL
      RETURNING
        VALUE(rs_result)       TYPE /fcbp/if_glt_types=>ty_handoff_result.

  PRIVATE SECTION.
    METHODS next_id
      IMPORTING
        iv_prefix       TYPE char8
      RETURNING
        VALUE(rv_value) TYPE char32.

    METHODS actor
      IMPORTING
        is_request       TYPE /fcbp/if_glt_types=>ty_handoff_request
      RETURNING
        VALUE(rv_actor)  TYPE char40.

ENDCLASS.

CLASS /fcbp/cl_glt_handoff_factory IMPLEMENTATION.

  METHOD create_registration.
    DATA(lv_actor) = actor( is_request ).
    rs_registration-registration_key   = iv_registration_key.
    rs_registration-source_type        = is_request-source_type.
    rs_registration-source_reference   = is_request-source_reference.
    rs_registration-source_doc_no      = is_request-source_doc_no.
    rs_registration-reconciliation_key = is_request-reconciliation_key.
    rs_registration-event_type         = is_request-event_type.
    rs_registration-event_id           = is_request-event_id.
    rs_registration-routing_bucket     = is_route_context-routing_bucket.
    rs_registration-target_id          = is_route_context-target_id.
    rs_registration-processing_mode    = is_request-processing_mode.
    rs_registration-registration_status = /fcbp/if_glt_types=>c_reg_status-reserved.
    rs_registration-reserved_by        = lv_actor.
    rs_registration-created_at         = is_request-requested_at.
    rs_registration-changed_at         = is_request-requested_at.
  ENDMETHOD.

  METHOD create_header.
    DATA(lv_actor) = actor( is_request ).
    rs_header-transfer_id             = next_id( 'TRF' ).
    rs_header-transfer_type           = is_request-event_type.
    IF rs_header-transfer_type IS INITIAL.
      rs_header-transfer_type = 'SOURCE_HANDOFF'.
    ENDIF.
    rs_header-source_system           = 'FCBP'.
    rs_header-source_type             = is_request-source_type.
    rs_header-source_ref_id           = is_request-source_reference.
    rs_header-source_doc_no           = is_request-source_doc_no.
    rs_header-reconciliation_key      = is_request-reconciliation_key.
    rs_header-bus_event_id            = is_request-event_id.
    rs_header-source_registration_key = iv_registration_key.
    rs_header-routing_bucket          = is_route_context-routing_bucket.
    rs_header-target_id               = is_route_context-target_id.
    rs_header-processing_mode         = is_request-processing_mode.
    rs_header-company_code            = is_request-company_code.
    " Accounting facts remain initial until source reading/package preparation
    " supplies durable source evidence. Handoff must not manufacture them.
    rs_header-external_corr_id        = is_request-external_corr_id.
    rs_header-correlation_id          = next_id( 'CORR' ).
    rs_header-idempotency_key         = iv_registration_key.
    rs_header-request_hash            = is_request-source_payload_hash.
    IF rs_header-request_hash IS INITIAL.
      rs_header-request_hash = iv_registration_key.
    ENDIF.
    rs_header-status_code             = /fcbp/if_glt_types=>c_status-received.
    rs_header-external_status         = /fcbp/if_glt_types=>c_ext_status-received.
    rs_header-internal_state          = /fcbp/if_glt_types=>c_internal_state-new.
    rs_header-retry_count             = 0.
    " The maximum retry count remains initial until resolved from policy.
    rs_header-target_system           = is_route_context-target_system.
    rs_header-target_adapter          = is_route_context-target_adapter.
    rs_header-created_by              = lv_actor.
    rs_header-changed_by              = lv_actor.
    rs_header-created_at              = is_request-requested_at.
    rs_header-changed_at              = is_request-requested_at.
    rs_header-version_no              = 1.
  ENDMETHOD.

  METHOD create_initial_status.
    rs_status-transfer_id         = is_header-transfer_id.
    rs_status-seq_no              = 1.
    rs_status-new_status_code     = /fcbp/if_glt_types=>c_status-received.
    rs_status-new_external_status = /fcbp/if_glt_types=>c_ext_status-received.
    rs_status-reason_code         = 'HANDOFF'.
    rs_status-actor_type          = /fcbp/if_glt_types=>c_actor_type-system.
    rs_status-actor_id            = is_header-created_by.
    rs_status-correlation_id      = is_header-correlation_id.
    rs_status-created_at          = is_header-created_at.
  ENDMETHOD.

  METHOD create_outbox.
    rs_work-outbox_id         = next_id( 'OBX' ).
    rs_work-transfer_id       = is_header-transfer_id.
    rs_work-work_type         = /fcbp/if_glt_types=>c_outbox_work_type-dispatch.
    rs_work-due_at            = is_header-created_at.
    rs_work-priority          = COND i( WHEN is_route_context-priority IS INITIAL THEN 5 ELSE is_route_context-priority ).
    rs_work-target_id         = is_route_context-target_id.
    rs_work-processing_mode   = is_header-processing_mode.
    rs_work-processing_status = /fcbp/if_glt_types=>c_outbox_status-open.
    rs_work-lock_status       = /fcbp/if_glt_types=>c_lock_status-free.
    rs_work-attempt_no        = 0.
    rs_work-created_at        = is_header-created_at.
    rs_work-created_by        = is_header-created_by.
  ENDMETHOD.

  METHOD create_audit_event.
    rs_event-audit_id         = next_id( 'AUD' ).
    rs_event-transfer_id      = is_header-transfer_id.
    rs_event-event_type       = /fcbp/if_glt_sec_types=>c_event_type-receive.
    rs_event-event_category   = /fcbp/if_glt_sec_types=>c_event_category-lifecycle.
    rs_event-source_type      = is_request-source_type.
    rs_event-source_reference = is_request-source_reference.
    rs_event-company_code     = is_header-company_code.
    rs_event-target_id        = is_route_context-target_id.
    rs_event-routing_bucket   = is_route_context-routing_bucket.
    rs_event-correlation_id   = is_header-correlation_id.
    rs_event-request_id       = is_request-external_corr_id.
    rs_event-decision_outcome = iv_outcome.
    rs_event-actor_type       = COND char12(
      WHEN is_request-processing_mode = /fcbp/if_glt_types=>c_processing_mode-batch THEN /fcbp/if_glt_types=>c_actor_type-job
      ELSE /fcbp/if_glt_types=>c_actor_type-system ).
    rs_event-actor_id         = actor( is_request ).
    rs_event-criticality      = /fcbp/if_glt_sec_types=>c_criticality-business_critical.
    rs_event-created_at       = is_header-created_at.
  ENDMETHOD.

  METHOD create_result.
    rs_result-transfer_id         = is_header-transfer_id.
    rs_result-registration_key    = iv_registration_key.
    rs_result-already_registered  = iv_already_registered.
    rs_result-registration_status = iv_registration_status.
    rs_result-external_status     = is_header-external_status.
    rs_result-internal_state      = is_header-internal_state.
    rs_result-target_id           = is_header-target_id.
    rs_result-routing_bucket      = is_header-routing_bucket.
    rs_result-message             = iv_message.
  ENDMETHOD.

  METHOD next_id.
    TRY.
        rv_value = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        rv_value = |{ iv_prefix }-{ sy-datum }-{ sy-uzeit }|.
    ENDTRY.
  ENDMETHOD.

  METHOD actor.
    rv_actor = COND #( WHEN is_request-requested_by IS NOT INITIAL THEN is_request-requested_by ELSE sy-uname ).
  ENDMETHOD.

ENDCLASS.
