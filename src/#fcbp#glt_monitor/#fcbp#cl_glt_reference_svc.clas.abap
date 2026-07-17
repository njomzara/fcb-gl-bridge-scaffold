"! Target reference service that couples confirmation evidence with POSTED status.
CLASS /fcbp/cl_glt_reference_svc DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_reference_svc.

    METHODS constructor
      IMPORTING
        io_repository     TYPE REF TO /fcbp/if_glt_monitor_repo OPTIONAL
        io_status_manager TYPE REF TO /fcbp/if_glt_status_manager OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_monitor_repo.
    DATA mo_status_manager TYPE REF TO /fcbp/if_glt_status_manager.

    METHODS ensure_services
      RAISING
        /fcbp/cx_glt_error.

    METHODS assert_target_ref
      IMPORTING
        is_target_ref TYPE /fcbp/if_glt_types=>ty_target_ref
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_reference_svc IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    mo_status_manager = io_status_manager.
  ENDMETHOD.

  METHOD /fcbp/if_glt_reference_svc~record_confirmation.
    ensure_services( ).

    DATA(ls_ref) = is_target_ref.
    assert_target_ref( ls_ref ).

    IF ls_ref-confirmed_at IS INITIAL.
      GET TIME STAMP FIELD ls_ref-confirmed_at.
    ENDIF.
    IF ls_ref-created_at IS INITIAL.
      ls_ref-created_at = ls_ref-confirmed_at.
    ENDIF.

    rv_ref_id = mo_repository->insert_target_ref( ls_ref ).

    mo_status_manager->set_status(
      iv_transfer_id = ls_ref-transfer_id
      iv_status      = /fcbp/if_glt_types=>c_status-posted
      iv_reason      = iv_reason
      iv_actor_type  = /fcbp/if_glt_types=>c_actor_type-system
      iv_actor_id    = iv_actor_id ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_reference_svc~assert_posting_evidence.
    IF is_transfer-target_refs IS INITIAL.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_transfer-header-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = 'POSTED status requires target reference evidence.'.
    ENDIF.
  ENDMETHOD.

  METHOD ensure_services.
    IF mo_repository IS NOT BOUND OR mo_status_manager IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Reference service requires repository and status manager implementations.'.
    ENDIF.
  ENDMETHOD.

  METHOD assert_target_ref.
    IF is_target_ref-transfer_id IS INITIAL OR
       ( is_target_ref-target_doc_no IS INITIAL AND
         is_target_ref-target_corr_id IS INITIAL AND
         is_target_ref-raw_ref_hash IS INITIAL ).
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          transfer_id    = is_target_ref-transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-technical
          operator_text  = 'Target confirmation must include transfer and target evidence.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
