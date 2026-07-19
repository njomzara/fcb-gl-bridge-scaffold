# Code-vs-DTS iteration 2: GAP-023

- Run ID: 20260719T065408892Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T065408892Z/002
- Outcome: code_updated
- Validation passed: True

## Gap

Required source identity and cardinality constraints were not fully validated before normalized snapshot output.

## Reasoning

The DTS explicitly requires these consistency checks, and they can be implemented without deciding unsupported source shapes. Validation now occurs before normalized lines leave Source Reading. A positive max_line_count enforces the optional configured guardrail; zero leaves it unconfigured.

## Introduced fix, update, or new artifact

- Added max_line_count to the source-read request contract.
- Rejected returned lines whose source type differs from the request.
- Rejected duplicate source document/item identities.
- Validated eligible row counts against reconciliation and document headers.
- Validated eligible rows against header identity, snapshot, company code, and currency.
- Marked only GAP-023 resolved and updated unresolved counts in the register.
