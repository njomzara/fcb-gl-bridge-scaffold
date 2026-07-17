"! Normalizes validation findings and operator-safe messages.
CLASS /fcbp/cl_glt_val_finding DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        iv_transfer_id       TYPE /fcbp/if_glt_types=>ty_transfer_id
        iv_package_id        TYPE /fcbp/if_glt_pkg_types=>ty_package_id
        iv_target_id         TYPE char20
        iv_rule_id           TYPE char30
        iv_rule_category     TYPE char30
        iv_severity          TYPE char10 DEFAULT /fcbp/if_glt_types=>c_severity-error
        iv_blocking          TYPE abap_bool DEFAULT abap_true
        iv_message_code      TYPE char40
        iv_operator_text     TYPE char220
        iv_outdoc_id         TYPE /fcbp/if_glt_pkg_types=>ty_outdoc_id OPTIONAL
        iv_line_no           TYPE numc6 OPTIONAL
        iv_field_name        TYPE char40 OPTIONAL
        iv_remediation_owner TYPE char20 OPTIONAL
        iv_policy_version    TYPE i OPTIONAL
      RETURNING
        VALUE(rs_finding)    TYPE /fcbp/if_glt_val_types=>ty_finding.

    METHODS to_message
      IMPORTING
        is_finding       TYPE /fcbp/if_glt_val_types=>ty_finding
      RETURNING
        VALUE(rs_message) TYPE /fcbp/if_glt_types=>ty_message.

ENDCLASS.

CLASS /fcbp/cl_glt_val_finding IMPLEMENTATION.

  METHOD build.
    rs_finding = VALUE #(
      transfer_id = iv_transfer_id
      package_id = iv_package_id
      outdoc_id = iv_outdoc_id
      line_no = iv_line_no
      field_name = iv_field_name
      rule_id = iv_rule_id
      rule_category = iv_rule_category
      severity = iv_severity
      blocking_flag = iv_blocking
      message_code = iv_message_code
      operator_text = iv_operator_text
      remediation_owner = iv_remediation_owner
      target_id = iv_target_id
      policy_version = iv_policy_version
      created_by = sy-uname ).
    GET TIME STAMP FIELD rs_finding-created_at.
  ENDMETHOD.

  METHOD to_message.
    rs_message = VALUE #(
      rule_id = is_finding-rule_id
      severity = is_finding-severity
      blocking = is_finding-blocking_flag
      entity_name = 'VALIDATION'
      field_name = is_finding-field_name
      item_no = is_finding-line_no
      operator_text = is_finding-operator_text ).
  ENDMETHOD.

ENDCLASS.
