# Code-vs-DTS iteration 3: GAP-012

- Run ID: 20260719T071537099Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T071537099Z/003
- Outcome: needs_human
- Validation passed: True

## Gap

Productive source, target, eligibility, batch-discovery, and Application Job bindings are unresolved.

## Reasoning

The necessary bindings depend on tenant-released FCBP projections, the selected target channel and communication contract, supported Application Job artifacts, and an approved deployment composition root. Guessing these could introduce unreleased APIs or unsafe accounting and recovery semantics. Existing seams should remain fail-closed pending approval.

## Introduced fix, update, or new artifact

- Changed GAP-012 status from Open to Needs Human Decision.
- Documented the required source, target, scheduler, and composition-root decisions.
- Recorded three alternatives and recommended implementing approved tenant-specific bindings behind existing interfaces.
- Updated only docs/code-dts-gap-register.md; no runtime or DTS contracts changed.
