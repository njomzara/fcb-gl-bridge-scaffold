[CmdletBinding()]
param(
    [ValidateRange(1024, 65535)]
    [int]$Port = 8765,

    [string]$ProjectRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)),

    [string]$DtsRoot = "C:\Users\Minja\Documents\FCBP GL Connector",

    [switch]$NoBrowser
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$DtsRoot = [System.IO.Path]::GetFullPath($DtsRoot)
$UiPath = Join-Path $PSScriptRoot "decision-admin.html"
$DecisionTool = Join-Path (Split-Path -Parent $PSScriptRoot) "manage-code-dts-gap-decisions.ps1"
$RegisterPath = Join-Path $DtsRoot "docs\code-dts-gap-register.md"
$PendingRoot = Join-Path $DtsRoot "docs\code-dts-gap-decisions\pending"
$AppliedRelativeRoot = "docs\code-dts-gap-decisions\applied"
$ServerUrl = "http://127.0.0.1:$Port/"
$script:StopRequested = $false

function Assert-RequiredFile {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file does not exist: $Path"
    }
}

function Assert-DecisionSetId {
    param([Parameter(Mandatory)][string]$Value)

    if ($Value -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]{0,79}$' -or
        $Value.Contains("..") -or $Value.EndsWith(".") -or $Value.EndsWith(".lock")) {
        throw "Invalid decision-set ID '$Value'. Use letters, numbers, '.', '_', or '-' and a Git-safe name."
    }
}

function Assert-GapId {
    param([Parameter(Mandatory)][string]$Value)

    if ($Value -notmatch '^GAP-[0-9]{3,}$') {
        throw "Invalid gap ID '$Value'."
    }
}

function Invoke-Git {
    param(
        [Parameter(Mandatory)][string]$Repository,
        [Parameter(Mandatory)][string[]]$Arguments
    )

    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $output = & git -C $Repository @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }

    if ($exitCode -ne 0) {
        throw "Git failed in ${Repository}: git $($Arguments -join ' ')`n$(($output | Out-String).Trim())"
    }
    return @($output)
}

function Get-RepositoryState {
    param([Parameter(Mandatory)][string]$Repository)

    $branch = (Invoke-Git -Repository $Repository -Arguments @("branch", "--show-current") | Out-String).Trim()
    $changes = @(Invoke-Git -Repository $Repository -Arguments @("status", "--porcelain=v1", "--untracked-files=all"))
    return [ordered]@{
        root = $Repository
        branch = $branch
        clean = ($changes.Count -eq 0)
        changes = $changes
    }
}

function Get-Gaps {
    $register = Get-Content -LiteralPath $RegisterPath -Raw -Encoding utf8
    $pattern = '(?ms)^### (?<id>GAP-[0-9]{3,}) \u2014 (?<title>[^\r\n]+)\r?\n(?<body>.*?)(?=^### GAP-|^## Synthesis conclusion|\z)'
    $records = @()

    foreach ($match in [regex]::Matches($register, $pattern)) {
        $body = $match.Groups['body'].Value
        $metadata = [regex]::Match(
            $body,
            '(?m)^- \*\*Area / risk / status:\*\* (?<area>.+?) / (?<risk>P[012]) / (?<status>Open|In Progress|Resolved|Needs Human Decision)\s*$'
        )
        if (-not $metadata.Success) { continue }

        $required = [regex]::Match($body, '(?m)^- \*\*Decision required:\*\* (?<value>.+)$')
        $alternatives = [regex]::Match($body, '(?m)^- \*\*Alternatives considered:\*\* (?<value>.+)$')
        $records += [ordered]@{
            gap_id = $match.Groups['id'].Value
            gap_title = $match.Groups['title'].Value.Trim()
            area = $metadata.Groups['area'].Value.Trim()
            risk = $metadata.Groups['risk'].Value
            status = $metadata.Groups['status'].Value
            decision_required = $(if ($required.Success) { $required.Groups['value'].Value.Trim() } else { "" })
            alternatives_considered = $(if ($alternatives.Success) { $alternatives.Groups['value'].Value.Trim() } else { "" })
        }
    }
    return $records
}

function Get-DecisionIds {
    param([Parameter(Mandatory)][string]$Directory)

    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) { return @() }
    return @(
        Get-ChildItem -LiteralPath $Directory -File -Filter "*.json" |
            Sort-Object Name |
            ForEach-Object { $_.BaseName }
    )
}

