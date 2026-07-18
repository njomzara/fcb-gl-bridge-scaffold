[CmdletBinding()]
param(
    [ValidateRange(1, 1000)]
    [Alias("MaxGaps")]
    [int]$MaxIterations = 50,

    [switch]$ContinueExistingRegister
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DtsRoot = "C:\Users\Minja\Documents\FCBP GL Connector"
$Register = Join-Path $DtsRoot "docs\code-dts-gap-register.md"
$GapHistoryDirectory = Join-Path $DtsRoot "docs\code-dts-gap-history"
$Schema = Join-Path $PSScriptRoot "gap-step-result.schema.json"
$runId = [DateTime]::UtcNow.ToString("yyyyMMdd'T'HHmmssfff'Z'")
$temporaryDirectory = [System.IO.Path]::GetTempPath()
$Result = Join-Path $temporaryDirectory "fcbp-gap-step-$runId.json"
$DiscoveryLog = Join-Path $temporaryDirectory "fcbp-gap-discovery-$runId.txt"

Set-Location -LiteralPath $ProjectRoot

if (-not (Test-Path -LiteralPath $Schema -PathType Leaf)) {
    throw "Missing result schema: $Schema"
}

function Invoke-Codex {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [Parameter(Mandatory)]
        [string]$OutputFile,

        [switch]$Structured
    )

    $arguments = @(
        "exec",
        "--sandbox", "workspace-write",
        "--add-dir", $DtsRoot
    )

    if ($Structured) {
        $arguments += @("--output-schema", $Schema)
    }

    $arguments += @("--output-last-message", $OutputFile, $Prompt)

    & codex @arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Codex failed with exit code $LASTEXITCODE"
    }

    if (-not (Test-Path -LiteralPath $OutputFile -PathType Leaf)) {
        throw "Codex did not create the expected output file: $OutputFile"
    }
}

function Invoke-Git {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Repository,

        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $output = & git -C $Repository @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        $details = ($output | Out-String).Trim()
        throw "Git failed in ${Repository}: git $($Arguments -join ' ')`n$details"
    }

    return $output
}

function Assert-CleanRepository {
    param(
        [Parameter(Mandatory)]
        [string]$Repository
    )

    $status = Invoke-Git -Repository $Repository -Arguments @("status", "--porcelain")
    if ($status) {
        throw "Repository must be clean before starting automation: $Repository`n$($status -join [Environment]::NewLine)"
    }

    $branch = (Invoke-Git -Repository $Repository -Arguments @("branch", "--show-current") | Out-String).Trim()
    if (-not $branch) {
        throw "Repository is in detached HEAD state: $Repository"
    }

    return $branch
}

function Test-GitBranchExists {
    param(
        [Parameter(Mandatory)]
        [string]$Repository,

        [Parameter(Mandatory)]
        [string]$Branch
    )

    & git -C $Repository show-ref --verify --quiet "refs/heads/$Branch"
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) { return $true }
    if ($exitCode -eq 1) { return $false }
    throw "Unable to check branch $Branch in $Repository (exit code $exitCode)."
}

function New-IterationBranch {
    param(
        [Parameter(Mandatory)]
        [int]$Iteration
    )

    $branch = "codex/dts-gap-$runId/{0:D3}" -f $Iteration

    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        if (Test-GitBranchExists -Repository $repository -Branch $branch) {
            throw "Iteration branch already exists in ${repository}: $branch"
        }
    }

    # Preflight both repositories before changing either branch. Git operations
    # are still not atomic across repositories; if the second switch fails, the
    # error identifies the branch that needs manual reconciliation.
    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        Invoke-Git -Repository $repository -Arguments @("switch", "--create", $branch) | Out-Null
    }

    Write-Host "Iteration branch: $branch" -ForegroundColor DarkCyan
    return $branch
}

function Commit-Iteration {
    param(
        [Parameter(Mandatory)]
        [int]$Iteration,

        [AllowNull()]
        [string]$GapId
    )

    $commitGapId = if ($GapId) { $GapId } else { "no-gaps" }
    $message = "Resolve DTS gap iteration {0:D3} ({1})" -f $Iteration, $commitGapId

    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        Invoke-Git -Repository $repository -Arguments @("add", "--all") | Out-Null

        & git -C $repository diff --cached --quiet
        $diffExitCode = $LASTEXITCODE
        if ($diffExitCode -eq 0) {
            Invoke-Git -Repository $repository -Arguments @("commit", "--allow-empty", "--message", $message) | Out-Null
        }
        elseif ($diffExitCode -eq 1) {
            Invoke-Git -Repository $repository -Arguments @("commit", "--message", $message) | Out-Null
        }
        else {
            throw "Unable to inspect staged changes in $repository (exit code $diffExitCode)."
        }
    }

    Write-Host "Committed iteration $Iteration in both repositories." -ForegroundColor DarkCyan
}

$startingCodeBranch = Assert-CleanRepository -Repository $ProjectRoot
$startingDtsBranch = Assert-CleanRepository -Repository $DtsRoot
Write-Host "Starting code branch: $startingCodeBranch" -ForegroundColor DarkCyan
Write-Host "Starting DTS branch:  $startingDtsBranch" -ForegroundColor DarkCyan

# The first iteration branch also contains discovery and the immutable starting
# register snapshot. Later iteration branches inherit all earlier commits.
$currentIterationBranch = New-IterationBranch -Iteration 1

