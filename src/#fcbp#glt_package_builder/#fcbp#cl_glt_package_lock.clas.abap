"! Fail-open scaffold lock. Productive binding must enforce one package publisher per transfer.
CLASS /fcbp/cl_glt_package_lock DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_package_lock.

ENDCLASS.

CLASS /fcbp/cl_glt_package_lock IMPLEMENTATION.

  METHOD /fcbp/if_glt_package_lock~acquire.
    rv_acquired = abap_true.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_lock~release.
    " No-op scaffold. Bind to Transfer Core/outbox ownership or enqueue service in the tenant.
  ENDMETHOD.

ENDCLASS.
