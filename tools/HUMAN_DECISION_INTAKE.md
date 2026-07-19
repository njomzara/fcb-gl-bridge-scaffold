# Human Decision Intake Automation

This guide describes `manage-code-dts-gap-decisions.ps1`, the companion tool
for supplying approved human decisions to the code-vs-DTS gap loop.

The decision tool does not make governance choices. It generates a controlled
decision form, validates the completed form, records the approved decision,
reopens the selected gaps, reconciles the register counts, and creates matching
Git history in both repositories.

## Repositories and source of truth

The tool coordinates:

- Implementation repository: `C:\Users\Minja\source\repos\fcbp-gl-bridge`
- DTS repository: `C:\Users\Minja\Documents\FCBP GL Connector`

The live register in the DTS repository remains the operational source of gap
status:

```text
docs/code-dts-gap-register.md
```

Decision batches are persisted in both repositories after approval:

```text
docs/code-dts-gap-decisions/applied/<decision-set-id>.json
docs/code-dts-gap-decisions/applied/<decision-set-id>.md
```

The JSON file is the machine-readable authority. The Markdown file is the
human-readable audit record. The completed JSON structure is documented by
`tools/gap-human-decision-batch.schema.json`.

## Prerequisites

- Run the tool from the implementation repository.
- Both repositories must be clean and on named branches before generating a
  decision batch.
- Both repositories must start on the same branch name.
- Start from the latest cumulative code-vs-DTS branch in both repositories.
- The selected gaps must have status `Needs Human Decision` and contain both
  `Decision required` and `Alternatives considered` fields.
- Use a unique decision-set ID containing only letters, numbers, `.`, `_`, or
  `-`, for example `20260719-batch01`.

## Recommended batch size

Generate decisions in batches of no more than five gaps. This aligns one human
decision batch with the next five-iteration resolution run and keeps review
focused.

## Step 1: generate a decision batch

Generate a template for one gap:

```powershell
cd C:\Users\Minja\source\repos\fcbp-gl-bridge
.\tools\manage-code-dts-gap-decisions.ps1 `
    -Generate `
    -DecisionSetId 20260719-batch01 `
    -GapId GAP-002
```

Generate one batch for several gaps:

```powershell
.\tools\manage-code-dts-gap-decisions.ps1 `
    -Generate `
    -DecisionSetId 20260719-batch01 `
    -GapId GAP-002,GAP-003,GAP-004
```

Omit `-GapId` to generate templates for every current `Needs Human Decision`
entry.

Generation performs these actions:

1. Verifies that both repositories are clean and on named branches.
2. Creates the same branch in both repositories:

   ```text
   codex/gap-decisions-<decision-set-id>
   ```

3. Reads the current register and fingerprints every selected gap.
4. Creates the authoritative pending JSON file:

   ```text
   docs/code-dts-gap-decisions/pending/<decision-set-id>.json
   ```

5. Creates a friendly Markdown preview beside the JSON file.

The DTS repository is intentionally dirty after generation. The implementation
repository remains clean on the matching decision branch. Do not start the gap
resolution loop at this point.

## Step 2: complete the JSON decision form

Open the pending JSON file in VS Code. The generated Markdown file shows the
question and alternatives in a more readable format, but the JSON file is the
one to edit.

For each decision, complete:

- `approved`: must be `true`
- `authority`: actual approving person or board
- `decision_date`: `YYYY-MM-DD`
- `decision`: the approved behavior or alternative
- `constraints`: one or more binding constraints
- `implementation_direction`: one or more actionable directions
- `migration`: migration policy, or an explicit statement that none is needed
- `acceptance_criteria`: one or more verifiable completion conditions
- `requires_fresh_discovery`: `true` only when authoritative architecture or
  mandatory DTS sources changed and the register must be rediscovered

Do not edit these generated evidence fields:

- `gap_id`
- `gap_title`
- `gap_fingerprint`
- `decision_required`
- `alternatives_considered`

The importer rejects a stale fingerprint or edited evidence field.

### GAP-002 example when no productive data exists

