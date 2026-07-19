# Code-vs-DTS iteration 5: GAP-009

- Run ID: 20260719T075347421Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T075347421Z/005
- Outcome: needs_human
- Validation passed: True

## Gap

Operational orchestration has competing and incomplete execution paths.

## Reasoning

The direct Core dispatcher bypasses staged evidence, while job wrappers inconsistently use the common runner and poll/status paths remain shells. Selecting the productive orchestration root, compatibility behavior, scheduler bindings, and route-specific recovery semantics requires architecture and operations authority. The register recommends the outbox-backed runner with legacy APIs enqueueing work.

## Introduced fix, update, or new artifact

- Changed GAP-009 status from Open to Needs Human Decision.
- Added the required decision, three alternatives, preferred direction, changed-files statement, and validation evidence to docs/code-dts-gap-register.md.
