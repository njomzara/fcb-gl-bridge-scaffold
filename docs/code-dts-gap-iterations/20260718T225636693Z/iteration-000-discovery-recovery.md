# Code-vs-DTS discovery recovery checkpoint

- Run ID: 20260718T225636693Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260718T225636693Z/001
- Outcome: discovery_completed_after_schema_recovery
- Validation passed: true

## Gap

Discovery stage 17 could not start because the Codex structured-output API rejects the JSON Schema `uniqueItems` keyword used by `reviewed_dts_files`.

## Reasoning

Stages 1 through 16 had completed and their immutable Markdown evidence was already persisted. Repeating those stages would discard useful history and incur a large unnecessary analysis pass. The compatible recovery was to remove only the unsupported schema keyword, preserve the uniqueness invariant as an explicit PowerShell validation, and rerun stage 17 against the persisted evidence.

The resumed synthesis confirmed the mandatory architecture baseline, all 14 DTS files, the implementation, and all four comparison lanes. It consolidated the layer candidates into 29 unresolved gaps: 10 P0, 17 P1, and 2 P2.

## Introduced fix, update, or new artefact

- Removed the unsupported `uniqueItems` keyword from `tools/gap-discovery-result.schema.json`.
- Added an explicit duplicate-DTS-name coverage check to `tools/run-code-dts-gap-loop.ps1`.
- Persisted the complete 17-stage discovery evidence under `docs/code-dts-discovery/20260718T225636693Z/cycle-001`.
- Created `docs/code-dts-gap-register.md` with 29 open gaps.
- Verified that stage 17 returned all 14 DTS filenames, baseline and implementation coverage, and all four comparison lanes.

