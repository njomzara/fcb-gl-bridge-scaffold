"! Package Builder orchestration constants and lifecycle vocabulary.
INTERFACE /fcbp/if_glt_pkg_prep_types PUBLIC.

  CONSTANTS:
    BEGIN OF c_build_mode,
      dispatch   TYPE char20 VALUE 'DISPATCH',
      rebuild    TYPE char20 VALUE 'REBUILD',
      simulation TYPE char20 VALUE 'SIMULATION',
    END OF c_build_mode.

  CONSTANTS:
    BEGIN OF c_error_code,
      request_invalid     TYPE char40 VALUE 'PACKAGE_REQUEST_INVALID',
      transfer_not_found  TYPE char40 VALUE 'TRANSFER_NOT_FOUND',
      state_invalid       TYPE char40 VALUE 'PACKAGE_STATE_INVALID',
      lock_failed         TYPE char40 VALUE 'PACKAGE_LOCK_FAILED',
      source_scope_invalid TYPE char40 VALUE 'SOURCE_SCOPE_INVALID',
      source_scope_conflict TYPE char40 VALUE 'SOURCE_SCOPE_CONFLICT',
      policy_invalid      TYPE char40 VALUE 'POLICY_CONTEXT_INVALID',
      policy_hash_missing TYPE char40 VALUE 'POLICY_HASH_MISSING',
      graph_invalid       TYPE char40 VALUE 'PACKAGE_GRAPH_INVALID',
      trace_invalid       TYPE char40 VALUE 'SOURCE_TRACE_INVALID',
      hash_missing        TYPE char40 VALUE 'PACKAGE_HASH_MISSING',
      blocked             TYPE char40 VALUE 'PACKAGE_PREPARATION_BLOCKED',
      repository_failed   TYPE char40 VALUE 'PACKAGE_REPOSITORY_FAILED',
      publication_failed  TYPE char40 VALUE 'PACKAGE_PUBLICATION_FAILED',
      rebuild_invalid     TYPE char40 VALUE 'REBUILD_REQUEST_INVALID',
      lineage_invalid     TYPE char40 VALUE 'REBUILD_LINEAGE_INVALID',
    END OF c_error_code.

  CONSTANTS:
    BEGIN OF c_lifecycle_state,
      requested       TYPE char20 VALUE 'REQUESTED',
      transfer_loaded TYPE char20 VALUE 'TRANSFER_LOADED',
      source_read     TYPE char20 VALUE 'SOURCE_READ',
      graph_built     TYPE char20 VALUE 'GRAPH_BUILT',
      graph_rejected  TYPE char20 VALUE 'GRAPH_REJECTED',
      graph_persisted TYPE char20 VALUE 'GRAPH_PERSISTED',
      published       TYPE char20 VALUE 'PUBLISHED',
      failed          TYPE char20 VALUE 'FAILED',
    END OF c_lifecycle_state.

  CONSTANTS:
    BEGIN OF c_rule_id,
      req_transfer_id      TYPE char30 VALUE 'PKG_REQ_001',
      req_transfer_exists  TYPE char30 VALUE 'PKG_REQ_002',
      req_state            TYPE char30 VALUE 'PKG_REQ_003',
      req_lock             TYPE char30 VALUE 'PKG_REQ_004',
      req_source_scope     TYPE char30 VALUE 'PKG_REQ_005',
      req_target_context   TYPE char30 VALUE 'PKG_REQ_006',
      req_policy_context   TYPE char30 VALUE 'PKG_REQ_007',
      req_build_mode       TYPE char30 VALUE 'PKG_REQ_008',
      src_not_empty        TYPE char30 VALUE 'PKG_SRC_001',
      src_identity         TYPE char30 VALUE 'PKG_SRC_002',
      src_scope_match      TYPE char30 VALUE 'PKG_SRC_003',
      src_trace_identity   TYPE char30 VALUE 'PKG_SRC_004',
      src_amount_side      TYPE char30 VALUE 'PKG_SRC_005',
      src_hash             TYPE char30 VALUE 'PKG_SRC_006',
      pol_aggregation      TYPE char30 VALUE 'PKG_POL_001',
      pol_split            TYPE char30 VALUE 'PKG_POL_003',
      pol_hash             TYPE char30 VALUE 'PKG_POL_004',
      graph_header         TYPE char30 VALUE 'PKG_GRAPH_001',
      graph_package_id     TYPE char30 VALUE 'PKG_GRAPH_002',
      graph_outdoc         TYPE char30 VALUE 'PKG_GRAPH_003',
      graph_line           TYPE char30 VALUE 'PKG_GRAPH_004',
      graph_line_outdoc    TYPE char30 VALUE 'PKG_GRAPH_005',
      graph_trace          TYPE char30 VALUE 'PKG_GRAPH_006',
      graph_count          TYPE char30 VALUE 'PKG_GRAPH_007',
      graph_hash           TYPE char30 VALUE 'PKG_GRAPH_008',
      graph_blocked        TYPE char30 VALUE 'PKG_GRAPH_009',
      reb_predecessor      TYPE char30 VALUE 'PKG_REB_001',
      reb_ownership        TYPE char30 VALUE 'PKG_REB_002',
      reb_reason           TYPE char30 VALUE 'PKG_REB_004',
    END OF c_rule_id.

ENDINTERFACE.
