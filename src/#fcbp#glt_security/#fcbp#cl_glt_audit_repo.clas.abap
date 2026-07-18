"! Audit repository over append-only /FCBP/GLT_AUD evidence.
CLASS /fcbp/cl_glt_audit_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_audit_repo.

  PRIVATE SECTION.
    METHODS create_id
      RETURNING
        VALUE(rv_value) TYPE char32.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

    METHODS raise_audit
      IMPORTING
        iv_text TYPE char220
      RAISING
        /fcbp/cx_glt_audit.

ENDCLASS.

CLASS /fcbp/cl_glt_audit_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_audit_repo~insert_audit_event.
    DATA(ls_event) = is_event.
    IF ls_event-audit_id IS INITIAL.
      ls_event-audit_id = create_id( ).
    ENDIF.
    IF ls_event-created_at IS INITIAL.
      ls_event-created_at = now( ).
    ENDIF.
    IF ls_event-actor_type IS INITIAL.
      ls_event-actor_type = /fcbp/if_glt_types=>c_actor_type-system.
    ENDIF.
    IF ls_event-actor_id IS INITIAL.
      ls_event-actor_id = sy-uname.
    ENDIF.

    INSERT /fcbp/glt_aud FROM @ls_event.
    IF sy-subrc <> 0.
      raise_audit( |Audit event { ls_event-audit_id } could not be inserted.| ).
    ENDIF.
    rv_audit_id = ls_event-audit_id.
  ENDMETHOD.

  METHOD /fcbp/if_glt_audit_repo~query_audit.
    SELECT *
      FROM /fcbp/glt_aud
      WHERE ( @is_filter-transfer_id IS INITIAL OR transfer_id = @is_filter-transfer_id )
        AND ( @is_filter-event_category IS INITIAL OR event_category = @is_filter-event_category )
        AND ( @is_filter-event_type IS INITIAL OR event_type = @is_filter-event_type )
        AND ( @is_filter-actor_id IS INITIAL OR actor_id = @is_filter-actor_id )
        AND ( @is_filter-company_code IS INITIAL OR company_code = @is_filter-company_code )
        AND ( @is_filter-target_id IS INITIAL OR target_id = @is_filter-target_id )
        AND ( @is_filter-support_ticket_id IS INITIAL OR support_ticket_id = @is_filter-support_ticket_id )
        AND ( @is_filter-created_from IS INITIAL OR created_at >= @is_filter-created_from )
        AND ( @is_filter-created_to IS INITIAL OR created_at <= @is_filter-created_to )
      ORDER BY created_at DESCENDING, audit_id DESCENDING
      INTO TABLE @DATA(lt_event).
    rt_event = CORRESPONDING #( lt_event ).
  ENDMETHOD.

  METHOD create_id.
    TRY.
        rv_value = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        rv_value = |AUD{ sy-datum }{ sy-uzeit }|.
    ENDTRY.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

  METHOD raise_audit.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_audit
      EXPORTING
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = iv_text.
  ENDMETHOD.

ENDCLASS.
