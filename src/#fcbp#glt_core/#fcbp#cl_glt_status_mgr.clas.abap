"! Enforces the Transfer Core status lifecycle and appends status history.
CLASS /fcbp/cl_glt_status_mgr DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_status_manager.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_repository OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_repository.

    METHODS derive_internal_state
      IMPORTING
        iv_status                  TYPE /fcbp/if_glt_types=>ty_status
      RETURNING
        VALUE(rv_internal_state)   TYPE char25.

    METHODS requires_operator_action
      IMPORTING
        iv_status                  TYPE /fcbp/if_glt_types=>ty_status
      RETURNING
        VALUE(rv_required)         TYPE abap_bool.

ENDCLASS.

CLASS /fcbp/cl_glt_status_mgr IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD /fcbp/if_glt_status_manager~derive_external_status.
    CASE iv_status.
      WHEN /fcbp/if_glt_types=>c_status-posted
        OR /fcbp/if_glt_types=>c_status-reversed.
        rv_ext_status = /fcbp/if_glt_types=>c_ext_status-posted.
      WHEN /fcbp/if_glt_types=>c_status-validation_failed
        OR /fcbp/if_glt_types=>c_status-failed_retryable
        OR /fcbp/if_glt_types=>c_status-unknown_confirmation
        OR /fcbp/if_glt_types=>c_status-failed_final
        OR /fcbp/if_glt_types=>c_status-reprocess_requested
        OR /fcbp/if_glt_types=>c_status-cancelled.
        rv_ext_status = /fcbp/if_glt_types=>c_ext_status-failed.
      WHEN OTHERS.
        rv_ext_status = /fcbp/if_glt_types=>c_ext_status-received.
    ENDCASE.
  ENDMETHOD.

  METHOD /fcbp/if_glt_status_manager~assert_transition.
    DATA lv_allowed TYPE abap_bool.

    IF iv_old_status IS INITIAL.
      lv_allowed = xsdbool( iv_new_status = /fcbp/if_glt_types=>c_status-received ).
    ELSE.
      CASE iv_old_status.
        WHEN /fcbp/if_glt_types=>c_status-received.
          lv_allowed = xsdbool( iv_new_status = /fcbp/if_glt_types=>c_status-validating OR iv_new_status = /fcbp/if_glt_types=>c_status-cancelled ).
        WHEN /fcbp/if_glt_types=>c_status-validating.
          lv_allowed = xsdbool( iv_new_status = /fcbp/if_glt_types=>c_status-validation_failed OR iv_new_status = /fcbp/if_glt_types=>c_status-ready ).
        WHEN /fcbp/if_glt_types=>c_status-ready.
          lv_allowed = xsdbool( iv_new_status = /fcbp/if_glt_types=>c_status-processing OR iv_new_status = /fcbp/if_glt_types=>c_status-cancelled ).
        WHEN /fcbp/if_glt_types=>c_status-processing.
          lv_allowed = xsdbool(
            iv_new_status = /fcbp/if_glt_types=>c_status-posted OR
            iv_new_status = /fcbp/if_glt_types=>c_status-dispatched OR
            iv_new_status = /fcbp/if_glt_types=>c_status-failed_retryable OR
            iv_new_status = /fcbp/if_glt_types=>c_status-failed_final OR
            iv_new_status = /fcbp/if_glt_types=>c_status-unknown_confirmation ).
        WHEN /fcbp/if_glt_types=>c_status-failed_retryable
          OR /fcbp/if_glt_types=>c_status-validation_failed
          OR /fcbp/if_glt_types=>c_status-failed_final.
          lv_allowed = xsdbool( iv_new_status = /fcbp/if_glt_types=>c_status-reprocess_requested ).
        WHEN /fcbp/if_glt_types=>c_status-unknown_confirmation.
          lv_allowed = xsdbool(
            iv_new_status = /fcbp/if_glt_types=>c_status-posted OR
            iv_new_status = /fcbp/if_glt_types=>c_status-failed_retryable OR
            iv_new_status = /fcbp/if_glt_types=>c_status-failed_final ).
        WHEN /fcbp/if_glt_types=>c_status-reprocess_requested.
          lv_allowed = xsdbool(
            iv_new_status = /fcbp/if_glt_types=>c_status-validating OR
            iv_new_status = /fcbp/if_glt_types=>c_status-processing OR
            iv_new_status = /fcbp/if_glt_types=>c_status-failed_final ).
        WHEN /fcbp/if_glt_types=>c_status-dispatched.
          lv_allowed = xsdbool(
            iv_new_status = /fcbp/if_glt_types=>c_status-posted OR
            iv_new_status = /fcbp/if_glt_types=>c_status-failed_final OR
            iv_new_status = /fcbp/if_glt_types=>c_status-cancelled ).
        WHEN /fcbp/if_glt_types=>c_status-posted.
          lv_allowed = xsdbool( iv_new_status = /fcbp/if_glt_types=>c_status-reversed ).
        WHEN OTHERS.
          lv_allowed = abap_false.
      ENDCASE.
    ENDIF.

    IF lv_allowed = abap_false.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = |Invalid GLT status transition { iv_old_status } -> { iv_new_status }.|.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_status_manager~set_status.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Status manager requires a repository implementation.'.
    ENDIF.

    DATA(ls_transfer) = mo_repository->read_transfer( iv_transfer_id ).
    DATA(ls_header) = ls_transfer-header.
    GET TIME STAMP FIELD DATA(lv_now).

    /fcbp/if_glt_status_manager~assert_transition(
      iv_old_status = ls_header-status_code
      iv_new_status = iv_status ).

    DATA(lv_ext_status) = /fcbp/if_glt_status_manager~derive_external_status( iv_status ).
    DATA(lv_seq_no) = lines( ls_transfer-statuses ) + 1.

    mo_repository->insert_status( VALUE #(
      transfer_id         = iv_transfer_id
      seq_no              = lv_seq_no
      old_status_code     = ls_header-status_code
      new_status_code     = iv_status
      old_external_status = ls_header-external_status
      new_external_status = lv_ext_status
      reason_code         = iv_reason
      error_id            = iv_error_id
      attempt_no          = iv_attempt_no
      actor_type          = iv_actor_type
      actor_id            = iv_actor_id
      correlation_id      = ls_header-correlation_id
      created_at          = lv_now ) ).

    ls_header-status_code     = iv_status.
    ls_header-external_status = lv_ext_status.
    ls_header-internal_state  = derive_internal_state( iv_status ).
    ls_header-last_error_id   = iv_error_id.
    ls_header-confirmation_pending = xsdbool( iv_status = /fcbp/if_glt_types=>c_status-unknown_confirmation ).
    ls_header-operator_action_required = requires_operator_action( iv_status ).
    ls_header-changed_by      = sy-uname.
    ls_header-changed_at      = lv_now.
    ls_header-version_no      = ls_header-version_no + 1.
    mo_repository->update_header( ls_header ).
  ENDMETHOD.

  METHOD derive_internal_state.
    CASE iv_status.
      WHEN /fcbp/if_glt_types=>c_status-received.
        rv_internal_state = /fcbp/if_glt_types=>c_internal_state-new.
      WHEN /fcbp/if_glt_types=>c_status-validating.
        rv_internal_state = /fcbp/if_glt_types=>c_internal_state-prepared.
      WHEN /fcbp/if_glt_types=>c_status-ready.
        rv_internal_state = /fcbp/if_glt_types=>c_internal_state-validated.
      WHEN /fcbp/if_glt_types=>c_status-processing
        OR /fcbp/if_glt_types=>c_status-dispatched.
        rv_internal_state = /fcbp/if_glt_types=>c_internal_state-submitted.
      WHEN /fcbp/if_glt_types=>c_status-validation_failed.
        rv_internal_state = /fcbp/if_glt_types=>c_internal_state-validation_error.
      WHEN /fcbp/if_glt_types=>c_status-failed_retryable
        OR /fcbp/if_glt_types=>c_status-failed_final.
        rv_internal_state = /fcbp/if_glt_types=>c_internal_state-submit_error.
      WHEN /fcbp/if_glt_types=>c_status-unknown_confirmation.
        rv_internal_state = /fcbp/if_glt_types=>c_internal_state-unknown_confirmation.
      WHEN /fcbp/if_glt_types=>c_status-posted
        OR /fcbp/if_glt_types=>c_status-reversed.
        rv_internal_state = /fcbp/if_glt_types=>c_internal_state-transferred.
      WHEN /fcbp/if_glt_types=>c_status-cancelled.
        rv_internal_state = /fcbp/if_glt_types=>c_internal_state-functional_rejected.
      WHEN OTHERS.
        rv_internal_state = /fcbp/if_glt_types=>c_internal_state-prepare_error.
    ENDCASE.
  ENDMETHOD.

  METHOD requires_operator_action.
    rv_required = xsdbool(
      iv_status = /fcbp/if_glt_types=>c_status-validation_failed OR
      iv_status = /fcbp/if_glt_types=>c_status-unknown_confirmation OR
      iv_status = /fcbp/if_glt_types=>c_status-failed_final OR
      iv_status = /fcbp/if_glt_types=>c_status-reprocess_requested ).
  ENDMETHOD.

ENDCLASS.
