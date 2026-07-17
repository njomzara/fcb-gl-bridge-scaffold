"! Builds canonical audit events; runtime services must not invent free-text event names.
INTERFACE /fcbp/if_glt_audit_event_factory PUBLIC.

  METHODS for_transfer_event
    IMPORTING
      is_transfer       TYPE /fcbp/if_glt_types=>ty_transfer
      is_context        TYPE /fcbp/if_glt_sec_types=>ty_security_context
      iv_event_category TYPE char30
      iv_event_type     TYPE char30
      iv_event_subtype  TYPE char30 OPTIONAL
      iv_outcome        TYPE char30 OPTIONAL
      iv_evidence_ref   TYPE string OPTIONAL
    RETURNING
      VALUE(rs_event)   TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_receive
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_duplicate_handoff
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_package_created
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
              iv_package_id TYPE char32 OPTIONAL
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_package_rebuilt
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
              iv_package_id TYPE char32 OPTIONAL
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_validation_result
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
              iv_passed   TYPE abap_bool
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_mapping_result
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
              iv_passed   TYPE abap_bool
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_submit_started
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
              iv_attempt_id TYPE /fcbp/if_glt_types=>ty_attempt_id OPTIONAL
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_submit_accepted
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
              iv_attempt_id TYPE /fcbp/if_glt_types=>ty_attempt_id OPTIONAL
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_submit_failed
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
              iv_attempt_id TYPE /fcbp/if_glt_types=>ty_attempt_id OPTIONAL
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_posted
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
              iv_ref_id   TYPE /fcbp/if_glt_types=>ty_ref_id OPTIONAL
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_unknown_confirmation
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_retry_scheduled
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_retry_exhausted
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_status_query
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_cancelled
    IMPORTING is_transfer TYPE /fcbp/if_glt_types=>ty_transfer
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_config_changed
    IMPORTING is_change  TYPE /fcbp/if_glt_sec_types=>ty_config_change
              is_context TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_config_activated
    IMPORTING is_change  TYPE /fcbp/if_glt_sec_types=>ty_config_change
              is_context TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_auth_denied
    IMPORTING is_decision TYPE /fcbp/if_glt_sec_types=>ty_auth_decision
              is_context  TYPE /fcbp/if_glt_sec_types=>ty_security_context
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

  METHODS for_support_access
    IMPORTING is_scope   TYPE /fcbp/if_glt_sec_types=>ty_support_scope
              is_context TYPE /fcbp/if_glt_sec_types=>ty_security_context
              iv_outcome TYPE char30
    RETURNING VALUE(rs_event) TYPE /fcbp/if_glt_types=>ty_audit_event.

ENDINTERFACE.
