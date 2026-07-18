# Code-vs-DTS Gap Automation

This guide describes the workflow implemented by
`run-code-dts-gap-loop.ps1`.

## Repositories

The automation coordinates two Git repositories:

- Implementation repository: `C:\Users\Minja\source\repos\fcbp-gl-bridge`
- DTS documentation repository: `C:\Users\Minja\Documents\FCBP GL Connector`

Run the script from the implementation repository. Codex uses that repository
as its primary workspace and receives the DTS repository through `--add-dir`.

## Prerequisites

- `codex` and `git` must be available in the shell.
- Codex CLI authentication must already be configured.
- Both repositories must be on named branches, not detached `HEAD`.
- Both repositories must have completely clean working trees, including no
  untracked files.
- The automation script and its JSON schema should be committed before starting
  a run.

The clean-worktree requirement prevents unrelated changes from being absorbed
into automated commits.

## Running the automation

Start with a new discovery pass and process at most five gaps:

```powershell
cd C:\Users\Minja\source\repos\fcbp-gl-bridge
.\tools\run-code-dts-gap-loop.ps1 -MaxIterations 5
```

Continue from an existing live register and process at most five gaps:

```powershell
.\tools\run-code-dts-gap-loop.ps1 `
    -ContinueExistingRegister `
    -MaxIterations 5
```

`-MaxGaps` remains a backward-compatible alias for `-MaxIterations`.

## Complete workflow

### 1. Startup and preflight

The script establishes both repository paths and creates a unique UTC run ID,
for example:

```text
20260718T220000123Z
```

It checks that the structured-result schema exists and that both repositories
are clean and on named branches. If either repository has staged, modified,
deleted, or untracked files, the script stops before creating a branch.

### 2. First iteration branch

Before discovery or resolution, the script creates a matching branch in both
repositories:

```text
codex/dts-gap-20260718T220000123Z/001
```

Both branches start from the branches that were checked out when the script was
launched. The script refuses to reuse or overwrite an existing branch.

### 3. Gap discovery

Unless `-ContinueExistingRegister` is supplied, Codex performs a complete
code-vs-DTS comparison. It:

1. Reads applicable repository guidance.
2. Identifies authoritative DTS documents and distinguishes them from drafts,
   superseded versions, generated renderings, and supporting material.
3. Inspects implementation code and relevant tests.
4. Compares documented and implemented behavior, interfaces, validations,
   workflows, data mappings, error handling, security, recovery, and
   operational requirements.
5. Creates or replaces the live gap register.
6. Assigns stable identifiers such as `GAP-001`.
7. Records code evidence, DTS evidence, affected area, risk, and status.
8. Marks newly discovered gaps `Open` without resolving them.

The live register is:

```text
C:\Users\Minja\Documents\FCBP GL Connector\docs\code-dts-gap-register.md
```

With `-ContinueExistingRegister`, discovery is skipped. The script stops if the
live register does not exist.

Codex is instructed not to create branches, stage files, or make commits. The
controller script owns all Git operations.

### 4. Immutable run snapshot

Before resolving any gap, the script copies the starting register into:

```text
C:\Users\Minja\Documents\FCBP GL Connector\docs\code-dts-gap-history
```

For example:

```text
code-dts-gap-register-20260718T220000123Z.md
```

This snapshot is immutable and preserves the gap set at the beginning of the
run. The live register continues to change as gaps are resolved. A snapshot is
created for both fresh discovery and continuation runs.

### 5. One gap per iteration

Each Codex invocation handles exactly one unresolved register entry. `Open` and
`In Progress` entries are considered unresolved.

Codex:

1. Selects the first unresolved gap in register order.
2. Revalidates it against current code and authoritative DTS documents.
3. Marks it `In Progress` before editing.
4. Determines whether code, DTS documents, or both require correction.
5. Makes the smallest complete change.
6. Adds or updates tests where appropriate.
7. Runs relevant validation.
8. Updates the live register with the final status, decision, rationale,
   changed files, evidence, and validation results.

Codex may not work on a second gap in the same invocation.

### 6. Clear and unclear decisions

