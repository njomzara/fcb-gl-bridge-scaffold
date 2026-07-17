"! Persistence abstraction for Transfer Core services and ABAP Unit doubles.
INTERFACE /fcbp/if_glt_repository PUBLIC.

  METHODS create_transfer
    IMPORTING
      is_header             TYPE /fcbp/if_glt_types=>ty_header
      it_item               TYPE /fcbp/if_glt_types=>tt_item
    RETURNING
      VALUE(rv_transfer_id) TYPE /fcbp/if_glt_types=>ty_transfer_id
    RAISING
      /fcbp/cx_glt_repository.

  METHODS read_transfer
    IMPORTING
      iv_transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id
    RETURNING
      VALUE(rs_transfer)   TYPE /fcbp/if_glt_types=>ty_transfer
    RAISING
      /fcbp/cx_glt_repository.

  METHODS update_header
    IMPORTING
      is_header            TYPE /fcbp/if_glt_types=>ty_header
    RAISING
      /fcbp/cx_glt_repository.

  METHODS insert_status
    IMPORTING
      is_status            TYPE /fcbp/if_glt_types=>ty_status_row
    RAISING
      /fcbp/cx_glt_repository.

  METHODS insert_error
    IMPORTING
      is_error             TYPE /fcbp/if_glt_types=>ty_error
    RETURNING
      VALUE(rv_error_id)   TYPE /fcbp/if_glt_types=>ty_error_id
    RAISING
      /fcbp/cx_glt_repository.

  METHODS reserve_idempotency
    IMPORTING
      is_reservation       TYPE /fcbp/if_glt_types=>ty_idemp_reservation
    RETURNING
      VALUE(rs_decision)   TYPE /fcbp/if_glt_types=>ty_idemp_decision
    RAISING
      /fcbp/cx_glt_repository.

  METHODS confirm_idempotency
    IMPORTING
      iv_idempotency_key   TYPE /fcbp/if_glt_types=>ty_idempotency_key
      iv_transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id
      iv_status            TYPE char12
    RAISING
      /fcbp/cx_glt_repository.

  METHODS insert_retry
    IMPORTING
      is_retry             TYPE /fcbp/if_glt_types=>ty_retry
    RETURNING
      VALUE(rv_retry_id)   TYPE /fcbp/if_glt_types=>ty_retry_id
    RAISING
      /fcbp/cx_glt_repository.

  METHODS insert_target_ref
    IMPORTING
      is_target_ref        TYPE /fcbp/if_glt_types=>ty_target_ref
    RETURNING
      VALUE(rv_ref_id)     TYPE /fcbp/if_glt_types=>ty_ref_id
    RAISING
      /fcbp/cx_glt_repository.

  METHODS read_config
    IMPORTING
      iv_transfer_type     TYPE char20
    RETURNING
      VALUE(rs_config)     TYPE /fcbp/if_glt_types=>ty_config
    RAISING
      /fcbp/cx_glt_repository.

  METHODS resolve_route
    IMPORTING
      is_header            TYPE /fcbp/if_glt_types=>ty_header
    RETURNING
      VALUE(rs_route)      TYPE /fcbp/if_glt_types=>ty_route
    RAISING
      /fcbp/cx_glt_repository.

  METHODS query_reconciliation
    IMPORTING
      is_filter            TYPE /fcbp/if_glt_types=>ty_recon_filter
    RETURNING
      VALUE(rt_transfer)   TYPE /fcbp/if_glt_types=>tt_transfer
    RAISING
      /fcbp/cx_glt_repository.

ENDINTERFACE.
