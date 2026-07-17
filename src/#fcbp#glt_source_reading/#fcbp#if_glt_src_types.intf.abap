"! Source Reading Layer DTOs and constants.
"! Source Reading is side-effect-free and returns package-builder source lines.
INTERFACE /fcbp/if_glt_src_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_source_type,
      reconciliation_key TYPE char20 VALUE 'RECONCILIATION_KEY',
      document           TYPE char20 VALUE 'DOCUMENT',
      mock               TYPE char20 VALUE 'MOCK',
    END OF c_source_type.

  CONSTANTS:
    BEGIN OF c_read_mode,
      dispatch TYPE char20 VALUE 'DISPATCH',
      rebuild  TYPE char20 VALUE 'REBUILD',
      replay   TYPE char20 VALUE 'REPLAY',
      support  TYPE char20 VALUE 'SUPPORT',
      dry_run  TYPE char20 VALUE 'DRY_RUN',
    END OF c_read_mode.

  CONSTANTS:
    BEGIN OF c_read_consistency,
      not_checked      TYPE char20 VALUE 'NOT_CHECKED',
      stable           TYPE char20 VALUE 'STABLE',
      snapshot_checked TYPE char20 VALUE 'SNAPSHOT_CHECKED',
      stale            TYPE char20 VALUE 'STALE',
    END OF c_read_consistency.

  CONSTANTS:
    BEGIN OF c_error_code,
      request_invalid TYPE char30 VALUE 'SOURCE_REQUEST_INVALID',
      unsupported_type TYPE char30 VALUE 'SOURCE_UNSUPPORTED_TYPE',
      not_found       TYPE char30 VALUE 'SOURCE_NOT_FOUND',
      not_ready       TYPE char30 VALUE 'SOURCE_NOT_READY',
      not_authorized  TYPE char30 VALUE 'SOURCE_NOT_AUTHORIZED',
      no_lines        TYPE char30 VALUE 'SOURCE_NO_LINES',
      conflict        TYPE char30 VALUE 'SOURCE_CONFLICT',
      inconsistent    TYPE char30 VALUE 'SOURCE_INCONSISTENT',
      hash_missing    TYPE char30 VALUE 'SOURCE_HASH_MISSING',
      stale           TYPE char30 VALUE 'SOURCE_STALE',
      technical       TYPE char30 VALUE 'SOURCE_READ_TECHNICAL',
    END OF c_error_code.

  CONSTANTS:
    BEGIN OF c_lifecycle_state,
      requested        TYPE char20 VALUE 'REQUESTED',
      prechecked       TYPE char20 VALUE 'PRECHECKED',
      source_confirmed TYPE char20 VALUE 'SOURCE_CONFIRMED',
      source_stable    TYPE char20 VALUE 'SOURCE_STABLE',
      lines_read       TYPE char20 VALUE 'LINES_READ',
      lines_normalized TYPE char20 VALUE 'LINES_NORMALIZED',
      hashed           TYPE char20 VALUE 'HASHED',
      returned         TYPE char20 VALUE 'RETURNED',
      failed           TYPE char20 VALUE 'FAILED',
    END OF c_lifecycle_state.

  CONSTANTS:
    BEGIN OF c_diag_status,
      started   TYPE char20 VALUE 'STARTED',
      completed TYPE char20 VALUE 'COMPLETED',
      failed    TYPE char20 VALUE 'FAILED',
      blocked   TYPE char20 VALUE 'BLOCKED',
    END OF c_diag_status.

  TYPES ty_source_snapshot_id TYPE char64.
  TYPES ty_source_hash TYPE char64.
  TYPES ty_source_read_id TYPE char32.

  TYPES: BEGIN OF ty_source_read_request,
           transfer_id          TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id           TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           source_type          TYPE char20,
           source_reference     TYPE char50,
           routing_bucket       TYPE char32,
           target_id            TYPE char20,
           policy_context_id    TYPE /fcbp/if_glt_config_types=>ty_policy_context_id,
           read_mode            TYPE char20,
           expected_snapshot_id TYPE ty_source_snapshot_id,
           previous_source_hash TYPE ty_source_hash,
           requested_by         TYPE syuname,
         END OF ty_source_read_request.

  TYPES: BEGIN OF ty_source_read_diag,
           lifecycle_state TYPE char20,
           error_code      TYPE char30,
           severity        TYPE char10,
           retryable       TYPE abap_bool,
           field_name      TYPE char40,
           source_doc_no   TYPE char20,
           source_item_no  TYPE numc6,
           operator_text   TYPE char220,
           technical_detail TYPE string,
         END OF ty_source_read_diag.
  TYPES tt_source_read_diag TYPE STANDARD TABLE OF ty_source_read_diag WITH EMPTY KEY.

  TYPES: BEGIN OF ty_source_read_result,
           request           TYPE ty_source_read_request,
           source_line       TYPE /fcbp/if_glt_pkg_types=>tt_source_gl_line,
           source_line_count TYPE i,
           source_hash       TYPE ty_source_hash,
           snapshot_id       TYPE ty_source_snapshot_id,
           read_consistency  TYPE char20,
           diagnostics       TYPE tt_source_read_diag,
         END OF ty_source_read_result.

  TYPES: BEGIN OF ty_recon_header,
           reconciliation_key TYPE char32,
           source_reference   TYPE char50,
           source_snapshot_id TYPE ty_source_snapshot_id,
           source_status      TYPE char30,
           closed_flag        TYPE abap_bool,
           frozen_flag        TYPE abap_bool,
           immutable_flag     TYPE abap_bool,
           company_code       TYPE char4,
           currency           TYPE c LENGTH 5,
           item_count         TYPE i,
           control_hash       TYPE char64,
         END OF ty_recon_header.

  TYPES: BEGIN OF ty_document_header,
           source_reference    TYPE char50,
           source_doc_no       TYPE char20,
           source_snapshot_id  TYPE ty_source_snapshot_id,
           source_status       TYPE char30,
           accounting_complete TYPE abap_bool,
           immutable_flag      TYPE abap_bool,
           company_code        TYPE char4,
           currency            TYPE c LENGTH 5,
           item_count          TYPE i,
           control_hash        TYPE char64,
         END OF ty_document_header.

  TYPES: BEGIN OF ty_source_projection_item,
           source_type           TYPE char20,
           source_reference      TYPE char50,
           source_doc_no         TYPE char20,
           source_item_no        TYPE numc6,
           reconciliation_key    TYPE char32,
           routing_bucket        TYPE char32,
           source_snapshot_id    TYPE ty_source_snapshot_id,
           immutable_source_hash TYPE char64,
           source_status         TYPE char30,
           source_version        TYPE char30,
           exclude_flag          TYPE abap_bool,
           sort_key              TYPE char80,
           company_code          TYPE char4,
           chart_of_accounts     TYPE char4,
           gl_account            TYPE char10,
           profit_center         TYPE char10,
           segment               TYPE char10,
           cost_center           TYPE char10,
           internal_order        TYPE char12,
           trading_partner       TYPE char10,
           amount                TYPE p LENGTH 16 DECIMALS 2,
           currency              TYPE c LENGTH 5,
           debit_credit          TYPE char1,
           tax_code              TYPE char2,
           tax_report_date       TYPE dats,
           posting_date          TYPE dats,
           document_type         TYPE char10,
           ledger_group          TYPE char10,
           assignment            TYPE char18,
           item_text             TYPE char50,
         END OF ty_source_projection_item.
  TYPES tt_source_projection_item TYPE STANDARD TABLE OF ty_source_projection_item WITH EMPTY KEY.

ENDINTERFACE.
