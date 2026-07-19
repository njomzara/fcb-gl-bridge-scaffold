# Code-vs-DTS iteration 4: GAP-018

- Run ID: 20260719T065408892Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T065408892Z/004
- Outcome: needs_human
- Validation passed: True

## Gap

Configuration activation, deactivation, and governance actions are declared in RAP but lack behavior implementations.

## Reasoning

The existing admin service requires productive authorization and audit dependencies that have no composition root. The managed RAP update and durable audit event also lack declared LUW ownership. Adding handlers now would either fail activation/deactivation or bypass mandatory governance controls. A RAP-facing dependency factory and transaction contract should be selected alongside GAP-005 and GAP-007.

## Introduced fix, update, or new artifact

- Changed GAP-018 status from Open to Needs Human Decision.
- Documented the required composition-root, authorization, audit, and LUW decisions.
- Recorded three alternatives and the preferred technical direction.
- Modified only docs/code-dts-gap-register.md.
