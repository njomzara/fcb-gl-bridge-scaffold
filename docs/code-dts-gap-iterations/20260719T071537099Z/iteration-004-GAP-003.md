# Code-vs-DTS iteration 4: GAP-003

- Run ID: 20260719T071537099Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T071537099Z/004
- Outcome: needs_human
- Validation passed: True

## Gap

Intake and core idempotency lack an atomic, recoverable reservation protocol.

## Reasoning

The registration row is reserved atomically, but transfer, status, outbox, audit, and activation writes are separate. Duplicate state is fabricated, recovery is unimplemented, and core idempotency lacks fencing/takeover metadata. Implementing recovery safely requires authoritative LUW ownership, fencing, lease, takeover, and compensation policies. A versioned fencing/lease protocol is preferred.

## Introduced fix, update, or new artifact

- Changed GAP-003 status from Open to Needs Human Decision.
- Added required decisions and evaluated alternatives for GAP-003.
- Updated unresolved-gap counts from 18 to 17.
- Changed only docs/code-dts-gap-register.md; no runtime or DTS contract was modified.
