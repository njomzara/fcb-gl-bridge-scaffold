"! Message/error normalization service for monitor evidence.
CLASS /fcbp/cl_glt_message_svc DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_message_svc.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO /fcbp/if_glt_monitor_repo OPTIONAL.

  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO /fcbp/if_glt_monitor_repo.

    METHODS ensure_repository
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_message_svc IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD /fcbp/if_glt_message_svc~normalize_message.
    rs_error = VALUE #(
      transfer_id          = iv_transfer_id
      item_no              = is_message-item_no
      severity             = is_message-severity
      category             = iv_category
      retryable            = iv_retryable
      unknown_confirmation = iv_unknown_confirmation
      msgid                = is_message-msgid
      msgno                = is_message-msgno
      msgv1                = is_message-msgv1
      msgv2                = is_message-msgv2
      msgv3                = is_message-msgv3
      msgv4                = is_message-msgv4
      operator_text        = is_message-operator_text
      created_by           = sy-uname ).
    GET TIME STAMP FIELD rs_error-created_at.
  ENDMETHOD.

  METHOD /fcbp/if_glt_message_svc~record_error.
    ensure_repository( ).

    DATA(ls_error) = is_error.
    IF ls_error-created_at IS INITIAL.
      GET TIME STAMP FIELD ls_error-created_at.
    ENDIF.
    IF ls_error-created_by IS INITIAL.
      ls_error-created_by = sy-uname.
    ENDIF.

    rv_error_id = mo_repository->insert_error( ls_error ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_message_svc~record_message.
    ensure_repository( ).

    DATA(ls_message) = is_message.
    IF ls_message-created_at IS INITIAL.
      GET TIME STAMP FIELD ls_message-created_at.
    ENDIF.
    IF ls_message-created_by IS INITIAL.
      ls_message-created_by = sy-uname.
    ENDIF.

    rv_message_id = mo_repository->insert_message( ls_message ).
  ENDMETHOD.

  METHOD ensure_repository.
    IF mo_repository IS NOT BOUND.
      RAISE EXCEPTION TYPE /fcbp/cx_glt_error
        EXPORTING
          error_category = /fcbp/if_glt_types=>c_error_category-repository
          operator_text  = 'Message service requires a monitoring repository implementation.'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
