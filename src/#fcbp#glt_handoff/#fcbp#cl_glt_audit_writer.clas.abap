"! Audit writer wrapper. Writes append-only evidence in the caller's LUW.
CLASS /fcbp/cl_glt_audit_writer DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_audit_writer.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_audit_repo OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_audit_repo.

    METHODS ensure_repository
      RAISING
        /fcbp/cx_glt_audit.

    METHODS validate_event
      IMPORTING
        is_event       TYPE /fcbp/if_glt_types=>ty_audit_event
        iv_criticality TYPE char20
      RAISING
        /fcbp/cx_glt_audit.

ENDCLASS.

CLASS /fcbp/cl_glt_audit_writer IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_writer~write_event.
    ensure_repository( ).
    validate_event(
      is_event       = is_event
      iv_criticality = iv_criticality ).

    DATA(ls_event) = is_event.
    IF ls_event-created_at IS INITIAL.
      GET TIME STAMP FIELD ls_event-created_at.
    ENDIF.
    IF ls_event-criticality IS INITIAL.
      ls_event-criticality = iv_criticality.
    ENDIF.

    rv_audit_id = mo_repository->insert_audit_event( ls_event ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_writer~write_authorization_denial.
    DATA(ls_event) = VALUE /fcbp/if_glt_types=>ty_audit_event(
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

    rv_audit_id = /fcbp/if_glt_audit_writer~write_event(
      is_event       = ls_event
      iv_criticality = /fcbp/if_glt_sec_types=>c_criticality-security ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_writer~write_support_access.
    DATA(ls_event) = VALUE /fcbp/if_glt_types=>ty_audit_event(
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

    rv_audit_id = /fcbp/if_glt_audit_writer~write_event(
      is_event       = ls_event
      iv_criticality = /fcbp/if_glt_sec_types=>c_criticality-security ).
  ENDMETHOD.

  METHOD ensure_repository.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_audit
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Audit writer requires an audit repository implementation.'.
    ENDIF.
  ENDMETHOD.

  METHOD validate_event.
    IF is_event-event_type IS INITIAL OR
       is_event-event_category IS INITIAL OR
       is_event-actor_type IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_audit
        EXPORTING
          transfer_id     = is_event-transfer_id
          event_type      = is_event-event_type
          event_category  = is_event-event_category
          criticality     = iv_criticality
          error_category  = /fcbp/if_glt_types=>c_error_category-technical
          operator_text   = 'Audit event requires type, category, and actor type.'.
    ENDIF.

    IF is_event-event_category = /fcbp/if_glt_sec_types=>c_event_category-support AND
       is_event-support_ticket_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_audit
        EXPORTING
          transfer_id     = is_event-transfer_id
          event_type      = is_event-event_type
          event_category  = is_event-event_category
          criticality     = iv_criticality
          error_category  = /fcbp/if_glt_types=>c_error_category-authorization
          operator_text   = 'Support audit event requires support ticket evidence.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
