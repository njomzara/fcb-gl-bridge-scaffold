"! Communication client scaffold. Bind to released HTTP/OData APIs per target tenant.
CLASS /fcbp/cl_glt_adapter_client DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_adapter_client.

  PRIVATE SECTION.
    METHODS not_bound
      IMPORTING
        iv_operation TYPE char30
        iv_target_adapter TYPE char30 OPTIONAL
      RAISING
        /fcbp/cx_glt_adapter.

ENDCLASS.

CLASS /fcbp/cl_glt_adapter_client IMPLEMENTATION.

  METHOD /fcbp/if_glt_adapter_client~submit.
    not_bound( iv_operation = 'SUBMIT' iv_target_adapter = is_request-target_adapter ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_client~query_status.
    not_bound( iv_operation = 'QUERY_STATUS' iv_target_adapter = is_request-target_adapter ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_client~cancel.
    not_bound( iv_operation = 'CANCEL' iv_target_adapter = is_request-target_adapter ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_client~check_connection.
    not_bound( iv_operation = 'CHECK_CONNECTION' iv_target_adapter = is_profile-adapter_type ).
  ENDMETHOD.

  METHOD not_bound.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_adapter
      EXPORTING
        target_adapter    = iv_target_adapter
        error_category    = /fcbp/if_glt_types=>c_error_category-config
        protocol_category = /fcbp/if_glt_adapter_types=>c_protocol_category-config
        operator_text     = |Adapter client operation { iv_operation } is not bound to a released communication API.|.
  ENDMETHOD.

ENDCLASS.
