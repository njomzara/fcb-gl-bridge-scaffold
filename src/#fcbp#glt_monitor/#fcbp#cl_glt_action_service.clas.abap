"! Guarded operator action service for monitor RAP actions.
CLASS /fcbp/cl_glt_action_service DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_action_service.

    METHODS constructor
      IMPORTING
        io_repository     TYPE REF TO /fcbp/if_glt_monitor_repo OPTIONAL
        io_status_manager TYPE REF TO /fcbp/if_glt_status_manager OPTIONAL
        io_auth_check     TYPE REF TO /fcbp/if_glt_auth_check OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_monitor_repo.
    DATA mo_status_manager TYPE REF TO /fcbp/if_glt_status_manager.
    DATA mo_auth_check TYPE REF TO /fcbp/if_glt_auth_check.

    METHODS ensure_services
      RAISING
        /fcbp/cx_glt_error.

    METHODS check_action_auth
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_action      TYPE char30
      RAISING
        /fcbp/cx_glt_error.

    METHODS assert_reason
      IMPORTING
        is_request TYPE /fcbp/if_glt_types=>ty_monitor_action_request
      RAISING
        /fcbp/cx_glt_error.

    METHODS assert_action_allowed
      IMPORTING
        is_transfer            TYPE /fcbp/if_glt_types=>ty_transfer
        iv_action              TYPE char30
        iv_attempt_started     TYPE abap_bool DEFAULT abap_false
      RAISING
        /fcbp/cx_glt_error.

    METHODS enqueue_work
      IMPORTING
        iv_transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_work_type         TYPE char20
        iv_target_id         TYPE char20 OPTIONAL
      RETURNING
        VALUE(rv_outbox_id)  TYPE /fcbp/if_glt_types=>ty_outbox_id
      RAISING
        /fcbp/cx_glt_error.

    METHODS write_action_audit
      IMPORTING
        is_request          TYPE /fcbp/if_glt_types=>ty_monitor_action_request
        iv_outcome          TYPE char30
      RETURNING
        VALUE(rv_audit_id)  TYPE /fcbp/if_glt_types=>ty_audit_id
      RAISING
        /fcbp/cx_glt_error.

    METHODS build_result
      IMPORTING
        is_request         TYPE /fcbp/if_glt_types=>ty_monitor_action_request
        iv_status          TYPE /fcbp/if_glt_types=>ty_status
        iv_outbox_id       TYPE /fcbp/if_glt_types=>ty_outbox_id OPTIONAL
        iv_audit_id        TYPE /fcbp/if_glt_types=>ty_audit_id OPTIONAL
        iv_message         TYPE char255
      RETURNING
        VALUE(rs_result)   TYPE /fcbp/if_glt_types=>ty_monitor_action_result.

    METHODS raise_action_error
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_action      TYPE char30
        iv_text        TYPE char220
      RAISING
        /fcbp/cx_glt_error.

    METHODS resolve_request
      IMPORTING
        is_request       TYPE /fcbp/if_glt_types=>ty_monitor_action_request
        iv_action        TYPE char30
      RETURNING
        VALUE(rs_request) TYPE /fcbp/if_glt_types=>ty_monitor_action_request.

ENDCLASS.

