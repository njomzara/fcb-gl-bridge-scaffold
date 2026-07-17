"! No-op Package Builder status facade.
"! Productive binding should persist messages, status transitions, and audit in owning layers.
CLASS /fcbp/cl_glt_package_status DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_package_status.

ENDCLASS.

CLASS /fcbp/cl_glt_package_status IMPLEMENTATION.

  METHOD /fcbp/if_glt_package_status~preparation_started.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_status~preparation_blocked.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_status~preparation_succeeded.
  ENDMETHOD.

  METHOD /fcbp/if_glt_package_status~preparation_failed.
  ENDMETHOD.

ENDCLASS.
