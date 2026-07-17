"! Diagnostic policy-context consistency check.
CLASS /fcbp/cl_glt_polctx_cons_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_policy_context TYPE REF TO /fcbp/if_glt_policy_context OPTIONAL
        io_hash           TYPE REF TO /fcbp/if_glt_effective_ctx_hash OPTIONAL.

    METHODS execute
      IMPORTING
        iv_context_id     TYPE /fcbp/if_glt_config_types=>ty_policy_context_id
        is_current_context TYPE /fcbp/if_glt_config_types=>ty_effective_context OPTIONAL
      RETURNING
        VALUE(rs_result)  TYPE /fcbp/if_glt_trp_types=>ty_context_compare_result
      RAISING
        /fcbp/cx_glt_config.

  PRIVATE SECTION.
    DATA mo_policy_context TYPE REF TO /fcbp/if_glt_policy_context.
    DATA mo_hash TYPE REF TO /fcbp/if_glt_effective_ctx_hash.

ENDCLASS.

CLASS /fcbp/cl_glt_polctx_cons_job IMPLEMENTATION.

  METHOD constructor.
    mo_policy_context = io_policy_context.
    IF io_hash IS BOUND.
      mo_hash = io_hash.
    ELSE.
      mo_hash = NEW /fcbp/cl_glt_effective_ctx_hash( ).
    ENDIF.
  ENDMETHOD.

  METHOD execute.
    IF mo_policy_context IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_config
        EXPORTING
          error_category     = /fcbp/if_glt_types=>c_error_category-config
          reason_code        = /fcbp/if_glt_config_types=>c_resolution_reason-missing
          config_object_type = /fcbp/if_glt_config_types=>c_object_type-policy_context
          config_object_key  = iv_context_id
          operator_text      = 'Policy-context consistency job requires a policy-context service.'.
    ENDIF.

    DATA(ls_context) = mo_policy_context->read_context( iv_context_id ).
    rs_result-policy_context_id = iv_context_id.
    rs_result-target_id = ls_context-target_id.
    rs_result-historical_hash = mo_hash->hash_policy_context( ls_context ).

    IF is_current_context-target_profile-target_id IS NOT INITIAL.
      rs_result-current_hash = mo_hash->hash_effective_context( is_current_context ).
      rs_result-hashes_match = xsdbool( rs_result-current_hash = rs_result-historical_hash ).
      rs_result-blocking = xsdbool( rs_result-hashes_match = abap_false ).
      rs_result-operator_text = COND #(
        WHEN rs_result-hashes_match = abap_true THEN 'Current effective context matches historical policy-context evidence.'
        ELSE 'Current effective context differs from historical policy-context evidence.' ).
    ELSE.
      rs_result-hashes_match = abap_false.
      rs_result-blocking = abap_false.
      rs_result-operator_text = 'Historical policy context was read; no current context was supplied for comparison.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
