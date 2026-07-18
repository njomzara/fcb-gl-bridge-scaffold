# /FCBP/GLT_ADAPTER - Adapter Package

This package owns target-system adapter contracts, payload builders, normalized adapter outcomes, and adapter evidence persistence helpers. It is used by Outbox Execution after Mapping has produced target-ready journal content.

## Runtime Pattern

- Outbox handlers ask the adapter factory in Core for a target adapter.
- Adapter implementations expose one common transfer adapter contract from Core.
- Payload builders create target-specific request structures.
- Adapter clients isolate protocol execution from handler logic.
- Normalizers convert target/protocol responses into GL Bridge adapter outcomes.
- Evidence classes persist attempt lifecycle rows for submit, retry, poll, and status query.

## Interfaces

- `/FCBP/IF_GLT_ADAPTER_TYPES`
  - Adapter DTOs and constants for submit/query requests, capabilities, timeout policies, query handles, and payload metadata.

- `/FCBP/IF_GLT_ADAPTER_PAYLOAD`
  - Contract for target payload builders.
  - Turns mapped journal/package context into target-specific request payload references.

- `/FCBP/IF_GLT_ADAPTER_NORMALIZER`
  - Contract for response/error normalization.
  - Converts protocol or target responses into `/FCBP/IF_GLT_TYPES=>TY_ADAPTER_RESULT`.

- `/FCBP/IF_GLT_ADAPTER_CLIENT`
  - Low-level client contract for target submit/query calls.
  - Keeps HTTP/RFC/middleware mechanics out of business handlers.

- `/FCBP/IF_GLT_ADAPTER_CAPABILITY`
  - Contract for adapter capability discovery.
  - Describes whether submit, status query, synchronous confirmation, and export-only modes are supported.

- `/FCBP/IF_GLT_ADAPTER_EVIDENCE`
  - Contract for adapter attempt evidence.
  - Starts, finishes, and persists submit/retry/poll/status-query attempt rows.

## Classes

- `/FCBP/CL_GLT_ADAPTER_CAPABILITY`
  - Default capability builder used by adapters and tests.

- `/FCBP/CL_GLT_ADAPTER_CLIENT`
  - Protocol client scaffold for outbound adapter calls.
  - Intended replacement point for released HTTP/RFC/middleware APIs in the target tenant.

- `/FCBP/CL_GLT_ADAPTER_NORMALIZER`
  - Normalizes adapter responses and errors into bridge outcomes.
  - Centralizes retryable, terminal, and unknown-confirmation classification inputs.

- `/FCBP/CL_GLT_ADAPTER_EVIDENCE`
  - Persists adapter attempt evidence into `/FCBP/GLT_ATT`.
  - Populates attempt timestamps, package/document references, request hashes, response hashes, and outcomes.

- `/FCBP/CL_GLT_ADAPTER_MOCK`
  - Mock target adapter for happy-path and local scaffold execution.
  - Returns deterministic target results without real target connectivity.

- `/FCBP/CL_GLT_ADAPTER_TEST_DOUBLE`
  - Test double adapter with configurable submit/query behavior.
  - Used by ABAP Unit or harness-style verification.

- `/FCBP/CL_GLT_ADAPTER_CPI`
  - Integration Suite adapter scaffold.
  - Owns CPI-specific dispatch/status-query semantics.

- `/FCBP/CL_GLT_ADAPTER_S4PUB`
  - S/4HANA Public Cloud adapter scaffold.
  - Uses public-cloud compatible payload and confirmation assumptions.

- `/FCBP/CL_GLT_ADAPTER_S4PRV`
  - S/4HANA Private Cloud adapter scaffold.
  - Reserved for private-cloud API/RFC differences.

- `/FCBP/CL_GLT_ADAPTER_ONPREM`
  - On-premise adapter scaffold.
  - Reserved for on-premise protocol and destination patterns.

- `/FCBP/CL_GLT_PAYLOAD_CPI`
  - CPI payload builder.
  - Shapes mapped journal data for middleware dispatch.

- `/FCBP/CL_GLT_PAYLOAD_S4PUB`
  - S/4HANA Public Cloud payload builder.
  - Shapes mapped journal data for public-cloud posting APIs.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_ADAPTER`.
