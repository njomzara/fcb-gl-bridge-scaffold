"! Structured Source Reading failure with source scope and retry semantics.
CLASS /fcbp/cx_glt_source_read DEFINITION PUBLIC INHERITING FROM /fcbp/cx_glt_error FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    DATA package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id READ-ONLY.
    DATA source_type       TYPE char20 READ-ONLY.
    DATA source_reference  TYPE char50 READ-ONLY.
    DATA routing_bucket    TYPE char32 READ-ONLY.
    DATA target_id         TYPE char20 READ-ONLY.
    DATA policy_context_id TYPE /fcbp/if_glt_config_types=>ty_policy_context_id READ-ONLY.
    DATA error_code        TYPE char30 READ-ONLY.
    DATA field_name        TYPE char40 READ-ONLY.
    DATA snapshot_id       TYPE /fcbp/if_glt_src_types=>ty_source_snapshot_id READ-ONLY.

    METHODS constructor
      IMPORTING
        package_id           TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
        source_type          TYPE char20 OPTIONAL
        source_reference     TYPE char50 OPTIONAL
        routing_bucket       TYPE char32 OPTIONAL
        target_id            TYPE char20 OPTIONAL
        policy_context_id    TYPE /fcbp/if_glt_config_types=>ty_policy_context_id OPTIONAL
        error_code           TYPE char30 OPTIONAL
        field_name           TYPE char40 OPTIONAL
        snapshot_id          TYPE /fcbp/if_glt_src_types=>ty_source_snapshot_id OPTIONAL
        transfer_id          TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
        correlation_id       TYPE /fcbp/if_glt_types=>ty_correlation_id OPTIONAL
        idempotency_key      TYPE /fcbp/if_glt_types=>ty_idempotency_key OPTIONAL
        error_category       TYPE char24 DEFAULT /fcbp/if_glt_types=>c_error_category-technical
        retryable            TYPE abap_bool DEFAULT abap_false
        unknown_confirmation TYPE abap_bool DEFAULT abap_false
        operator_text        TYPE char220 OPTIONAL
        technical_reference  TYPE string OPTIONAL
        textid               LIKE if_t100_message=>t100key OPTIONAL
        previous             TYPE REF TO cx_root OPTIONAL.

    CLASS-METHODS from_request
      IMPORTING
        is_request           TYPE /fcbp/if_glt_src_types=>ty_source_read_request
        iv_error_code        TYPE char30
        iv_retryable         TYPE abap_bool DEFAULT abap_false
        iv_field_name        TYPE char40 OPTIONAL
        iv_operator_text     TYPE char220 OPTIONAL
        iv_technical_reference TYPE string OPTIONAL
        ix_previous          TYPE REF TO cx_root OPTIONAL
      RETURNING
        VALUE(ro_error)      TYPE REF TO /fcbp/cx_glt_source_read.

    CLASS-METHODS not_found
      IMPORTING
        is_request      TYPE /fcbp/if_glt_src_types=>ty_source_read_request
      RETURNING
        VALUE(ro_error) TYPE REF TO /fcbp/cx_glt_source_read.

    CLASS-METHODS not_ready
      IMPORTING
        is_request      TYPE /fcbp/if_glt_src_types=>ty_source_read_request
        iv_detail       TYPE string OPTIONAL
      RETURNING
        VALUE(ro_error) TYPE REF TO /fcbp/cx_glt_source_read.

    CLASS-METHODS not_authorized
      IMPORTING
        is_request      TYPE /fcbp/if_glt_src_types=>ty_source_read_request
        ix_previous     TYPE REF TO cx_root OPTIONAL
      RETURNING
        VALUE(ro_error) TYPE REF TO /fcbp/cx_glt_source_read.

    CLASS-METHODS no_lines
      IMPORTING
        is_request      TYPE /fcbp/if_glt_src_types=>ty_source_read_request
      RETURNING
        VALUE(ro_error) TYPE REF TO /fcbp/cx_glt_source_read.

    CLASS-METHODS unsupported_type
      IMPORTING
        is_request      TYPE /fcbp/if_glt_src_types=>ty_source_read_request
      RETURNING
        VALUE(ro_error) TYPE REF TO /fcbp/cx_glt_source_read.

    CLASS-METHODS inconsistent
      IMPORTING
        is_request      TYPE /fcbp/if_glt_src_types=>ty_source_read_request
        iv_field_name   TYPE char40 OPTIONAL
        iv_detail       TYPE string OPTIONAL
      RETURNING
        VALUE(ro_error) TYPE REF TO /fcbp/cx_glt_source_read.

    CLASS-METHODS technical_failure
      IMPORTING
        is_request      TYPE /fcbp/if_glt_src_types=>ty_source_read_request
        iv_detail       TYPE string OPTIONAL
        ix_previous     TYPE REF TO cx_root OPTIONAL
      RETURNING
        VALUE(ro_error) TYPE REF TO /fcbp/cx_glt_source_read.