function Get-AdminState {
    $gaps = @(Get-Gaps)
    return [ordered]@{
        code_repository = Get-RepositoryState -Repository $ProjectRoot
        dts_repository = Get-RepositoryState -Repository $DtsRoot
        needs_human_decision = @($gaps | Where-Object status -eq "Needs Human Decision")
        pending_decision_sets = @(Get-DecisionIds -Directory $PendingRoot)
        applied_decision_sets = @(Get-DecisionIds -Directory (Join-Path $DtsRoot $AppliedRelativeRoot))
    }
}

function ConvertTo-PowerShellLiteral {
    param([Parameter(Mandatory)][string]$Value)
    return "'" + $Value.Replace("'", "''") + "'"
}

function Invoke-DecisionTool {
    param(
        [Parameter(Mandatory)][ValidateSet("Generate", "Validate", "Apply")][string]$Action,
        [Parameter(Mandatory)][string]$DecisionSetId,
        [string[]]$GapIds = @()
    )

    Assert-DecisionSetId -Value $DecisionSetId
    $switchName = if ($Action -eq "Validate") { "Apply" } else { $Action }
    $parts = @(
        "& $(ConvertTo-PowerShellLiteral -Value $DecisionTool)",
        "-$switchName",
        "-DecisionSetId $(ConvertTo-PowerShellLiteral -Value $DecisionSetId)",
        "-ProjectRoot $(ConvertTo-PowerShellLiteral -Value $ProjectRoot)",
        "-DtsRoot $(ConvertTo-PowerShellLiteral -Value $DtsRoot)"
    )

    if ($Action -eq "Generate" -and $GapIds.Count -gt 0) {
        foreach ($gapId in $GapIds) { Assert-GapId -Value $gapId }
        $literalIds = @($GapIds | ForEach-Object { ConvertTo-PowerShellLiteral -Value $_ }) -join ","
        $parts += "-GapId @($literalIds)"
    }
    if ($Action -eq "Validate") { $parts += "-ValidateOnly" }

    $command = '$ProgressPreference = ''SilentlyContinue''; ' +
        ($parts -join " ") +
        ' *>&1 | ForEach-Object { $_.ToString() }'
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    $startInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded"
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    [void]$process.Start()
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    $stdout = $stdoutTask.Result.Trim()
    $stderr = $stderrTask.Result.Trim()
    $exitCode = $process.ExitCode
    $process.Dispose()

    $combined = @($stdout, $stderr) | Where-Object { $_ } | ForEach-Object { $_.Trim() }
    if ($exitCode -ne 0) {
        throw "Decision tool failed with exit code ${exitCode}:`n$($combined -join [Environment]::NewLine)"
    }
    return ($combined -join [Environment]::NewLine)
}

function Get-PendingBatchPath {
    param([Parameter(Mandatory)][string]$DecisionSetId)

    Assert-DecisionSetId -Value $DecisionSetId
    return Join-Path $PendingRoot "$DecisionSetId.json"
}

function Read-PendingBatch {
    param([Parameter(Mandatory)][string]$DecisionSetId)

    $path = Get-PendingBatchPath -DecisionSetId $DecisionSetId
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Pending decision set does not exist: $DecisionSetId"
    }
    return Get-Content -LiteralPath $path -Raw -Encoding utf8 | ConvertFrom-Json
}

function Get-RequiredPayloadProperty {
    param(
        [Parameter(Mandatory)][object]$Object,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Context
    )

    if ($Object.PSObject.Properties.Name -notcontains $Name) {
        throw "$Context is missing '$Name'."
    }
    return $Object.$Name
}

function Save-PendingBatch {
    param([Parameter(Mandatory)][object]$Payload)

    $decisionSetId = [string](Get-RequiredPayloadProperty -Object $Payload -Name "decision_set_id" -Context "Request")
    $submitted = @(Get-RequiredPayloadProperty -Object $Payload -Name "decisions" -Context "Request")
    $path = Get-PendingBatchPath -DecisionSetId $decisionSetId
    $batch = Read-PendingBatch -DecisionSetId $decisionSetId

    if ($submitted.Count -ne @($batch.decisions).Count) {
        throw "The submitted decision count does not match the generated batch."
    }

    $editableFields = @(
        "approved", "authority", "decision_date", "decision", "constraints",
        "implementation_direction", "migration", "acceptance_criteria", "requires_fresh_discovery"
    )
    foreach ($storedDecision in @($batch.decisions)) {
        $gapId = [string]$storedDecision.gap_id
        $matches = @($submitted | Where-Object { [string]$_.gap_id -eq $gapId })
        if ($matches.Count -ne 1) {
            throw "$gapId must appear exactly once in the submitted batch."
        }
        foreach ($field in $editableFields) {
            $value = Get-RequiredPayloadProperty -Object $matches[0] -Name $field -Context $gapId
            $storedDecision.$field = $value
        }
    }

    $temporaryPath = Join-Path (Split-Path -Parent $path) ("." + [IO.Path]::GetRandomFileName())
    try {
        Set-Content -LiteralPath $temporaryPath -Value ($batch | ConvertTo-Json -Depth 20) -Encoding utf8
        Move-Item -LiteralPath $temporaryPath -Destination $path -Force
    }
    finally {
        if (Test-Path -LiteralPath $temporaryPath) {
            Remove-Item -LiteralPath $temporaryPath -Force
        }
    }
    return $batch
}

