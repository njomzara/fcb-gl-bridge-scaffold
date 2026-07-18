# /FCBP/GLT_TEST - Test Harness Package

This package owns the happy-path scaffold harness, test doubles, mock source/target stores, seed data, and assertion helpers.

## Runtime Pattern

- Seed class populates mock source, configuration, package, outbox, and target state.
- Test factory wires test doubles for repository, authorization, dispatch, and target adapter.
- Runner executes a happy-path flow through the same contracts as productive code.
- Store keeps test-run state and mock target documents.
- Assertions verify transfer, package, validation, mapping, dispatch, and target evidence.

## Interfaces

- `/FCBP/IF_GLT_TST_TYPES`
  - Test harness DTOs and constants for seeds, runs, expected evidence, and mock target records.

## Classes

- `/FCBP/CL_GLT_TST_FACTORY`
  - Builds the test harness dependency graph.

- `/FCBP/CL_GLT_TST_SEED`
  - Populates mock source rows, seeded configuration, and initial test data.

- `/FCBP/CL_GLT_TST_RUNNER`
  - Executes the happy-path scenario.

- `/FCBP/CL_GLT_TST_REPO`
  - In-memory/test repository implementation for productive repository contracts.

- `/FCBP/CL_GLT_TST_STORE`
  - Shared test store for transfer/package/config/mock-target state.

- `/FCBP/CL_GLT_TST_TARGET_ADPTR`
  - Mock target adapter for GL document posting evidence.

- `/FCBP/CL_GLT_TST_WH_DISPATCH`
  - Test dispatch work handler/double for harness-level execution.

- `/FCBP/CL_GLT_TST_AUTH_ALLOW`
  - Authorization test double that permits actions.

- `/FCBP/CL_GLT_TST_ASSERT`
  - Assertion helper for happy-path evidence checks.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_TEST`.
