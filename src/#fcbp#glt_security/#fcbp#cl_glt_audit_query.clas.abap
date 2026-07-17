"! Secured audit query facade with authorization and redaction hooks.
CLASS /fcbp/cl_glt_audit_query DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_audit_query.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_audit_repo OPTIONAL
        io_auth_check TYPE REF TO /fcbp/if_glt_auth_check OPTIONAL
        io_redaction  TYPE REF TO /fcbp/if_glt_redaction OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_audit_repo.
    DATA mo_auth_check TYPE REF TO /fcbp/if_glt_auth_check.
    DATA mo_redaction TYPE REF TO /fcbp/if_glt_redaction.

    METHODS ensure_dependencies
      RAISING
        /fcbp/cx_glt_audit.

    METHODS redact_events
      IMPORTING
        it_event        TYPE /fcbp/if_glt_types=>tt_audit_event
        is_context      TYPE /fcbp/if_glt_sec_types=>ty_security_context
      RETURNING
        VALUE(rt_event) TYPE /fcbp/if_glt_types=>tt_audit_event.

ENDCLASS.

CLASS /fcbp/cl_glt_audit_query IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    mo_auth_check = io_auth_check.
    mo_redaction = io_redaction.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_query~query_audit.
    ensure_dependencies( ).
    mo_auth_check->check_audit_read(
      iv_transfer_id  = is_filter-transfer_id
      iv_company_code = is_filter-company_code
      iv_target_id    = is_filter-target_id
      is_context      = is_context ).

    DATA(lt_event) = mo_repository->query_audit( is_filter ).
    rt_event = redact_events(
      it_event   = lt_event
      is_context = is_context ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_query~get_transfer_audit.
    DATA(ls_filter) = VALUE /fcbp/if_glt_sec_types=>ty_audit_filter(
      transfer_id = iv_transfer_id ).
    rt_event = /fcbp/if_glt_audit_query~query_audit(
      is_filter  = ls_filter
      is_context = is_context ).
  ENDMETHOD.

  METHOD ensure_dependencies.
    IF mo_repository IS NOT BOUND OR mo_auth_check IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_audit
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Audit query requires repository and authorization services.'.
    ENDIF.
  ENDMETHOD.

  METHOD redact_events.
    LOOP AT it_event INTO DATA(ls_event).
      IF mo_redaction IS BOUND.
        APPEND mo_redaction->redact_audit_event(
          is_event   = ls_event
          is_context = is_context ) TO rt_event.
      ELSE.
        APPEND ls_event TO rt_event.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
