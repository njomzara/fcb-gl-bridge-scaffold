"! Authorization check scaffold. Fail closed until IAM/DCL model is configured.
CLASS /fcbp/cl_glt_auth_check DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_auth_check.

  PRIVATE SECTION.
    METHODS raise_not_configured
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
        iv_action      TYPE char30
        is_context     TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
      RAISING
        /fcbp/cx_glt_auth.

    METHODS build_denied_decision
      IMPORTING
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
        iv_action      TYPE char30
        is_context     TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
      RETURNING
        VALUE(rs_decision) TYPE /fcbp/if_glt_sec_types=>ty_auth_decision.

ENDCLASS.

CLASS /fcbp/cl_glt_auth_check IMPLEMENTATION.

  METHOD /fcbp/if_glt_auth_check~check_display.
    raise_not_configured(
      iv_transfer_id = iv_transfer_id
      iv_action      = /fcbp/if_glt_sec_types=>c_action-display
      is_context     = is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_action.
    rs_decision = build_denied_decision(
      iv_transfer_id = iv_transfer_id
      iv_action      = iv_action
      is_context     = is_context ).
    raise_not_configured(
      iv_transfer_id = iv_transfer_id
      iv_action      = iv_action
      is_context     = is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_reprocess.
    raise_not_configured(
      iv_transfer_id = iv_transfer_id
      iv_action      = /fcbp/if_glt_sec_types=>c_action-reprocess
      is_context     = is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_config.
    DATA(lv_action) = COND char30(
      WHEN iv_activity IS INITIAL
      THEN /fcbp/if_glt_sec_types=>c_action-config_view
      ELSE iv_activity ).
    raise_not_configured(
      iv_action  = lv_action
      is_context = is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_audit_read.
    raise_not_configured(
      iv_transfer_id = iv_transfer_id
      iv_action      = /fcbp/if_glt_sec_types=>c_action-audit_read
      is_context     = is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_support_access.
    IF is_scope-support_ticket_id IS INITIAL OR is_context-reason_code IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_auth
        EXPORTING
          transfer_id    = is_scope-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-authorization
          operator_text  = 'Support access requires ticket and reason context.'.
    ENDIF.
    raise_not_configured(
      iv_transfer_id = is_scope-transfer_id
      iv_action      = /fcbp/if_glt_sec_types=>c_action-support_access
      is_context     = is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_worker_execute.
    raise_not_configured(
      iv_action  = /fcbp/if_glt_sec_types=>c_action-job_execute
      is_context = is_context ).
  ENDMETHOD.

  METHOD raise_not_configured.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_auth
      EXPORTING
        transfer_id    = iv_transfer_id
        error_category = /fcbp/if_glt_types=>c_error_category-authorization
        operator_text  = |Authorization action { iv_action } is not configured in the scaffold.|.
  ENDMETHOD.

  METHOD build_denied_decision.
    rs_decision = VALUE #(
      transfer_id      = iv_transfer_id
      action           = iv_action
      allowed          = abap_false
      decision_outcome = /fcbp/if_glt_sec_types=>c_decision_outcome-denied
      denial_reason    = 'AUTH_NOT_CONFIGURED'
      company_code     = is_context-company_code
      target_id        = is_context-target_id
      requires_audit   = abap_true
      actor_id         = is_context-actor_id ).
    GET TIME STAMP FIELD rs_decision-created_at.
  ENDMETHOD.

ENDCLASS.
