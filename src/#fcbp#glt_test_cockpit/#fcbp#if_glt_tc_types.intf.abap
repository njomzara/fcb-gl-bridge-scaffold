"! Test cockpit constants and lightweight DTOs.
INTERFACE /fcbp/if_glt_tc_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_command,
      kickoff_happy_path TYPE char30 VALUE 'KICKOFF_HAPPY_PATH',
      refresh_run        TYPE char30 VALUE 'REFRESH_RUN',
    END OF c_command.

  CONSTANTS:
    BEGIN OF c_status,
      queued    TYPE char20 VALUE 'QUEUED',
      running   TYPE char20 VALUE 'RUNNING',
      passed    TYPE char20 VALUE 'PASSED',
      failed    TYPE char20 VALUE 'FAILED',
      cancelled TYPE char20 VALUE 'CANCELLED',
      stale     TYPE char20 VALUE 'STALE',
    END OF c_status.

  CONSTANTS:
    BEGIN OF c_node_type,
      gl_document_line TYPE char20 VALUE 'GL_DOCUMENT_LINE',
      source_item      TYPE char20 VALUE 'SOURCE_ITEM',
    END OF c_node_type.

  CONSTANTS:
    BEGIN OF c_timeline_kind,
      status TYPE char10 VALUE 'STATUS',
      audit  TYPE char10 VALUE 'AUDIT',
    END OF c_timeline_kind.

  CONSTANTS:
    BEGIN OF c_criticality,
      neutral  TYPE i VALUE 0,
      negative TYPE i VALUE 1,
      critical TYPE i VALUE 2,
      positive TYPE i VALUE 3,
    END OF c_criticality.

  TYPES ty_run_id TYPE char32.

  TYPES: BEGIN OF ty_kickoff_result,
           run_id        TYPE ty_run_id,
           scenario_id   TYPE char30,
           run_status    TYPE char20,
           transfer_id   TYPE /fcbp/if_glt_types=>ty_transfer_id,
           package_id    TYPE /fcbp/if_glt_pkg_types=>ty_package_id,
           target_doc_no TYPE char30,
           message_text  TYPE char220,
         END OF ty_kickoff_result.

ENDINTERFACE.
