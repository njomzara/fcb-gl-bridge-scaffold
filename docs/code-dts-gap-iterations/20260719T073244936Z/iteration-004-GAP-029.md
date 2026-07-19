# Code-vs-DTS iteration 4: GAP-029

- Run ID: 20260719T073244936Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T073244936Z/004
- Outcome: needs_human
- Validation passed: True

## Gap

Active validation runs lack idempotency and concurrency control, allowing competing RUNNING records and inconsistent decisions.

## Reasoning

A local code guard is unsafe. Validation creates an unconditional UUID-keyed RUNNING row, while findings and closure have no ownership token. The DTS assigns locking and the composite LUW to the caller but permits skip, wait, or BLOCKED loser behavior depending on outbox semantics. Lock ownership, stale-run recovery, fencing, and commit boundaries therefore require human architecture/platform/operations approval alongside GAP-005.

## Introduced fix, update, or new artifact

- Changed GAP-029 status from Open to Needs Human Decision.
- Recorded the decisions required for locking, reservation identity, loser behavior, stale-run recovery, supersession, ownership fencing, and completed-run reuse.
- Documented three alternatives and identified caller-owned locking with persisted fencing and atomic publication as the preferred direction.
- Added scoped validation evidence to C:\Users\Minja\Documents\FCBP GL Connector\docs\code-dts-gap-register.md.
