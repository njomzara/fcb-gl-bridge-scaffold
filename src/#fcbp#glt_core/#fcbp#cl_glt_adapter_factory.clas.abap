"! Adapter lookup boundary. Selection is driven by configured target adapter type.
CLASS /fcbp/cl_glt_adapter_factory DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_capability TYPE REF TO /fcbp/if_glt_adapter_capability OPTIONAL.

    METHODS get_adapter
      IMPORTING
        is_route          TYPE /fcbp/if_glt_types=>ty_route
      RETURNING
        VALUE(ro_adapter) TYPE REF TO /fcbp/if_glt_transfer_adapter
      RAISING
        /fcbp/cx_glt_config.

    METHODS get_adapter_for_profile
      IMPORTING
        is_profile        TYPE /fcbp/if_glt_config_types=>ty_target_profile
      RETURNING
        VALUE(ro_adapter) TYPE REF TO /fcbp/if_glt_transfer_adapter
      RAISING
        /fcbp/cx_glt_config.

    METHODS get_registered_catalog
      RETURNING
        VALUE(rt_capability) TYPE /fcbp/if_glt_adapter_types=>tt_capability.

  PRIVATE SECTION.
    DATA mo_capability TYPE REF TO /fcbp/if_glt_adapter_capability.

    METHODS normalize_adapter_type
      IMPORTING
        iv_adapter_type        TYPE char30
      RETURNING
        VALUE(rv_adapter_type) TYPE char30.

    METHODS create_adapter
      IMPORTING
        iv_adapter_type   TYPE char30
      RETURNING
        VALUE(ro_adapter) TYPE REF TO /fcbp/if_glt_transfer_adapter
      RAISING
        /fcbp/cx_glt_config.

    METHODS ensure_mock_route_allowed
      IMPORTING
        is_route TYPE /fcbp/if_glt_types=>ty_route
      RAISING
        /fcbp/cx_glt_config.

    METHODS ensure_mock_profile_allowed
      IMPORTING
        is_profile TYPE /fcbp/if_glt_config_types=>ty_target_profile
      RAISING
        /fcbp/cx_glt_config.

ENDCLASS.

CLASS /fcbp/cl_glt_adapter_factory IMPLEMENTATION.

  METHOD constructor.
    IF io_capability IS BOUND.
      mo_capability = io_capability.
    ELSE.
      mo_capability = NEW /fcbp/cl_glt_adapter_capability( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_adapter.
    DATA(lv_adapter_type) = normalize_adapter_type( is_route-target_adapter ).
    IF lv_adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-mock.
      ensure_mock_route_allowed( is_route ).
    ENDIF.
    ro_adapter = create_adapter( lv_adapter_type ).
  ENDMETHOD.

  METHOD get_adapter_for_profile.
    DATA(lv_adapter_type) = normalize_adapter_type( is_profile-adapter_type ).
    IF lv_adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-mock.
      ensure_mock_profile_allowed( is_profile ).
    ENDIF.
    ro_adapter = create_adapter( lv_adapter_type ).
  ENDMETHOD.

  METHOD get_registered_catalog.
    rt_capability = mo_capability->get_registered_catalog( ).
  ENDMETHOD.

  METHOD normalize_adapter_type.
    CASE iv_adapter_type.
      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-mock
        OR /fcbp/if_glt_adapter_types=>c_adapter_type-mock_adapter.
        rv_adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-mock.
      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-cpi
        OR /fcbp/if_glt_adapter_types=>c_adapter_type-integration_suite.
        rv_adapter_type = /fcbp/if_glt_adapter_types=>c_adapter_type-integration_suite.
      WHEN OTHERS.
        rv_adapter_type = iv_adapter_type.
    ENDCASE.
  ENDMETHOD.

  METHOD create_adapter.
    CASE iv_adapter_type.
      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-mock.
        ro_adapter = NEW /fcbp/cl_glt_adapter_mock( ).
      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-s4_public_cloud.
        ro_adapter = NEW /fcbp/cl_glt_adapter_s4pub( ).
      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-s4_private_cloud.
        ro_adapter = NEW /fcbp/cl_glt_adapter_s4prv( ).
      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-integration_suite.
        ro_adapter = NEW /fcbp/cl_glt_adapter_cpi( ).
      WHEN /fcbp/if_glt_adapter_types=>c_adapter_type-on_premise.
        ro_adapter = NEW /fcbp/cl_glt_adapter_onprem( ).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE /fcbp/cx_glt_config
          EXPORTING
            error_category     = /fcbp/if_glt_types=>c_error_category-config
            reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-unsupported
            config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
            operator_text      = |Adapter { iv_adapter_type } is not registered in the scaffold.|.
    ENDCASE.
  ENDMETHOD.

  METHOD ensure_mock_route_allowed.
    IF is_route-target_system CP '*MOCK*'
       OR is_route-feature_switch_set CP '*ALLOW_MOCK*'
       OR is_route-feature_switch_set CP '*POC*'.
      RETURN.
    ENDIF.

    RAISE EXCEPTION TYPE /fcbp/cx_glt_config
      EXPORTING
        error_category     = /fcbp/if_glt_types=>c_error_category-config
        reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-unsupported
        config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
        config_object_key  = is_route-route_id
        operator_text      = 'Mock adapter requires explicit POC/mock route configuration.'.
  ENDMETHOD.

  METHOD ensure_mock_profile_allowed.
    IF is_profile-target_type = /fcbp/if_glt_config_types=>c_target_type-mock.
      RETURN.
    ENDIF.

    RAISE EXCEPTION TYPE /fcbp/cx_glt_config
      EXPORTING
        error_category     = /fcbp/if_glt_types=>c_error_category-config
        reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-unsupported
        config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
        config_object_key  = is_profile-target_id
        target_id          = is_profile-target_id
        operator_text      = 'Mock adapter can be selected only by explicit mock target profiles.'.
  ENDMETHOD.

ENDCLASS.
