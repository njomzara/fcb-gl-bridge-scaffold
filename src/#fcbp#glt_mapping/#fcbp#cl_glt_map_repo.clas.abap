"! Mapping evidence repository over append-only /FCBP/GLT_MAPEV rows.
CLASS /fcbp/cl_glt_map_repo DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES /fcbp/if_glt_map_repo.

  PRIVATE SECTION.
    METHODS create_id
      RETURNING
        VALUE(rv_value) TYPE char32.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

    METHODS raise_mapping
      IMPORTING
        iv_text        TYPE char220
        iv_transfer_id TYPE /fcbp/if_glt_types=>ty_transfer_id OPTIONAL
        iv_package_id  TYPE /fcbp/if_glt_pkg_types=>ty_package_id OPTIONAL
      RAISING
        /fcbp/cx_glt_error.

ENDCLASS.

CLASS /fcbp/cl_glt_map_repo IMPLEMENTATION.

  METHOD /fcbp/if_glt_map_repo~insert_events.
    LOOP AT it_event INTO DATA(ls_event).
      IF ls_event-mapping_event_id IS INITIAL.
        ls_event-mapping_event_id = create_id( ).
      ENDIF.
      IF ls_event-created_at IS INITIAL.
        ls_event-created_at = now( ).
      ENDIF.
      IF ls_event-created_by IS INITIAL.
        ls_event-created_by = sy-uname.
      ENDIF.

      INSERT /fcbp/glt_mapev FROM @ls_event.
      IF sy-subrc <> 0.
        raise_mapping(
          iv_transfer_id = ls_event-transfer_id
          iv_package_id  = ls_event-package_id
          iv_text        = |Mapping event { ls_event-mapping_event_id } could not be inserted.| ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD /fcbp/if_glt_map_repo~read_events_for_package.
    SELECT *
      FROM /fcbp/glt_mapev
      WHERE package_id = @iv_package_id
      ORDER BY created_at ASCENDING, outdoc_id ASCENDING, line_no ASCENDING, field_name ASCENDING
      INTO TABLE @DATA(lt_event).
    rt_event = CORRESPONDING #( lt_event ).
  ENDMETHOD.

  METHOD /fcbp/if_glt_map_repo~mark_superseded.
    UPDATE /fcbp/glt_mapev
      SET result_status = @/fcbp/if_glt_map_types=>c_result_status-superseded,
          operator_text = @iv_reason
      WHERE package_id = @iv_package_id
        AND result_status <> @/fcbp/if_glt_map_types=>c_result_status-superseded.
  ENDMETHOD.

  METHOD create_id.
    TRY.
        rv_value = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        rv_value = |MAP{ sy-datum }{ sy-uzeit }|.
    ENDTRY.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

  METHOD raise_mapping.
    RAISE EXCEPTION TYPE /fcbp/cx_glt_mapping
      EXPORTING
        transfer_id    = iv_transfer_id
        package_id     = iv_package_id
        error_category = /fcbp/if_glt_types=>c_error_category-repository
        operator_text  = iv_text.
  ENDMETHOD.

ENDCLASS.
