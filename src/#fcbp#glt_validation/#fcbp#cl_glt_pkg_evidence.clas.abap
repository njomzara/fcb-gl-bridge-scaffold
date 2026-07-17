"! Package evidence reader scaffold used by package validation.
CLASS /fcbp/cl_glt_pkg_evidence DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_pkg_evidence.

    METHODS constructor
      IMPORTING
        io_transfer_repo TYPE REF TO /fcbp/if_glt_repository OPTIONAL
        io_package_repo  TYPE REF TO /fcbp/if_glt_package_repo OPTIONAL
        io_config_repo   TYPE REF TO /fcbp/if_glt_config_repo OPTIONAL.

  PRIVATE SECTION.
    DATA mo_transfer_repo TYPE REF TO /fcbp/if_glt_repository.
    DATA mo_package_repo TYPE REF TO /fcbp/if_glt_package_repo.
    DATA mo_config_repo TYPE REF TO /fcbp/if_glt_config_repo.

ENDCLASS.

CLASS /fcbp/cl_glt_pkg_evidence IMPLEMENTATION.

  METHOD constructor.
    IF io_transfer_repo IS BOUND.
      mo_transfer_repo = io_transfer_repo.
    ELSE.
      mo_transfer_repo = NEW /fcbp/cl_glt_repository( ).
    ENDIF.

    IF io_package_repo IS BOUND.
      mo_package_repo = io_package_repo.
    ELSE.
      mo_package_repo = NEW /fcbp/cl_glt_package_repo( ).
    ENDIF.

    IF io_config_repo IS BOUND.
      mo_config_repo = io_config_repo.
    ELSE.
      mo_config_repo = NEW /fcbp/cl_glt_config_repo( ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_pkg_evidence~read_for_validation.
    IF mo_transfer_repo IS NOT BOUND OR mo_package_repo IS NOT BOUND OR mo_config_repo IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_validation
        EXPORTING
          transfer_id    = iv_transfer_id
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Package validation evidence reader requires transfer, package, and configuration repositories.'.
    ENDIF.

    TRY.
        rs_evidence-transfer = mo_transfer_repo->read_transfer( iv_transfer_id ).
        rs_evidence-transfer_found = abap_true.

        rs_evidence-package_graph = mo_package_repo->read_package( iv_package_id ).
        rs_evidence-package_found = abap_true.

        rs_evidence-policy_context = mo_config_repo->read_policy_context( iv_policy_context_id ).
        rs_evidence-policy_context_found = abap_true.

        IF rs_evidence-policy_context-target_id IS NOT INITIAL.
          rs_evidence-target_profile = mo_config_repo->read_target_profile( rs_evidence-policy_context-target_id ).
          rs_evidence-target_profile_found = abap_true.
        ENDIF.

        IF rs_evidence-policy_context-validation_profile_id IS NOT INITIAL.
          rs_evidence-validation_rules = mo_config_repo->read_validation_rules(
            iv_profile_id = rs_evidence-policy_context-validation_profile_id
            iv_version    = rs_evidence-policy_context-validation_version ).
        ENDIF.

        rs_evidence-target_refs = rs_evidence-transfer-target_refs.
      CATCH /fcbp/cx_glt_repository INTO DATA(lx_repo).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_validation
          EXPORTING
            transfer_id    = iv_transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-repository
            operator_text  = 'Package validation evidence could not be read from repository.'
            previous       = lx_repo.
      CATCH /fcbp/cx_glt_config INTO DATA(lx_config).
        RAISE EXCEPTION TYPE /fcbp/cx_glt_validation
          EXPORTING
            transfer_id    = iv_transfer_id
            error_category = /fcbp/if_glt_types=>c_error_category-config
            operator_text  = 'Package validation configuration evidence could not be resolved.'
            previous       = lx_config.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
