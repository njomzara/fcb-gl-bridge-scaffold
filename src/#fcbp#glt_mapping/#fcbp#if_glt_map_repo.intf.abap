"! Persistence seam for append-only mapping evidence.
INTERFACE /fcbp/if_glt_map_repo PUBLIC.

  METHODS insert_events
    IMPORTING
      it_event TYPE /fcbp/if_glt_map_types=>tt_event
    RAISING
      /fcbp/cx_glt_error.

  METHODS read_events_for_package
    IMPORTING
      iv_package_id    TYPE /fcbp/if_glt_pkg_types=>ty_package_id
    RETURNING
      VALUE(rt_event)  TYPE /fcbp/if_glt_map_types=>tt_event
    RAISING
      /fcbp/cx_glt_error.

  METHODS mark_superseded
    IMPORTING
      iv_package_id TYPE /fcbp/if_glt_pkg_types=>ty_package_id
      iv_reason     TYPE char40
    RAISING
      /fcbp/cx_glt_error.

ENDINTERFACE.
