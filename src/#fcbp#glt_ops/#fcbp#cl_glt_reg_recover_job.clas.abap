"! Application job shell for /FCBP/GLT_REG_RECOVER.
CLASS /fcbp/cl_glt_reg_recover_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_handoff_repo OPTIONAL
        io_audit      TYPE REF TO /fcbp/if_glt_audit_writer OPTIONAL.

    METHODS execute
      IMPORTING
        iv_dry_run TYPE abap_bool DEFAULT abap_true
      RAISING
        /fcbp/cx_glt_handoff.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_handoff_repo.
    DATA mo_audit      TYPE REF TO /fcbp/if_glt_audit_writer.

ENDCLASS.

CLASS /fcbp/cl_glt_reg_recover_job IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    mo_audit      = io_audit.
  ENDMETHOD.

  METHOD execute.
    " TODO: Select stale RESERVED registrations, verify evidence, then recover or mark FAILED.
    " Dry-run must be the default until tenant-specific recovery policy is approved.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
      EXPORTING
        reason_code    = 'NOT_IMPLEMENTED'
        error_category = /fcbp/if_glt_types=>c_error_category-technical
        retryable      = abap_true
        operator_text  = 'Registration recovery job is not implemented in the scaffold.'.
  ENDMETHOD.

ENDCLASS.

