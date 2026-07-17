"! Guarded operator actions for the Monitoring and Status RAP layer.
INTERFACE /fcbp/if_glt_action_service PUBLIC.

  METHODS request_reprocess
    IMPORTING
      is_request       TYPE /fcbp/if_glt_types=>ty_monitor_action_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_types=>ty_monitor_action_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS query_status
    IMPORTING
      is_request       TYPE /fcbp/if_glt_types=>ty_monitor_action_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_types=>ty_monitor_action_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS cancel_transfer
    IMPORTING
      is_request       TYPE /fcbp/if_glt_types=>ty_monitor_action_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_types=>ty_monitor_action_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS retry_now
    IMPORTING
      is_request       TYPE /fcbp/if_glt_types=>ty_monitor_action_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_types=>ty_monitor_action_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS rebuild_after_correction
    IMPORTING
      is_request       TYPE /fcbp/if_glt_types=>ty_monitor_action_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_types=>ty_monitor_action_result
    RAISING
      /fcbp/cx_glt_error.

  METHODS mark_duplicate_resolved
    IMPORTING
      is_request       TYPE /fcbp/if_glt_types=>ty_monitor_action_request
    RETURNING
      VALUE(rs_result) TYPE /fcbp/if_glt_types=>ty_monitor_action_result
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
