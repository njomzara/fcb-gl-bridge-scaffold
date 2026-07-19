# Code-vs-DTS iteration 2: GAP-004

- Run ID: 20260719T073244936Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T073244936Z/002
- Outcome: needs_human
- Validation passed: True

## Gap

Dispatch ambiguity is not durably fenced before target side effects.

## Reasoning

A safe implementation requires approved cross-layer contracts for the pre-I/O commit boundary, persisted fencing tokens and lease semantics, route-aware target-reference uniqueness, status-query-first recovery, and productive-route idempotency/query capabilities. Implementing only part of this protocol could still permit duplicate posting or stale-worker finalization.

## Introduced fix, update, or new artifact

- Updated only GAP-004 in docs/code-dts-gap-register.md.
- Documented the decisions requiring architecture, integration, and operations approval.
- Recorded three alternatives and recommended a persisted fencing token, committed pre-I/O evidence, idempotent reference insertion, and evidence-driven recovery state machine.
- Added scoped validation evidence; no runtime or DTS files were changed.
