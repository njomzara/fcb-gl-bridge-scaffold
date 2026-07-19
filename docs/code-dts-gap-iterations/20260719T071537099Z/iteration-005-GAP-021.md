# Code-vs-DTS iteration 5: GAP-021

- Run ID: 20260719T071537099Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T071537099Z/005
- Outcome: needs_human
- Validation passed: True

## Gap

Mapping derivation, truncation, validity, and rule matching use scaffold behavior rather than governed semantics.

## Reasoning

A safe runtime implementation cannot be inferred. DERIVE fabricates `DRV:<rule id>`, truncation ignores `TRUNCATION_RULE`, and the rule schema lacks effective-date and target/profile scope. The DTS explicitly leaves the derivation model and truncation policy to human owners. A versioned derivation registry, truncation catalogue, expanded rule metadata, and shared activation/runtime resolver is preferred.

## Introduced fix, update, or new artifact

- Changed GAP-021 status from Open to Needs Human Decision.
- Documented required decisions and three alternatives.
- Updated only docs/code-dts-gap-register.md; no code or DTS contract changed.
