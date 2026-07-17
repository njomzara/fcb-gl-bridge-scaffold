"! Canonical hash utility for effective context and policy-context evidence.
CLASS /fcbp/cl_glt_effective_ctx_hash DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_effective_ctx_hash.

  PRIVATE SECTION.
    METHODS add_part
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE string
      CHANGING
        cv_input TYPE string.

    METHODS compact_hash
      IMPORTING
        iv_prefix      TYPE string
        iv_input       TYPE string
      RETURNING
        VALUE(rv_hash) TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_effective_ctx_hash IMPLEMENTATION.

  METHOD /fcbp/if_glt_effective_ctx_hash~hash_effective_context.
    DATA(lv_input) = ``.
    add_part( EXPORTING iv_name = 'TARGET_ID' iv_value = is_context-target_profile-target_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'TARGET_VERSION' iv_value = |{ is_context-target_profile-config_version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'TARGET_HASH' iv_value = is_context-target_profile-config_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'AGGR_ID' iv_value = is_context-target_profile-aggregation_profile_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'AGGR_VERSION' iv_value = |{ is_context-aggregation_policy-version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'AGGR_HASH' iv_value = is_context-aggregation_policy-config_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'SPLIT_ID' iv_value = is_context-target_profile-split_profile_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'SPLIT_VERSION' iv_value = |{ is_context-split_policy-version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'SPLIT_HASH' iv_value = is_context-split_policy-config_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'VALIDATION_ID' iv_value = is_context-target_profile-validation_profile_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'MAPPING_ID' iv_value = is_context-target_profile-mapping_policy_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'RETRY_ID' iv_value = is_context-target_profile-retry_policy_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'RETRY_VERSION' iv_value = |{ is_context-retry_policy-version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'RETRY_HASH' iv_value = is_context-retry_policy-config_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'THROTTLE_ID' iv_value = is_context-target_profile-throttle_policy_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'THROTTLE_VERSION' iv_value = |{ is_context-throttle_policy-version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'THROTTLE_HASH' iv_value = is_context-throttle_policy-config_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'CONFIRM_ID' iv_value = is_context-target_profile-confirmation_policy_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'CONFIRM_VERSION' iv_value = |{ is_context-confirmation_policy-version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'CONFIRM_HASH' iv_value = is_context-confirmation_policy-config_hash CHANGING cv_input = lv_input ).
    rv_hash = compact_hash( iv_prefix = 'ECH' iv_input = lv_input ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_effective_ctx_hash~hash_policy_context.
    DATA(lv_input) = ``.
    add_part( EXPORTING iv_name = 'TARGET_ID' iv_value = is_context-target_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'TARGET_VERSION' iv_value = |{ is_context-target_profile_version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'TARGET_HASH' iv_value = is_context-target_profile_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'AGGR_ID' iv_value = is_context-aggregation_profile_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'AGGR_VERSION' iv_value = |{ is_context-aggregation_version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'AGGR_HASH' iv_value = is_context-aggregation_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'SPLIT_ID' iv_value = is_context-split_profile_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'SPLIT_VERSION' iv_value = |{ is_context-split_version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'SPLIT_HASH' iv_value = is_context-split_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'VALIDATION_ID' iv_value = is_context-validation_profile_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'VALIDATION_VERSION' iv_value = |{ is_context-validation_version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'VALIDATION_HASH' iv_value = is_context-validation_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'MAPPING_ID' iv_value = is_context-mapping_policy_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'MAPPING_VERSION' iv_value = |{ is_context-mapping_version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'MAPPING_HASH' iv_value = is_context-mapping_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'RETRY_ID' iv_value = is_context-retry_policy_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'RETRY_VERSION' iv_value = |{ is_context-retry_version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'RETRY_HASH' iv_value = is_context-retry_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'THROTTLE_ID' iv_value = is_context-throttle_policy_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'THROTTLE_VERSION' iv_value = |{ is_context-throttle_version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'THROTTLE_HASH' iv_value = is_context-throttle_hash CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'CONFIRM_ID' iv_value = is_context-confirmation_policy_id CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'CONFIRM_VERSION' iv_value = |{ is_context-confirmation_version }| CHANGING cv_input = lv_input ).
    add_part( EXPORTING iv_name = 'CONFIRM_HASH' iv_value = is_context-confirmation_hash CHANGING cv_input = lv_input ).
    rv_hash = compact_hash( iv_prefix = 'PCH' iv_input = lv_input ).
  ENDMETHOD.

  METHOD add_part.
    DATA(lv_value) = iv_value.
    DATA(lv_len) = strlen( lv_value ).
    cv_input = |{ cv_input }#{ iv_name }:{ lv_len }:{ lv_value }|.
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 40 THEN lv_len ELSE 40 ).
    rv_hash = |{ iv_prefix }-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

ENDCLASS.
