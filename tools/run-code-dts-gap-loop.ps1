[CmdletBinding()]
param(
    [ValidateRange(1, 1000)]
    [Alias("MaxGaps")]
    [int]$MaxIterations = 50,

    [ValidateRange(1, 1000)]
    [int]$MaxDiscoveryCycles = 10,

    [switch]$ContinueExistingRegister
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DtsRoot = "C:\Users\Minja\Documents\FCBP GL Connector"
$MandatoryBaseline = Join-Path $DtsRoot "FCBP_GL_Bridge_Transfer_Proposed_Solution_Architecture_v0.1_First_Draft.docx"
$MandatoryDtsDirectory = Join-Path $DtsRoot "DTS"
$Register = Join-Path $DtsRoot "docs\code-dts-gap-register.md"
$GapHistoryDirectory = Join-Path $DtsRoot "docs\code-dts-gap-history"
$DiscoveryArtifactRoot = Join-Path $DtsRoot "docs\code-dts-discovery"
$StepSchema = Join-Path $PSScriptRoot "gap-step-result.schema.json"
$DiscoverySchema = Join-Path $PSScriptRoot "gap-discovery-result.schema.json"
$BaselineStageSchema = Join-Path $PSScriptRoot "gap-baseline-stage-result.schema.json"
$LayerStageSchema = Join-Path $PSScriptRoot "gap-layer-stage-result.schema.json"
$CrossLayerStageSchema = Join-Path $PSScriptRoot "gap-cross-layer-stage-result.schema.json"
$runId = [DateTime]::UtcNow.ToString("yyyyMMdd'T'HHmmssfff'Z'")
$temporaryDirectory = [System.IO.Path]::GetTempPath()
$Result = Join-Path $temporaryDirectory "fcbp-gap-step-$runId.json"
$DiscoveryResult = Join-Path $temporaryDirectory "fcbp-gap-discovery-$runId.json"

Set-Location -LiteralPath $ProjectRoot

foreach ($schemaPath in @(
    $StepSchema,
    $DiscoverySchema,
    $BaselineStageSchema,
    $LayerStageSchema,
    $CrossLayerStageSchema
)) {
    if (-not (Test-Path -LiteralPath $schemaPath -PathType Leaf)) {
        throw "Missing result schema: $schemaPath"
    }
}

if (-not (Test-Path -LiteralPath $MandatoryBaseline -PathType Leaf)) {
    throw "Mandatory architecture baseline is missing: $MandatoryBaseline"
}

if (-not (Test-Path -LiteralPath $MandatoryDtsDirectory -PathType Container)) {
    throw "Mandatory DTS directory is missing: $MandatoryDtsDirectory"
}

$MandatoryDtsFiles = @(Get-ChildItem -LiteralPath $MandatoryDtsDirectory -File -Filter "*.md" | Sort-Object Name)
if ($MandatoryDtsFiles.Count -eq 0) {
    throw "No mandatory Markdown layer specifications were found in: $MandatoryDtsDirectory"
}

$ExpectedDtsLayerCount = 14
if ($MandatoryDtsFiles.Count -ne $ExpectedDtsLayerCount) {
    throw "The staged discovery is defined as 17 steps (1 baseline + 14 layers + 1 cross-layer + 1 synthesis), but found $($MandatoryDtsFiles.Count) DTS Markdown files. Review the source set and update the workflow deliberately."
}

$DiscoveryStageCount = $MandatoryDtsFiles.Count + 3

function Invoke-Codex {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [Parameter(Mandatory)]
        [string]$OutputFile,

        [string]$OutputSchema
    )

    $arguments = @(
        "exec",
        "--sandbox", "workspace-write",
        "--add-dir", $DtsRoot
    )

    if ($OutputSchema) {
        $arguments += @("--output-schema", $OutputSchema)
    }

    if (Test-Path -LiteralPath $OutputFile -PathType Leaf) {
        Remove-Item -LiteralPath $OutputFile -Force
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

function Write-IterationReport {
    param(
        [Parameter(Mandatory)]
        [int]$Iteration,

        [Parameter(Mandatory)]
        [int]$DiscoveryCycle,

        [Parameter(Mandatory)]
        [string]$Branch,

        [Parameter(Mandatory)]
        [string]$GapId,

        [Parameter(Mandatory)]
        [string]$Outcome,

        [Parameter(Mandatory)]
        [string]$GapDescription,

        [Parameter(Mandatory)]
        [string]$Reasoning,

        [Parameter(Mandatory)]
        [string[]]$IntroducedChanges,

        [Parameter(Mandatory)]
        [bool]$ValidationPassed
    )

    $safeGapId = ($GapId -replace "[^A-Za-z0-9._-]", "-").Trim("-")
    if (-not $safeGapId) { $safeGapId = "no-gap" }
    $reportName = "iteration-{0:D3}-{1}.md" -f $Iteration, $safeGapId
    $changeLines = if ($IntroducedChanges.Count -gt 0) {
        ($IntroducedChanges | ForEach-Object { "- $_" }) -join [Environment]::NewLine
    }
    else {
        "- No code or DTS artifact change was required."
    }

    $report = @"
# Code-vs-DTS iteration ${Iteration}: $GapId

- Run ID: $runId
- Discovery cycle: $DiscoveryCycle
- Iteration branch: $Branch
- Outcome: $Outcome
- Validation passed: $ValidationPassed

## Gap

$GapDescription

## Reasoning

$Reasoning

## Introduced fix, update, or new artifact

$changeLines
"@

    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        $reportDirectory = Join-Path $repository "docs\code-dts-gap-iterations\$runId"
        if (-not (Test-Path -LiteralPath $reportDirectory -PathType Container)) {
            New-Item -ItemType Directory -Path $reportDirectory | Out-Null
        }

        $reportPath = Join-Path $reportDirectory $reportName
        if (Test-Path -LiteralPath $reportPath) {
            throw "Refusing to overwrite an existing iteration report: $reportPath"
        }

        Set-Content -LiteralPath $reportPath -Value $report -Encoding utf8
    }

    Write-Host "Iteration report: docs/code-dts-gap-iterations/$runId/$reportName" -ForegroundColor DarkCyan
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

function Read-StructuredResult {
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$StageName
    )

    try {
        return Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
    }
    catch {
        throw "Codex returned invalid structured output for $StageName in ${Path}: $($_.Exception.Message)"
    }
}

function Invoke-StagedDiscovery {
    param(
        [Parameter(Mandatory)]
        [int]$DiscoveryCycle
    )

    $cycleDirectory = Join-Path $DiscoveryArtifactRoot ("$runId\cycle-{0:D3}" -f $DiscoveryCycle)
    $layerDirectory = Join-Path $cycleDirectory "layers"
    if (Test-Path -LiteralPath $cycleDirectory) {
        throw "Refusing to overwrite an existing discovery artifact directory: $cycleDirectory"
    }
    New-Item -ItemType Directory -Path $layerDirectory -Force | Out-Null

    # Stage 1/17: extract the mandatory architecture baseline once into a
    # durable Markdown evidence artifact used by every later stage.
    $baselineArtifact = Join-Path $cycleDirectory "01-architecture-baseline.md"
    $baselineResultPath = Join-Path $temporaryDirectory "fcbp-gap-baseline-$runId-cycle$DiscoveryCycle.json"
    Write-Host "[Discovery 1/$DiscoveryStageCount] Architecture baseline extraction" -ForegroundColor Cyan
    $baselinePrompt = @"
Discovery stage 1 of ${DiscoveryStageCount}: extract and analyze the mandatory
architecture baseline.

Mandatory baseline: $MandatoryBaseline
Output artifact: $baselineArtifact

Read the complete document contents using appropriate DOCX extraction tools.
The filename contains First_Draft, but this document is the mandatory baseline
and must not be excluded, downgraded, or replaced. Create the Markdown artifact
with traceable headings covering components, layers, responsibilities,
interfaces, data flows, persistence, status transitions, orchestration,
validation, security, monitoring, error/recovery behavior, operational
requirements, explicit constraints, and internal ambiguities. Cite source
sections, headings, tables, or other locators wherever possible.

Do not modify the baseline, DTS specifications, implementation, gap register,
branches, staging area, or commits. Return baseline_reviewed=true only after the
complete baseline has been analyzed, and return the output artifact path.
"@
    Invoke-Codex -Prompt $baselinePrompt -OutputFile $baselineResultPath -OutputSchema $BaselineStageSchema
    $baselineResult = Read-StructuredResult -Path $baselineResultPath -StageName "baseline extraction"
    if (-not [bool]$baselineResult.baseline_reviewed) {
        throw "Baseline discovery stage did not confirm complete review."
    }
    if (-not (Test-Path -LiteralPath $baselineArtifact -PathType Leaf)) {
        throw "Baseline discovery stage did not create its artifact: $baselineArtifact"
    }

    # Stages 2-15/17: analyze exactly one mandatory layer per invocation.
    $layerArtifacts = @()
    $reviewedDtsNames = @()
    for ($layerIndex = 0; $layerIndex -lt $MandatoryDtsFiles.Count; $layerIndex++) {
        $stageNumber = $layerIndex + 2
        $dtsFile = $MandatoryDtsFiles[$layerIndex]
        $layerArtifact = Join-Path $layerDirectory $dtsFile.Name
        $layerResultPath = Join-Path $temporaryDirectory ("fcbp-gap-layer-$runId-cycle{0:D3}-{1:D2}.json" -f $DiscoveryCycle, ($layerIndex + 1))
        Write-Host "[Discovery $stageNumber/$DiscoveryStageCount] $($dtsFile.Name)" -ForegroundColor Cyan

        $layerPrompt = @"
Discovery stage $stageNumber of ${DiscoveryStageCount}: perform one focused
layer comparison.

Architecture evidence: $baselineArtifact
Detailed layer specification: $($dtsFile.FullName)
Implementation repository: $ProjectRoot
Output artifact: $layerArtifact

Read the complete layer specification and the architecture evidence artifact.
Identify and inspect all corresponding implementation under src/, app/,
relevant tests, ABAP metadata, persistence definitions, interfaces, and local
documentation. Compare:
1. Architecture baseline to this detailed specification.
2. Architecture baseline to this layer's implementation.
3. This detailed specification to its implementation.
4. This layer's inbound and outbound contracts that affect other layers.

Create the requested Markdown artifact with source evidence, implemented and
missing requirements, contradictions, extra undocumented behavior, ambiguous
decisions, validation evidence, and candidate gaps. Give candidate gaps stable
local identifiers but do not edit the live gap register or resolve anything.

Do not modify the baseline, DTS specifications, production code, gap register,
branches, staging area, or commits. Return dts_reviewed, baseline_used, and
implementation_reviewed as true only after those checks are complete. Return
the exact DTS filename, artifact path, candidate gap count, and summary.
"@
        Invoke-Codex -Prompt $layerPrompt -OutputFile $layerResultPath -OutputSchema $LayerStageSchema
        $layerResult = Read-StructuredResult -Path $layerResultPath -StageName "layer analysis $($dtsFile.Name)"
        $reportedDtsName = [System.IO.Path]::GetFileName([string]$layerResult.dts_file)
        if ($reportedDtsName -ne $dtsFile.Name) {
            throw "Layer discovery reported '$reportedDtsName' but expected '$($dtsFile.Name)'."
        }
        if (-not [bool]$layerResult.dts_reviewed -or
            -not [bool]$layerResult.baseline_used -or
            -not [bool]$layerResult.implementation_reviewed) {
            throw "Layer discovery coverage failed for $($dtsFile.Name)."
        }
        if (-not (Test-Path -LiteralPath $layerArtifact -PathType Leaf)) {
            throw "Layer discovery did not create its artifact: $layerArtifact"
        }
        $layerArtifacts += $layerArtifact
        $reviewedDtsNames += $reportedDtsName
    }

    # Stage 16/17: compare layer reports with each other and with implementation
    # interfaces to find gaps that isolated layer passes cannot see.
    $layerArtifactList = ($layerArtifacts | ForEach-Object { "- $_" }) -join [Environment]::NewLine
    $crossLayerArtifact = Join-Path $cycleDirectory "16-cross-layer-analysis.md"
    $crossLayerResultPath = Join-Path $temporaryDirectory "fcbp-gap-cross-layer-$runId-cycle$DiscoveryCycle.json"
    Write-Host "[Discovery 16/$DiscoveryStageCount] Cross-layer analysis" -ForegroundColor Cyan
    $crossLayerPrompt = @"
Discovery stage 16 of ${DiscoveryStageCount}: perform cross-layer analysis.

Architecture evidence: $baselineArtifact
Mandatory layer reports:
$layerArtifactList
Implementation repository: $ProjectRoot
Output artifact: $crossLayerArtifact

Read every layer report. Inspect corresponding implementation interfaces where
needed. Analyze cross-layer consistency for ownership boundaries, inbound and
outbound contracts, persistence models, identifiers, data shapes, status
transitions, transaction boundaries, orchestration order, retries, idempotency,
recovery, monitoring, validation order, authorization, and audit controls.
Create the requested Markdown artifact with traceable evidence and candidate
cross-layer gaps. Do not modify source specifications, production code, the live
gap register, branches, staging area, or commits.

Return all_layer_reports_reviewed=true only after reading every report and
implementation_interfaces_reviewed=true only after checking the affected code.
"@
    Invoke-Codex -Prompt $crossLayerPrompt -OutputFile $crossLayerResultPath -OutputSchema $CrossLayerStageSchema
    $crossLayerResult = Read-StructuredResult -Path $crossLayerResultPath -StageName "cross-layer analysis"
    if (-not [bool]$crossLayerResult.all_layer_reports_reviewed -or
        -not [bool]$crossLayerResult.implementation_interfaces_reviewed) {
        throw "Cross-layer discovery coverage was not confirmed."
    }
    if (-not (Test-Path -LiteralPath $crossLayerArtifact -PathType Leaf)) {
        throw "Cross-layer discovery did not create its artifact: $crossLayerArtifact"
    }

    # Stage 17/17: synthesize, challenge, deduplicate, and assign final gap IDs.
    $synthesisArtifact = Join-Path $cycleDirectory "17-register-synthesis.md"
    Write-Host "[Discovery 17/$DiscoveryStageCount] Gap-register synthesis" -ForegroundColor Cyan
    $synthesisPrompt = @"
Discovery stage 17 of ${DiscoveryStageCount}: synthesize the final gap register.

Architecture evidence: $baselineArtifact
Layer reports:
$layerArtifactList
Cross-layer report: $crossLayerArtifact
Implementation repository: $ProjectRoot
Live gap register to create or replace: $Register
Synthesis audit artifact: $synthesisArtifact

Read every discovery artifact. Challenge candidate findings against their cited
source and implementation evidence, merge duplicates, reject cosmetic or false
positive differences, preserve materially distinct gaps, and assign stable IDs
such as GAP-001. The register must record affected area, mismatch, architecture
evidence, DTS evidence, code evidence, cross-layer impact, risk, ambiguity,
status Open, and provenance back to discovery artifacts. Include counts by area
and risk. If there are no gaps, explicitly record the zero-gap conclusion and
evidence reviewed.

Create both the live register and the synthesis audit artifact. Do not modify
the mandatory baseline, detailed DTS specifications, production code, branches,
staging area, or commits. Return gap_count equal to the unresolved gaps written
to the register. Confirm baseline_reviewed, implementation_reviewed, every DTS
filename, and all four comparison lanes based on the persisted staged evidence.
"@
    Invoke-Codex -Prompt $synthesisPrompt -OutputFile $DiscoveryResult -OutputSchema $DiscoverySchema
    $discovery = Read-StructuredResult -Path $DiscoveryResult -StageName "register synthesis"

    foreach ($artifact in @($synthesisArtifact, $Register)) {
        if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) {
            throw "Register synthesis did not create its required artifact: $artifact"
        }
    }
    if (-not [bool]$discovery.baseline_reviewed) {
        throw "Synthesis coverage check failed: baseline review not confirmed."
    }
    if (-not [bool]$discovery.implementation_reviewed) {
        throw "Synthesis coverage check failed: implementation review not confirmed."
    }

    $synthesisDtsNames = @(
        $discovery.reviewed_dts_files |
            ForEach-Object { [System.IO.Path]::GetFileName([string]$_) }
    )
    $missingDtsFiles = @(
        $MandatoryDtsFiles |
            Where-Object {
                $reviewedDtsNames -notcontains $_.Name -or
                $synthesisDtsNames -notcontains $_.Name
            } |
            ForEach-Object { $_.Name }
    )
    if ($missingDtsFiles.Count -gt 0) {
        throw "Staged discovery coverage failed. Missing DTS confirmation:`n$($missingDtsFiles -join [Environment]::NewLine)"
    }

    $comparisonLanes = $discovery.comparison_lanes
    $incompleteLanes = @()
    if (-not [bool]$comparisonLanes.baseline_to_dts) { $incompleteLanes += "baseline_to_dts" }
    if (-not [bool]$comparisonLanes.baseline_to_code) { $incompleteLanes += "baseline_to_code" }
    if (-not [bool]$comparisonLanes.dts_to_code) { $incompleteLanes += "dts_to_code" }
    if (-not [bool]$comparisonLanes.cross_layer_dts) { $incompleteLanes += "cross_layer_dts" }
    if ($incompleteLanes.Count -gt 0) {
        throw "Staged discovery coverage failed. Incomplete comparison lanes: $($incompleteLanes -join ', ')"
    }

    Write-Host "Staged discovery artifacts: $cycleDirectory" -ForegroundColor DarkCyan
    Write-Host "Mandatory evidence coverage: verified" -ForegroundColor DarkCyan
    return $discovery
}