function Push-DecisionBranch {
    param([Parameter(Mandatory)][string]$DecisionSetId)

    Assert-DecisionSetId -Value $DecisionSetId
    $expectedBranch = "codex/gap-decisions-$DecisionSetId"
    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        $state = Get-RepositoryState -Repository $repository
        if ($state.branch -ne $expectedBranch) {
            throw "Both repositories must be on '$expectedBranch'. Found '$($state.branch)' in $repository."
        }
        if (-not $state.clean) {
            throw "Repository must be clean before push: $repository"
        }
        foreach ($extension in @("json", "md")) {
            $artifact = Join-Path $repository "$AppliedRelativeRoot\$DecisionSetId.$extension"
            if (-not (Test-Path -LiteralPath $artifact -PathType Leaf)) {
                throw "Applied decision artifact is missing: $artifact"
            }
        }
    }

    $logs = @()
    foreach ($repository in @($ProjectRoot, $DtsRoot)) {
        $output = Invoke-Git -Repository $repository -Arguments @("push", "--set-upstream", "origin", $expectedBranch)
        $logs += "[$repository]`n$(($output | Out-String).Trim())"
    }
    return ($logs -join [Environment]::NewLine)
}

function ConvertFrom-RequestJson {
    param([AllowEmptyString()][string]$Body)

    if ([string]::IsNullOrWhiteSpace($Body)) { return [pscustomobject]@{} }
    try { return $Body | ConvertFrom-Json }
    catch { throw "Request body is not valid JSON: $($_.Exception.Message)" }
}

function Get-QueryValue {
    param(
        [Parameter(Mandatory)][uri]$Uri,
        [Parameter(Mandatory)][string]$Name
    )

    foreach ($pair in $Uri.Query.TrimStart('?').Split('&', [StringSplitOptions]::RemoveEmptyEntries)) {
        $parts = $pair.Split('=', 2)
        if ([Uri]::UnescapeDataString($parts[0]) -eq $Name) {
            if ($parts.Count -eq 1) { return "" }
            return [Uri]::UnescapeDataString($parts[1].Replace('+', ' '))
        }
    }
    return $null
}

function Read-HttpRequest {
    param([Parameter(Mandatory)][System.Net.Sockets.TcpClient]$Client)

    $stream = $Client.GetStream()
    $stream.ReadTimeout = 30000
    $headerBytes = New-Object 'System.Collections.Generic.List[byte]'
    $matched = 0
    $marker = [byte[]](13, 10, 13, 10)

    while ($matched -lt 4) {
        $value = $stream.ReadByte()
        if ($value -lt 0) { throw "Connection closed before request headers were complete." }
        $headerBytes.Add([byte]$value)
        if ($headerBytes.Count -gt 32768) { throw "Request headers are too large." }
        if ($value -eq $marker[$matched]) { $matched++ }
        elseif ($value -eq $marker[0]) { $matched = 1 }
        else { $matched = 0 }
    }

    $headerText = [Text.Encoding]::ASCII.GetString($headerBytes.ToArray())
    $lines = $headerText -split "`r`n"
    $requestParts = $lines[0].Split(' ')
    if ($requestParts.Count -ne 3) { throw "Invalid HTTP request line." }

    $headers = @{}
    foreach ($line in $lines[1..($lines.Count - 1)]) {
        if (-not $line) { continue }
        $separator = $line.IndexOf(':')
        if ($separator -le 0) { continue }
        $headers[$line.Substring(0, $separator).Trim().ToLowerInvariant()] = $line.Substring($separator + 1).Trim()
    }

    $contentLength = 0
    if ($headers.ContainsKey('content-length')) {
        if (-not [int]::TryParse($headers['content-length'], [ref]$contentLength) -or $contentLength -lt 0) {
            throw "Invalid Content-Length header."
        }
    }
    if ($contentLength -gt 1048576) { throw "Request body exceeds the 1 MiB limit." }

    $bodyBytes = New-Object byte[] $contentLength
    $offset = 0
    while ($offset -lt $contentLength) {
        $read = $stream.Read($bodyBytes, $offset, $contentLength - $offset)
        if ($read -le 0) { throw "Connection closed before the request body was complete." }
        $offset += $read
    }

    return [ordered]@{
        method = $requestParts[0].ToUpperInvariant()
        target = $requestParts[1]
        headers = $headers
        body = [Text.Encoding]::UTF8.GetString($bodyBytes)
    }
}

