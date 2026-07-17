"! Assembles the in-memory happy-path test harness.
CLASS /fcbp/cl_glt_tst_factory DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor.

    METHODS get_store
      RETURNING
        VALUE(ro_store) TYPE REF TO /fcbp/cl_glt_tst_store.

    METHODS get_repo
      RETURNING
        VALUE(ro_repo) TYPE REF TO /fcbp/cl_glt_tst_repo.

    METHODS create_seed
      RETURNING
        VALUE(ro_seed) TYPE REF TO /fcbp/cl_glt_tst_seed.

    METHODS create_config_provider
      RETURNING
        VALUE(ro_provider) TYPE REF TO /fcbp/if_glt_config_provider.

    METHODS create_handoff_receiver
      RETURNING
        VALUE(ro_receiver) TYPE REF TO /fcbp/if_glt_handoff_receiver.

    METHODS create_dispatcher
      RETURNING
        VALUE(ro_dispatcher) TYPE REF TO /fcbp/if_glt_outbox_dispatcher.

  PRIVATE SECTION.
    DATA mo_store TYPE REF TO /fcbp/cl_glt_tst_store.
    DATA mo_repo TYPE REF TO /fcbp/cl_glt_tst_repo.

ENDCLASS.

CLASS /fcbp/cl_glt_tst_factory IMPLEMENTATION.

  METHOD constructor.
    mo_store = NEW /fcbp/cl_glt_tst_store( ).
    mo_repo = NEW /fcbp/cl_glt_tst_repo( io_store = mo_store ).
  ENDMETHOD.

  METHOD get_store.
    ro_store = mo_store.
  ENDMETHOD.

  METHOD get_repo.
    ro_repo = mo_repo.
  ENDMETHOD.

  METHOD create_seed.
    ro_seed = NEW /fcbp/cl_glt_tst_seed( io_store = mo_store ).
  ENDMETHOD.

  METHOD create_config_provider.
    ro_provider = NEW /fcbp/cl_glt_config_provider(
      io_config_repo    = mo_repo
      io_policy_context = NEW /fcbp/cl_glt_policy_context( io_repository = mo_repo ) ).
  ENDMETHOD.

  METHOD create_handoff_receiver.
    DATA(lo_config_provider) = create_config_provider( ).

    ro_receiver = NEW /fcbp/cl_glt_handoff_receiver(
      io_validator        = NEW /fcbp/cl_glt_handoff_validator( )
      io_profile_resolver = NEW /fcbp/cl_glt_profile_resolver( io_config_provider = lo_config_provider )
      io_key_builder      = NEW /fcbp/cl_glt_reg_key_builder( )
      io_registry         = NEW /fcbp/cl_glt_source_registry( io_repository = mo_repo )
      io_factory          = NEW /fcbp/cl_glt_handoff_factory( )
      io_repository       = mo_repo
      io_outbox           = NEW /fcbp/cl_glt_outbox_enqueuer( io_repository = mo_repo )
      io_audit            = NEW /fcbp/cl_glt_audit_writer( io_repository = mo_repo )
      io_logger           = NEW /fcbp/cl_glt_handoff_logger( io_logger = NEW /fcbp/cl_glt_app_logger( ) ) ).
  ENDMETHOD.

  METHOD create_dispatcher.
    DATA(lo_dispatch_handler) = NEW /fcbp/cl_glt_tst_wh_dispatch(
      io_repo            = mo_repo
      io_config_provider = create_config_provider( ) ).
    DATA(lo_registry) = NEW /fcbp/cl_glt_work_handler_reg( io_dispatch = lo_dispatch_handler ).

    ro_dispatcher = NEW /fcbp/cl_glt_outbox_dispatcher(
      io_repo     = mo_repo
      io_registry = lo_registry ).
  ENDMETHOD.

ENDCLASS.
