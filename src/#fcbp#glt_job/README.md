# /FCBP/GLT_JOB - Job Layer Package

This package owns job execution contracts, job context construction, run recording, authorization guarding, source selection, counters, and generic job runner scaffolding.

## Runtime Pattern

- Job context builder validates scheduled/manual job parameters, including `IMMEDIATE_DISPATCH` for approved rebuild-and-dispatch execution.
- Authorization guard checks whether the actor may run the requested job.
- Job runner records start/end state and delegates to the selected service.
- Outbox dispatch context carries `IMMEDIATE_DISPATCH` so a successful `REBUILD` worker can enqueue a successor `DISPATCH` only when explicitly approved.
- Counters derive job result status from processed/success/failed/skipped counts.
- Source selector builds candidate handoff scopes for batch processing.
- Batch handoff runner turns selected source candidates into handoff requests.

## Interfaces

- `/FCBP/IF_GLT_JOB_TYPES`
  - Job DTOs and constants for job types, trigger types, selection modes, retry modes, context, result, and source candidates.

- `/FCBP/IF_GLT_JOB_RUNNER`
  - Generic job runner contract.

- `/FCBP/IF_GLT_JOB_RUN_RECORDER`
  - Contract for persisting job run lifecycle evidence.

- `/FCBP/IF_GLT_JOB_AUTH_GUARD`
  - Contract for job-level authorization checks.

- `/FCBP/IF_GLT_SOURCE_SELECTOR`
  - Contract for selecting source candidates for batch handoff.

## Classes

- `/FCBP/CL_GLT_JOB_CONTEXT_BUILDER`
  - Builds and validates job context from job parameters, including the rebuild-and-dispatch approval flag.
  - Defaults `PACKAGE_REBUILD` jobs to `REBUILD` outbox work when `WORK_TYPE` is not supplied.

- `/FCBP/CL_GLT_JOB_RUNNER`
  - Generic job runner scaffold for start, execute, finish, and fail lifecycle.
  - Propagates `IMMEDIATE_DISPATCH` into outbox dispatch context.

- `/FCBP/CL_GLT_JOB_RUN_RECORDER`
  - Persists `/FCBP/GLT_JOBRUN` rows and job result counters.

- `/FCBP/CL_GLT_JOB_AUTH_GUARD`
  - Checks actor authorization before job execution.

- `/FCBP/CL_GLT_JOB_COUNTERS`
  - Aggregates job counters and derives job status.

- `/FCBP/CL_GLT_JOB_MESSAGE_MAPPER`
  - Converts exceptions and diagnostics into job-result messages.

- `/FCBP/CL_GLT_SOURCE_SELECTOR`
  - Selects source candidates by scope, date, company code, source type, and selection mode.

- `/FCBP/CL_GLT_BATCH_HANDOFF_RUNNER`
  - Runs batch handoff by feeding selected source candidates into Source Handoff.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_JOB`.
