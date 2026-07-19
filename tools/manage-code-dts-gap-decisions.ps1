[CmdletBinding(DefaultParameterSetName = "Generate")]
param(
    [Parameter(Mandatory, ParameterSetName = "Generate")]
    [switch]$Generate,

    [Parameter(Mandatory, ParameterSetName = "Apply")]
    [switch]$Apply,

    [Parameter(Mandatory)]
    [ValidatePattern("^[A-Za-z0-9][A-Za-z0-9._-]{0,79}$")]
    [string]$DecisionSetId,

    [Parameter(ParameterSetName = "Generate")]
    [ValidatePattern("^GAP-[0-9]{3,}$")]
    [string[]]$GapId,

    [Parameter(ParameterSetName = "Apply")]
    [switch]$ValidateOnly,

    [Parameter(ParameterSetName = "Apply")]
    [switch]$Push,

    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot),

    [string]$DtsRoot = "C:\Users\Minja\Documents\FCBP GL Connector"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$DtsRoot = [System.IO.Path]::GetFullPath($DtsRoot)
$Register = Join-Path $DtsRoot "docs\code-dts-gap-register.md"
$DecisionRoot = Join-Path $DtsRoot "docs\code-dts-gap-decisions"
$PendingDirectory = Join-Path $DecisionRoot "pending"
$PendingJson = Join-Path $PendingDirectory "$DecisionSetId.json"
$PendingPreview = Join-Path $PendingDirectory "$DecisionSetId.preview.md"
$AppliedRelativeDirectory = "docs/code-dts-gap-decisions/applied"
$AppliedRelativeJson = "$AppliedRelativeDirectory/$DecisionSetId.json"
$AppliedRelativeMarkdown = "$AppliedRelativeDirectory/$DecisionSetId.md"
$DecisionSchema = Join-Path $PSScriptRoot "gap-human-decision-batch.schema.json"
$DecisionBranch = "codex/gap-decisions-$DecisionSetId"

function Invoke-Git {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Repository,

        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $output = & git -C $Repository @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        $details = ($output | Out-String).Trim()
        throw "Git failed in ${Repository}: git $($Arguments -join ' ')`n$details"
    }

    return $output
}

function Get-CurrentBranch {
    param(
        [Parameter(Mandatory)]
        [string]$Repository
    )

    $branch = (Invoke-Git -Repository $Repository -Arguments @("branch", "--show-current") | Out-String).Trim()
    if (-not $branch) {
        throw "Repository is in detached HEAD state: $Repository"
    }
    return $branch
}

function Get-RepositoryStatus {
    param(
        [Parameter(Mandatory)]
        [string]$Repository
    )

    return @(Invoke-Git -Repository $Repository -Arguments @("status", "--porcelain=v1", "--untracked-files=all"))
}

function Assert-CleanRepository {
    param(
        [Parameter(Mandatory)]
        [string]$Repository
    )

    $status = @(Get-RepositoryStatus -Repository $Repository)
    if ($status.Count -gt 0) {
        throw "Repository must be clean: $Repository`n$($status -join [Environment]::NewLine)"
    }
    [void](Get-CurrentBranch -Repository $Repository)
}

function Test-LocalBranchExists {
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
    throw "Unable to inspect branch $Branch in $Repository (exit code $exitCode)."
}

function New-SynchronizedDecisionBranch {
    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        if (Test-LocalBranchExists -Repository $repository -Branch $DecisionBranch) {
            throw "Decision branch already exists in ${repository}: $DecisionBranch"
        }
    }

    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        Invoke-Git -Repository $repository -Arguments @("switch", "--create", $DecisionBranch) | Out-Null
    }

    Write-Host "Decision branch: $DecisionBranch" -ForegroundColor DarkCyan
}

function Get-Sha256Text {
    param(
        [Parameter(Mandatory)]
        [string]$Text
    )

    $normalized = ($Text -replace "`r`n", "`n").Trim()
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($normalized)
        $digest = $sha256.ComputeHash($bytes)
        return (($digest | ForEach-Object { $_.ToString("x2") }) -join "")
    }
    finally {
        $sha256.Dispose()
    }
}

