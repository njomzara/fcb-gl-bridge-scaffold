"! Support-access policy scaffold. Requires explicit ticket, reason, scope, auth, and audit.
CLASS /fcbp/cl_glt_support_access DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_support_access.

    METHODS constructor
      IMPORTING
        io_context      TYPE REF TO /fcbp/if_glt_security_context OPTIONAL
        io_auth_check   TYPE REF TO /fcbp/if_glt_auth_check OPTIONAL
        io_audit_writer TYPE REF TO /fcbp/if_glt_audit_writer OPTIONAL.

  PRIVATE SECTION.
    DATA mo_context TYPE REF TO /fcbp/if_glt_security_context.
    DATA mo_auth_check TYPE REF TO /fcbp/if_glt_auth_check.
    DATA mo_audit_writer TYPE REF TO /fcbp/if_glt_audit_writer.

    METHODS ensure_dependencies
      RAISING
        /fcbp/cx_glt_auth.

ENDCLASS.

CLASS /fcbp/cl_glt_support_access IMPLEMENTATION.

  METHOD constructor.
    mo_context = io_context.
    mo_auth_check = io_auth_check.
    mo_audit_writer = io_audit_writer.
  ENDMETHOD.

  METHOD /fcbp/if_glt_support_access~request_access.
    ensure_dependencies( ).
    rs_context = mo_context->build_support_context( is_scope ).
    mo_auth_check->check_support_access(
      is_scope   = is_scope
      is_context = rs_context ).
    DATA(lv_audit_id) = /fcbp/if_glt_support_access~record_access(
      is_scope   = is_scope
      is_context = rs_context
      iv_outcome = /fcbp/if_glt_sec_types=>c_decision_outcome-allowed ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_support_access~record_access.
    IF mo_audit_writer IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_audit
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Support access requires an audit writer implementation.'.
    ENDIF.

    rv_audit_id = mo_audit_writer->write_support_access(
      is_scope   = is_scope
      is_context = is_context
      iv_outcome = iv_outcome ).
  ENDMETHOD.

  METHOD ensure_dependencies.
    IF mo_context IS NOT BOUND OR mo_auth_check IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_auth
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-authorization
          operator_text  = 'Support access requires context and authorization services.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