When the intended behavior is clear, Codex updates code, DTS documents, or both
according to the strongest evidence.

When the decision is initially unclear, Codex analyzes:

- Related DTS requirements
- Current implementation and tests
- Public interfaces and compatibility expectations
- Related mappings and workflows
- Local Git history when useful
- Security and data-integrity implications
- Operational consequences

It records considered alternatives and its rationale in the live register
before implementing the best-supported solution.

Codex must not invent business requirements merely to eliminate ambiguity. If
the remaining uncertainty could cause significant business, financial,
security, compliance, compatibility, or destructive consequences, it makes no
speculative change and marks the item `Needs Human Decision`.

### 7. Structured result

Every iteration returns JSON conforming to `gap-step-result.schema.json`. The
result contains:

- Whether all gaps are finished
- The processed gap ID
- The outcome
- A summary
- Whether validation passed

Possible outcomes are:

```text
code_updated
dts_updated
both_updated
not_a_gap
needs_human
no_gaps_remaining
```

The controller uses these fields instead of interpreting prose.

### 8. Validation gate

The current iteration is committed only when validation succeeds.

If validation fails, the script does not commit or create the next branch. It
stops with the current branch and working changes intact for inspection.

If a human decision is required, the script also stops without committing the
iteration.

### 9. Coordinated commits

After successful validation, the script stages and commits all changes in both
repositories with matching commit messages, for example:

```text
Resolve DTS gap iteration 001 (GAP-001)
```

If one repository has no changes, it receives an empty synchronization commit.
This keeps the iteration histories aligned.

Git cannot make a commit across two repositories atomically. If the first
repository commits successfully and the second commit fails, the script stops
and reports the repository requiring manual reconciliation.

### 10. Child branch for the next iteration

After committing an iteration, the next iteration creates new branches from the
currently checked-out iteration branches:

```text
starting branch
└── codex/dts-gap-<run-id>/001
    └── codex/dts-gap-<run-id>/002
        └── codex/dts-gap-<run-id>/003
```

The latest branch therefore contains the cumulative result of every preceding
iteration.

### 11. Iteration limit

`-MaxIterations` limits the number of gaps processed during the run:

```powershell
.\tools\run-code-dts-gap-loop.ps1 -MaxIterations 5
```

After five successfully processed iterations, the script stops normally and
prints the latest cumulative branch. Reaching the limit is not treated as an
error.

### 12. Completion

When no unresolved gaps remain, the script commits the final iteration, reports
completion, and exits successfully. It does not merge into the starting branch
or `main` automatically.

## Stop and commit behavior

| Situation | Commit current iteration | Create next branch | Result |
|---|---:|---:|---|
| Gap resolved and validation passes | Yes | Yes, if required | Continue |
| Iteration limit reached | Yes | No | Successful controlled stop |
| No unresolved gaps remain | Yes | No | Successful completion |
| Human decision required | No | No | Stop for review |
| Validation fails | No | No | Stop with error |
| Codex command fails | No | No | Stop with error |
| Repository dirty at startup | No | No | Stop during preflight |
| Iteration branch already exists | No | No | Stop without overwriting |

## Reviewing and integrating a completed run

Review both repositories and the latest cumulative branch before integration.
To retain every per-gap commit, fast-forward or merge the final branch into the
desired target branch:

```powershell
git switch main
git merge --ff-only codex/dts-gap-<run-id>/<last-iteration>
```

To collapse all iterations into one commit:

```powershell
git switch main
git merge --squash codex/dts-gap-<run-id>/<last-iteration>
git commit -m "Resolve code-vs-DTS gaps"
```

Perform the chosen integration separately in both repositories. Integration is
deliberately outside the automated run so that the final review remains an
explicit human decision.

## Recovery notes

- A validation or human-decision stop intentionally leaves the current branch
  and changes uncommitted.
- Do not start another automated run until both repositories are clean again.
- If commits become unsynchronized across repositories, inspect both logs and
  reconcile them manually before continuing.
- The immutable history snapshot can be used to reconstruct the exact gap set
  that initiated a run.
