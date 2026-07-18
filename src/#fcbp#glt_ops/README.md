# /FCBP/GLT_OPS - Operations Job Package

This package owns concrete operational job shells that invoke the layer services. It keeps scheduled/manual job entry points separate from the reusable domain services.

## Runtime Pattern

- Job layer builds and validates a job context.
- The selected operations class executes one operational concern.
- Most classes are thin wrappers around package, mapping, adapter, source, monitor, or outbox services.
- Jobs return `/FCBP/IF_GLT_JOB_TYPES=>TY_JOB_RESULT` counters and message text.

## Job Classes

- `/FCBP/CL_GLT_DISPATCH_JOB`
  - Runs due outbox dispatch work through the Outbox Dispatcher.

- `/FCBP/CL_GLT_RETRY_JOB`
  - Job shell for retry due work.
  - Intended to claim due retry rows and route retry/status-query work according to retry type and resolved operator action.

- `/FCBP/CL_GLT_POLL_CONFIRM_JOB`
  - Job shell for asynchronous confirmation polling.

- `/FCBP/CL_GLT_STATUS_QUERY_JOB`
  - Job shell for explicit status-query processing.

- `/FCBP/CL_GLT_PACKAGE_PREPARE_JOB`
  - Calls Package Preparer for explicit package preparation.

- `/FCBP/CL_GLT_PACKAGE_REBUILD_JOB`
  - Calls Package Preparer `REBUILD_PACKAGE` with predecessor and reason.

- `/FCBP/CL_GLT_PKG_CONSISTENCY_JOB`
  - Runs package repository consistency checks.

- `/FCBP/CL_GLT_VALIDATE_PKG_JOB`
  - Runs package validation for a selected package.

- `/FCBP/CL_GLT_MAPPING_JOB`
  - Runs package mapping for a selected package/context.

- `/FCBP/CL_GLT_HANDOFF_BATCH_JOB`
  - Runs batch source selection and handoff.

- `/FCBP/CL_GLT_SOURCE_READ_PROBE_JOB`
  - Probes Source Reading for a scope without full dispatch.

- `/FCBP/CL_GLT_ROUTE_SIM_JOB`
  - Simulates route/profile resolution for support or configuration checks.

- `/FCBP/CL_GLT_POLCTX_CONS_JOB`
  - Checks persisted policy-context consistency.

- `/FCBP/CL_GLT_ADAPTER_HEALTH_JOB`
  - Checks adapter/profile reachability or capability health.

- `/FCBP/CL_GLT_REG_RECOVER_JOB`
  - Recovers stale or inconsistent source registration states.

- `/FCBP/CL_GLT_RETENTION_JOB`
  - Retention job shell for cleanup/report-only/approved execution modes.

- `/FCBP/CL_GLT_RECON_JOB`
  - Runs reconciliation checks.

## Services

- `/FCBP/CL_GLT_RECON_SERVICE`
  - Reconciliation service used by the reconciliation job.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_OPS`.