function Write-HttpResponse {
    param(
        [Parameter(Mandatory)][System.Net.Sockets.TcpClient]$Client,
        [Parameter(Mandatory)][int]$StatusCode,
        [Parameter(Mandatory)][string]$ContentType,
        [Parameter(Mandatory)][string]$Body
    )

    $reason = switch ($StatusCode) {
        200 { "OK" }
        400 { "Bad Request" }
        403 { "Forbidden" }
        404 { "Not Found" }
        405 { "Method Not Allowed" }
        500 { "Internal Server Error" }
        default { "Error" }
    }
    $bodyBytes = [Text.Encoding]::UTF8.GetBytes($Body)
    $headers = @(
        "HTTP/1.1 $StatusCode $reason",
        "Content-Type: $ContentType",
        "Content-Length: $($bodyBytes.Length)",
        "Cache-Control: no-store",
        "X-Content-Type-Options: nosniff",
        "X-Frame-Options: DENY",
        "Content-Security-Policy: default-src 'self'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'",
        "Connection: close",
        "",
        ""
    ) -join "`r`n"
    $headerBytes = [Text.Encoding]::ASCII.GetBytes($headers)
    $stream = $Client.GetStream()
    $stream.Write($headerBytes, 0, $headerBytes.Length)
    $stream.Write($bodyBytes, 0, $bodyBytes.Length)
    $stream.Flush()
}

function Write-JsonResponse {
    param(
        [Parameter(Mandatory)][System.Net.Sockets.TcpClient]$Client,
        [Parameter(Mandatory)][int]$StatusCode,
        [Parameter(Mandatory)][object]$Value
    )

    Write-HttpResponse -Client $Client -StatusCode $StatusCode -ContentType "application/json; charset=utf-8" -Body ($Value | ConvertTo-Json -Depth 30)
}

function Assert-PostToken {
    param(
        [Parameter(Mandatory)][hashtable]$Headers,
        [Parameter(Mandatory)][string]$Token
    )

    if (-not $Headers.ContainsKey('x-decision-admin-token') -or
        $Headers['x-decision-admin-token'] -cne $Token) {
        throw "Missing or invalid local request token. Refresh the admin page."
    }
}