function Get-RegisterText {
    if (-not (Test-Path -LiteralPath $Register -PathType Leaf)) {
        throw "Gap register does not exist: $Register"
    }
    return Get-Content -LiteralPath $Register -Raw -Encoding utf8
}

function Get-GapRecords {
    param(
        [Parameter(Mandatory)]
        [string]$RegisterText
    )

    $pattern = '(?ms)^### (?<id>GAP-[0-9]{3,}) \u2014 (?<title>[^\r\n]+)\r?\n(?<body>.*?)(?=^### GAP-|^## Synthesis conclusion|\z)'
    $matches = [regex]::Matches($RegisterText, $pattern)
    $records = @()

    foreach ($match in $matches) {
        $block = $match.Value.TrimEnd()
        $metadata = [regex]::Match(
            $block,
            '(?m)^- \*\*Area / risk / status:\*\* (?<area>.+?) / (?<risk>P[012]) / (?<status>Open|In Progress|Resolved|Needs Human Decision)\s*$'
        )
        if (-not $metadata.Success) {
            throw "Unable to parse area/risk/status for $($match.Groups['id'].Value)."
        }

        $decisionRequired = [regex]::Match($block, '(?m)^- \*\*Decision required:\*\* (?<value>.+)$')
        $alternatives = [regex]::Match($block, '(?m)^- \*\*Alternatives considered:\*\* (?<value>.+)$')

        $records += [pscustomobject]@{
            Id                     = $match.Groups['id'].Value
            Title                  = $match.Groups['title'].Value.Trim()
            Area                   = $metadata.Groups['area'].Value.Trim()
            Risk                   = $metadata.Groups['risk'].Value
            Status                 = $metadata.Groups['status'].Value
            DecisionRequired       = if ($decisionRequired.Success) { $decisionRequired.Groups['value'].Value.Trim() } else { "" }
            AlternativesConsidered = if ($alternatives.Success) { $alternatives.Groups['value'].Value.Trim() } else { "" }
            Block                  = $block
            Fingerprint            = Get-Sha256Text -Text $block
        }
    }

    if ($records.Count -eq 0) {
        throw "No GAP-### entries were found in $Register."
    }

    return $records
}

function Get-RegisterDiscoveryRun {
    param(
        [Parameter(Mandatory)]
        [string]$RegisterText
    )

    $match = [regex]::Match($RegisterText, '(?m)^Discovery run: `(?<id>[^`]+)`')
    if ($match.Success) { return $match.Groups['id'].Value }
    return "unknown"
}

function Get-RequiredProperty {
    param(
        [Parameter(Mandatory)]
        [object]$Object,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Context
    )

    if ($Object.PSObject.Properties.Name -notcontains $Name) {
        throw "$Context is missing required property '$Name'."
    }
    return $Object.$Name
}

function Assert-NonBlankString {
    param(
        [AllowNull()]
        [object]$Value,

        [Parameter(Mandatory)]
        [string]$Field,

        [Parameter(Mandatory)]
        [string]$GapId
    )

    if ($null -eq $Value -or -not ($Value -is [string]) -or [string]::IsNullOrWhiteSpace([string]$Value)) {
        throw "$GapId requires a non-empty '$Field'."
    }
}

function Assert-NonEmptyStringArray {
    param(
        [AllowNull()]
        [object]$Value,

        [Parameter(Mandatory)]
        [string]$Field,

        [Parameter(Mandatory)]
        [string]$GapId
    )

    if ($Value -is [string]) {
        throw "$GapId '$Field' must be a JSON array, not a single string."
    }
    $items = @($Value)
    if ($items.Count -eq 0) {
        throw "$GapId requires at least one '$Field' entry."
    }
    foreach ($item in $items) {
        Assert-NonBlankString -Value $item -Field $Field -GapId $GapId
    }
}

