# Code-vs-DTS iteration 1: GAP-013

- Run ID: 20260719T060812100Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T060812100Z/001
- Outcome: code_updated
- Validation passed: True

## Gap

Runtime split execution did not enforce the DTS target document/item/amount limits.

## Reasoning

The splitter previously grouped all matching lines into one document, reporting only a line-limit violation afterward and never using max_amount. It now creates deterministic continuation documents only at balanced boundaries. If a balanced split cannot satisfy either limit, it emits blocking GLT_SPL_007 or GLT_SPL_008 evidence so package preparation fails closed.

## Introduced fix, update, or new artifact

- Updated /FCBP/CL_GLT_SPLITTER to track the current continuation document per split key.
- Added balanced-boundary continuation creation for maximum line and amount limits.
- Added final blocking checks for unsatisfied line and amount limits.
- Marked GAP-013 resolved and updated the register totals to 23 open and 6 resolved.