$startingCodeBranch = Assert-CleanRepository -Repository $ProjectRoot
$startingDtsBranch = Assert-CleanRepository -Repository $DtsRoot
Write-Host "Starting code branch: $startingCodeBranch" -ForegroundColor DarkCyan
Write-Host "Starting DTS branch:  $startingDtsBranch" -ForegroundColor DarkCyan

$globalIteration = 0
$currentIterationBranch = $null

for ($discoveryCycle = 1; $discoveryCycle -le $MaxDiscoveryCycles; $discoveryCycle++) {
    $globalIteration++
    $currentIterationBranch = New-IterationBranch -Iteration $globalIteration
    Write-Host "`n=== Discovery cycle $discoveryCycle of $MaxDiscoveryCycles ===" -ForegroundColor Cyan

    $skipDiscovery = $ContinueExistingRegister -and $discoveryCycle -eq 1
    $discoveredGapCount = $null

    if (-not $skipDiscovery) {
        $discovery = Invoke-StagedDiscovery -DiscoveryCycle $discoveryCycle
        $discoveredGapCount = [int]$discovery.gap_count
        Write-Host "Discovered gaps: $discoveredGapCount" -ForegroundColor DarkCyan
    }
    elseif (-not (Test-Path -LiteralPath $Register -PathType Leaf)) {
        throw "Cannot continue because the gap register does not exist: $Register"
    }

    # Preserve every cycle's newly discovered or starting gap set before any
    # resolution changes the live register.
    if (-not (Test-Path -LiteralPath $GapHistoryDirectory -PathType Container)) {
        New-Item -ItemType Directory -Path $GapHistoryDirectory | Out-Null
    }

    $historyFileName = "code-dts-gap-register-$runId-cycle{0:D3}.md" -f $discoveryCycle
    $historyFile = Join-Path $GapHistoryDirectory $historyFileName

    if (Test-Path -LiteralPath $historyFile) {
        throw "Refusing to overwrite an existing gap-history snapshot: $historyFile"
    }

    Copy-Item -LiteralPath $Register -Destination $historyFile
    Write-Host "Gap discovery snapshot: $historyFile" -ForegroundColor DarkCyan

    # A fresh discovery with zero gaps is the only convergence condition. Commit
    # its register and history snapshot, then finish without a resolution pass.
    if ($null -ne $discoveredGapCount -and $discoveredGapCount -eq 0) {
        Write-IterationReport `
            -Iteration $globalIteration `
            -DiscoveryCycle $discoveryCycle `
            -Branch $currentIterationBranch `
            -GapId "discovery-zero-gaps" `
            -Outcome "no_gaps_remaining" `
            -GapDescription "Fresh code-vs-DTS discovery found no unresolved gaps." `
            -Reasoning $discovery.summary `
            -IntroducedChanges @(
                "Updated the live gap register with the zero-gap discovery result.",
                "Created the immutable discovery-cycle history snapshot: $historyFileName.",
                "Created the complete 17-stage discovery evidence set under docs/code-dts-discovery/$runId/cycle-$('{0:D3}' -f $discoveryCycle)."
            ) `
            -ValidationPassed $true
        Commit-Iteration -Iteration $globalIteration -GapId "discovery-zero-gaps"
        Write-Host "`nDiscovery found no gaps. The repositories have converged." -ForegroundColor Green
        exit 0
    }

    $registerExhausted = $false

    for ($cycleIteration = 1; $cycleIteration -le $MaxIterations; $cycleIteration++) {
        if ($cycleIteration -gt 1) {
            $globalIteration++
            $currentIterationBranch = New-IterationBranch -Iteration $globalIteration
        }

        Write-Host "`n=== Gap iteration $cycleIteration of $MaxIterations (cycle $discoveryCycle) ===" -ForegroundColor Cyan

        $stepPrompt = @"
Work on exactly one unresolved entry from $Register.

Use these workspace roles:
- Implementation repository: $ProjectRoot
- DTS documentation workspace: $DtsRoot
- Mandatory architecture baseline: $MandatoryBaseline
- Mandatory detailed layer specifications: $MandatoryDtsDirectory\*.md

Workflow:
1. Read the repository guidance and the entire gap register.
2. Select the first unresolved gap in register order. Treat Open and In Progress
   as unresolved.
3. Revalidate that gap against the current code, the mandatory architecture
   baseline, every applicable detailed DTS layer specification, and affected
   cross-layer contracts. Do not resolve a gap from only one document-to-code
   comparison when another mandatory comparison lane bears on the decision.
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
7. In the structured result, provide a concise gap_description, the reasoning
   and evidence supporting the decision, and a complete introduced_changes list
   covering fixes, DTS updates, tests, and newly created artifacts.

If no unresolved gaps remain, make no changes and return done=true with outcome
no_gaps_remaining. Otherwise return done=false. Return outcome needs_human when
the selected item requires a human decision. Set validation_passed=false if a
required verification fails or cannot be completed.
"@

        Invoke-Codex -Prompt $stepPrompt -OutputFile $Result -OutputSchema $StepSchema

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

        $reportGapId = if ($step.gap_id) { [string]$step.gap_id } else { "no-gaps-in-register" }
        $iterationChanges = @($step.introduced_changes)
        if ($cycleIteration -eq 1 -and -not $skipDiscovery) {
            $iterationChanges += "Created the complete 17-stage discovery evidence set under docs/code-dts-discovery/$runId/cycle-$('{0:D3}' -f $discoveryCycle)."
            $iterationChanges += "Created the immutable discovery-cycle history snapshot: $historyFileName."
        }
        Write-IterationReport `
            -Iteration $globalIteration `
            -DiscoveryCycle $discoveryCycle `
            -Branch $currentIterationBranch `
            -GapId $reportGapId `
            -Outcome ([string]$step.outcome) `
            -GapDescription ([string]$step.gap_description) `
            -Reasoning ([string]$step.reasoning) `
            -IntroducedChanges $iterationChanges `
            -ValidationPassed ([bool]$step.validation_passed)

        Commit-Iteration -Iteration $globalIteration -GapId $step.gap_id

        if ($step.done) {
            $registerExhausted = $true
            Write-Host "Live register exhausted; starting a verification discovery cycle." -ForegroundColor Yellow
            break
        }
    }

    if ($discoveryCycle -lt $MaxDiscoveryCycles) {
        if (-not $registerExhausted) {
            Write-Host "Per-cycle iteration limit reached; rediscovering before continuing." -ForegroundColor Yellow
        }
        continue
    }
}

Write-Host "`nStopped after reaching the $MaxDiscoveryCycles discovery-cycle limit without a zero-gap discovery." -ForegroundColor Yellow
Write-Host "Latest cumulative branch: $currentIterationBranch" -ForegroundColor Yellow
exit 0