function Read-AndValidateDecisionBatch {
    param(
        [Parameter(Mandatory)]
        [object[]]$CurrentGaps
    )

    if (-not (Test-Path -LiteralPath $PendingJson -PathType Leaf)) {
        throw "Pending decision batch does not exist: $PendingJson"
    }

    try {
        $rawJson = Get-Content -LiteralPath $PendingJson -Raw -Encoding utf8
        $batch = $rawJson | ConvertFrom-Json
    }
    catch {
        throw "Decision batch is not valid JSON: $($_.Exception.Message)"
    }

    $schemaVersion = Get-RequiredProperty -Object $batch -Name "schema_version" -Context "Decision batch"
    if ([int]$schemaVersion -ne 1) {
        throw "Unsupported decision batch schema_version '$schemaVersion'. Expected 1."
    }

    $batchId = [string](Get-RequiredProperty -Object $batch -Name "decision_set_id" -Context "Decision batch")
    if ($batchId -ne $DecisionSetId) {
        throw "Decision batch ID '$batchId' does not match -DecisionSetId '$DecisionSetId'."
    }

    $decisions = @(Get-RequiredProperty -Object $batch -Name "decisions" -Context "Decision batch")
    if ($decisions.Count -eq 0) {
        throw "Decision batch contains no decisions."
    }

    $validated = @()
    $validatedIds = @()
    foreach ($decision in $decisions) {
        $id = [string](Get-RequiredProperty -Object $decision -Name "gap_id" -Context "Decision")
        if ($id -notmatch '^GAP-[0-9]{3,}$') {
            throw "Invalid gap ID in decision batch: '$id'."
        }

        $approved = Get-RequiredProperty -Object $decision -Name "approved" -Context $id
        if ($approved -isnot [bool] -or -not [bool]$approved) {
            throw "$id is not explicitly approved. Set approved to true only after human approval."
        }

        foreach ($field in @("authority", "decision_date", "decision", "migration")) {
            $value = Get-RequiredProperty -Object $decision -Name $field -Context $id
            Assert-NonBlankString -Value $value -Field $field -GapId $id
        }
        foreach ($field in @("constraints", "implementation_direction", "acceptance_criteria")) {
            $value = Get-RequiredProperty -Object $decision -Name $field -Context $id
            Assert-NonEmptyStringArray -Value $value -Field $field -GapId $id
        }

        $parsedDate = [DateTime]::MinValue
        $dateValid = [DateTime]::TryParseExact(
            [string]$decision.decision_date,
            "yyyy-MM-dd",
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::None,
            [ref]$parsedDate
        )
        if (-not $dateValid) {
            throw "$id decision_date must use YYYY-MM-DD."
        }

        $requiresFreshDiscovery = Get-RequiredProperty -Object $decision -Name "requires_fresh_discovery" -Context $id
        if ($requiresFreshDiscovery -isnot [bool]) {
            throw "$id requires_fresh_discovery must be true or false."
        }

        $currentGap = @($CurrentGaps | Where-Object Id -eq $id)
        if ($currentGap.Count -ne 1) {
            throw "$id does not identify exactly one current register entry."
        }
        if ($currentGap[0].Status -ne "Needs Human Decision") {
            throw "$id must currently have status 'Needs Human Decision'; found '$($currentGap[0].Status)'."
        }

        $fingerprint = [string](Get-RequiredProperty -Object $decision -Name "gap_fingerprint" -Context $id)
        if ($fingerprint -ne $currentGap[0].Fingerprint) {
            throw "$id changed after template generation. Generate a fresh decision template before applying it."
        }

        $templateTitle = [string](Get-RequiredProperty -Object $decision -Name "gap_title" -Context $id)
        $templateDecisionRequired = [string](Get-RequiredProperty -Object $decision -Name "decision_required" -Context $id)
        $templateAlternatives = [string](Get-RequiredProperty -Object $decision -Name "alternatives_considered" -Context $id)
        if ($templateTitle -ne $currentGap[0].Title -or
            $templateDecisionRequired -ne $currentGap[0].DecisionRequired -or
            $templateAlternatives -ne $currentGap[0].AlternativesConsidered) {
            throw "$id template evidence was edited. Regenerate the template and edit only the human decision fields."
        }

        $validated += [pscustomobject]@{
            Input = $decision
            Gap   = $currentGap[0]
        }
        $validatedIds += $id
    }

    $duplicateIds = @($validatedIds | Group-Object | Where-Object Count -gt 1 | ForEach-Object Name)
    if ($duplicateIds.Count -gt 0) {
        throw "Decision batch contains duplicate gap IDs: $($duplicateIds -join ', ')"
    }

    return [pscustomobject]@{
        Batch      = $batch
        RawJson    = $rawJson
        Decisions  = $validated
    }
}

