# /FCBP/GLT_VALIDATION - Validation Package

This package owns package-level validation before mapping and adapter execution. It reads package evidence, evaluates validation rules, persists validation runs/findings, and returns pass/block decisions.

## Runtime Pattern

- Work handlers build a package validation context.
- Package evidence reader loads transfer, package graph, target profile, policy context, validation rules, target references, and attempts.
- Rule evaluator produces findings.
- Result builder converts findings into passed, blocked, warning, and next-step outcomes.
- Validation repository persists run and finding evidence.

## Interfaces

- `/FCBP/IF_GLT_VAL_TYPES`
  - Validation DTOs and constants for rules, run modes, findings, package evidence, and results.

- `/FCBP/IF_GLT_PKG_VALIDATOR`
  - Facade contract for validating or revalidating a package.

- `/FCBP/IF_GLT_PKG_EVIDENCE`
  - Contract for reading all evidence needed by validation.

- `/FCBP/IF_GLT_VAL_RULE_EVAL`
  - Contract for applying validation rules to package evidence.

- `/FCBP/IF_GLT_VAL_REPO`
  - Persistence contract for validation runs and findings.

- `/FCBP/IF_GLT_VAL_HEALTH`
  - Validation health/reporting contract.

## Classes

- `/FCBP/CL_GLT_PKG_VALIDATOR`
  - Main validation facade.
  - Creates validation run, reads evidence, evaluates rules, stamps findings, computes result, and closes run.

- `/FCBP/CL_GLT_PKG_EVIDENCE`
  - Reads transfer, package graph, target profile, policy context, validation rules, target refs, and attempts.

- `/FCBP/CL_GLT_VAL_RULES`
  - Default validation rule evaluator.

- `/FCBP/CL_GLT_VAL_RESULT`
  - Computes validation result status, blocking count, warning count, messages, and next allowed step.

- `/FCBP/CL_GLT_VAL_FINDING`
  - Finding helper/factory for validation diagnostics.

- `/FCBP/CL_GLT_VAL_REPO`
  - Productive repository scaffold over `/FCBP/GLT_VALRUN` and `/FCBP/GLT_VALFND`.

- `/FCBP/CL_GLT_VAL_HEALTH`
  - Validation health check scaffold.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_VALIDATION`.