CLASS /fcbp/cl_glt_action_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    mo_status_manager = io_status_manager.
    mo_auth_check = io_auth_check.
  ENDMETHOD.

  METHOD /fcbp/if_glt_action_service~request_reprocess.
    DATA(ls_request) = resolve_request(
      is_request = is_request
      iv_action  = /fcbp/if_glt_types=>c_monitor_action-request_reprocess ).

    ensure_services( ).
    assert_reason( ls_request ).
    check_action_auth(
      iv_transfer_id = ls_request-transfer_id
      iv_action      = /fcbp/if_glt_types=>c_monitor_action-request_reprocess ).

    DATA(ls_transfer) = mo_repository->read_transfer( ls_request-transfer_id ).
    assert_action_allowed(
      is_transfer = ls_transfer
      iv_action   = /fcbp/if_glt_types=>c_monitor_action-request_reprocess ).

    DATA(lv_outbox_id) = enqueue_work(
      iv_transfer_id = ls_request-transfer_id
      iv_work_type   = /fcbp/if_glt_types=>c_outbox_work_type-reprocess
      iv_target_id   = ls_transfer-header-target_id ).

    mo_status_manager->set_status(
      iv_transfer_id = ls_request-transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-reprocess_requested
      iv_reason      = ls_request-reason_code
      iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-user
      iv_actor_id    = sy-uname ).

    DATA(lv_audit_id) = write_action_audit(
      is_request = ls_request
      iv_outcome = 'ACCEPTED' ).

    rs_result = build_result(
      is_request   = ls_request
      iv_status    = /fcbp/if_glt_types=>c_status-reprocess_requested
      iv_outbox_id = lv_outbox_id
      iv_audit_id  = lv_audit_id
      iv_message   = 'Reprocess work queued.' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_action_service~query_status.
    DATA(ls_request) = resolve_request(
      is_request = is_request
      iv_action  = /fcbp/if_glt_types=>c_monitor_action-query_status ).

    ensure_services( ).
    check_action_auth(
      iv_transfer_id = ls_request-transfer_id
      iv_action      = /fcbp/if_glt_types=>c_monitor_action-query_status ).

    DATA(ls_transfer) = mo_repository->read_transfer( ls_request-transfer_id ).
    assert_action_allowed(
      is_transfer = ls_transfer
      iv_action   = /fcbp/if_glt_types=>c_monitor_action-query_status ).

    DATA(lv_outbox_id) = enqueue_work(
      iv_transfer_id = ls_request-transfer_id
      iv_work_type   = /fcbp/if_glt_types=>c_outbox_work_type-status_query
      iv_target_id   = ls_transfer-header-target_id ).

    DATA(lv_audit_id) = write_action_audit(
      is_request = ls_request
      iv_outcome = 'ACCEPTED' ).

    rs_result = build_result(
      is_request   = ls_request
      iv_status    = ls_transfer-header-status_code
      iv_outbox_id = lv_outbox_id
      iv_audit_id  = lv_audit_id
      iv_message   = 'Status-query work queued; no submit was requested.' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_action_service~cancel_transfer.
    DATA(ls_request) = resolve_request(
      is_request = is_request
      iv_action  = /fcbp/if_glt_types=>c_monitor_action-cancel_transfer ).

    ensure_services( ).
    check_action_auth(
      iv_transfer_id = ls_request-transfer_id
      iv_action      = /fcbp/if_glt_types=>c_monitor_action-cancel_transfer ).

    DATA(ls_transfer) = mo_repository->read_transfer( ls_request-transfer_id ).
    DATA(lv_attempt_started) = mo_repository->has_started_attempt( ls_request-transfer_id ).
    assert_action_allowed(
      is_transfer        = ls_transfer
      iv_action          = /fcbp/if_glt_types=>c_monitor_action-cancel_transfer
      iv_attempt_started = lv_attempt_started ).

    mo_repository->cancel_open_work( ls_request-transfer_id ).
    mo_status_manager->set_status(
      iv_transfer_id = ls_request-transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-cancelled
      iv_reason      = ls_request-reason_code
      iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-user
      iv_actor_id    = sy-uname ).

    DATA(lv_audit_id) = write_action_audit(
      is_request = ls_request
      iv_outcome = 'ACCEPTED' ).

    rs_result = build_result(
      is_request  = ls_request
      iv_status   = /fcbp/if_glt_types=>c_status-cancelled
      iv_audit_id = lv_audit_id
      iv_message  = 'Transfer cancelled and open work cancelled.' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_action_service~retry_now.
    DATA(ls_request) = resolve_request(
      is_request = is_request
      iv_action  = /fcbp/if_glt_types=>c_monitor_action-retry_now ).

    ensure_services( ).
    check_action_auth(
      iv_transfer_id = ls_request-transfer_id
      iv_action      = /fcbp/if_glt_types=>c_monitor_action-retry_now ).

    DATA(ls_transfer) = mo_repository->read_transfer( ls_request-transfer_id ).
    assert_action_allowed(
      is_transfer = ls_transfer
      iv_action   = /fcbp/if_glt_types=>c_monitor_action-retry_now ).

    DATA(lv_outbox_id) = enqueue_work(
      iv_transfer_id = ls_request-transfer_id
      iv_work_type   = /fcbp/if_glt_types=>c_outbox_work_type-retry
      iv_target_id   = ls_transfer-header-target_id ).

    DATA(lv_audit_id) = write_action_audit(
      is_request = ls_request
      iv_outcome = 'ACCEPTED' ).

    rs_result = build_result(
      is_request   = ls_request
      iv_status    = ls_transfer-header-status_code
      iv_outbox_id = lv_outbox_id
      iv_audit_id  = lv_audit_id
      iv_message   = 'Retry work queued through outbox.' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_action_service~rebuild_after_correction.
    DATA(ls_request) = resolve_request(
      is_request = is_request
      iv_action  = /fcbp/if_glt_types=>c_monitor_action-rebuild_after_correction ).

    ensure_services( ).
    assert_reason( ls_request ).
    check_action_auth(
      iv_transfer_id = ls_request-transfer_id
      iv_action      = /fcbp/if_glt_types=>c_monitor_action-rebuild_after_correction ).

    DATA(ls_transfer) = mo_repository->read_transfer( ls_request-transfer_id ).
    assert_action_allowed(
      is_transfer = ls_transfer
      iv_action   = /fcbp/if_glt_types=>c_monitor_action-rebuild_after_correction ).

    DATA(lv_outbox_id) = enqueue_work(
      iv_transfer_id = ls_request-transfer_id
      iv_work_type   = /fcbp/if_glt_types=>c_outbox_work_type-rebuild
      iv_target_id   = ls_transfer-header-target_id ).

    mo_status_manager->set_status(
      iv_transfer_id = ls_request-transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-reprocess_requested
      iv_reason      = ls_request-reason_code
      iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-user
      iv_actor_id    = sy-uname ).

    DATA(lv_audit_id) = write_action_audit(
      is_request = ls_request
      iv_outcome = 'ACCEPTED' ).

    rs_result = build_result(
      is_request   = ls_request
      iv_status    = /fcbp/if_glt_types=>c_status-reprocess_requested
      iv_outbox_id = lv_outbox_id
      iv_audit_id  = lv_audit_id
      iv_message   = 'Rebuild work queued after correction.' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_action_service~mark_duplicate_resolved.
    DATA(ls_request) = resolve_request(
      is_request = is_request
      iv_action  = /fcbp/if_glt_types=>c_monitor_action-mark_duplicate_resolved ).

    ensure_services( ).
    assert_reason( ls_request ).
    check_action_auth(
      iv_transfer_id = ls_request-transfer_id
      iv_action      = /fcbp/if_glt_types=>c_monitor_action-mark_duplicate_resolved ).

    DATA(ls_transfer) = mo_repository->read_transfer( ls_request-transfer_id ).
    assert_action_allowed(
      is_transfer = ls_transfer
      iv_action   = /fcbp/if_glt_types=>c_monitor_action-mark_duplicate_resolved ).

    DATA(lv_audit_id) = write_action_audit(
      is_request = ls_request
      iv_outcome = 'ACCEPTED' ).

    rs_result = build_result(
      is_request  = ls_request
      iv_status   = ls_transfer-header-status_code
      iv_audit_id = lv_audit_id
      iv_message  = 'Duplicate resolution recorded for audit.' ).
  ENDMETHOD.

  METHOD ensure_services.
    IF mo_repository IS NOT BOUND OR
       mo_status_manager IS NOT BOUND OR
       mo_auth_check IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Action service requires repository, status manager, and authorization implementations.'.
    ENDIF.
  ENDMETHOD.

  METHOD check_action_auth.
    DATA(lv_sec_action) = SWITCH char30( iv_action
      WHEN /fcbp/if_glt_types=>c_monitor_action-query_status
      THEN /fcbp/if_glt_sec_types=>c_action-status_query
      WHEN /fcbp/if_glt_types=>c_monitor_action-cancel_transfer
      THEN /fcbp/if_glt_sec_types=>c_action-cancel
      WHEN /fcbp/if_glt_types=>c_monitor_action-retry_now
      THEN /fcbp/if_glt_sec_types=>c_action-retry
      WHEN /fcbp/if_glt_types=>c_monitor_action-rebuild_after_correction
      THEN /fcbp/if_glt_sec_types=>c_action-rebuild
      ELSE /fcbp/if_glt_sec_types=>c_action-reprocess ).

    DATA(ls_decision) = mo_auth_check->check_action(
      iv_action      = lv_sec_action
      iv_transfer_id = iv_transfer_id ).
  ENDMETHOD.

  METHOD assert_reason.
    IF is_request-reason_code IS INITIAL AND is_request-reason_text IS INITIAL.
      raise_action_error(
        iv_transfer_id = is_request-transfer_id
        iv_action      = is_request-action_id
        iv_text        = 'Manual monitor action requires a reason.' ).
    ENDIF.
  ENDMETHOD.

  METHOD assert_action_allowed.
    DATA(lv_status) = is_transfer-header-status_code.
    DATA(lv_allowed) = abap_false.

    IF lv_status = /fcbp/if_glt_types=>c_status-unknown_confirmation AND
       iv_action <> /fcbp/if_glt_types=>c_monitor_action-query_status.
      raise_action_error(
        iv_transfer_id = is_transfer-header-transfer_id
        iv_action      = iv_action
        iv_text        = 'Unknown confirmation requires queryStatus or poll; retry/reprocess is blocked.' ).
    ENDIF.

    CASE iv_action.
      WHEN /fcbp/if_glt_types=>c_monitor_action-request_reprocess.
        lv_allowed = xsdbool(
          lv_status = /fcbp/if_glt_types=>c_status-validation_failed OR
          lv_status = /fcbp/if_glt_types=>c_status-failed_retryable OR
          lv_status = /fcbp/if_glt_types=>c_status-failed_final ).
      WHEN /fcbp/if_glt_types=>c_monitor_action-rebuild_after_correction.
        lv_allowed = xsdbool(
          lv_status = /fcbp/if_glt_types=>c_status-validation_failed OR
          lv_status = /fcbp/if_glt_types=>c_status-failed_final ).
      WHEN /fcbp/if_glt_types=>c_monitor_action-query_status.
        lv_allowed = xsdbool(
          lv_status = /fcbp/if_glt_types=>c_status-unknown_confirmation OR
          lv_status = /fcbp/if_glt_types=>c_status-processing OR
          lv_status = /fcbp/if_glt_types=>c_status-dispatched ).
      WHEN /fcbp/if_glt_types=>c_monitor_action-cancel_transfer.
        lv_allowed = xsdbool(
          iv_attempt_started = abap_false AND
          ( lv_status = /fcbp/if_glt_types=>c_status-received OR
            lv_status = /fcbp/if_glt_types=>c_status-ready ) ).
      WHEN /fcbp/if_glt_types=>c_monitor_action-retry_now.
        lv_allowed = xsdbool( lv_status = /fcbp/if_glt_types=>c_status-failed_retryable ).
      WHEN /fcbp/if_glt_types=>c_monitor_action-mark_duplicate_resolved.
        lv_allowed = xsdbool(
          lv_status = /fcbp/if_glt_types=>c_status-failed_final OR
          lv_status = /fcbp/if_glt_types=>c_status-reprocess_requested ).
    ENDCASE.

    IF lv_allowed = abap_false.
      raise_action_error(
        iv_transfer_id = is_transfer-header-transfer_id
        iv_action      = iv_action
        iv_text        = |Action { iv_action } is not allowed for status { lv_status }.| ).
    ENDIF.
  ENDMETHOD.

  METHOD enqueue_work.
    DATA(ls_work) = VALUE /fcbp/if_glt_types=>ty_outbox_work(
      transfer_id       = iv_transfer_id
      work_type         = iv_work_type
      target_id         = iv_target_id
      processing_status = /fcbp/if_glt_types=>c_outbox_status-open
      lock_status       = /fcbp/if_glt_types=>c_lock_status-free
      priority          = 5
      attempt_no        = 0
      created_by        = sy-uname ).

    GET TIME STAMP FIELD ls_work-created_at.
    ls_work-due_at = ls_work-created_at.

    rv_outbox_id = mo_repository->insert_outbox_work( ls_work ).
  ENDMETHOD.

  METHOD write_action_audit.
    DATA(ls_event) = VALUE /fcbp/if_glt_types=>ty_audit_event(
      transfer_id      = is_request-transfer_id
      event_type       = 'MONITOR_ACTION'
      event_subtype    = is_request-action_id
      event_category   = 'OPERATOR_ACTION'
      decision_outcome = iv_outcome
      actor_type       = /fcbp/if_glt_types=>c_actor_type-user
      actor_id         = sy-uname
      reason_code      = is_request-reason_code
      evidence_ref     = is_request-reason_text ).

    GET TIME STAMP FIELD ls_event-created_at.
    rv_audit_id = mo_repository->write_audit_event( ls_event ).
  ENDMETHOD.

  METHOD build_result.
    rs_result = VALUE #(
      transfer_id     = is_request-transfer_id
      action_id       = is_request-action_id
      accepted        = abap_true
      status_code     = iv_status
      external_status = mo_status_manager->derive_external_status( iv_status )
      outbox_id       = iv_outbox_id
      audit_id        = iv_audit_id
      message         = iv_message ).
  ENDMETHOD.

  METHOD raise_action_error.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_error
      EXPORTING
        transfer_id    = iv_transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-authorization
        operator_text  = |{ iv_text } Action={ iv_action }.|.
  ENDMETHOD.

  METHOD resolve_request.
    rs_request = is_request.
    rs_request-action_id = iv_action.
  ENDMETHOD.

ENDCLASS.
