"! Default outcome classifier for normalized adapter results.
CLASS /fcbp/cl_glt_outcome_classifier DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_outcome_classifier.

  PRIVATE SECTION.
    METHODS build_followup_decision
      IMPORTING
        is_work             TYPE /fcbp/if_glt_types=>ty_outbox_work
        iv_next_action      TYPE char30
        iv_status_code      TYPE /fcbp/if_glt_types=>ty_status
        iv_followup_type    TYPE char20
        iv_message_text     TYPE char220
      RETURNING
        VALUE(rs_decision)  TYPE /fcbp/if_glt_outbox_types=>ty_outcome_decision.

ENDCLASS.

CLASS /fcbp/cl_glt_outcome_classifier IMPLEMENTATION.

  METHOD /fcbp/if_glt_outcome_classifier~classify.
    CASE is_result-outcome.
      WHEN /fcbp/if_glt_types=>c_adapter_outcome-posted.
        rs_decision = VALUE #(
          next_action       = /fcbp/if_glt_outbox_types=>c_next_action-mark_posted
          completion_status = /fcbp/if_glt_types=>c_outbox_status-done
          status_code       = /fcbp/if_glt_types=>c_status-posted
          message_text      = 'Target posting confirmed.' ).

      WHEN /fcbp/if_glt_types=>c_adapter_outcome-dispatched.
        rs_decision = VALUE #(
          next_action       = /fcbp/if_glt_outbox_types=>c_next_action-mark_dispatched
          completion_status = /fcbp/if_glt_types=>c_outbox_status-done
          status_code       = /fcbp/if_glt_types=>c_status-dispatched
          message_text      = 'Target dispatch accepted; confirmation remains pending by route policy.' ).

      WHEN /fcbp/if_glt_types=>c_adapter_outcome-unknown_confirmation.
        rs_decision = build_followup_decision(
          is_work          = is_work
          iv_next_action   = /fcbp/if_glt_outbox_types=>c_next_action-schedule_status_query
          iv_status_code   = /fcbp/if_glt_types=>c_status-unknown_confirmation
          iv_followup_type = /fcbp/if_glt_types=>c_outbox_work_type-status_query
          iv_message_text  = 'Unknown confirmation requires status query before any retry.' ).
        rs_decision-unknown_confirmation = abap_true.

      WHEN /fcbp/if_glt_types=>c_adapter_outcome-retryable_failure.
        rs_decision = build_followup_decision(
          is_work          = is_work
          iv_next_action   = /fcbp/if_glt_outbox_types=>c_next_action-schedule_retry
          iv_status_code   = /fcbp/if_glt_types=>c_status-failed_retryable
          iv_followup_type = /fcbp/if_glt_types=>c_outbox_work_type-retry
          iv_message_text  = 'Retryable target failure; retry work should be scheduled by policy.' ).
        rs_decision-retryable = abap_true.

      WHEN OTHERS.
        rs_decision = VALUE #(
          next_action              = /fcbp/if_glt_outbox_types=>c_next_action-fail_terminal
          completion_status        = /fcbp/if_glt_types=>c_outbox_status-failed
          status_code              = /fcbp/if_glt_types=>c_status-failed_final
          operator_action_required = abap_true
          message_text             = 'Target outcome is terminal or unsupported.' ).
    ENDCASE.
  ENDMETHOD.

  METHOD build_followup_decision.
    DATA(lv_due_at) = VALUE utclong( ).
    GET TIME STAMP FIELD lv_due_at.

    rs_decision = VALUE #(
      next_action        = iv_next_action
      completion_status  = /fcbp/if_glt_types=>c_outbox_status-done
      status_code        = iv_status_code
      followup_work_type = iv_followup_type
      followup_due_at    = lv_due_at
      message_text       = iv_message_text ).
  ENDMETHOD.

ENDCLASS.
