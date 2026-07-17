"! Hash scaffold. Replace placeholder hash with released tenant-approved hash API.
CLASS /fcbp/cl_glt_config_hash DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_config_hash.

  PRIVATE SECTION.
    METHODS compact_hash
      IMPORTING
        iv_input       TYPE string
      RETURNING
        VALUE(rv_hash) TYPE char64.

ENDCLASS.

CLASS /fcbp/cl_glt_config_hash IMPLEMENTATION.

  METHOD /fcbp/if_glt_config_hash~hash_target_profile.
    rv_hash = compact_hash(
      |TGT:{ is_profile-target_id }:{ is_profile-target_type }:{ is_profile-adapter_type }:{ is_profile-destination_alias }:{ is_profile-transfer_mode }:{ is_profile-confirmation_mode }:{ is_profile-retry_policy_id }:{ is_profile-aggregation_profile_id }:{ is_profile-split_profile_id }:{ is_profile-validation_profile_id }:{ is_profile-mapping_policy_id }:{ is_profile-throttle_policy_id }:{ is_profile-confirmation_policy_id }:{ is_profile-config_version }| ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_hash~hash_effective_context.
    rv_hash = compact_hash(
      |CTX:{ is_context-target_profile-target_id }:{ is_context-target_profile-config_hash }:{ is_context-retry_policy-config_hash }:{ is_context-aggregation_policy-config_hash }:{ is_context-split_policy-config_hash }:{ is_context-throttle_policy-config_hash }:{ is_context-confirmation_policy-config_hash }| ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_hash~hash_config_change.
    rv_hash = compact_hash(
      |CFG:{ is_change-config_object_type }:{ is_change-config_object_key }:{ is_change-config_version }:{ is_change-old_value_hash }:{ is_change-new_value_hash }| ).
  ENDMETHOD.

  METHOD compact_hash.
    DATA(lv_len) = strlen( iv_input ).
    DATA(lv_take) = COND i( WHEN lv_len < 20 THEN lv_len ELSE 20 ).
    rv_hash = |HASH-{ lv_len }-{ iv_input(lv_take) }|.
  ENDMETHOD.

ENDCLASS.
