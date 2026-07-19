# Code-vs-DTS iteration 1: GAP-022

- Run ID: 20260719T065408892Z
- Discovery cycle: 1
- Iteration branch: codex/dts-gap-20260719T065408892Z/001
- Outcome: code_updated
- Validation passed: True

## Gap

The handoff factory hard-coded posting/document dates to the runtime date, currency to USD, and maximum retries to 5 without authoritative source or policy evidence.

## Reasoning

The handoff request and routing context do not supply authoritative values for these fields. Leaving them initial until source reading, package preparation, and configuration resolution populate them follows the documented safe boundary without inventing a new API contract.

## Introduced fix, update, or new artifact

- Removed runtime-date assignments for posting date and document date.
- Removed the hard-coded USD currency assignment.
- Removed the hard-coded maximum retry count of 5.
- Preserved the supplied company code and initial retry count.
- Marked GAP-022 resolved and updated register summary metadata.
- Created the immutable discovery-cycle history snapshot: code-dts-gap-register-20260719T065408892Z-cycle001.md.
