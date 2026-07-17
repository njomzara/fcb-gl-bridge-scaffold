"! Default Job Layer authorization guard.
CLASS /fcbp/cl_glt_job_auth_guard DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_job_auth_guard.

    METHODS constructor
      IMPORTING
        io_auth_check TYPE REF TO /fcbp/if_glt_auth_check OPTIONAL.

  PRIVATE SECTION.
    DATA mo_auth_check TYPE REF TO /fcbp/if_glt_auth_check.

    METHODS build_security_context
      IMPORTING
        is_context         TYPE /fcbp/if_glt_job_types=>ty_job_context
      RETURNING
        VALUE(rs_context)  TYPE /fcbp/if_glt_sec_types=>ty_security_context.

ENDCLASS.

CLASS /fcbp/cl_glt_job_auth_guard IMPLEMENTATION.

  METHOD constructor.
    IF io_auth_check IS BOUND.
      mo_auth_check = io_auth_check.
    ELSE.
      mo_auth_check = NEW /fcbp/cl_glt_auth_check( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_job_auth_guard~check_job_scope.
    IF mo_auth_check IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_auth
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-authorization
          operator_text  = 'Job authorization guard requires an authorization checker.'.
    ENDIF.

    mo_auth_check->check_worker_execute(
      iv_job_type = is_context-job_type
      is_context  = build_security_context( is_context ) ).
  ENDMETHOD.

  METHOD build_security_context.
    rs_context = VALUE #(
      actor_type     = /fcbp/if_glt_types=>c_actor_type-job
      actor_id       = is_context-actor_id
      user_name      = sy-uname
      jobrun_id      = is_context-jobrun_id
      reason_code    = is_context-reason_code
      correlation_id = is_context-correlation_id
      company_code   = is_context-company_code
      target_id      = is_context-target_id
      purpose        = /fcbp/if_glt_sec_types=>c_purpose-technical_worker ).
  ENDMETHOD.

ENDCLASS.
