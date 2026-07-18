# /FCBP/GLT_MONITOR - Monitoring and Status Package

This package owns operator-facing monitoring, status rollups, messages, references, and monitor actions such as retry, rebuild, reprocess, query status, and cancel.

## Runtime Pattern

- Monitor repository reads transfer, status, error, target reference, package, and outbox evidence.
- Monitor query builds cockpit/support projections.
- Message service exposes operator-safe diagnostics.
- Reference service exposes target references and correlation handles.
- Action service validates authorization and allowed status transitions, then enqueues outbox work.
- Status rollup derives high-level health and criticality for support views.

## Interfaces

- `/FCBP/IF_GLT_MONITOR_REPO`
  - Repository contract for monitor/support evidence reads.

- `/FCBP/IF_GLT_ACTION_SERVICE`
  - Contract for monitor actions such as request reprocess, retry now, rebuild after correction, query status, cancel, and duplicate resolution.

- `/FCBP/IF_GLT_MESSAGE_SVC`
  - Contract for operator-visible messages.

- `/FCBP/IF_GLT_REFERENCE_SVC`
  - Contract for target and source reference lookups.

## Classes

- `/FCBP/CL_GLT_MONITOR_REPO`
  - Productive monitor repository scaffold over transfer, status, package, attempt, error, message, and target reference tables.

- `/FCBP/CL_GLT_MONITOR_QUERY`
  - Builds monitor result views and filters for cockpit/support use.

- `/FCBP/CL_GLT_ACTION_SERVICE`
  - Enforces action authorization and status eligibility.
  - Resolves request reprocess into concrete outbox work and directly enqueues retry, rebuild, and status query actions.

- `/FCBP/CL_GLT_MESSAGE_SVC`
  - Reads and formats operator-safe messages.

- `/FCBP/CL_GLT_REFERENCE_SVC`
  - Reads source, package, adapter, and target references for transfer tracing.

- `/FCBP/CL_GLT_STATUS_ROLLUP`
  - Derives rollup status, criticality, and operator-action indicators.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_MONITOR`.
