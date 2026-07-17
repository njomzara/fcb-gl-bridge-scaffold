"! Persistence seam for Monitoring and Status read/action services.
INTERFACE /fcbp/if_glt_monitor_repo PUBLIC.

  METHODS read_transfer
    IMPORTING
      iv_transfer_id     TYPE /fcbp/if_glt_types=>ty_transfer_id
    RETURNING
      VALUE(rs_transfer) TYPE /fcbp/if_glt_types=>ty_transfer
    RAISING
      /fcbp/cx_glt_error.

  METHODS query_monitor
    IMPORTING
      is_filter          TYPE /fcbp/if_glt_types=>ty_monitor_filter
    RETURNING
      VALUE(rt_transfer) TYPE /fcbp/if_glt_types=>tt_transfer
    RAISING
      /fcbp/cx_glt_error.

  METHODS insert_error
    IMPORTING
      is_error           TYPE /fcbp/if_glt_types=>ty_error
    RETURNING
      VALUE(rv_error_id) TYPE /fcbp/if_glt_types=>ty_error_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS insert_message
    IMPORTING
      is_message           TYPE /fcbp/if_glt_types=>ty_monitor_message
    RETURNING
      VALUE(rv_message_id) TYPE /fcbp/if_glt_types=>ty_message_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS insert_target_ref
    IMPORTING
      is_target_ref      TYPE /fcbp/if_glt_types=>ty_target_ref
    RETURNING
      VALUE(rv_ref_id)   TYPE /fcbp/if_glt_types=>ty_ref_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS insert_attempt
    IMPORTING
      is_attempt           TYPE /fcbp/if_glt_types=>ty_attempt
    RETURNING
      VALUE(rv_attempt_id) TYPE /fcbp/if_glt_types=>ty_attempt_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS insert_jobrun
    IMPORTING
      is_jobrun           TYPE /fcbp/if_glt_types=>ty_jobrun
    RETURNING
      VALUE(rv_jobrun_id) TYPE /fcbp/if_glt_types=>ty_jobrun_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS update_jobrun
    IMPORTING
      is_jobrun TYPE /fcbp/if_glt_types=>ty_jobrun
    RAISING
      /fcbp/cx_glt_error.

  METHODS insert_outbox_work
    IMPORTING
      is_work             TYPE /fcbp/if_glt_types=>ty_outbox_work
    RETURNING
      VALUE(rv_outbox_id) TYPE /fcbp/if_glt_types=>ty_outbox_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS cancel_open_work
    IMPORTING
      iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id
    RAISING
      /fcbp/cx_glt_error.

  METHODS has_started_attempt
    IMPORTING
      iv_transfer_id  TYPE /fcbp/if_glt_types=>ty_transfer_id
    RETURNING
      VALUE(rv_found) TYPE abap_bool
    RAISING
      /fcbp/cx_glt_error.

  METHODS write_audit_event
    IMPORTING
      is_event          TYPE /fcbp/if_glt_types=>ty_audit_event
    RETURNING
      VALUE(rv_audit_id) TYPE /fcbp/if_glt_types=>ty_audit_id
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
