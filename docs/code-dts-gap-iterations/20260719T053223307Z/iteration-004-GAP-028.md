# Code-vs-DTS iteration 4: GAP-028

- Run ID: 20260719T053223307Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T053223307Z/004
- Outcome: code_updated
- Validation passed: True

## Gap

Active validation rules with blank or unsupported expression references could pass without executing a required control.

## Reasoning

The runtime evaluator previously ignored blank expression references and respected the invalid ruleâ€™s configured blocking flag for unsupported expressions. It now creates an unconditional blocking finding for both cases, while leaving supported expressions unchanged.

## Introduced fix, update, or new artifact

- Updated `#fcbp#cl_glt_val_rules.clas.abap` to reject blank or unsupported expression references with `iv_blocking = abap_true`.
- Marked GAP-028 resolved and documented the decision and validation.
- Reconciled register totals to 25 open and 4 resolved entries, including the previously resolved GAP-027.
