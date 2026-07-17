"! Configuration change audit scaffold.
CLASS /fcbp/cl_glt_config_audit DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_config_audit.

    METHODS constructor
      IMPORTING
        io_auth_check    TYPE REF TO /fcbp/if_glt_auth_check OPTIONAL
        io_event_factory TYPE REF TO /fcbp/if_glt_audit_event_factory OPTIONAL
        io_audit_writer  TYPE REF TO /fcbp/if_glt_audit_writer OPTIONAL.

  PRIVATE SECTION.
    DATA mo_auth_check TYPE REF TO /fcbp/if_glt_auth_check.
    DATA mo_event_factory TYPE REF TO /fcbp/if_glt_audit_event_factory.
    DATA mo_audit_writer TYPE REF TO /fcbp/if_glt_audit_writer.

    METHODS ensure_dependencies
      RAISING
        /fcbp/cx_glt_audit.

ENDCLASS.

CLASS /fcbp/cl_glt_config_audit IMPLEMENTATION.

  METHOD constructor.
    mo_auth_check = io_auth_check.
    mo_event_factory = io_event_factory.
    mo_audit_writer = io_audit_writer.
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_audit~record_config_change.
    ensure_dependencies( ).
    mo_auth_check->check_config(
      iv_config_object_type = is_change-config_object_type
      iv_config_object_key  = is_change-config_object_key
      iv_activity           = /fcbp/if_glt_sec_types=>c_action-config_change
      iv_company_code       = is_change-company_code
      iv_target_id          = is_change-target_id
      is_context            = is_context ).

    DATA(ls_event) = mo_event_factory->for_config_changed(
      is_change  = is_change
      is_context = is_context ).
    rv_audit_id = mo_audit_writer->write_event( ls_event ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_audit~record_config_activation.
    ensure_dependencies( ).
    mo_auth_check->check_config(
      iv_config_object_type = is_change-config_object_type
      iv_config_object_key  = is_change-config_object_key
      iv_activity           = /fcbp/if_glt_sec_types=>c_action-config_activate
      iv_company_code       = is_change-company_code
      iv_target_id          = is_change-target_id
      is_context            = is_context ).

    DATA(ls_event) = mo_event_factory->for_config_activated(
      is_change  = is_change
      is_context = is_context ).
    rv_audit_id = mo_audit_writer->write_event( ls_event ).
  ENDMETHOD.

  METHOD ensure_dependencies.
    IF mo_auth_check IS NOT BOUND OR
       mo_event_factory IS NOT BOUND OR
       mo_audit_writer IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_audit
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Config audit requires auth, event factory, and audit writer services.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
