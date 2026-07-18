# /FCBP/GLT_CONFIG - Configuration Package

This package owns target profiles, policy families, configuration health, deterministic config hashes, and policy-context evidence used by package build, validation, mapping, and adapter execution.

## Runtime Pattern

- Configuration repository reads active target profiles and policy objects.
- Configuration provider in Core resolves the effective context for a transfer scope.
- Policy context persists the exact configuration evidence used for a package/run.
- Health checks detect missing, inactive, expired, ambiguous, or inconsistent configuration.
- Hash utilities support auditability and reproducibility.

## Interfaces

- `/FCBP/IF_GLT_CONFIG_TYPES`
  - Configuration DTOs and constants for target profiles, policy objects, health findings, and policy contexts.

- `/FCBP/IF_GLT_CONFIG_REPO`
  - Repository contract for target profiles, retry, aggregation, split, validation, mapping, throttle, confirmation, health, and policy-context tables.

- `/FCBP/IF_GLT_CONFIG_ADMIN`
  - Administrative contract for create/change/activate/deactivate style configuration operations.

- `/FCBP/IF_GLT_CONFIG_HASH`
  - Contract for deterministic configuration hash calculation.

- `/FCBP/IF_GLT_CONFIG_HEALTH`
  - Contract for configuration health checks and findings.

- `/FCBP/IF_GLT_POLICY_CONTEXT`
  - Contract for creating and reading policy-context evidence records.

## Classes

- `/FCBP/CL_GLT_CONFIG_REPO`
  - Productive repository scaffold over `/FCBP/CC_*`, `/FCBP/GLT_CFG`, `/FCBP/GLT_ROUTE`, `/FCBP/GLT_POLCTX`, and config health tables.

- `/FCBP/CL_GLT_CONFIG_ADMIN`
  - Administrative service scaffold for controlled configuration change.

- `/FCBP/CL_GLT_CONFIG_VALIDATOR`
  - Validates configuration objects before activation or use.

- `/FCBP/CL_GLT_CONFIG_MIGRATION`
  - Migration/seed scaffold for versioned configuration structures.

- `/FCBP/CL_GLT_CONFIG_HEALTH`
  - Runs health checks and persists configuration health findings.

- `/FCBP/CL_GLT_CONFIG_HASH`
  - Produces stable hashes for configuration objects and policy sets.

- `/FCBP/CL_GLT_POLICY_CONTEXT`
  - Creates policy-context evidence from effective configuration.
  - Supports later validation, mapping, retry, poll, and audit traceability.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_CONFIG`.