function Convert-ToInlineText {
    param(
        [AllowNull()]
        [object]$Value
    )

    if ($null -eq $Value) { return "" }
    return (([string]$Value -replace '\s+', ' ').Trim())
}

function Join-DecisionItems {
    param(
        [AllowNull()]
        [object]$Value
    )

    return ((@($Value) | ForEach-Object { Convert-ToInlineText -Value $_ }) -join "; ")
}

function Add-DecisionsToRegister {
    param(
        [Parameter(Mandatory)]
        [string]$RegisterText,

        [Parameter(Mandatory)]
        [object[]]$ValidatedDecisions
    )

    $decisionMap = @{}
    foreach ($item in $ValidatedDecisions) {
        $decisionMap[$item.Gap.Id] = $item
    }

    $pattern = '(?ms)^### (?<id>GAP-[0-9]{3,}) \u2014 (?<title>[^\r\n]+)\r?\n(?<body>.*?)(?=^### GAP-|^## Synthesis conclusion|\z)'
    $gapRegex = [regex]::new($pattern)
    $statusRegex = [regex]::new(
        '(?m)^(?<prefix>- \*\*Area / risk / status:\*\* .+? / P[012] / )Needs Human Decision\s*$'
    )
    $newline = if ($RegisterText.Contains("`r`n")) { "`r`n" } else { "`n" }

    return $gapRegex.Replace($RegisterText, {
        param($match)

        $id = $match.Groups['id'].Value
        if (-not $decisionMap.ContainsKey($id)) {
            return $match.Value
        }

        $item = $decisionMap[$id]
        $decision = $item.Input
        $block = $statusRegex.Replace(
            $match.Value.TrimEnd(),
            { param($statusMatch) $statusMatch.Groups['prefix'].Value + "Open" },
            1
        )

        if ($block -match '(?m)^- \*\*Human decision:\*\*') {
            throw "$id already contains a human decision."
        }

        $decisionLines = @(
            "- **Human decision:** $(Convert-ToInlineText -Value $decision.decision)",
            "- **Decision authority:** $(Convert-ToInlineText -Value $decision.authority)",
            "- **Decision date:** $(Convert-ToInlineText -Value $decision.decision_date)",
            "- **Constraints:** $(Join-DecisionItems -Value $decision.constraints)",
            "- **Implementation direction:** $(Join-DecisionItems -Value $decision.implementation_direction)",
            "- **Migration:** $(Convert-ToInlineText -Value $decision.migration)",
            "- **Acceptance criteria:** $(Join-DecisionItems -Value $decision.acceptance_criteria)",
            "- **Requires fresh discovery:** $([bool]$decision.requires_fresh_discovery)",
            "- **Decision record:** ``$AppliedRelativeMarkdown``."
        )

        return $block + $newline + ($decisionLines -join $newline) + $newline + $newline
    })
}

function Join-EnglishList {
    param(
        [string[]]$Items
    )

    $values = @($Items)
    if ($values.Count -eq 0) { return "" }
    if ($values.Count -eq 1) { return $values[0] }
    if ($values.Count -eq 2) { return "$($values[0]) and $($values[1])" }
    return (($values[0..($values.Count - 2)] -join ", ") + ", and " + $values[-1])
}

