"! Test framework constants and DTOs for seeded happy-path execution.
INTERFACE /fcbp/if_glt_tst_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_scenario,
      happy_recon_post TYPE char30 VALUE 'HAPPY_RECON_POST',
    END OF c_scenario.

  CONSTANTS:
    BEGIN OF c_seed,
      source_reference TYPE char50 VALUE 'TST_RECON_0001',
      source_doc_no    TYPE char20 VALUE 'TSTDOC0001',
      company_code     TYPE char4 VALUE '1000',
      currency         TYPE c LENGTH 5 VALUE 'USD',
      target_id        TYPE char20 VALUE 'MOCK_S4',
      transfer_type    TYPE char20 VALUE 'SOURCE_HANDOFF',
      actor_id         TYPE char40 VALUE 'GLT_TEST',
    END OF c_seed.

  TYPES: BEGIN OF ty_target_doc,
           target_doc_no      TYPE char30,
           transfer_id        TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id         TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           outdoc_id          TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id,
           company_code       TYPE char4,
           fiscal_year        TYPE numc4,
           currency           TYPE c LENGTH 5,
           debit_amount       TYPE p LENGTH 16 DECIMALS 2,
           credit_amount      TYPE p LENGTH 16 DECIMALS 2,
           line_count         TYPE i,
           target_status      TYPE char20,
           correlation_id     TYPE /fcbp/if_glt_types=>ty_correlation_id,
           created_at         TYPE utclong,
         END OF ty_target_doc.
  TYPES tt_target_doc TYPE STANDARD TABLE OF ty_target_doc WITH EMPTY KEY.

  TYPES: BEGIN OF ty_run_result,
           scenario_id        TYPE char30,
           transfer_id        TYPE /fcbp/if_glt_types=>ty_transfer_id,
           outbox_id          TYPE /fcbp/if_glt_types=>ty_outbox_id,
           package_id         TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           policy_context_id  TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           validation_run_id  TYPE /fcbp/if_glt_val_types=>ty_validation_run_id,
           mapping_run_id     TYPE char32,
           target_doc_no      TYPE char30,
           final_status       TYPE /fcbp/if_glt_types=>ty_status,
           outbox_status      TYPE char12,
           validation_status  TYPE char20,
           mapping_status     TYPE char20,
           passed             TYPE abap_bool,
           message_text       TYPE char220,
         END OF ty_run_result.

ENDINTERFACE.
