"! Builds audit event DTOs for target routing and policy-resolution decisions.
CLASS /fcbp/cl_glt_route_audit_helper DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS for_resolution_success
      IMPORTING
        is_scope          TYPE /fcbp/if_glt_config_types=>ty_routing_scope
        is_route_context  TYPE /fcbp/if_glt_types=>ty_route_context
        is_effective_context TYPE /fcbp/if_glt_config_types=>ty_effective_context OPTIONAL
      RETURNING
        VALUE(rs_event)   TYPE /fcbp/if_glt_types=>ty_audit_event.

    METHODS for_resolution_failure
      IMPORTING
        is_scope          TYPE /fcbp/if_glt_config_types=>ty_routing_scope
        ix_error          TYPE REF TO /fcbp/cx_glt_config OPTIONAL
      RETURNING
        VALUE(rs_event)   TYPE /fcbp/if_glt_types=>ty_audit_event.

ENDCLASS.

CLASS /fcbp/cl_glt_route_audit_helper IMPLEMENTATION.

  METHOD for_resolution_success.
    rs_event = VALUE #(
      transfer_id      = is_scope-transfer_id
      event_type       = 'TARGET_RESOLVED'
      event_subtype    = 'SUCCESS'
      event_category   = 'ROUTING_POLICY'
      source_type      = is_scope-source_type
      source_reference = is_scope-source_reference
      company_code     = is_scope-company_code
      target_id        = is_route_context-target_id
      routing_bucket   = is_route_context-routing_bucket
      config_object_type = /fcbp/if_glt_config_types=>c_object_type-target_profile
      config_object_key  = is_route_context-target_id
      evidence_ref     = |POLCTX={ is_effective_context-policy_context_id };HASH={ is_effective_context-target_profile-config_hash }| ).
    GET TIME STAMP FIELD rs_event-created_at.
  ENDMETHOD.

  METHOD for_resolution_failure.
    rs_event = VALUE #(
      transfer_id      = is_scope-transfer_id
      event_type       = 'TARGET_RESOLUTION_FAILED'
      event_subtype    = COND #( WHEN ix_error IS BOUND THEN ix_error->reason_code ELSE 'CONFIG_FAILED' )
      event_category   = 'ROUTING_POLICY'
      source_type      = is_scope-source_type
      source_reference = is_scope-source_reference
      company_code     = is_scope-company_code
      target_id        = COND #( WHEN ix_error IS BOUND THEN ix_error->target_id ELSE '' )
      routing_bucket   = COND #( WHEN ix_error IS BOUND THEN ix_error->routing_bucket ELSE '' )
      config_object_type = COND #( WHEN ix_error IS BOUND THEN ix_error->config_object_type ELSE /fcbp/if_glt_config_types=>c_object_type-target_profile )
      config_object_key  = COND #( WHEN ix_error IS BOUND THEN ix_error->config_object_key ELSE '' )
      evidence_ref     = COND #( WHEN ix_error IS BOUND THEN ix_error->technical_reference ELSE '' ) ).
    GET TIME STAMP FIELD rs_event-created_at.
  ENDMETHOD.

ENDCLASS.
