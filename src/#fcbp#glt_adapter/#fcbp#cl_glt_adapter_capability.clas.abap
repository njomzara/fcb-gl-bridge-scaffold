"! Capability registry scaffold. Productive matrices remain blocked until finalized.
CLASS /fcbp/cl_glt_adapter_capability DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_adapter_capability.

  PRIVATE SECTION.
    METHODS add_finding
      IMPORTING
        is_profile TYPE /fcbp/if_glt_config_types=>ty_target_profile
        iv_check_id TYPE char30
        iv_code TYPE char40
        iv_text TYPE char220
      CHANGING
        ct_finding TYPE /fcbp/if_glt_config_types=>tt_health_finding.

ENDCLASS.

CLASS /fcbp/cl_glt_adapter_capability IMPLEMENTATION.

  METHOD /fcbp/if_glt_adapter_capability~get_by_adapter_type.
    CASE iv_adapter_type.
      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-mock
        OR /fcbp/if_glt_adapter_types=>c_adapter_type-mock_adapter.
        rs_capability = VALUE #(
          adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-mock
          target_type = /fcbp/if_glt_config_types=>c_target_type-mock
          supports_submit = abap_true
          supports_status_query = abap_true
          supports_idempotency_key = abap_true
          supports_correlation_id = abap_true
          supports_sync_confirm = abap_true
          supports_async_confirm = abap_true
          supports_export_only = abap_true
          supports_cancel = abap_false
          max_lines = 9999
          max_payload_size = 1048576
          rate_limit = 0
          max_parallel = 10
          productive_allowed = abap_false
          matrix_complete = abap_true
          status_handle_types = 'TARGET_CORRELATION;BRIDGE_CORRELATION;IDEMPOTENCY_KEY'
          notes = 'Mock adapter is limited to tests and explicit POC profiles.' ).

      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-s4_public_cloud.
        rs_capability = VALUE #(
          adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-s4_public_cloud
          target_type = /fcbp/if_glt_config_types=>c_target_type-s4_public_cloud
          supports_submit = abap_true
          supports_status_query = abap_true
          supports_idempotency_key = abap_true
          supports_correlation_id = abap_true
          supports_sync_confirm = abap_true
          supports_async_confirm = abap_true
          productive_allowed = abap_false
          matrix_complete = abap_false
          status_handle_types = 'TARGET_DOCUMENT;TARGET_CORRELATION'
          notes = 'S/4 Public Cloud route requires final released API and capability matrix.' ).

      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-s4_private_cloud.
        rs_capability = VALUE #(
          adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-s4_private_cloud
          target_type = /fcbp/if_glt_config_types=>c_target_type-s4_private_cloud
          supports_submit = abap_true
          supports_status_query = abap_true
          supports_correlation_id = abap_true
          productive_allowed = abap_false
          matrix_complete = abap_false
          status_handle_types = 'TARGET_DOCUMENT;TARGET_CORRELATION'
          notes = 'S/4 Private Cloud route requires approved API/connectivity design.' ).

      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-integration_suite
        OR /fcbp/if_glt_adapter_types=>c_adapter_type-cpi.
        rs_capability = VALUE #(
          adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-integration_suite
          target_type = /fcbp/if_glt_config_types=>c_target_type-integration_suite
          supports_submit = abap_true
          supports_status_query = abap_true
          supports_idempotency_key = abap_true
          supports_correlation_id = abap_true
          supports_async_confirm = abap_true
          productive_allowed = abap_false
          matrix_complete = abap_false
          status_handle_types = 'MIDDLEWARE_MESSAGE;TARGET_CORRELATION'
          notes = 'Integration Suite route requires middleware status-query contract.' ).

      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-on_premise.
        rs_capability = VALUE #(
          adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-on_premise
          target_type = /fcbp/if_glt_config_types=>c_target_type-on_prem
          supports_submit = abap_true
          supports_status_query = abap_false
          supports_correlation_id = abap_true
          productive_allowed = abap_false
          matrix_complete = abap_false
          notes = 'On-premise route requires approved ABAP Cloud connectivity path.' ).

      WHEN OTHERS.
        rs_capability = VALUE #(
          adapter_type = iv_adapter_type
          productive_allowed = abap_false
          matrix_complete = abap_false
          notes = 'Adapter type is not registered.' ).
    ENDCASE.
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_capability~get_for_profile.
    rs_capability = /fcbp/if_glt_adapter_capability~get_by_adapter_type( is_profile-adapter_type ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_capability~validate_profile.
    DATA(ls_capability) = /fcbp/if_glt_adapter_capability~get_for_profile( is_profile ).

    IF ls_capability-adapter_type IS INITIAL OR ls_capability-matrix_complete = abap_false.
      add_finding(
        EXPORTING is_profile = is_profile
                  iv_check_id = 'GLT_ADP_C005'
                  iv_code = 'CAPABILITY_MATRIX_INCOMPLETE'
                  iv_text = 'Adapter capability matrix is missing or incomplete for this route.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF is_profile-adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-mock AND
       is_profile-target_type <> /fcbp/if_glt_config_types=>c_target_type-mock.
      add_finding(
        EXPORTING is_profile = is_profile
                  iv_check_id = 'GLT_ADP_MOCK'
                  iv_code = 'MOCK_NOT_PRODUCTIVE'
                  iv_text = 'Mock adapter can be active only on explicit mock/POC target profiles.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF is_profile-target_type <> /fcbp/if_glt_config_types=>c_target_type-mock AND
       is_profile-destination_alias IS INITIAL.
      add_finding(
        EXPORTING is_profile = is_profile
                  iv_check_id = 'GLT_ADP_C004'
                  iv_code = 'DESTINATION_MISSING'
                  iv_text = 'Non-mock adapter route requires a destination alias.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.

    IF is_profile-confirmation_mode = /fcbp/if_glt_types=>c_confirmation_mode-async_query AND
       ls_capability-supports_status_query = abap_false.
      add_finding(
        EXPORTING is_profile = is_profile
                  iv_check_id = 'GLT_ADP_C002'
                  iv_code = 'STATUS_QUERY_UNSUPPORTED'
                  iv_text = 'Configured confirmation mode requires adapter status-query support.'
        CHANGING ct_finding = rt_finding ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_adapter_capability~get_registered_catalog.
    APPEND /fcbp/if_glt_adapter_capability~get_by_adapter_type( /fcbp/if_glt_adapter_types=>c_adapter_type-mock ) TO rt_capability.
    APPEND /fcbp/if_glt_adapter_capability~get_by_adapter_type( /fcbp/if_glt_adapter_types=>c_adapter_type-s4_public_cloud ) TO rt_capability.
    APPEND /fcbp/if_glt_adapter_capability~get_by_adapter_type( /fcbp/if_glt_adapter_types=>c_adapter_type-s4_private_cloud ) TO rt_capability.
    APPEND /fcbp/if_glt_adapter_capability~get_by_adapter_type( /fcbp/if_glt_adapter_types=>c_adapter_type-integration_suite ) TO rt_capability.
    APPEND /fcbp/if_glt_adapter_capability~get_by_adapter_type( /fcbp/if_glt_adapter_types=>c_adapter_type-on_premise ) TO rt_capability.
  ENDMETHOD.

  METHOD add_finding.
    DATA(ls_finding) = VALUE /fcbp/if_glt_config_types=>ty_health_finding(
      health_run_id      = |ADP-{ sy-datum }-{ sy-uzeit }|
      target_id          = is_profile-target_id
      config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
      config_object_key  = is_profile-target_id
      check_id           = iv_check_id
      severity           = /fcbp/if_glt_types=>c_severity-error
      blocking_flag      = abap_true
      finding_code       = iv_code
      operator_text      = iv_text
      evidence_ref       = is_profile-adapter_type
      checked_by         = sy-uname ).
    GET TIME STAMP FIELD ls_finding-checked_at.
    APPEND ls_finding TO ct_finding.
  ENDMETHOD.

ENDCLASS.
