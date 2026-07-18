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
- The automation script and all five JSON schemas should be committed before
  starting a run.

The clean-worktree requirement prevents unrelated changes from being absorbed
into automated commits.

## Running the automation

Start with fresh discovery cycles, process at most five gaps per cycle, and
allow at most three discovery cycles:

```powershell
cd C:\Users\Minja\source\repos\fcbp-gl-bridge
.\tools\run-code-dts-gap-loop.ps1 `
    -MaxIterations 5 `
    -MaxDiscoveryCycles 3
```

Use the existing live register for the first cycle, then allow fresh
rediscovery cycles until convergence or the cycle limit:

```powershell
.\tools\run-code-dts-gap-loop.ps1 `
    -ContinueExistingRegister `
    -MaxIterations 5 `
    -MaxDiscoveryCycles 3
```

`-MaxGaps` remains a backward-compatible alias for `-MaxIterations`.
`-MaxDiscoveryCycles` includes the initial cycle and defaults to `10`.

## Complete workflow

### 1. Startup and preflight

The script establishes both repository paths and creates a unique UTC run ID,
for example:

```text
20260718T220000123Z
```

It checks that all five structured-result schemas exist and that both repositories
are clean and on named branches. If either repository has staged, modified,
deleted, or untracked files, the script stops before creating a branch.

The staged workflow is intentionally fixed at 14 layer specifications and 17
discovery invocations. If the number of `DTS/*.md` files changes, preflight stops
so the source set and staged workflow can be reviewed deliberately.

### 2. First iteration branch

Before each discovery cycle, the script creates a matching branch in both
repositories:

```text
codex/dts-gap-20260718T220000123Z/001
```

The first branches start from the branches that were checked out when the script
was launched. Later discovery and resolution branches inherit from the latest
successful iteration. The script refuses to reuse or overwrite a branch.

### 3. Seventeen-stage discovery

Codex performs exactly 17 persisted discovery invocations at the start of every
fresh discovery cycle. When `-ContinueExistingRegister` is supplied, only the
first cycle skips discovery and starts from the existing register; later cycles
use all 17 stages.

#### Stage 1: architecture-baseline extraction

Codex reads the complete mandatory baseline:

```text
FCBP_GL_Bridge_Transfer_Proposed_Solution_Architecture_v0.1_First_Draft.docx
```

Despite `First_Draft` in its filename, it is treated as the mandatory baseline.
Codex must use DOCX extraction tools and persist a traceable Markdown evidence
artifact covering architecture, responsibilities, interfaces, persistence,
statuses, orchestration, validation, security, monitoring, recovery, operations,
constraints, and internal ambiguities.

#### Stages 2-15: one focused pass per DTS layer

The controller invokes Codex once for each of the 14 Markdown specifications in
`DTS/`. Each invocation reads:

- The persisted architecture-baseline artifact
- One complete DTS layer specification
- The corresponding implementation under `src/`, `app/`, tests, ABAP metadata,
  persistence definitions, interfaces, and local documentation

Each layer pass evaluates baseline-to-DTS, baseline-to-code, DTS-to-code, and the
layer's inbound/outbound contracts. It persists a layer Markdown report with
evidence and candidate gaps but does not modify the live register or resolve
anything.

#### Stage 16: cross-layer analysis

Codex reads all 14 layer reports and checks affected implementation interfaces.
It analyzes ownership, contracts, persistence, identifiers, data shapes, status
transitions, transaction boundaries, orchestration, idempotency, retry/recovery,
monitoring, validation order, authorization, and audit continuity. Candidate
cross-layer gaps are persisted in a separate Markdown report.

#### Stage 17: register synthesis

Codex reads the baseline artifact, all 14 layer reports, and the cross-layer
report. It challenges candidate findings against their evidence, removes false
positives, merges duplicates, preserves materially distinct issues, assigns
stable `GAP-###` identifiers, creates or replaces the live register, and writes
a synthesis audit artifact.

The 17-stage evidence is persisted under:

```text
docs/code-dts-discovery/<run-id>/cycle-<number>/
```

The live register is:

```text
C:\Users\Minja\Documents\FCBP GL Connector\docs\code-dts-gap-register.md
```

With `-ContinueExistingRegister`, first-cycle discovery is skipped. The script
stops if the live register does not exist.

The final synthesis returns a structured `gap_count`. A fresh staged discovery
reporting zero gaps is the only successful convergence condition.

Every stage has its own JSON schema and coverage checks. The controller verifies
that each required Markdown artifact exists, each layer stage names the expected
DTS file, every stage confirms its required evidence, all layer reports reach
the cross-layer stage, and synthesis confirms every source and comparison lane.
It stops before resolution on any omission. Secondary drafts and generated
artifacts may be supporting evidence but cannot replace the mandatory source set.

Codex is instructed not to create branches, stage files, or make commits. The
controller script owns all Git operations.

### 4. Immutable run snapshot

Before resolving any gap in each cycle, the script copies that cycle's starting
register into:

```text
C:\Users\Minja\Documents\FCBP GL Connector\docs\code-dts-gap-history
```

For example:

```text
code-dts-gap-register-20260718T220000123Z-cycle001.md
```

Each snapshot is immutable and preserves the gap set at the beginning of its
cycle. The live register continues to change as gaps are resolved. A snapshot
is created for every fresh discovery cycle and for a continuation first cycle.

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

Every resolution iteration returns JSON conforming to
`gap-step-result.schema.json`. The four discovery stage types use baseline,
layer, cross-layer, and final-synthesis schemas. The resolution result contains:

- Whether all gaps are finished
- The processed gap ID
- The outcome
- A summary
- A concise gap description
- The reasoning and evidence supporting the decision
- A list of introduced fixes, updates, tests, and new artifacts
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

### 9. Per-commit Markdown reports

Before every successful commit, the controller creates a Markdown report in
both repositories:

```text
docs/code-dts-gap-iterations/<run-id>/iteration-<number>-<gap-id>.md
```

For example:

```text
docs/code-dts-gap-iterations/20260718T220000123Z/iteration-003-GAP-002.md
```

The report is included in the same commit as the corresponding code or DTS
changes. Each report records:

- Run ID, discovery cycle, iteration branch, outcome, and validation status
- The gap that was evaluated
- The reasoning and evidence behind the selected decision
- Every introduced fix, DTS update, test, or new artifact

The same report is written to both repositories, which gives each synchronized
commit a local explanation even when that iteration changed only code or only
DTS content. A zero-gap convergence commit also receives a report explaining
the discovery result and the register/history artifacts it introduced.

### 10. Coordinated commits

After successful validation, the script stages and commits all changes in both
repositories with matching commit messages, for example:

```text
Resolve DTS gap iteration 001 (GAP-001)
```

If one repository has no code or DTS changes, its companion report still gives
the synchronized commit meaningful content. This keeps the iteration histories
aligned and explains why that repository required no domain change.

Git cannot make a commit across two repositories atomically. If the first
repository commits successfully and the second commit fails, the script stops
and reports the repository requiring manual reconciliation.

### 11. Child branch for the next iteration

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

### 12. Iteration and discovery-cycle limits

`-MaxIterations` limits the number of gap-resolution attempts in each discovery
cycle. `-MaxDiscoveryCycles` limits how many times the discover-and-resolve loop
may run:

```powershell
.\tools\run-code-dts-gap-loop.ps1 `
    -MaxIterations 5 `
    -MaxDiscoveryCycles 3
```

In this example, the script can make at most five resolution attempts per cycle
and can perform at most three cycles. After reaching the per-cycle iteration
limit, it creates the next child branch and performs a fresh discovery rather
than continuing from a potentially stale list.

Reaching the discovery-cycle limit is a controlled stop, but it does not prove
convergence. The latest cumulative branch is printed for review or continuation.

### 13. Completion

Exhausting the current live register triggers another fresh discovery cycle; it
does not by itself finish the run. The run completes as converged only when a
fresh discovery returns `gap_count: 0`. The zero-gap register and its history
snapshot are committed in both repositories before the script exits.

The script never merges into the starting branch or `main` automatically.

## Stop and commit behavior

| Situation | Commit current iteration | Create next branch | Result |
|---|---:|---:|---|
| Gap resolved and validation passes | Yes | Yes, if required | Continue |
| Per-cycle iteration limit reached | Yes | Yes | Start fresh discovery cycle |
| Current register has no unresolved gaps | Yes | Yes | Verify with fresh discovery |
| Fresh discovery finds zero gaps | Yes | No | Successful convergence |
| Discovery-cycle limit reached | Yes | No | Controlled, not proven converged |
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
