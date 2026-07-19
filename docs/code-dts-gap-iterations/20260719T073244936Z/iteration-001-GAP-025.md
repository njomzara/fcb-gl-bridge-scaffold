# Code-vs-DTS iteration 1: GAP-025

- Run ID: 20260719T073244936Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T073244936Z/001
- Outcome: needs_human
- Validation passed: True

## Gap

Document type and routing hint are absent from target-profile persistence/query, while exact-versus-wildcard routing precedence is unspecified.

## Reasoning

The routing DTO declares both dimensions, but the target-profile table and query cannot represent them. The DTS explicitly leaves routing-store ownership, wildcard/default modeling, numeric-priority direction, and routing-bucket composition unresolved. Implementing code now would invent schema, precedence, and identity semantics that can affect registration, retries, and duplicate detection.

## Introduced fix, update, or new artifact

- Changed GAP-025 status from Open to Needs Human Decision.
- Documented the decisions required for routing storage, dimensions, wildcard encoding, precedence, and routing identity.
- Recorded three alternatives and recommended approving a unified routing contract before coordinated implementation.
- Updated only C:\Users\Minja\Documents\FCBP GL Connector\docs\code-dts-gap-register.md.
- Created the immutable discovery-cycle history snapshot: code-dts-gap-register-20260719T073244936Z-cycle001.md.
