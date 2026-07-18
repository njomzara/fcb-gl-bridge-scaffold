# /FCBP/GLT_OUTBOX_EXEC - Outbox Execution Package

This package owns due-work execution for GL Bridge transfers. It claims `/FCBP/GLT_OUTBOX` rows, routes each row to the correct worker, records final work state, and creates concrete follow-up work where recovery or confirmation is required.

## Runtime Pattern

- Outbox work is selected by `/FCBP/CL_GLT_OUTBOX_DISPATCHER`.
- Each selected row is claimed owner-only through `/FCBP/IF_GLT_OUTBOX_REPO`.
- `/FCBP/CL_GLT_WORK_HANDLER_REG` resolves `WORK_TYPE` to a concrete `/FCBP/IF_GLT_WORK_HANDLER`.
- The handler returns a `/FCBP/IF_GLT_OUTBOX_TYPES=>TY_WORK_HANDLER_RESULT`.
- The dispatcher finalizes the claimed work as complete, failed, released, or superseded.
- If a handler returns `FOLLOWUP_WORK`, the dispatcher enqueues the successor before finalizing the current work.

## Interfaces

- `/FCBP/IF_GLT_WORK_HANDLER`
  - Common handler contract for one claimed outbox work row.
  - Receives `TY_OUTBOX_WORK` plus dispatch job context.
  - Returns standardized next action, completion status, status code, target reference, error id, and optional follow-up work.

- `/FCBP/IF_GLT_OUTBOX_TYPES`
  - Shared DTO and vocabulary interface for the package.
  - Defines next actions such as `COMPLETE`, `SCHEDULE_RETRY`, `SCHEDULE_STATUS_QUERY`, `SUPERSEDE`, `OPERATOR_ACTION`, and `FAIL_TERMINAL`.
  - Defines claim, handler result, outcome decision, and lock-recovery DTOs.

- `/FCBP/IF_GLT_OUTBOX_REPO`
  - Persistence contract for `/FCBP/GLT_OUTBOX`.
  - Selects due work, claims work, completes/fails/releases/supersedes work, enqueues follow-up work, and recovers expired locks.

- `/FCBP/IF_GLT_OUTBOX_DISPATCHER`
  - Job-facing dispatcher contract.
  - Executes due work for a dispatch context and returns job counters.

- `/FCBP/IF_GLT_OUTCOME_CLASSIFIER`
  - Converts normalized adapter outcomes into outbox decisions.
  - Maps posted, dispatched, retryable failure, unknown confirmation, and terminal outcomes to follow-up semantics.

- `/FCBP/IF_GLT_LOCK_RECOVERY`
  - Contract for stale outbox lock recovery/reporting.
  - Keeps recovery callable without exposing repository internals.

## Core Services

- `/FCBP/CL_GLT_OUTBOX_DISPATCHER`
  - Selects due work using dispatch context filters.
  - Claims each row with claim owner and lock expiry.
  - Resolves the correct handler by work type.
  - Enqueues handler follow-up work when present.
  - Finalizes work according to `NEXT_ACTION` and `COMPLETION_STATUS`.
  - Aggregates processed, success, failed, skipped, dry-run, and rescheduled counters.

- `/FCBP/CL_GLT_OUTBOX_REPO`
  - Productive outbox repository scaffold over `/FCBP/GLT_OUTBOX`.
  - Implements due-work selection, owner-only claim, complete, fail, release, supersede, enqueue, and expired-lock recovery.
  - Generates outbox ids when missing.
  - Keeps status/lock changes localized to the outbox table.

- `/FCBP/CL_GLT_WORK_HANDLER_REG`
  - Default registry for work-type to handler resolution.
  - Maps `DISPATCH`, `RETRY`, `REBUILD`, `POLL`, and `STATUS_QUERY`.
  - Supports dependency injection of alternate handlers for tests or tenant-specific replacement.

- `/FCBP/CL_GLT_OUTCOME_CLASSIFIER`
  - Default adapter-result classifier.
  - `POSTED` -> mark posted.
  - `DISPATCHED` -> mark dispatched.
  - `UNKNOWN_CONFIRMATION` -> schedule status query.
  - `RETRYABLE_FAILURE` -> schedule retry.
  - Other outcomes -> terminal failure and operator action.