function Update-RegisterCounts {
    param(
        [Parameter(Mandatory)]
        [string]$RegisterText
    )

    $records = @(Get-GapRecords -RegisterText $RegisterText)
    $unresolved = @($records | Where-Object Status -ne "Resolved")
    $resolved = @($records | Where-Object Status -eq "Resolved")
    $newline = if ($RegisterText.Contains("`r`n")) { "`r`n" } else { "`n" }

    $updated = [regex]::Replace(
        $RegisterText,
        '(?m)^Open gaps: \*\*[0-9]+\*\*$',
        "Open gaps: **$($unresolved.Count)**"
    )

    $countLines = @(
        "## Counts",
        "",
        "| Risk | Count |",
        "|---|---:|"
    )
    foreach ($risk in @("P0", "P1", "P2")) {
        $countLines += "| $risk | $(@($unresolved | Where-Object Risk -eq $risk).Count) |"
    }

    $countLines += @(
        "",
        "| Status | Count |",
        "|---|---:|",
        "| Open | $(@($records | Where-Object Status -eq 'Open').Count) |",
        "| In Progress | $(@($records | Where-Object Status -eq 'In Progress').Count) |",
        "| Needs Human Decision | $(@($records | Where-Object Status -eq 'Needs Human Decision').Count) |",
        "| Resolved | $($resolved.Count) |",
        "",
        "| Area | Count |",
        "|---|---:|"
    )
    $areaGroups = @($unresolved | Group-Object Area | Sort-Object Name)
    if ($areaGroups.Count -eq 0) {
        $countLines += "| None | 0 |"
    }
    else {
        foreach ($group in $areaGroups) {
            $countLines += "| $($group.Name) | $($group.Count) |"
        }
    }

    $countsSection = ($countLines -join $newline) + $newline
    $updated = [regex]::Replace(
        $updated,
        '(?ms)^## Counts\s*.*?(?=^## Open gaps\s*$)',
        $countsSection + $newline
    )

    $resolvedList = Join-EnglishList -Items @($resolved.Id)
    $resolutionPhrase = if ($resolved.Count -eq 0) {
        "no entries are resolved."
    }
    elseif ($resolved.Count -eq 1) {
        "$resolvedList is resolved."
    }
    else {
        "$resolvedList are resolved."
    }
    $newSynthesisStart = "Of the $($records.Count) registered entries, $($unresolved.Count) remain unresolved; $resolutionPhrase"
    $updated = [regex]::Replace(
        $updated,
        '(?m)^Of the [0-9]+ registered entries, [0-9]+ remain unresolved(?: and `Open`)?; .*? (?:is|are) resolved\.',
        $newSynthesisStart
    )

    return $updated
}

function Assert-RegisterConsistency {
    param(
        [Parameter(Mandatory)]
        [string]$RegisterText
    )

    $records = @(Get-GapRecords -RegisterText $RegisterText)
    $unresolvedCount = @($records | Where-Object Status -ne "Resolved").Count
    $header = [regex]::Match($RegisterText, '(?m)^Open gaps: \*\*(?<count>[0-9]+)\*\*$')
    if (-not $header.Success -or [int]$header.Groups['count'].Value -ne $unresolvedCount) {
        throw "Register header count does not match the $unresolvedCount unresolved entries."
    }

    $synthesis = [regex]::Match($RegisterText, '(?m)^Of the (?<total>[0-9]+) registered entries, (?<open>[0-9]+) remain unresolved;')
    if (-not $synthesis.Success -or
        [int]$synthesis.Groups['total'].Value -ne $records.Count -or
        [int]$synthesis.Groups['open'].Value -ne $unresolvedCount) {
        throw "Register synthesis counts do not match parsed entry statuses."
    }
}

