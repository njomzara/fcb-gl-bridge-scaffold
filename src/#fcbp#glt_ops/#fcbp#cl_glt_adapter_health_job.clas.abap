"! Application job shell for adapter destination and capability health checks.
CLASS /fcbp/cl_glt_adapter_health_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_factory    TYPE REF TO /fcbp/cl_glt_adapter_factory OPTIONAL
        io_repository TYPE REF TO /fcbp/if_glt_config_repo OPTIONAL.

    METHODS execute
      IMPORTING
        iv_target_id TYPE char20 OPTIONAL
      RAISING
        /fcbp/cx_glt_error.

  PRIVATE SECTION.
    DATA mo_factory TYPE REF TO /fcbp/cl_glt_adapter_factory.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_config_repo.

ENDCLASS.

CLASS /fcbp/cl_glt_adapter_health_job IMPLEMENTATION.

  METHOD constructor.
    IF io_factory IS BOUND.
      mo_factory = io_factory.
    ELSE.
      mo_factory = NEW /fcbp/cl_glt_adapter_factory( ).
    ENDIF.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD execute.
    IF mo_repository IS NOT BOUND OR iv_target_id IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = 'Adapter health job requires a configuration repository and target ID in the scaffold.'.
    ENDIF.

    DATA(ls_profile) = mo_repository->read_target_profile( iv_target_id ).
    DATA(lo_adapter) = mo_factory->get_adapter_for_profile( ls_profile ).
    DATA(ls_connection) = lo_adapter->validate_connection( ls_profile ).
    IF ls_connection-blocking = abap_true.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-config
          operator_text  = ls_connection-operator_text.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
