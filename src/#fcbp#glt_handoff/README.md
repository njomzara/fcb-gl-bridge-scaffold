# /FCBP/GLT_HANDOFF - Source Handoff Package

This package owns the inbound handoff boundary from source systems into GL Bridge transfer registration and outbox creation.

## Runtime Pattern

- Source system submits a handoff request.
- Handoff validator checks required request fields.
- Source eligibility checks decide whether the source object is ready for GL transfer.
- Registration key builder creates the duplicate/idempotency key.
- Source registry reserves or resolves registration state.
- Profile resolver chooses target profile/routing context.
- Transfer receiver creates the transfer and enqueues dispatch work.
- Audit writer records handoff decisions and operator-visible outcomes.

## Interfaces

- `/FCBP/IF_GLT_HANDOFF_RECEIVER`
  - Public contract for receiving handoff requests and returning transfer registration results.

- `/FCBP/IF_GLT_HANDOFF_REPO`
  - Persistence contract for registration and handoff-owned data access.

- `/FCBP/IF_GLT_OUTBOX_ENQUEUER`
  - Contract for creating initial outbox dispatch work.

- `/FCBP/IF_GLT_PROFILE_RESOLVER`
  - Contract for resolving target/routing profile during handoff.

- `/FCBP/IF_GLT_SOURCE_ELIG_CHK`
  - Contract for source eligibility checks.

- `/FCBP/IF_GLT_AUDIT_WRITER`
  - Handoff-facing audit writer contract.

## Classes

- `/FCBP/CL_GLT_HANDOFF_RECEIVER`
  - Main handoff application service.
  - Validates request, checks eligibility, reserves registration, creates transfer, enqueues work, and writes audit.

- `/FCBP/CL_GLT_HANDOFF_FACTORY`
  - Factory for assembling handoff service dependencies.

- `/FCBP/CL_GLT_HANDOFF_VALIDATOR`
  - Validates handoff requests before registration.

- `/FCBP/CL_GLT_HANDOFF_REPO`
  - Productive handoff repository scaffold over registration and related transfer tables.

- `/FCBP/CL_GLT_SOURCE_ELIG_CHK`
  - Source eligibility checker scaffold.

- `/FCBP/CL_GLT_SOURCE_REGISTRY`
  - Registration service for duplicate, in-progress, and conflict handling.

- `/FCBP/CL_GLT_REG_KEY_BUILDER`
  - Builds deterministic source registration keys.

- `/FCBP/CL_GLT_PROFILE_RESOLVER`
  - Resolves target profile/routing hints for inbound source objects.

- `/FCBP/CL_GLT_OUTBOX_ENQUEUER`
  - Creates initial `DISPATCH` outbox work after successful registration.

- `/FCBP/CL_GLT_HANDOFF_LOGGER`
  - Handoff-specific logging helper.

- `/FCBP/CL_GLT_AUDIT_WRITER`
  - Writes handoff audit events.

## Exceptions

- `/FCBP/CX_GLT_HANDOFF`
  - General handoff failure.

- `/FCBP/CX_GLT_SRC_INELIG`
  - Source object is not eligible for transfer.

- `/FCBP/CX_GLT_ROUTE`
  - Routing/profile resolution failure.

- `/FCBP/CX_GLT_REG_DUP`
  - Duplicate registration condition.

- `/FCBP/CX_GLT_REG_LOCK`
  - Registration lock or in-progress conflict.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_HANDOFF`.