```json
{
  "gap_id": "GAP-002",
  "gap_title": "Identity and evidence hashes are collision-prone and mutually incompatible",
  "gap_fingerprint": "<generated value — do not edit>",
  "decision_required": "<generated value — do not edit>",
  "alternatives_considered": "<generated value — do not edit>",
  "approved": true,
  "authority": "Minja",
  "decision_date": "2026-07-19",
  "decision": "Replace all placeholder hashes with one shared, versioned SHA-256 contract before production use.",
  "constraints": [
    "No productive data exists.",
    "Development and test data may be discarded and regenerated."
  ],
  "implementation_direction": [
    "Use deterministic UTF-8 canonical serialization.",
    "Represent SHA-256 as 64 lowercase hexadecimal characters.",
    "Identify the first production contract as SHA256_V1.",
    "Replace every local prefix, truncation, and length-marker hash helper with the shared contract."
  ],
  "migration": "No migration, compatibility reads, dual writes, backfill, or legacy aliases are required.",
  "acceptance_criteria": [
    "All affected layers use the shared hashing service.",
    "Canonical serialization edge cases have automated tests.",
    "No placeholder hash implementation remains."
  ],
  "requires_fresh_discovery": false
}
```

## Step 3: validate without changing anything

```powershell
.\tools\manage-code-dts-gap-decisions.ps1 `
    -Apply `
    -DecisionSetId 20260719-batch01 `
    -ValidateOnly
```

Validation checks:

- Required fields and values
- Explicit human approval
- ISO decision date
- Non-empty constraints, implementation directions, and acceptance criteria
- Unique gap IDs
- Current `Needs Human Decision` status
- Unchanged gap fingerprint, title, question, and alternatives
- Absence of unrelated working-tree changes

Validation-only mode does not edit, stage, commit, or push anything.

## Step 4: apply and commit

```powershell
.\tools\manage-code-dts-gap-decisions.ps1 `
    -Apply `
    -DecisionSetId 20260719-batch01
```

Application performs these actions:

1. Repeats all validation.
2. Confirms that both repositories are on the matching decision branch.
3. Adds the approved decision under each gap.
4. Changes each selected status from `Needs Human Decision` to `Open`.
5. Recalculates unresolved, risk, status, and exact-area counts.
6. Reconciles the synthesis totals with the parsed entries.
7. Creates identical immutable JSON and Markdown decision records in both
   repositories.
8. Removes the pending template and preview from the DTS repository.
9. Commits both repositories with the same message:

   ```text
   Record human gap decisions (<decision-set-id>)
   ```

Both repositories are clean after a successful apply.

## Optional push

Add `-Push` to publish the decision branch from both repositories after both
local commits succeed:

```powershell
.\tools\manage-code-dts-gap-decisions.ps1 `
    -Apply `
    -DecisionSetId 20260719-batch01 `
    -Push
```

Pushing is deliberately opt-in because network access, authentication, and
remote branch policy are external concerns.

## Step 5: run gap resolution

When `requires_fresh_discovery` is `false`, run the existing register:

```powershell
.\tools\run-code-dts-gap-loop.ps1 `
    -ContinueExistingRegister `
    -ContinueOnNeedsHuman `
    -MaxIterations 5 `
    -MaxDiscoveryCycles 1
```

When any applied decision has `requires_fresh_discovery: true`, update the
authoritative baseline or DTS sources first and run without
`-ContinueExistingRegister`.

## Git model

The resulting history is:

```text
latest cumulative gap branch
└── codex/gap-decisions-<decision-set-id>
    └── codex/dts-gap-<new-run-id>/001
        └── codex/dts-gap-<new-run-id>/002
```

The two repositories use the same branch and commit-message names, but their
commit hashes differ because they contain different repository trees.

## Safety and recovery

- Generation refuses dirty repositories, mismatched starting branches,
  existing decision branches, and reused applied decision-set IDs.
- Apply permits only the two expected pending batch files in the DTS working
  tree; unrelated changes stop the operation.
- A gap changed after generation cannot receive a stale decision.
- An unapproved or incomplete batch cannot be applied.
- Git commits across two repositories are not atomic. If the first commit
  succeeds and the second fails, reconcile the repositories manually before
  retrying.
- Git pushes across two repositories are also not atomic.
- Applied decision records are immutable audit artifacts. Amend a decision by
  creating a new decision set rather than overwriting an applied record.