function New-PendingPreview {
    param(
        [Parameter(Mandatory)]
        [object[]]$Decisions
    )

    $lines = @(
        "# Pending human gap decisions: $DecisionSetId",
        "",
        "The JSON file next to this preview is authoritative. Complete every",
        "decision field there, set ``approved`` to ``true``, then run the apply command.",
        "Do not edit the gap register directly.",
        ""
    )

    foreach ($decision in $Decisions) {
        $lines += @(
            "## $($decision.gap_id) - $($decision.gap_title)",
            "",
            "- **Fingerprint:** ``$($decision.gap_fingerprint)``",
            "- **Decision required:** $($decision.decision_required)",
            "- **Alternatives considered:** $($decision.alternatives_considered)",
            "- **Approved:** $($decision.approved)",
            "- **Authority:** $($decision.authority)",
            "- **Decision date:** $($decision.decision_date)",
            "- **Human decision:** $($decision.decision)",
            ""
        )
    }

    return ($lines -join [Environment]::NewLine)
}

function New-AppliedDecisionMarkdown {
    param(
        [Parameter(Mandatory)]
        [object[]]$ValidatedDecisions,

        [Parameter(Mandatory)]
        [string]$AppliedAtUtc
    )

    $lines = @(
        "# Human gap decision batch: $DecisionSetId",
        "",
        "- Applied at UTC: $AppliedAtUtc",
        "- Decision branch: ``$DecisionBranch``",
        "- Source register: ``docs/code-dts-gap-register.md``",
        ""
    )

    foreach ($item in $ValidatedDecisions) {
        $decision = $item.Input
        $gap = $item.Gap
        $lines += @(
            "## $($gap.Id) - $($gap.Title)",
            "",
            "- **Decision authority:** $(Convert-ToInlineText -Value $decision.authority)",
            "- **Decision date:** $(Convert-ToInlineText -Value $decision.decision_date)",
            "- **Gap fingerprint:** ``$($gap.Fingerprint)``",
            "- **Requires fresh discovery:** $([bool]$decision.requires_fresh_discovery)",
            "",
            "### Decision required",
            "",
            $gap.DecisionRequired,
            "",
            "### Alternatives considered",
            "",
            $gap.AlternativesConsidered,
            "",
            "### Approved human decision",
            "",
            ([string]$decision.decision).Trim(),
            "",
            "### Constraints",
            ""
        )
        $lines += @($decision.constraints | ForEach-Object { "- $([string]$_)" })
        $lines += @("", "### Implementation direction", "")
        $lines += @($decision.implementation_direction | ForEach-Object { "- $([string]$_)" })
        $lines += @("", "### Migration", "", ([string]$decision.migration).Trim(), "", "### Acceptance criteria", "")
        $lines += @($decision.acceptance_criteria | ForEach-Object { "- $([string]$_)" })
        $lines += ""
    }

    return ($lines -join [Environment]::NewLine)
}

