"! Validates the handoff envelope only. It does not read full source lines or call downstream layers.
CLASS /fcbp/cl_glt_handoff_validator DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_eligibility_checker TYPE REF TO /fcbp/if_glt_source_elig_chk OPTIONAL.

    METHODS validate_request
      IMPORTING
        is_request TYPE /fcbp/if_glt_types=>ty_handoff_request
      RAISING
        /fcbp/cx_glt_handoff.

  PRIVATE SECTION.
    DATA mo_eligibility_checker TYPE REF TO /fcbp/if_glt_source_elig_chk.

    METHODS raise_validation
      IMPORTING
        iv_rule_id          TYPE char20
        iv_operator_text    TYPE char220
        is_request          TYPE /fcbp/if_glt_types=>ty_handoff_request
      RAISING
        /fcbp/cx_glt_handoff.

ENDCLASS.

CLASS /fcbp/cl_glt_handoff_validator IMPLEMENTATION.

  METHOD constructor.
    mo_eligibility_checker = io_eligibility_checker.
  ENDMETHOD.

  METHOD validate_request.
    IF is_request-source_type IS INITIAL.
      raise_validation( iv_rule_id = 'GLT_HND_001' iv_operator_text = 'Source type is required.' is_request = is_request ).
    ENDIF.

    IF is_request-source_type <> /fcbp/if_glt_types=>c_source_type-recon_key
       AND is_request-source_type <> /fcbp/if_glt_types=>c_source_type-document.
      raise_validation( iv_rule_id = 'GLT_HND_002' iv_operator_text = 'Source type is not supported by Source Handoff.' is_request = is_request ).
    ENDIF.

    IF is_request-source_reference IS INITIAL.
      raise_validation( iv_rule_id = 'GLT_HND_003' iv_operator_text = 'Source reference is required.' is_request = is_request ).
    ENDIF.

    IF is_request-source_type = /fcbp/if_glt_types=>c_source_type-recon_key
       AND is_request-reconciliation_key IS INITIAL.
      raise_validation( iv_rule_id = 'GLT_HND_004' iv_operator_text = 'Reconciliation key is required for reconciliation-key handoff.' is_request = is_request ).
    ENDIF.

    IF is_request-source_type = /fcbp/if_glt_types=>c_source_type-document
       AND is_request-source_doc_no IS INITIAL.
      raise_validation( iv_rule_id = 'GLT_HND_005' iv_operator_text = 'Source document number is required for document handoff.' is_request = is_request ).
    ENDIF.

    IF is_request-processing_mode IS INITIAL.
      raise_validation( iv_rule_id = 'GLT_HND_006' iv_operator_text = 'Processing mode is required.' is_request = is_request ).
    ENDIF.

    IF is_request-processing_mode <> /fcbp/if_glt_types=>c_processing_mode-realtime
       AND is_request-processing_mode <> /fcbp/if_glt_types=>c_processing_mode-batch.
      raise_validation( iv_rule_id = 'GLT_HND_006' iv_operator_text = 'Processing mode must be REALTIME or BATCH.' is_request = is_request ).
    ENDIF.

    IF mo_eligibility_checker IS BOUND.
      mo_eligibility_checker->check_eligible( is_request ).
    ENDIF.
  ENDMETHOD.

  METHOD raise_validation.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_handoff
      EXPORTING
        source_type      = is_request-source_type
        source_reference = is_request-source_reference
        reason_code      = iv_rule_id
        error_category   = /fcbp/if_glt_types=>c_error_category-validation
        operator_text    = iv_operator_text.
  ENDMETHOD.

ENDCLASS.

