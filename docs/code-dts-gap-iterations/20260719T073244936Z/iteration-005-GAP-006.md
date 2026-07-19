# Code-vs-DTS iteration 5: GAP-006

- Run ID: 20260719T073244936Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T073244936Z/005
- Outcome: needs_human
- Validation passed: True

## Gap

Immutable effective policy/package context is not preserved across processing, rebuild, and retry.

## Reasoning

A safe implementation requires authoritative choices for the context lifecycle owner and binding instant, target-system versus target-profile identity, pinned version/hash set, rebuild semantics, and existing-context compatibility. A partial code change could produce conflicting persisted evidence or change retry behavior. The register now recommends creating one transfer-bound immutable context and using explicit supersession for authorized changes.

## Introduced fix, update, or new artifact

- Changed GAP-006 status from Open to Needs Human Decision.
- Added required architecture decisions and three evaluated alternatives.
- Added scoped evidence and validation notes to C:\Users\Minja\Documents\FCBP GL Connector\docs\code-dts-gap-register.md.
- Modified no other gap entry, runtime file, or DTS contract.
