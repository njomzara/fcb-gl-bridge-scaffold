# Code-vs-DTS iteration 2: GAP-014

- Run ID: 20260719T060812100Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T060812100Z/002
- Outcome: code_updated
- Validation passed: True

## Gap

Required split dimensions and configured balance scopes could previously be silently ignored.

## Reasoning

The DTS explicitly defines supported balance scopes and blocking error identifiers. The splitter now validates these requirements before constructing split keys or outbound documents, without expanding the unresolved dimension catalogue.

## Introduced fix, update, or new artifact

- Added blank-value validation for all five enabled split dimensions.
- Added explicit validation for all four supported balance scopes and their required grouping flags.
- Rejected missing, unsupported, and grouping-incompatible balance scopes.
- Marked only GAP-014 as Resolved and updated the registerâ€™s unresolved count from 23 to 22.
