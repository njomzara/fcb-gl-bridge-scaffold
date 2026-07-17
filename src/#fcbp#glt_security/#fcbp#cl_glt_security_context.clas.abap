"! Security context builder. Fails closed when required scope cannot be resolved.
CLASS /fcbp/cl_glt_security_context DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_security_context.

  PRIVATE SECTION.
    METHODS enrich_defaults
      CHANGING
        cs_context TYPE /fcbp/if_glt_sec_types=>ty_security_context.

ENDCLASS.

CLASS /fcbp/cl_glt_security_context IMPLEMENTATION.

  METHOD /fcbp/if_glt_security_context~get_current_context.
    rs_context = VALUE #(
      actor_type        = /fcbp/if_glt_types=>c_actor_type-user
      actor_id          = sy-uname
      user_name         = sy-uname
      company_code      = iv_company_code
      target_id         = iv_target_id
      purpose           = iv_purpose
      correlation_id    = iv_correlation_id
      redaction_profile = /fcbp/if_glt_sec_types=>c_redaction_profile-summary ).
    enrich_defaults( CHANGING cs_context = rs_context ).
    /fcbp/if_glt_security_context~assert_context( rs_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_security_context~build_support_context.
    rs_context = VALUE #(
      actor_type         = /fcbp/if_glt_types=>c_actor_type-support
      actor_id           = sy-uname
      user_name          = sy-uname
      company_code       = is_scope-company_code
      target_id          = is_scope-target_id
      support_ticket_id  = is_scope-support_ticket_id
      support_session_id = is_scope-support_session_id
      reason_code        = is_scope-reason_code
      reason_text        = is_scope-reason_text
      purpose            = /fcbp/if_glt_sec_types=>c_purpose-support
      redaction_profile  = /fcbp/if_glt_sec_types=>c_redaction_profile-support
      valid_until        = is_scope-valid_until ).
    enrich_defaults( CHANGING cs_context = rs_context ).
    /fcbp/if_glt_security_context~assert_context( rs_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_security_context~build_job_context.
    rs_context = VALUE #(
      actor_type        = /fcbp/if_glt_types=>c_actor_type-job
      actor_id          = iv_job_type
      jobrun_id         = iv_jobrun_id
      purpose           = /fcbp/if_glt_sec_types=>c_purpose-technical_worker
      redaction_profile = /fcbp/if_glt_sec_types=>c_redaction_profile-blocked ).
    enrich_defaults( CHANGING cs_context = rs_context ).
    /fcbp/if_glt_security_context~assert_context( rs_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_security_context~assert_context.
    IF is_context-actor_type IS INITIAL OR
       is_context-actor_id IS INITIAL OR
       is_context-purpose IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_auth
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-authorization
          operator_text  = 'Security context requires actor type, actor ID, and purpose.'.
    ENDIF.

    IF is_context-purpose = /fcbp/if_glt_sec_types=>c_purpose-support AND
       ( is_context-support_ticket_id IS INITIAL OR is_context-reason_code IS INITIAL ).
      RAISE EXCEPTION TYPE /fcbp/cx_glt_auth
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-authorization
          operator_text  = 'Support context requires ticket and reason.'.
    ENDIF.
  ENDMETHOD.

  METHOD enrich_defaults.
    IF cs_context-valid_from IS INITIAL.
      GET TIME STAMP FIELD cs_context-valid_from.
    ENDIF.
    IF cs_context-tenant_id IS INITIAL.
      cs_context-tenant_id = sy-mandt.
    ENDIF.
    IF cs_context-request_id IS INITIAL.
      cs_context-request_id = |REQ-{ sy-mandt }-{ sy-uname }|.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