- `/FCBP/CL_GLT_LOCK_RECOVERY`
  - Thin service wrapper around repository stale-lock recovery.
  - Validates repository binding and delegates to `/FCBP/IF_GLT_OUTBOX_REPO~RECOVER_EXPIRED_LOCKS`.

## Work Handlers

- `/FCBP/CL_GLT_WH_DISPATCH`
  - Handles initial `DISPATCH` work.
  - Resolves effective configuration and route.
  - Prepares package graph through Package Builder.
  - Validates package before mapping.
  - Maps the package into target journal payload.
  - Submits mapped journal through the selected adapter.
  - Persists adapter attempt evidence and target references.
  - Updates transfer status to `POSTED`, `DISPATCHED`, `UNKNOWN_CONFIRMATION`, `FAILED_RETRYABLE`, or `FAILED_FINAL`.
  - Schedules `POLL`, `STATUS_QUERY`, or `RETRY` follow-up work when adapter outcome requires it.

- `/FCBP/CL_GLT_WH_RETRY`
  - Handles `RETRY` work after retryable adapter failure.
  - Reuses the current non-superseded package; it does not rebuild package evidence.
  - Falls back to `/FCBP/GLT_PKG-CURRENT_FLAG` when transfer header `CURRENT_PACKAGE_ID` is missing.
  - Revalidates and remaps the current package.
  - Resubmits through the adapter and persists retry attempt evidence.
  - Updates transfer status from `FAILED_RETRYABLE` or `REPROCESS_REQUESTED` into processing and then to the classified adapter outcome.
  - Schedules status query, poll, or another retry as required.

- `/FCBP/CL_GLT_WH_REBUILD`
  - Handles `REBUILD` work after source/config correction.
  - Requires an existing current package as predecessor evidence.
  - Accepts `REPROCESS_REQUESTED`, `VALIDATION_FAILED`, or `FAILED_FINAL`.
  - Blocks rebuild while transfer is in `UNKNOWN_CONFIRMATION`.
  - Resolves fresh effective configuration context.
  - Calls Package Builder `REBUILD_PACKAGE` to create a successor package.
  - Calls Package Builder so successor publication and transfer `CURRENT_PACKAGE_ID` sync stay inside the package repository contract.
  - Validates the rebuilt package in `REBUILD` mode.
  - Moves the transfer to `READY` on success.
  - Enqueues successor `DISPATCH` follow-up when the dispatch job context carries approved `IMMEDIATE_DISPATCH`.
  - Leaves the rebuilt package at `READY` when rebuild-and-dispatch is not approved.

- `/FCBP/CL_GLT_WH_POLL`
  - Handles asynchronous `POLL` confirmation work.
  - Polls target status without blind resubmission.
  - Accepts `DISPATCHED`, `PROCESSING`, or `UNKNOWN_CONFIRMATION`.
  - Reads the current package and prior adapter attempts as query candidates.
  - Builds adapter status-query requests using target references, middleware ids, correlation ids, or response references.
  - Persists poll attempt evidence.
  - Marks posted when all queried documents are confirmed.
  - Keeps or reschedules poll/status-query work while confirmation remains pending or unknown.

- `/FCBP/CL_GLT_WH_STATUS_QRY`
  - Handles explicit `STATUS_QUERY` work.
  - Used for unknown confirmation and operator-requested target status lookup.
  - Reads current package evidence and policy context.
  - Chooses query handles from target references and adapter attempts.
  - Calls adapter status query and persists status-query attempt evidence.
  - Updates transfer status only when the target result changes the transfer state.
  - Blocks blind retry while confirmation remains unknown.

`REPROCESS` is intentionally not registered as a durable work type. Monitoring keeps `requestReprocess` as an operator action, but resolves it before enqueueing to `STATUS_QUERY`, `RETRY`, `REBUILD`, or `DISPATCH`.

## Current Boundaries

- Package rebuild stops at `READY`; when `IMMEDIATE_DISPATCH` is approved, it queues successor `DISPATCH` instead of submitting inline.
- Retry reuses current package evidence and is the worker that can resubmit without rebuilding.
- Dispatch reuses the current package when source hash and package-shaping policy evidence still match. If current evidence changed, dispatch blocks and rebuild remains the successor-package path.
- Reprocess is an operator action resolution, not a routing worker.
- Final tenant hardening still needs productive lock strategy review across transfer header, package publication, and competing workers.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_OUTBOX_EXEC`.
  - Package text: `GLT Outbox Execution`.
