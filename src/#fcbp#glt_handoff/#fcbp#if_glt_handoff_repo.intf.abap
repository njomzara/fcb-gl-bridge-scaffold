"! Persistence abstraction for the Source Handoff transaction.
INTERFACE /fcbp/if_glt_handoff_repo PUBLIC.

  METHODS try_reserve_reg
    IMPORTING
      is_registration    TYPE /fcbp/if_glt_types=>ty_registration
    RETURNING
      VALUE(rs_decision) TYPE /fcbp/if_glt_types=>ty_reg_decision
    RAISING
      /fcbp/cx_glt_handoff.

  METHODS read_reg
    IMPORTING
      iv_registration_key    TYPE /fcbp/if_glt_types=>ty_registration_key
    RETURNING
      VALUE(rs_registration) TYPE /fcbp/if_glt_types=>ty_registration
    RAISING
      /fcbp/cx_glt_handoff.

  METHODS create_transfer_root
    IMPORTING
      is_header TYPE /fcbp/if_glt_types=>ty_header
    RAISING
      /fcbp/cx_glt_handoff.

  METHODS insert_initial_status
    IMPORTING
      is_status TYPE /fcbp/if_glt_types=>ty_status_row
    RAISING
      /fcbp/cx_glt_handoff.

  METHODS insert_outbox_work
    IMPORTING
      is_work             TYPE /fcbp/if_glt_types=>ty_outbox_work
    RETURNING
      VALUE(rv_outbox_id) TYPE /fcbp/if_glt_types=>ty_outbox_id
    RAISING
      /fcbp/cx_glt_handoff.

  METHODS write_audit_event
    IMPORTING
      is_event          TYPE /fcbp/if_glt_types=>ty_audit_event
    RETURNING
      VALUE(rv_audit_id) TYPE /fcbp/if_glt_types=>ty_audit_id
    RAISING
      /fcbp/cx_glt_handoff.

  METHODS activate_reg
    IMPORTING
      iv_registration_key TYPE /fcbp/if_glt_types=>ty_registration_key
      iv_transfer_id      TYPE /fcbp/if_glt_types=>ty_transfer_id
    RAISING
      /fcbp/cx_glt_handoff.

  METHODS mark_reg_failed
    IMPORTING
      iv_registration_key TYPE /fcbp/if_glt_types=>ty_registration_key
      iv_reason           TYPE char40
    RAISING
      /fcbp/cx_glt_handoff.

ENDINTERFACE.

