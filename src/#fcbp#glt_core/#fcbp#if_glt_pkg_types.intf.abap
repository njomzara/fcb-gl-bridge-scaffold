"! Shared package graph DTOs for Source Reading, Aggregation/Split, Package Builder, Validation, and Mapping.
INTERFACE /fcbp/if_glt_pkg_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_package_status,
      prepared   TYPE char20 VALUE 'PREPARED',
      current    TYPE char20 VALUE 'CURRENT',
      superseded TYPE char20 VALUE 'SUPERSEDED',
      failed     TYPE char20 VALUE 'FAILED',
    END OF c_package_status.

  CONSTANTS:
    BEGIN OF c_grouping_mode,
      none         TYPE char20 VALUE 'NONE',
      by_signature TYPE char20 VALUE 'BY_SIGNATURE',
    END OF c_grouping_mode.

  CONSTANTS:
    BEGIN OF c_balance_status,
      balanced    TYPE char20 VALUE 'BALANCED',
      unbalanced  TYPE char20 VALUE 'UNBALANCED',
      not_checked TYPE char20 VALUE 'NOT_CHECKED',
    END OF c_balance_status.

  CONSTANTS:
    BEGIN OF c_balance_scope,
      document                     TYPE char30 VALUE 'DOCUMENT',
      company_code_currency        TYPE char30 VALUE 'COMPANY_CODE_CURRENCY',
      company_code_currency_ledger TYPE char30 VALUE 'COMPANY_CODE_CURRENCY_LEDGER',
      document_currency_ledger     TYPE char30 VALUE 'DOCUMENT_CURRENCY_LEDGER',
    END OF c_balance_scope.

  CONSTANTS:
    BEGIN OF c_normalize_rule,
      none       TYPE char30 VALUE 'NONE',
      upper_trim TYPE char30 VALUE 'UPPER_TRIM',
      alpha      TYPE char30 VALUE 'ALPHA',
      blank      TYPE char30 VALUE 'BLANK',
      date       TYPE char30 VALUE 'DATE',
    END OF c_normalize_rule.

  TYPES ty_package_id TYPE char32.
  TYPES ty_outdoc_id TYPE char32.
  TYPES ty_line_id TYPE char32.
  TYPES ty_trace_id TYPE char32.

  TYPES: BEGIN OF ty_package_build_context,
           transfer_id           TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id            TYPE ty_package_id,
           predecessor_package_id TYPE ty_package_id,
           package_version       TYPE i,
           source_type           TYPE char20,
           source_reference      TYPE char50,
           target_id             TYPE char20,
           policy_context_id     TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           posting_date          TYPE dats,
           document_date         TYPE dats,
           gl_doc_type           TYPE char10,
           ledger_group          TYPE char10,
           requested_by          TYPE syuname,
           rebuild_reason        TYPE char30,
         END OF ty_package_build_context.

  TYPES: BEGIN OF ty_source_gl_line,
           source_type          TYPE char20,
           source_reference     TYPE char50,
           source_doc_no        TYPE char20,
           source_item_no       TYPE numc6,
           reconciliation_key   TYPE char32,
           company_code         TYPE char4,
           chart_of_accounts    TYPE char4,
           gl_account           TYPE char10,
           profit_center        TYPE char10,
           segment              TYPE char10,
           cost_center          TYPE char10,
           internal_order       TYPE char12,
           trading_partner      TYPE char10,
           amount               TYPE p LENGTH 16 DECIMALS 2,
           currency             TYPE c LENGTH 5,
           debit_credit         TYPE char1,
           tax_code             TYPE char2,
           tax_report_date      TYPE dats,
           posting_date         TYPE dats,
           document_type        TYPE char10,
           ledger_group         TYPE char10,
           assignment           TYPE char18,
           item_text            TYPE char50,
           source_hash          TYPE char64,
           line_hash            TYPE char64,
         END OF ty_source_gl_line.
  TYPES tt_source_gl_line TYPE STANDARD TABLE OF ty_source_gl_line WITH EMPTY KEY.

  TYPES: BEGIN OF ty_package_header,
           package_id             TYPE ty_package_id,
           transfer_id            TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_version        TYPE i,
           current_flag           TYPE abap_bool,
           package_status         TYPE char20,
           predecessor_package_id TYPE ty_package_id,
           superseded_by_package_id TYPE ty_package_id,
           source_type            TYPE char20,
           source_reference       TYPE char50,
           target_id              TYPE char20,
           policy_context_id      TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           aggregation_profile_id TYPE char20,
           aggregation_version    TYPE i,
           aggregation_hash       TYPE char64,
           split_profile_id       TYPE char20,
           split_version          TYPE i,
           split_hash             TYPE char64,
           source_hash            TYPE char64,
           aggregation_output_hash TYPE char64,
           split_output_hash      TYPE char64,
           payload_hash           TYPE char64,
           outdoc_count           TYPE i,
           canonical_line_count   TYPE i,
           trace_count            TYPE i,
           created_by             TYPE syuname,
           created_at             TYPE utclong,
         END OF ty_package_header.
  TYPES tt_package_header TYPE STANDARD TABLE OF ty_package_header WITH EMPTY KEY.

  TYPES: BEGIN OF ty_outdoc,
           package_id        TYPE ty_package_id,
           outdoc_id         TYPE ty_outdoc_id,
           document_sequence TYPE i,
           company_code      TYPE char4,
           posting_date      TYPE dats,
           document_date     TYPE dats,
           gl_doc_type       TYPE char10,
           currency          TYPE c LENGTH 5,
           ledger_group      TYPE char10,
           reference         TYPE char50,
           header_text       TYPE char80,
           balance_status    TYPE char20,
           debit_amount      TYPE p LENGTH 16 DECIMALS 2,
           credit_amount     TYPE p LENGTH 16 DECIMALS 2,
           difference_amount TYPE p LENGTH 16 DECIMALS 2,
           line_count        TYPE i,
           payload_hash      TYPE char64,
         END OF ty_outdoc.
  TYPES tt_outdoc TYPE STANDARD TABLE OF ty_outdoc WITH EMPTY KEY.

  TYPES: BEGIN OF ty_canonical_line,
           package_id           TYPE ty_package_id,
           outdoc_id            TYPE ty_outdoc_id,
           line_id              TYPE ty_line_id,
           line_no              TYPE numc6,
           company_code         TYPE char4,
           chart_of_accounts    TYPE char4,
           gl_account           TYPE char10,
           debit_credit         TYPE char1,
           amount               TYPE p LENGTH 16 DECIMALS 2,
           currency             TYPE c LENGTH 5,
           profit_center        TYPE char10,
           segment              TYPE char10,
           cost_center          TYPE char10,
           internal_order       TYPE char12,
           trading_partner      TYPE char10,
           tax_code             TYPE char2,
           tax_report_date      TYPE dats,
           posting_date         TYPE dats,
           document_type        TYPE char10,
           ledger_group         TYPE char10,
           assignment           TYPE char18,
           item_text            TYPE char50,
           aggr_signature_hash  TYPE char64,
           source_count         TYPE i,
           line_hash            TYPE char64,
         END OF ty_canonical_line.
  TYPES tt_canonical_line TYPE STANDARD TABLE OF ty_canonical_line WITH EMPTY KEY.

  TYPES: BEGIN OF ty_source_trace,
           package_id                TYPE ty_package_id,
           outdoc_id                 TYPE ty_outdoc_id,
           line_id                   TYPE ty_line_id,
           line_no                   TYPE numc6,
           trace_id                  TYPE ty_trace_id,
           trace_sequence            TYPE i,
           source_type               TYPE char20,
           source_reference          TYPE char50,
           source_doc_no             TYPE char20,
           source_item_no            TYPE numc6,
           reconciliation_key        TYPE char32,
           company_code              TYPE char4,
           source_amount             TYPE p LENGTH 16 DECIMALS 2,
           source_currency           TYPE c LENGTH 5,
           source_hash               TYPE char64,
           contribution_ratio        TYPE p LENGTH 9 DECIMALS 6,
           contribution_amount       TYPE p LENGTH 16 DECIMALS 2,
           source_dimension_snapshot TYPE char255,
         END OF ty_source_trace.
  TYPES tt_source_trace TYPE STANDARD TABLE OF ty_source_trace WITH EMPTY KEY.

  TYPES: BEGIN OF ty_package_graph,
           package_header TYPE ty_package_header,
           outdocs        TYPE tt_outdoc,
           canonical_lines TYPE tt_canonical_line,
           source_trace    TYPE tt_source_trace,
         END OF ty_package_graph.

ENDINTERFACE.
