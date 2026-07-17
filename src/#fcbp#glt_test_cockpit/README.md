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
