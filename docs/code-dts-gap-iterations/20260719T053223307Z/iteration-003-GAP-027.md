# Code-vs-DTS iteration 3: GAP-027

- Run ID: 20260719T053223307Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T053223307Z/003
- Outcome: code_updated
- Validation passed: True

## Gap

Any non-empty waiver identifier bypassed blocking validation findings without verification of its authority, scope, or expiry.

## Reasoning

The register explicitly permits a fail-closed interim correction. Because no authoritative waiver-validation service is bound, an identifier alone cannot constitute governed waiver evidence. Zero-blocker results still pass normally.

## Introduced fix, update, or new artifact

- Removed the branch in /FCBP/CL_GLT_VAL_RESULT that returned WAIVED and allowed mapping solely because waiver_context_id was non-empty.
- Blocking findings now always return FAILED, passed = false, and OPERATOR_ACTION.
- Marked GAP-027 Resolved and recorded the decision and validation evidence in the gap register.