function Invoke-ApiRequest {
    param(
        [Parameter(Mandatory)][object]$Request,
        [Parameter(Mandatory)][uri]$Uri,
        [Parameter(Mandatory)][string]$Token
    )

    if ($Request.method -eq "GET" -and $Uri.AbsolutePath -eq "/api/state") {
        $state = Get-AdminState
        $state["request_token"] = $Token
        return [ordered]@{ status = 200; body = [ordered]@{ ok = $true; data = $state } }
    }
    if ($Request.method -eq "GET" -and $Uri.AbsolutePath -eq "/api/batch") {
        $id = Get-QueryValue -Uri $Uri -Name "id"
        return [ordered]@{ status = 200; body = [ordered]@{ ok = $true; data = Read-PendingBatch -DecisionSetId $id } }
    }
    if ($Request.method -ne "POST") {
        return [ordered]@{ status = 405; body = [ordered]@{ ok = $false; error = "Method not allowed." } }
    }

    Assert-PostToken -Headers $Request.headers -Token $Token
    $payload = ConvertFrom-RequestJson -Body $Request.body

    switch ($Uri.AbsolutePath) {
        "/api/generate" {
            $id = [string](Get-RequiredPayloadProperty -Object $payload -Name "decision_set_id" -Context "Request")
            $gapIds = @(Get-RequiredPayloadProperty -Object $payload -Name "gap_ids" -Context "Request")
            $log = Invoke-DecisionTool -Action Generate -DecisionSetId $id -GapIds $gapIds
            return [ordered]@{ status = 200; body = [ordered]@{ ok = $true; log = $log; data = Read-PendingBatch -DecisionSetId $id } }
        }
        "/api/save" {
            $batch = Save-PendingBatch -Payload $payload
            return [ordered]@{ status = 200; body = [ordered]@{ ok = $true; log = "Pending JSON saved."; data = $batch } }
        }
        "/api/validate" {
            $id = [string](Get-RequiredPayloadProperty -Object $payload -Name "decision_set_id" -Context "Request")
            $log = Invoke-DecisionTool -Action Validate -DecisionSetId $id
            return [ordered]@{ status = 200; body = [ordered]@{ ok = $true; log = $log } }
        }
        "/api/apply" {
            $id = [string](Get-RequiredPayloadProperty -Object $payload -Name "decision_set_id" -Context "Request")
            $log = Invoke-DecisionTool -Action Apply -DecisionSetId $id
            return [ordered]@{ status = 200; body = [ordered]@{ ok = $true; log = $log } }
        }
        "/api/push" {
            $id = [string](Get-RequiredPayloadProperty -Object $payload -Name "decision_set_id" -Context "Request")
            $log = Push-DecisionBranch -DecisionSetId $id
            return [ordered]@{ status = 200; body = [ordered]@{ ok = $true; log = $log } }
        }
        "/api/shutdown" {
            $script:StopRequested = $true
            return [ordered]@{ status = 200; body = [ordered]@{ ok = $true; log = "Server stopped." } }
        }
        default {
            return [ordered]@{ status = 404; body = [ordered]@{ ok = $false; error = "API route not found." } }
        }
    }
}

Assert-RequiredFile -Path $UiPath
Assert-RequiredFile -Path $DecisionTool
Assert-RequiredFile -Path $RegisterPath

$tokenBytes = New-Object byte[] 32
$random = [Security.Cryptography.RandomNumberGenerator]::Create()
try { $random.GetBytes($tokenBytes) }
finally { $random.Dispose() }
$requestToken = [Convert]::ToBase64String($tokenBytes).TrimEnd('=').Replace('+', '-').Replace('/', '_')

$listener = New-Object System.Net.Sockets.TcpListener([Net.IPAddress]::Loopback, $Port)
try {
    $listener.Start()
    Write-Host "Human Decision Admin is available at $ServerUrl" -ForegroundColor Green
    Write-Host "The server accepts loopback connections only. Press Ctrl+C to stop." -ForegroundColor DarkCyan
    if (-not $NoBrowser) { Start-Process $ServerUrl }

    while (-not $script:StopRequested) {
        $client = $listener.AcceptTcpClient()
        try {
            $remoteAddress = ([Net.IPEndPoint]$client.Client.RemoteEndPoint).Address
            if (-not [Net.IPAddress]::IsLoopback($remoteAddress)) {
                Write-JsonResponse -Client $client -StatusCode 403 -Value ([ordered]@{ ok = $false; error = "Loopback access only." })
                continue
            }

            $request = Read-HttpRequest -Client $client
            if ($request.headers.ContainsKey('host')) {
                $allowedHosts = @("127.0.0.1:$Port", "localhost:$Port")
                if ($allowedHosts -notcontains $request.headers['host'].ToLowerInvariant()) {
                    throw "Invalid Host header."
                }
            }
            $uri = [uri]::new("http://127.0.0.1:$Port$($request.target)")
            if ($request.method -eq "GET" -and $uri.AbsolutePath -eq "/") {
                Write-HttpResponse -Client $client -StatusCode 200 -ContentType "text/html; charset=utf-8" -Body (Get-Content -LiteralPath $UiPath -Raw -Encoding utf8)
                continue
            }

            try {
                $result = Invoke-ApiRequest -Request $request -Uri $uri -Token $requestToken
                Write-JsonResponse -Client $client -StatusCode $result.status -Value $result.body
            }
            catch {
                Write-JsonResponse -Client $client -StatusCode 400 -Value ([ordered]@{ ok = $false; error = $_.Exception.Message })
            }
        }
        catch {
            try {
                Write-JsonResponse -Client $client -StatusCode 400 -Value ([ordered]@{ ok = $false; error = $_.Exception.Message })
            }
            catch { Write-Warning $_.Exception.Message }
        }
        finally {
            $client.Close()
        }
    }
}
finally {
    $listener.Stop()
    Write-Host "Human Decision Admin stopped." -ForegroundColor DarkCyan
}
