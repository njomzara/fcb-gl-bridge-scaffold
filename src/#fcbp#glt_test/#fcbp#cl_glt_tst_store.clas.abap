"! Shared in-memory fixture store for GLT happy-path tests.
CLASS /fcbp/cl_glt_tst_store DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES tt_recon_header TYPE STANDARD TABLE OF /fcbp/if_glt_src_types=>ty_recon_header WITH EMPTY KEY.
    TYPES tt_doc_header TYPE STANDARD TABLE OF /fcbp/if_glt_src_types=>ty_document_header WITH EMPTY KEY.
    TYPES tt_source_item TYPE STANDARD TABLE OF /fcbp/if_glt_src_types=>ty_source_projection_item WITH EMPTY KEY.
    TYPES tt_retry_policy TYPE STANDARD TABLE OF /fcbp/if_glt_config_types=>ty_retry_policy WITH EMPTY KEY.
    TYPES tt_aggregation_policy TYPE STANDARD TABLE OF /fcbp/if_glt_config_types=>ty_aggregation_policy WITH EMPTY KEY.
    TYPES tt_split_policy TYPE STANDARD TABLE OF /fcbp/if_glt_config_types=>ty_split_policy WITH EMPTY KEY.
    TYPES tt_throttle_policy TYPE STANDARD TABLE OF /fcbp/if_glt_config_types=>ty_throttle_policy WITH EMPTY KEY.
    TYPES tt_confirmation_policy TYPE STANDARD TABLE OF /fcbp/if_glt_config_types=>ty_confirmation_policy WITH EMPTY KEY.
    TYPES tt_package_graph TYPE STANDARD TABLE OF /fcbp/if_glt_pkg_types=>ty_package_graph WITH EMPTY KEY.

    DATA mt_transfer TYPE /fcbp/if_glt_types=>tt_transfer.
    DATA mt_registration TYPE /fcbp/if_glt_types=>tt_registration.
    DATA mt_outbox TYPE /fcbp/if_glt_types=>tt_outbox_work.
    DATA mt_audit TYPE /fcbp/if_glt_types=>tt_audit_event.
    DATA mt_jobrun TYPE /fcbp/if_glt_types=>tt_jobrun.
    DATA mt_retry TYPE /fcbp/if_glt_types=>tt_retry.

    DATA mt_recon_header TYPE tt_recon_header.
    DATA mt_doc_header TYPE tt_doc_header.
    DATA mt_source_item TYPE tt_source_item.

    DATA mt_target_profile TYPE /fcbp/if_glt_config_types=>tt_target_profile.
    DATA mt_retry_policy TYPE tt_retry_policy.
    DATA mt_aggregation_policy TYPE tt_aggregation_policy.
    DATA mt_aggregation_field TYPE /fcbp/if_glt_config_types=>tt_aggregation_field.
    DATA mt_split_policy TYPE tt_split_policy.
    DATA mt_validation_rule TYPE /fcbp/if_glt_config_types=>tt_validation_rule.
    DATA mt_mapping_rule TYPE /fcbp/if_glt_config_types=>tt_mapping_rule.
    DATA mt_throttle_policy TYPE tt_throttle_policy.
    DATA mt_confirmation_policy TYPE tt_confirmation_policy.
    DATA mt_policy_context TYPE /fcbp/if_glt_config_types=>tt_policy_context.

    DATA mt_package TYPE tt_package_graph.
    DATA mt_validation_run TYPE /fcbp/if_glt_val_types=>tt_run.
    DATA mt_validation_finding TYPE /fcbp/if_glt_val_types=>tt_finding.
    DATA mt_mapping_event TYPE /fcbp/if_glt_map_types=>tt_event.
    DATA mt_target_doc TYPE /fcbp/if_glt_tst_types=>tt_target_doc.

    METHODS reset.

    METHODS next_id
      IMPORTING
        iv_prefix       TYPE char8
      RETURNING
        VALUE(rv_value) TYPE char32.

    METHODS now
      RETURNING
        VALUE(rv_now) TYPE utclong.

ENDCLASS.

CLASS /fcbp/cl_glt_tst_store IMPLEMENTATION.

  METHOD reset.
    CLEAR: mt_transfer,
           mt_registration,
           mt_outbox,
           mt_audit,
           mt_jobrun,
           mt_retry,
           mt_recon_header,
           mt_doc_header,
           mt_source_item,
           mt_target_profile,
           mt_retry_policy,
           mt_aggregation_policy,
           mt_aggregation_field,
           mt_split_policy,
           mt_validation_rule,
           mt_mapping_rule,
           mt_throttle_policy,
           mt_confirmation_policy,
           mt_policy_context,
           mt_package,
           mt_validation_run,
           mt_validation_finding,
           mt_mapping_event,
           mt_target_doc.
  ENDMETHOD.

  METHOD next_id.
    DATA(lv_count) = lines( mt_transfer )
                   + lines( mt_registration )
                   + lines( mt_outbox )
                   + lines( mt_package )
                   + lines( mt_validation_run )
                   + lines( mt_mapping_event )
                   + lines( mt_target_doc )
                   + 1.
    rv_value = |{ iv_prefix }{ sy-datum }{ sy-uzeit }{ lv_count }|.
  ENDMETHOD.

  METHOD now.
    GET TIME STAMP FIELD rv_now.
  ENDMETHOD.

ENDCLASS.
