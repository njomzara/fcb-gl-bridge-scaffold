# /FCBP/GLT_CORE - Transfer Core Package

This package owns shared runtime contracts, transfer persistence, status lifecycle, idempotency, locking, logging, orchestration, and cross-layer DTOs used by the GL Bridge.

## Runtime Pattern

- Source Handoff creates transfer headers/items through Core repository APIs.
- Transfer Core persists transfer state and status history.
- Package, validation, mapping, adapter, monitor, and outbox layers share DTOs from Core.
- Status manager is the single transition authority.
- Retry, lock, idempotency, logging, and authorization helpers centralize common operational behavior.

## Interfaces

- `/FCBP/IF_GLT_TYPES`
  - Transfer Core constants and DTOs for transfers, items, statuses, errors, target refs, attempts, retries, outbox, monitor actions, and handoff.

- `/FCBP/IF_GLT_PKG_TYPES`
  - Shared package graph DTOs for package header, outbound documents, canonical lines, source trace, and package build context.

- `/FCBP/IF_GLT_REPOSITORY`
  - Core persistence contract for transfer headers/items, status history, errors, retries, target refs, idempotency, config lookup, and reconciliation.

- `/FCBP/IF_GLT_TRANSFER_API`
  - Transfer-facing application API contract.

- `/FCBP/IF_GLT_TRANSFER_ADAPTER`
  - Common target adapter contract used by adapter implementations.

- `/FCBP/IF_GLT_VALIDATOR`
  - Core transfer request validation contract.

- `/FCBP/IF_GLT_STATUS_MANAGER`
  - Status transition and external-status derivation contract.

- `/FCBP/IF_GLT_RETRY_SERVICE`
  - Retry policy, retry scheduling, and adapter-result classification contract.

- `/FCBP/IF_GLT_IDEMPOTENCY`
  - Idempotency reservation and completion contract.

- `/FCBP/IF_GLT_LOCK_MANAGER`
  - Transfer lock contract.

- `/FCBP/IF_GLT_LOGGER`
  - Application logging and normalized error persistence contract.

- `/FCBP/IF_GLT_CONFIG_PROVIDER`
  - Configuration and route lookup contract consumed across layers.

- `/FCBP/IF_GLT_AUTH_CHECK`
  - Authorization check contract.

## Classes

- `/FCBP/CL_GLT_REPOSITORY`
  - Productive repository scaffold over the core GLT tables.

- `/FCBP/CL_GLT_ORCHESTRATOR`
  - Application orchestration shell for transfer processing.

- `/FCBP/CL_GLT_REQUEST_FACTORY`
  - Builds transfer requests from inbound handoff data.

- `/FCBP/CL_GLT_VALIDATOR`
  - Core request/header/item validator.

- `/FCBP/CL_GLT_STATUS_MGR`
  - Enforces status transitions and appends `/FCBP/GLT_STAT` history.

- `/FCBP/CL_GLT_RETRY_SERVICE`
  - Classifies adapter results and creates retry/status-query schedules.

- `/FCBP/CL_GLT_IDEMPOTENCY`
  - Manages idempotency reservation and completion records.

- `/FCBP/CL_GLT_LOCK_MANAGER`
  - Manages transfer-level locks for worker coordination.

- `/FCBP/CL_GLT_APP_LOGGER`
  - Writes normalized errors and application log references.

- `/FCBP/CL_GLT_CONFIG_PROVIDER`
  - Resolves transfer config, route, target profile, and effective policy context.

- `/FCBP/CL_GLT_AUTH_CHECK`
  - Authorization check scaffold for transfer and monitor actions.

- `/FCBP/CL_GLT_ADAPTER_FACTORY`
  - Chooses concrete adapter implementation by target profile.

## Exceptions

- `/FCBP/CX_GLT_ERROR`
  - Base bridge exception with transfer id, category, retryable, unknown-confirmation, and operator text.

- `/FCBP/CX_GLT_REPOSITORY`
  - Repository/persistence failure.

- `/FCBP/CX_GLT_VALIDATION`
  - Validation failure.

- `/FCBP/CX_GLT_CONFIG`
  - Configuration resolution failure.

- `/FCBP/CX_GLT_ADAPTER`
  - Adapter/protocol/target failure.

- `/FCBP/CX_GLT_LOCK`
  - Lock acquisition or ownership failure.

- `/FCBP/CX_GLT_DUPLICATE`
  - Duplicate or idempotency conflict.

- `/FCBP/CX_GLT_AUTH`
  - Authorization failure.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_CORE`.
