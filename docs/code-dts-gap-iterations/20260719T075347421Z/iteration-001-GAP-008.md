# Code-vs-DTS iteration 1: GAP-008

- Run ID: 20260719T075347421Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T075347421Z/001
- Outcome: needs_human
- Validation passed: True

## Gap

Lifecycle audit evidence is fragmented, schema-weak, and non-idempotent.

## Reasoning

A safe implementation requires approved mandatory-event classification, lifecycle ownership, audit-write failure semantics, deterministic identity compatible with GAP-002, and completeness/reconciliation authority. Implementing only validation, handler wiring, or guessed deterministic IDs could create duplicate or falsely authoritative audit evidence.

## Introduced fix, update, or new artifact

- Updated only GAP-008 in docs/code-dts-gap-register.md.
- Documented the required decisions and three alternatives.
- Recorded scoped validation evidence; no runtime or DTS contract changed.
- Created the immutable discovery-cycle history snapshot: code-dts-gap-register-20260719T075347421Z-cycle001.md.