ENDCLASS.

CLASS /fcbp/cx_glt_source_read IMPLEMENTATION.

  METHOD constructor.
    super->constructor(
      transfer_id          = transfer_id
      correlation_id       = correlation_id
      idempotency_key      = idempotency_key
      error_category       = error_category
      retryable            = retryable
      unknown_confirmation = unknown_confirmation
      operator_text        = operator_text
      technical_reference  = technical_reference
      textid               = textid
      previous             = previous ).
    me->package_id = package_id.
    me->source_type = source_type.
    me->source_reference = source_reference.
    me->routing_bucket = routing_bucket.
    me->target_id = target_id.
    me->policy_context_id = policy_context_id.
    me->error_code = error_code.
    me->field_name = field_name.
    me->snapshot_id = snapshot_id.
  ENDMETHOD.

  METHOD from_request.
    DATA(lv_category) = COND char24(
      WHEN iv_error_code = /fcbp/if_glt_src_types=>c_error_code-not_authorized
      THEN /fcbp/if_glt_types=>c_error_category-authorization
      WHEN iv_error_code = /fcbp/if_glt_src_types=>c_error_code-technical
      THEN /fcbp/if_glt_types=>c_error_category-repository
      ELSE /fcbp/if_glt_types=>c_error_category-technical ).

    ro_error = NEW /fcbp/cx_glt_source_read(
      package_id          = is_request-package_id
      source_type         = is_request-source_type
      source_reference    = is_request-source_reference
      routing_bucket      = is_request-routing_bucket
      target_id           = is_request-target_id
      policy_context_id   = is_request-policy_context_id
      error_code          = iv_error_code
      field_name          = iv_field_name
      snapshot_id         = is_request-expected_snapshot_id
      transfer_id         = is_request-transfer_id
      error_category      = lv_category
      retryable           = iv_retryable
      operator_text       = iv_operator_text
      technical_reference = iv_technical_reference
      previous            = ix_previous ).
  ENDMETHOD.

  METHOD not_found.
    ro_error = from_request(
      is_request       = is_request
      iv_error_code    = /fcbp/if_glt_src_types=>c_error_code-not_found
      iv_operator_text = |Source { is_request-source_type }/{ is_request-source_reference } was not found.| ).
  ENDMETHOD.

  METHOD not_ready.
    ro_error = from_request(
      is_request             = is_request
      iv_error_code          = /fcbp/if_glt_src_types=>c_error_code-not_ready
      iv_retryable           = abap_true
      iv_operator_text       = |Source { is_request-source_type }/{ is_request-source_reference } is not stable for transfer.|
      iv_technical_reference = iv_detail ).
  ENDMETHOD.

  METHOD not_authorized.
    ro_error = from_request(
      is_request       = is_request
      iv_error_code    = /fcbp/if_glt_src_types=>c_error_code-not_authorized
      iv_operator_text = |Not authorized to read source { is_request-source_type }/{ is_request-source_reference }.|
      ix_previous      = ix_previous ).
  ENDMETHOD.

  METHOD no_lines.
    ro_error = from_request(
      is_request       = is_request
      iv_error_code    = /fcbp/if_glt_src_types=>c_error_code-no_lines
      iv_operator_text = |Source { is_request-source_type }/{ is_request-source_reference } returned no eligible GL lines.| ).
  ENDMETHOD.

  METHOD unsupported_type.
    ro_error = from_request(
      is_request       = is_request
      iv_error_code    = /fcbp/if_glt_src_types=>c_error_code-unsupported_type
      iv_operator_text = |Source type { is_request-source_type } is not supported by Source Reading.| ).
  ENDMETHOD.

  METHOD inconsistent.
    ro_error = from_request(
      is_request             = is_request
      iv_error_code          = /fcbp/if_glt_src_types=>c_error_code-inconsistent
      iv_field_name          = iv_field_name
      iv_operator_text       = |Source { is_request-source_type }/{ is_request-source_reference } is inconsistent.|
      iv_technical_reference = iv_detail ).
  ENDMETHOD.

  METHOD technical_failure.
    ro_error = from_request(
      is_request             = is_request
      iv_error_code          = /fcbp/if_glt_src_types=>c_error_code-technical
      iv_retryable           = abap_true
      iv_operator_text       = |Source read failed for { is_request-source_type }/{ is_request-source_reference }.|
      iv_technical_reference = iv_detail
      ix_previous            = ix_previous ).
  ENDMETHOD.

ENDCLASS.
