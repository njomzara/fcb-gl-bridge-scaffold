# Code-vs-DTS iteration 2: GAP-020

- Run ID: 20260719T071537099Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T071537099Z/002
- Outcome: code_updated
- Validation passed: True

## Gap

The mapping catalogue advertised CHART_OF_ACCOUNTS, but runtime mapping and its canonical DTO/persistence path omitted it.

## Reasoning

The other 14 fields in DTS section 6.7 already had mapper evaluation. Adding the sole missing field to aggregation, canonical storage, CDS exposure, and mapping closes this bounded gap without altering the governed matching and derivation semantics tracked separately by GAP-021.

## Introduced fix, update, or new artifact

- Added chart_of_accounts to the canonical-line ABAP type.
- Propagated the source chart through aggregation.
- Added durable table storage and CDS projection.
- Added per-line mapping and decision evidence for CHART_OF_ACCOUNTS.
- Marked only GAP-020 resolved and changed the unresolved count from 19 to 18.
