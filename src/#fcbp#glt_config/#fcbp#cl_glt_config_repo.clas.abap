"! Default Configuration repository scaffold.
"! TODO: Implement against /FCBP/CC_* and /FCBP/GLT_POLCTX tables using released ABAP Cloud SQL/RAP APIs.
CLASS /fcbp/cl_glt_config_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_config_repo.

  PRIVATE SECTION.
    METHODS not_implemented
      IMPORTING
        iv_operation TYPE char40
      RAISING
        /fcbp/cx_glt_config.

ENDCLASS.

CLASS /fcbp/cl_glt_config_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_config_repo~query_target_profiles.
    not_implemented( 'QUERY_TARGET_PROFILES' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_target_profile.
    not_implemented( 'READ_TARGET_PROFILE' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_retry_policy.
    not_implemented( 'READ_RETRY_POLICY' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_aggregation_policy.
    not_implemented( 'READ_AGGREGATION_POLICY' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_aggregation_fields.
    not_implemented( 'READ_AGGREGATION_FIELDS' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_split_policy.
    not_implemented( 'READ_SPLIT_POLICY' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_validation_rules.
    not_implemented( 'READ_VALIDATION_RULES' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_mapping_rules.
    not_implemented( 'READ_MAPPING_RULES' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_throttle_policy.
    not_implemented( 'READ_THROTTLE_POLICY' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_confirmation_policy.
    not_implemented( 'READ_CONFIRMATION_POLICY' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~insert_policy_context.
    not_implemented( 'INSERT_POLICY_CONTEXT' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~read_policy_context.
    not_implemented( 'READ_POLICY_CONTEXT' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_config_repo~insert_health_finding.
    not_implemented( 'INSERT_HEALTH_FINDING' ).
  ENDMETHOD.

  METHOD not_implemented.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_config
      EXPORTING
        error_category     = /fcbp/if_glt_types=>c_error_category-config
        reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-missing
        config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
        operator_text      = |Configuration repository operation { iv_operation } is not implemented in the scaffold.|.
  ENDMETHOD.

ENDCLASS.
