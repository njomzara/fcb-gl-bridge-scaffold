"! Test-only authorization checker that allows all happy-path operations.
CLASS /fcbp/cl_glt_tst_auth_allow DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_auth_check.

  PRIVATE SECTION.
    METHODS allow
      IMPORTING
        iv_action      TYPE char30
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
        is_context     TYPE /fcbp/if_glt_sec_types=>ty_security_context OPTIONAL
      RETURNING
        VALUE(rs_decision) TYPE /fcbp/if_glt_sec_types=>ty_auth_decision.

ENDCLASS.

CLASS /fcbp/cl_glt_tst_auth_allow IMPLEMENTATION.

  METHOD /fcbp/if_glt_auth_check~check_display.
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_action.
    rs_decision = allow(
      iv_action      = iv_action
      iv_transfer_id = iv_transfer_id
      is_context     = is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_reprocess.
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_config.
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_audit_read.
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_support_access.
  ENDMETHOD.

  METHOD /fcbp/if_glt_auth_check~check_worker_execute.
  ENDMETHOD.

  METHOD allow.
    rs_decision = VALUE #(
      action = iv_action
      transfer_id = iv_transfer_id
      allowed = abap_true
      decision_outcome = /fcbp/if_glt_sec_types=>c_decision_outcome-allowed
      company_code = is_context-company_code
      target_id = is_context-target_id
      actor_id = COND #( WHEN is_context-actor_id IS INITIAL THEN sy-uname ELSE is_context-actor_id ) ).
    GET TIME STAMP FIELD rs_decision-created_at.
  ENDMETHOD.

ENDCLASS.
