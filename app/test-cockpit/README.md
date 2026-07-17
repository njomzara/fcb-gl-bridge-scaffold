# GLT Test Cockpit Fiori Elements Scaffold

This folder is a lightweight SAP Fiori elements OData V4 app scaffold for the
ABAP service `/FCBP/UI_GLT_TEST_COCKPIT`.

It is intentionally kept outside `src/` because the current repository is an
ABAPGit object scaffold rather than a deployable UI5 project. If this app is
later deployed as a BSP/UI5 repository object, move or generate the equivalent
UI artifact layout according to the target tenant tooling.

## Pages

- `TestRuns` list report: kickoff commands and run list.
- `TestRuns` object page: run metadata plus stacked evidence sections.
- `_MockTargetDocumentTree`: configured as a TreeTable. The hierarchy qualifier
  may need adjustment after checking the generated OData V4 metadata for
  `/FCBP/H_GLT_TC_TGTNODE`.
