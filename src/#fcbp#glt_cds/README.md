# /FCBP/GLT_CDS - CDS View Package

This package owns interface and consumption CDS views for the GL Bridge monitor, configuration, package, validation, mapping, adapter, audit, and support projections.

## Interface Views

- `/FCBP/I_GLT_TRANSFER`
  - Transfer header projection.

- `/FCBP/I_GLT_ITEM`
  - Transfer item projection.

- `/FCBP/I_GLT_STATUS`
  - Transfer status history projection.

- `/FCBP/I_GLT_ERROR`
  - Normalized error projection.

- `/FCBP/I_GLT_MESSAGE`
  - Operator message projection.

- `/FCBP/I_GLT_REFERENCE`
  - Target reference projection.

- `/FCBP/I_GLT_OUTBOX`
  - Outbox work projection.

- `/FCBP/I_GLT_ATTEMPT`
  - Adapter attempt projection.

- `/FCBP/I_GLT_JOBRUN`
  - Job run projection.

- `/FCBP/I_GLT_REGISTRATION`
  - Source registration projection.

- `/FCBP/I_GLT_PACKAGE`
  - Package header projection.

- `/FCBP/I_GLT_OUTDOC`
  - Outbound document projection.

- `/FCBP/I_GLT_CANON_LINE`
  - Canonical package line projection.

- `/FCBP/I_GLT_SOURCE_TRACE`
  - Source trace projection.

- `/FCBP/I_GLT_SOURCE_READ_RUN`
  - Source read run projection.

- `/FCBP/I_GLT_POLICY_CONTEXT`
  - Policy-context evidence projection.

- `/FCBP/I_GLT_TARGET_PROFILE`
  - Target profile configuration projection.

- `/FCBP/I_GLT_AGGR_POLICY`
  - Aggregation policy projection.

- `/FCBP/I_GLT_AGGR_FIELD`
  - Aggregation field projection.

- `/FCBP/I_GLT_SPLIT_POLICY`
  - Split policy projection.

- `/FCBP/I_GLT_VALIDATION_RULE`
  - Validation rule projection.

- `/FCBP/I_GLT_MAPPING_RULE`
  - Mapping rule projection.

- `/FCBP/I_GLT_RETRY_POLICY`
  - Retry policy projection.

- `/FCBP/I_GLT_CONFIRM_POLICY`
  - Confirmation policy projection.

- `/FCBP/I_GLT_THROTTLE_POLICY`
  - Throttle policy projection.

- `/FCBP/I_GLT_CONFIG_HEALTH`
  - Configuration health finding projection.

- `/FCBP/I_GLT_MAP_EVENT`
  - Mapping evidence projection.

- `/FCBP/I_GLT_VAL_RUN`
  - Validation run projection.

- `/FCBP/I_GLT_VAL_FIND`
  - Validation finding projection.

- `/FCBP/I_GLT_AUDIT`
  - Audit event projection.

- `/FCBP/I_GLT_TRANSFER_SEC_SCOPE`
  - Transfer security scope projection for authorization/DCL.

## Consumption Views

- `/FCBP/C_GLT_MONITOR`
  - Main monitor/cockpit projection.

- `/FCBP/C_GLT_TIMELINE`
  - Transfer timeline projection.

- `/FCBP/C_GLT_EXCEPTIONS`
  - Exception/support worklist projection.

- `/FCBP/C_GLT_QUEUE`
  - Outbox queue projection.

- `/FCBP/C_GLT_UNKNOWN_CONFIRM`
  - Unknown confirmation worklist projection.

- `/FCBP/C_GLT_TARGET_REFERENCE`
  - Target reference display projection.

- `/FCBP/C_GLT_RECON`
  - Reconciliation projection.

- `/FCBP/C_GLT_PACKAGE_DETAIL`
  - Package detail projection.

- `/FCBP/C_GLT_AGGR_TRACE`
  - Aggregation/source trace projection.

- `/FCBP/C_GLT_SPLIT_RESULT`
  - Split result projection.

- `/FCBP/C_GLT_REBUILD_COMPARE`
  - Rebuild comparison projection.

- `/FCBP/C_GLT_VALIDATION`
  - Validation run consumption projection.

- `/FCBP/C_GLT_VALIDATION_FIND`
  - Validation finding consumption projection.

- `/FCBP/C_GLT_MAPPING`
  - Mapping result/evidence projection.

- `/FCBP/C_GLT_MAPPING_FINDING`
  - Mapping finding projection.

- `/FCBP/C_GLT_ADAPTER_ATTEMPT`
  - Adapter attempt consumption projection.

- `/FCBP/C_GLT_ADAPTER_HEALTH`
  - Adapter health projection.

- `/FCBP/C_GLT_CONFIG_HEALTH`
  - Configuration health consumption projection.

- `/FCBP/C_GLT_CONFIG_AUDIT`
  - Configuration audit projection.

- `/FCBP/C_GLT_POLICY_ADMIN`
  - Policy administration projection.

- `/FCBP/C_GLT_POLICY_CONTEXT_TRACE`
  - Policy-context trace projection.

- `/FCBP/C_GLT_TARGET_PROFILE`
  - Target profile consumption projection.

- `/FCBP/C_GLT_PROVIDER_OPS`
  - Provider operations projection.

- `/FCBP/C_GLT_AUDIT_LOG`
  - Audit log consumption projection.

- `/FCBP/C_GLT_SUPPORT_AUDIT`
  - Support audit projection.

- `/FCBP/C_GLT_SECURITY_DECISION`
  - Security/access decision projection.

- `/FCBP/C_GLT_HANDOFF`
  - Handoff monitor projection.

- `/FCBP/C_GLT_SOURCE_READ`
  - Source reading projection.

- `/FCBP/C_GLT_JOBRUN`
  - Job run consumption projection.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_CDS`.