if (-not $ContinueExistingRegister) {
    Write-Host "`n=== Code-vs-DTS discovery pass ===" -ForegroundColor Cyan

    $discoveryPrompt = @"
Perform a comprehensive code-vs-DTS gap analysis across these workspaces:

- Implementation repository: $ProjectRoot
- DTS documentation workspace: $DtsRoot

DTS means the authoritative design and technical specification documents
applicable to the implementation.

Tasks:
1. Read all applicable repository guidance.
2. Locate and identify the authoritative DTS documents. Distinguish them from
   drafts, superseded versions, generated renderings, and supporting material.
3. Inspect the implementation and relevant tests.
4. Compare documented behavior, interfaces, validations, workflows, data
   mappings, error handling, security, recovery, and operational requirements
   against the code.
5. Create or replace $Register in the DTS documentation workspace.
6. Give every gap a stable ID such as GAP-001.
7. For each gap, record the affected area, observed mismatch, code evidence,
   DTS evidence, risk, and status.
8. Do not change production code or DTS documents during this discovery pass.
9. Do not record cosmetic wording differences unless they cause genuine
   ambiguity or behavioral inconsistency.
10. Mark every discovered item Open.
11. Include a summary with counts grouped by affected area and risk.
12. Do not create branches, stage files, or commit changes. The controller owns
    all Git operations.

Finish only after checking that the register accurately represents the current
repository state. If no gaps exist, still create the register and explicitly
record that conclusion and the evidence reviewed.
"@

    Invoke-Codex -Prompt $discoveryPrompt -OutputFile $DiscoveryLog

    if (-not (Test-Path -LiteralPath $Register -PathType Leaf)) {
        throw "Discovery completed without creating the gap register: $Register"
    }
}
elseif (-not (Test-Path -LiteralPath $Register -PathType Leaf)) {
    throw "Cannot continue because the gap register does not exist: $Register"
}

# Preserve the run's starting gap set before any resolution changes the main
# register. Millisecond UTC timestamps make snapshots sortable and unique for
# normal use; the explicit collision check prevents accidental overwrites.
if (-not (Test-Path -LiteralPath $GapHistoryDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $GapHistoryDirectory | Out-Null
}

$historyFileName = "code-dts-gap-register-$runId.md"
$historyFile = Join-Path $GapHistoryDirectory $historyFileName

if (Test-Path -LiteralPath $historyFile) {
    throw "Refusing to overwrite an existing gap-history snapshot: $historyFile"
}

Copy-Item -LiteralPath $Register -Destination $historyFile
Write-Host "Gap discovery snapshot: $historyFile" -ForegroundColor DarkCyan

for ($iteration = 1; $iteration -le $MaxIterations; $iteration++) {
    if ($iteration -gt 1) {
        $currentIterationBranch = New-IterationBranch -Iteration $iteration
    }

    Write-Host "`n=== Gap iteration $iteration of $MaxIterations ===" -ForegroundColor Cyan

    $stepPrompt = @"
Work on exactly one unresolved entry from $Register.

Use these workspace roles:
- Implementation repository: $ProjectRoot
- DTS documentation workspace: $DtsRoot

Workflow:
1. Read the repository guidance and the entire gap register.
2. Select the first unresolved gap in register order. Treat Open and In Progress
   as unresolved.
3. Revalidate that gap against the current code and authoritative DTS documents.
4. Mark it In Progress before editing.

Decision process:
- If the intended behavior is clear, update code, DTS documents, or both,
  according to the strongest available evidence.
- If the intended behavior is initially unclear, analyze surrounding DTS
  requirements, implementation and tests, public interfaces, compatibility
  expectations, related mappings and workflows, local repository history when
  available, and security, data-integrity, and operational consequences.
- Record the considered alternatives and rationale in the gap register.
- Choose the best-supported solution and implement it.
- Do not invent business requirements merely to eliminate ambiguity.
- If evidence remains genuinely insufficient and a choice would create
  significant business, financial, security, compliance, compatibility, or
  destructive consequences, make no speculative change. Mark the item Needs
  Human Decision and document the exact decision and evidence required.

After the decision:
1. Make the smallest complete change.
2. Add or update tests where appropriate.
3. Run the relevant verification.
4. Update the register with the final status, decision, changed files,
   supporting evidence, and validation commands and results.
5. Do not work on another gap in this invocation.
6. Do not create branches, stage files, or commit changes. The controller owns
   all Git operations.

If no unresolved gaps remain, make no changes and return done=true with outcome
no_gaps_remaining. Otherwise return done=false. Return outcome needs_human when
the selected item requires a human decision. Set validation_passed=false if a
required verification fails or cannot be completed.
"@

    Invoke-Codex -Prompt $stepPrompt -OutputFile $Result -Structured

    try {
        $step = Get-Content -Raw -LiteralPath $Result | ConvertFrom-Json
    }
    catch {
        throw "Codex returned invalid structured output in ${Result}: $($_.Exception.Message)"
    }

    Write-Host "Gap:        $($step.gap_id)"
    Write-Host "Outcome:    $($step.outcome)"
    Write-Host "Validation: $($step.validation_passed)"
    Write-Host "Summary:    $($step.summary)"

    if ($step.outcome -eq "needs_human") {
        Write-Warning "Automation stopped for a material human decision. See $Register."
        exit 2
    }

    if (-not $step.validation_passed) {
        throw "Validation failed while processing $($step.gap_id). See $Register."
    }

    Commit-Iteration -Iteration $iteration -GapId $step.gap_id

    if ($step.done) {
        Write-Host "`nAll gaps have been processed." -ForegroundColor Green
        exit 0
    }
}

Write-Host "`nStopped after the requested $MaxIterations iterations." -ForegroundColor Yellow
Write-Host "Latest cumulative branch: $currentIterationBranch" -ForegroundColor Yellow
exit 0