function Assert-ApplyWorkingTrees {
    $codeStatus = @(Get-RepositoryStatus -Repository $ProjectRoot)
    if ($codeStatus.Count -gt 0) {
        throw "Implementation repository must be clean before applying decisions:`n$($codeStatus -join [Environment]::NewLine)"
    }

    $allowedPaths = @(
        "docs/code-dts-gap-decisions/pending/$DecisionSetId.json",
        "docs/code-dts-gap-decisions/pending/$DecisionSetId.preview.md"
    )
    $unexpected = @()
    foreach ($line in @(Get-RepositoryStatus -Repository $DtsRoot)) {
        if ($line.Length -lt 4) {
            $unexpected += $line
            continue
        }
        $path = $line.Substring(3).Replace("\", "/")
        if ($allowedPaths -notcontains $path) {
            $unexpected += $line
        }
    }
    if ($unexpected.Count -gt 0) {
        throw "DTS repository has unrelated changes:`n$($unexpected -join [Environment]::NewLine)"
    }
}

function Assert-AppliedArtifactsAbsent {
    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        foreach ($relativePath in @($AppliedRelativeJson, $AppliedRelativeMarkdown)) {
            $path = Join-Path $repository ($relativePath -replace '/', '\')
            if (Test-Path -LiteralPath $path) {
                throw "Decision set '$DecisionSetId' already has an applied audit artifact: $path"
            }
        }
    }
}

function Write-AppliedArtifacts {
    param(
        [Parameter(Mandatory)]
        [object]$ValidatedBatch,

        [Parameter(Mandatory)]
        [string]$AppliedMarkdown,

        [Parameter(Mandatory)]
        [string]$AppliedAtUtc
    )

    $ValidatedBatch.Batch | Add-Member -NotePropertyName "applied_at_utc" -NotePropertyValue $AppliedAtUtc -Force
    $appliedJson = $ValidatedBatch.Batch | ConvertTo-Json -Depth 20

    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        $directory = Join-Path $repository ($AppliedRelativeDirectory -replace '/', '\')
        if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
        Set-Content -LiteralPath (Join-Path $repository ($AppliedRelativeJson -replace '/', '\')) -Value $appliedJson -Encoding utf8
        Set-Content -LiteralPath (Join-Path $repository ($AppliedRelativeMarkdown -replace '/', '\')) -Value $AppliedMarkdown -Encoding utf8
    }

    foreach ($pendingPath in @($PendingJson, $PendingPreview)) {
        if (Test-Path -LiteralPath $pendingPath) {
            Remove-Item -LiteralPath $pendingPath -Force
        }
    }
}

function Commit-DecisionBatch {
    $message = "Record human gap decisions ($DecisionSetId)"
    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        Invoke-Git -Repository $repository -Arguments @("add", "--all") | Out-Null
        Invoke-Git -Repository $repository -Arguments @("commit", "--message", $message) | Out-Null
    }
    Write-Host "Committed decision batch in both repositories." -ForegroundColor DarkCyan
}

function Push-DecisionBranches {
    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        Invoke-Git -Repository $repository -Arguments @("push", "--set-upstream", "origin", $DecisionBranch) | Out-Null
    }
    Write-Host "Pushed $DecisionBranch from both repositories." -ForegroundColor DarkCyan
}

if (-not (Test-Path -LiteralPath $DecisionSchema -PathType Leaf)) {
    throw "Missing human-decision schema: $DecisionSchema"
}
if ($ValidateOnly -and $Push) {
    throw "-Push cannot be combined with -ValidateOnly."
}

if ($Generate) {
    Assert-CleanRepository -Repository $ProjectRoot
    Assert-CleanRepository -Repository $DtsRoot

    $codeStartBranch = Get-CurrentBranch -Repository $ProjectRoot
    $dtsStartBranch = Get-CurrentBranch -Repository $DtsRoot
    if ($codeStartBranch -ne $dtsStartBranch) {
        throw "Repositories must start on the same branch. Found code='$codeStartBranch', DTS='$dtsStartBranch'."
    }
    Assert-AppliedArtifactsAbsent

    $registerText = Get-RegisterText
    $gaps = @(Get-GapRecords -RegisterText $registerText)
    $needsHuman = @($gaps | Where-Object Status -eq "Needs Human Decision")
    if ($needsHuman.Count -eq 0) {
        throw "The register has no Needs Human Decision entries."
    }

    $selected = if ($GapId -and $GapId.Count -gt 0) {
        $missing = @($GapId | Where-Object { $needsHuman.Id -notcontains $_ })
        if ($missing.Count -gt 0) {
            throw "Requested gaps are not in Needs Human Decision status: $($missing -join ', ')"
        }
        @($needsHuman | Where-Object { $GapId -contains $_.Id })
    }
    else {
        $needsHuman
    }

    foreach ($gap in $selected) {
        if (-not $gap.DecisionRequired -or -not $gap.AlternativesConsidered) {
            throw "$($gap.Id) must contain Decision required and Alternatives considered before template generation."
        }
    }

    if ((Test-Path -LiteralPath $PendingJson -PathType Leaf) -or
        (Test-Path -LiteralPath $PendingPreview -PathType Leaf)) {
        throw "Decision set already has pending artifacts: $DecisionSetId"
    }

    New-SynchronizedDecisionBranch

    if (-not (Test-Path -LiteralPath $PendingDirectory -PathType Container)) {
        New-Item -ItemType Directory -Path $PendingDirectory -Force | Out-Null
    }

    $templateDecisions = @($selected | ForEach-Object {
        [ordered]@{
            gap_id                  = $_.Id
            gap_title               = $_.Title
            gap_fingerprint         = $_.Fingerprint
            decision_required       = $_.DecisionRequired
            alternatives_considered = $_.AlternativesConsidered
            approved                = $false
            authority               = ""
            decision_date           = ""
            decision                = ""
            constraints             = @()
            implementation_direction = @()
            migration               = ""
            acceptance_criteria     = @()
            requires_fresh_discovery = $false
        }
    })
    $batch = [ordered]@{
        schema_version         = 1
        decision_set_id        = $DecisionSetId
        generated_at_utc       = [DateTime]::UtcNow.ToString("o")
        register_discovery_run = Get-RegisterDiscoveryRun -RegisterText $registerText
        decisions              = $templateDecisions
    }

    Set-Content -LiteralPath $PendingJson -Value ($batch | ConvertTo-Json -Depth 20) -Encoding utf8
    Set-Content -LiteralPath $PendingPreview -Value (New-PendingPreview -Decisions $templateDecisions) -Encoding utf8

    Write-Host "Generated $($templateDecisions.Count) decision template(s)." -ForegroundColor Green
    Write-Host "Authoritative JSON: $PendingJson" -ForegroundColor DarkCyan
    Write-Host "Markdown preview:   $PendingPreview" -ForegroundColor DarkCyan
    Write-Warning "Complete and approve the JSON file, then use -Apply. The DTS repository is intentionally dirty until the batch is applied."
    exit 0
}

Assert-ApplyWorkingTrees
$registerText = Get-RegisterText
$currentGaps = @(Get-GapRecords -RegisterText $registerText)
$validatedBatch = Read-AndValidateDecisionBatch -CurrentGaps $currentGaps
Assert-AppliedArtifactsAbsent

Write-Host "Validated $($validatedBatch.Decisions.Count) approved decision(s)." -ForegroundColor Green
if ($ValidateOnly) {
    Write-Host "Validation-only mode made no changes." -ForegroundColor DarkCyan
    exit 0
}

$codeBranch = Get-CurrentBranch -Repository $ProjectRoot
$dtsBranch = Get-CurrentBranch -Repository $DtsRoot
if ($codeBranch -ne $DecisionBranch -or $dtsBranch -ne $DecisionBranch) {
    throw "Apply must run on $DecisionBranch in both repositories. Found code='$codeBranch', DTS='$dtsBranch'."
}

$updatedRegister = Add-DecisionsToRegister -RegisterText $registerText -ValidatedDecisions $validatedBatch.Decisions
$updatedRegister = Update-RegisterCounts -RegisterText $updatedRegister
Assert-RegisterConsistency -RegisterText $updatedRegister

$appliedAtUtc = [DateTime]::UtcNow.ToString("o")
$appliedMarkdown = New-AppliedDecisionMarkdown -ValidatedDecisions $validatedBatch.Decisions -AppliedAtUtc $appliedAtUtc
Set-Content -LiteralPath $Register -Value $updatedRegister.TrimEnd() -Encoding utf8
Write-AppliedArtifacts -ValidatedBatch $validatedBatch -AppliedMarkdown $appliedMarkdown -AppliedAtUtc $appliedAtUtc
Commit-DecisionBatch

if ($Push) {
    Push-DecisionBranches
}

$freshDiscoveryRequired = @($validatedBatch.Decisions | Where-Object { [bool]$_.Input.requires_fresh_discovery })
Write-Host "Applied and reopened: $($validatedBatch.Decisions.Gap.Id -join ', ')" -ForegroundColor Green
if ($freshDiscoveryRequired.Count -gt 0) {
    Write-Warning "One or more decisions require fresh discovery. Run run-code-dts-gap-loop.ps1 without -ContinueExistingRegister."
}
else {
    Write-Host "The decision branch is ready for a resolution-only gap run." -ForegroundColor Green
}
