"! Aggregation/Split runtime result and diagnostic DTOs.
INTERFACE /fcbp/if_glt_aggr_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_prep_category,
      aggregation TYPE char30 VALUE 'PREPARATION_AGGREGATION',
      split       TYPE char30 VALUE 'PREPARATION_SPLIT',
      trace       TYPE char30 VALUE 'PREPARATION_TRACE',
      balance     TYPE char30 VALUE 'PREPARATION_BALANCE',
      config      TYPE char30 VALUE 'CONFIG',
      technical   TYPE char30 VALUE 'TECHNICAL',
    END OF c_prep_category.

  TYPES: BEGIN OF ty_preparation_message,
           rule_id          TYPE char30,
           category         TYPE char30,
           severity         TYPE char10,
           blocking         TYPE abap_bool,
           field_name       TYPE char40,
           package_id       TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           outdoc_id        TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id,
           line_id          TYPE /fcbp/if_glt_pkg_types=>ty_line_id,
           source_reference TYPE char50,
           operator_text    TYPE char220,
           technical_ref    TYPE string,
         END OF ty_preparation_message.
  TYPES tt_preparation_message TYPE STANDARD TABLE OF ty_preparation_message WITH EMPTY KEY.

  TYPES: BEGIN OF ty_signature_result,
           signature_string TYPE string,
           signature_hash   TYPE char64,
           blocking         TYPE abap_bool,
           message          TYPE ty_preparation_message,
         END OF ty_signature_result.

  TYPES: BEGIN OF ty_aggregation_result,
           canonical_lines        TYPE /fcbp/if_glt_pkg_types=>tt_canonical_line,
           source_trace           TYPE /fcbp/if_glt_pkg_types=>tt_source_trace,
           messages               TYPE tt_preparation_message,
           source_hash            TYPE char64,
           aggregation_output_hash TYPE char64,
           signature_count        TYPE i,
         END OF ty_aggregation_result.

  TYPES: BEGIN OF ty_split_key,
           split_key       TYPE string,
           split_key_hash  TYPE char64,
           company_code    TYPE char4,
           currency        TYPE c LENGTH 5,
           posting_date    TYPE dats,
           document_type   TYPE char10,
           ledger_group    TYPE char10,
         END OF ty_split_key.

  TYPES: BEGIN OF ty_balance_result,
           package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           outdoc_id         TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id,
           balance_scope     TYPE char30,
           company_code      TYPE char4,
           currency          TYPE c LENGTH 5,
           ledger_group      TYPE char10,
           debit_amount      TYPE p LENGTH 16 DECIMALS 2,
           credit_amount     TYPE p LENGTH 16 DECIMALS 2,
           difference_amount TYPE p LENGTH 16 DECIMALS 2,
           balance_status    TYPE char20,
           blocking          TYPE abap_bool,
           message           TYPE ty_preparation_message,
         END OF ty_balance_result.
  TYPES tt_balance_result TYPE STANDARD TABLE OF ty_balance_result WITH EMPTY KEY.

  TYPES: BEGIN OF ty_split_result,
           outdocs          TYPE /fcbp/if_glt_pkg_types=>tt_outdoc,
           canonical_lines  TYPE /fcbp/if_glt_pkg_types=>tt_canonical_line,
           source_trace     TYPE /fcbp/if_glt_pkg_types=>tt_source_trace,
           balance_results  TYPE tt_balance_result,
           messages         TYPE tt_preparation_message,
           split_output_hash TYPE char64,
         END OF ty_split_result.

  TYPES: BEGIN OF ty_package_build_result,
           graph            TYPE /fcbp/if_glt_pkg_types=>ty_package_graph,
           messages         TYPE tt_preparation_message,
           accepted         TYPE abap_bool,
           reusable_package TYPE abap_bool,
           package_hash     TYPE char64,
         END OF ty_package_build_result.

ENDINTERFACE.
