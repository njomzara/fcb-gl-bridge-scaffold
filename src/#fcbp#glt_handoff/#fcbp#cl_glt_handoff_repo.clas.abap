"! Default Source Handoff repository scaffold.
"! TODO: Implement atomic INSERT into /FCBP/GLT_REG and DB writes against activated tables.
CLASS /fcbp/cl_glt_handoff_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_handoff_repo.

  PRIVATE SECTION.
    METHODS not_implemented
      IMPORTING
        iv_operation       TYPE char40
        iv_registration_key TYPE /fcbp/if_glt_types=>ty_registration_key OPTIONAL
      RAISING
        /fcbp/cx_glt_handoff.

ENDCLASS.

CLASS /fcbp/cl_glt_handoff_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_handoff_repo~try_reserve_reg.
    not_implemented( iv_operation = 'TRY_RESERVE_REG' iv_registration_key = is_registration-registration_key ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~read_reg.
    not_implemented( iv_operation = 'READ_REG' iv_registration_key = iv_registration_key ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~create_transfer_root.
    not_implemented( iv_operation = 'CREATE_TRANSFER_ROOT' iv_registration_key = is_header-source_registration_key ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~insert_initial_status.
    not_implemented( iv_operation = 'INSERT_INITIAL_STATUS' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~insert_outbox_work.
    not_implemented( iv_operation = 'INSERT_OUTBOX_WORK' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~write_audit_event.
    not_implemented( iv_operation = 'WRITE_AUDIT_EVENT' ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~activate_reg.
    not_implemented( iv_operation = 'ACTIVATE_REG' iv_registration_key = iv_registration_key ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_handoff_repo~mark_reg_failed.
    not_implemented( iv_operation = 'MARK_REG_FAILED' iv_registration_key = iv_registration_key ).
  ENDMETHOD.

  METHOD not_implemented.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
      EXPORTING
        registration_key = iv_registration_key
        reason_code      = iv_operation
        error_category   = /fcbp/if_glt_types=>c_error_category-repository
        operator_text    = |Handoff repository operation { iv_operation } is not implemented in the scaffold.|.
  ENDMETHOD.

ENDCLASS.

