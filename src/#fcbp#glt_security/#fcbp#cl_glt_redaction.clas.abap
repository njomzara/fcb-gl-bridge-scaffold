"! Default redaction implementation. Conservative until tenant policy is configured.
CLASS /fcbp/cl_glt_redaction DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_redaction.

  PRIVATE SECTION.
    METHODS mask
      IMPORTING
        iv_value       TYPE char255
      RETURNING
        VALUE(rv_mask) TYPE char255.

ENDCLASS.

CLASS /fcbp/cl_glt_redaction IMPLEMENTATION.

  METHOD /fcbp/if_glt_redaction~redact_value.
    rs_result-field_name = is_request-field_name.
    IF is_request-sensitive = abap_true AND is_request-raw_allowed = abap_false.
      rs_result-display_value = mask( is_request-raw_value ).
      rs_result-redacted = abap_true.
      rs_result-audit_required = abap_true.
    ELSE.
      rs_result-display_value = is_request-raw_value.
      rs_result-redacted = abap_false.
      rs_result-audit_required = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_redaction~redact_error.
    rs_error = is_error.
    IF is_context-redaction_profile <> /fcbp/if_glt_sec_types=>c_redaction_profile-technical AND
       is_context-redaction_profile <> /fcbp/if_glt_sec_types=>c_redaction_profile-audit.
      rs_error-technical_ref = mask( CONV char255( is_error-technical_ref ) ).
    ENDIF.
  ENDMETHOD.

  METHOD /fcbp/if_glt_redaction~redact_audit_event.
    rs_event = is_event.
    IF is_context-redaction_profile = /fcbp/if_glt_sec_types=>c_redaction_profile-summary OR
       is_context-redaction_profile = /fcbp/if_glt_sec_types=>c_redaction_profile-blocked.
      rs_event-evidence_ref = mask( CONV char255( is_event-evidence_ref ) ).
      rs_event-old_value_hash = mask( is_event-old_value_hash ).
      rs_event-new_value_hash = mask( is_event-new_value_hash ).
    ENDIF.
  ENDMETHOD.

  METHOD mask.
    IF iv_value IS INITIAL.
      rv_mask = ''.
    ELSE.
      rv_mask = '[REDACTED]'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
