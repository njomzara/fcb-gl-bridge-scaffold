"! Durable outbox creation boundary. Handoff creates only initial DISPATCH work.
INTERFACE /fcbp/if_glt_outbox_enqueuer PUBLIC.

  METHODS enqueue_work
    IMPORTING
      is_work             TYPE /fcbp/if_glt_types=>ty_outbox_work
    RETURNING
      VALUE(rv_outbox_id) TYPE /fcbp/if_glt_types=>ty_outbox_id
    RAISING
      /fcbp/cx_glt_handoff.

ENDINTERFACE.

