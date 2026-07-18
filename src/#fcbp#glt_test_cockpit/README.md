# /FCBP/GLT_TEST_COCKPIT

Scaffold package for a Fiori elements OData V4 cockpit over the `/FCBP/GLT_TEST`
happy-path harness.

The package is intentionally separate from `/FCBP/GLT_TEST`: fixture services and
test doubles remain in `/FCBP/GLT_TEST`, while this package owns UI-facing run
history, snapshot persistence, RAP behavior shells, and the test cockpit service.

## Scope

- Landing page: test kickoff commands plus run list.
- Object page: run metadata and evidence tables stacked as sections.
- Mock target document section: tree table where posted GL document lines expand
  to contributing source/source-trace rows.
- Initial implementation target: scaffold and activation hardening, not a
  production support cockpit.

## Important activation notes

- `/FCBP/CL_GLT_TC_APP_SERVICE` currently delegates to
  `/FCBP/CL_GLT_TST_RUNNER->RUN_HAPPY_PATH` and marks persistence handoff points.
- Behavior implementation methods need to be filled in after the target RAP
  release syntax and action-signature conventions are confirmed in ADT.
- The TreeTable requires OData V4 hierarchy metadata generated from
  `/FCBP/H_GLT_TC_TGTNODE`; adjust the UI manifest `hierarchyQualifier` if the
  generated metadata qualifier differs in the target tenant.

## Interfaces

- `/FCBP/IF_GLT_TC_TYPES`
  - Test cockpit DTOs and constants for run, item, canonical line, seed, target node, timeline, and work projections.

## Tables

- `/FCBP/GLT_TCRUN`
  - Test cockpit run header/history.

- `/FCBP/GLT_TCITM`
  - Test run item evidence.

- `/FCBP/GLT_TCCAN`
  - Test run canonical line evidence.

- `/FCBP/GLT_TCSD`
  - Test seed/source data snapshot.

- `/FCBP/GLT_TCTGT`
  - Mock target document evidence.

- `/FCBP/GLT_TCTIME`
  - Test run timeline events.

- `/FCBP/GLT_TCWRK`
  - Test cockpit work/action records.

## CDS Views

- `/FCBP/C_GLT_TC_RUN`
  - Consumption view for test run headers.

- `/FCBP/C_GLT_TC_ITEM`
  - Consumption view for test run items.

- `/FCBP/C_GLT_TC_CANON`
  - Consumption view for canonical line evidence.

- `/FCBP/C_GLT_TC_SEED`
  - Consumption view for seeded source data.

- `/FCBP/C_GLT_TC_TGTNODE`
  - Consumption view for mock target tree nodes.

- `/FCBP/C_GLT_TC_TIME`
  - Consumption view for run timeline.

- `/FCBP/C_GLT_TC_WORK`
  - Consumption view for cockpit work/action rows.

- `/FCBP/I_GLT_TC_TGTNODE`
  - Interface view for target tree node data.

- `/FCBP/H_GLT_TC_TGTNODE`
  - Hierarchy view for target document and contributing source/source-trace rows.

## RAP and Services

- `/FCBP/UI_GLT_TEST_COCKPIT`
  - Test cockpit service definition and binding.

- `/FCBP/R_GLT_TC_RUN`
  - RAP behavior shell for test run actions.

- `/FCBP/BP_GLT_TC_RUN`
  - Behavior provider scaffold for test run actions.

- `/FCBP/CL_GLT_TC_APP_SERVICE`
  - Application service that delegates to the happy-path test runner and persists cockpit snapshots.

## ABAP Package Artifact

- `package.devc.xml`
  - abapGit package object for `/FCBP/GLT_TEST_COCKPIT`.
