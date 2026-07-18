# /FCBP/GLT_TARGET_RTG_POLICY - Target Routing and Policy Package

This package owns target routing helper logic, routing bucket calculation, effective-context hashing, policy cache, and route audit support.

## Runtime Pattern

- Handoff and Configuration determine routing scope.
- Routing bucket groups transfer work for target selection, throttling, and monitoring.
- Effective context hash captures resolved policy evidence.
- Context cache avoids repeated policy reads during a processing run.
- Route audit helper creates traceable records for support and governance.

## Interfaces

- `/FCBP/IF_GLT_TRP_TYPES`
  - Target routing and policy DTOs.

- `/FCBP/IF_GLT_ROUTING_BUCKET`
  - Contract for deriving routing buckets from transfer and scope data.

- `/FCBP/IF_GLT_EFFECTIVE_CTX_HASH`
  - Contract for hashing effective configuration context.

## Classes

- `/FCBP/CL_GLT_ROUTING_BUCKET`
  - Builds routing bucket identifiers for transfer grouping and queue filtering.

- `/FCBP/CL_GLT_EFFECTIVE_CTX_HASH`
  - Calculates deterministic hashes for effective context evidence.

- `/FCBP/CL_GLT_CONTEXT_CACHE`
  - In-memory context cache for repeated policy reads inside a run.

- `/FCBP/CL_GLT_ROUTE_AUDIT_HELPER`
  - Builds route decision/audit helper structures.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_TARGET_RTG_POLICY`.
