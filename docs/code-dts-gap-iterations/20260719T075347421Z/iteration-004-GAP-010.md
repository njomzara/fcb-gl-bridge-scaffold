# Code-vs-DTS iteration 4: GAP-010

- Run ID: 20260719T075347421Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T075347421Z/004
- Outcome: needs_human
- Validation passed: True

## Gap

Operator monitoring DTOs and persistence omit required evidence/context, while six declared RAP actions and the service binding remain unimplemented.

## Reasoning

A safe implementation requires approved evidence identities/cardinality, durable-versus-derived job fields, redaction and privileged-drilldown boundaries, transaction ownership, the productive RAP composition root, and the tenant-supported OData binding/deployment procedure. Implementing guessed fields or directly wiring the service could conflict with GAP-004/005/007/008/026. The register now documents three alternatives and recommends a versioned DTO/evidence contract followed by guarded persistence and injected RAP action implementation.

## Introduced fix, update, or new artifact

- Updated only GAP-010 in docs/code-dts-gap-register.md.
- Changed GAP-010 status from Open to Needs Human Decision.
- Recorded the required decisions, alternatives, preferred direction, changed-file scope, and validation evidence.
- No runtime or DTS files were changed.
