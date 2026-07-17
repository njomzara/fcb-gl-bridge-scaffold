"! Computes validation result status and next-step decision from findings.
CLASS /fcbp/cl_glt_val_result DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_finding TYPE REF TO /fcbp/cl_glt_val_finding OPTIONAL.

    METHODS compute
      IMPORTING
        is_context           TYPE /fcbp/if_glt_val_types=>ty_package_context
        iv_validation_run_id TYPE /fcbp/if_glt_val_types=>ty_validation_run_id
        it_finding           TYPE /fcbp/if_glt_val_types=>tt_finding
      RETURNING
        VALUE(rs_result)     TYPE /fcbp/if_glt_val_types=>ty_result.

  PRIVATE SECTION.
    DATA mo_finding TYPE REF TO /fcbp/cl_glt_val_finding.

ENDCLASS.

CLASS /fcbp/cl_glt_val_result IMPLEMENTATION.

  METHOD constructor.
    IF io_finding IS BOUND.
      mo_finding = io_finding.
    ELSE.
      mo_finding = NEW /fcbp/cl_glt_val_finding( ).
    ENDIF.
  ENDMETHOD.

  METHOD compute.
    rs_result = VALUE #(
      validation_run_id = iv_validation_run_id
      transfer_id = is_context-transfer_id
      package_id = is_context-package_id
      policy_context_id = is_context-policy_context_id
      findings = it_finding
      next_allowed_step = /fcbp/if_glt_val_types=>c_next_step-none ).

    LOOP AT it_finding INTO DATA(ls_finding).
      IF ls_finding-blocking_flag = abap_true.
        rs_result-blocking_count = rs_result-blocking_count + 1.
      ENDIF.
      IF ls_finding-severity = /fcbp/if_glt_types=>c_severity-warning.
        rs_result-warning_count = rs_result-warning_count + 1.
      ENDIF.
      APPEND mo_finding->to_message( ls_finding ) TO rs_result-messages.
    ENDLOOP.

    IF rs_result-blocking_count = 0.
      rs_result-result_status = /fcbp/if_glt_val_types=>c_run_status-passed.
      rs_result-passed = abap_true.
      rs_result-next_allowed_step = /fcbp/if_glt_val_types=>c_next_step-mapping.
    ELSEIF is_context-waiver_context_id IS NOT INITIAL.
      rs_result-result_status = /fcbp/if_glt_val_types=>c_run_status-waived.
      rs_result-passed = abap_true.
      rs_result-next_allowed_step = /fcbp/if_glt_val_types=>c_next_step-mapping.
    ELSE.
      rs_result-result_status = /fcbp/if_glt_val_types=>c_run_status-failed.
      rs_result-passed = abap_false.
      rs_result-next_allowed_step = /fcbp/if_glt_val_types=>c_next_step-operator_action.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
