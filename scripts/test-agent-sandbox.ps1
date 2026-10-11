#requires -Version 5.1
<#
.SYNOPSIS
    Runs reversible positive/negative tests for the Codex repo-locked profile.
.DESCRIPTION
    Run on a Windows host with Codex >= 0.162.0 and a working MXC backend.
    Tests sandboxed shell commands, not all agent tools or external MCP servers.
    Creates uniquely named disposable probes and deletes only those probes.
    Fails closed on project-trust/config/startup or permitted-operation errors.
    A network test is optional and inconclusive unless an outside baseline works.
.EXAMPLE
    .\scripts\test-agent-sandbox.ps1
.EXAMPLE
    .\scripts\test-agent-sandbox.ps1 -TestNetwork
#>
[CmdletBinding()]
param(
    [string]$CodexCommand = "codex",
    [switch]$TestNetwork
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$profileFile = Join-Path $root ".codex\config.toml"
if (-not (Test-Path -LiteralPath $profileFile)) {
    throw "Missing project profile: $profileFile"
}
$codex = Get-Command $CodexCommand -ErrorAction Stop
$codexExe = $codex.Source
$versionOutput = & $codexExe --version
if ($versionOutput -notmatch "(\d+)\.(\d+)\.(\d+)") {
    throw "Could not determine Codex version: $versionOutput"
}
$version = [version]$Matches[0]
if ($version -lt [version]"0.162.0") {
    throw "Codex >= 0.162.0 required for this tested MXC workflow. Found: $versionOutput"
}

function Invoke-Mxc {
    param([Parameter(Mandatory=$true)][string[]]$Command)
    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        # Capture exit code BEFORE post-processing output.
        $rawOutput = & $codexExe -c "windows.sandbox=mxc" sandbox --cd $root --permission-profile repo-locked -- @Command 2>&1
        $code = $LASTEXITCODE
        return [pscustomobject]@{
            ExitCode = $code
            Output = (($rawOutput | Out-String).Trim())
        }
    } finally {
        $ErrorActionPreference = $previous
    }
}

function Assert-UsableResult {
    param(
        [Parameter(Mandatory=$true)][psobject]$Result,
        [Parameter(Mandatory=$true)][string]$TestName
    )
    if ($Result.ExitCode -ne 0) {
        Write-Host ("[FAIL] " + $TestName + " - exit=" + $Result.ExitCode) -ForegroundColor Red
        Write-Host ("Command output: " + $Result.Output)
        throw "Sandbox did not execute a permitted command. Check trust in ~/.codex/config.toml ([projects.'<full repo path>'] trust_level = 'trusted'), project profile, and MXC. Negative tests were NOT evaluated."
    }
}

function Test-ExplicitDenial {
    param([Parameter(Mandatory=$true)][psobject]$Result)
    # Do not treat a missing/invalid profile or a failed launcher as a sandbox denial.
    return ($Result.ExitCode -ne 0) -and
        ($Result.Output -match '(?i)(Zugriff verweigert|Access is denied|Permission denied|Operation not permitted|Access denied)') -and
        ($Result.Output -notmatch '(?i)(default_permissions|failed to load config|unknown permission profile|required arguments|unexpected argument)')
}

$checks = New-Object System.Collections.Generic.List[object]
function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Details)
    $checks.Add([pscustomobject]@{ Name=$Name; Passed=$Passed; Details=$Details })
    $tag = if ($Passed) { "PASS" } else { "FAIL" }
    Write-Host ("[{0}] {1} - {2}" -f $tag, $Name, $Details)
}

$id = [guid]::NewGuid().ToString("N").Substring(0,12)
$outsideDir = Join-Path $HOME ("mxc-outside-" + $id)
$siblingDir = Join-Path (Split-Path $root -Parent) ("mxc-sibling-" + $id)
$insideFile = Join-Path $root ("mxc-inside-" + $id + ".txt")
$outsideRead = Join-Path $outsideDir "read.txt"
$outsideWrite = Join-Path $outsideDir "write.txt"
$siblingRead = Join-Path $siblingDir "read.txt"

New-Item -ItemType Directory -Path $outsideDir, $siblingDir -ErrorAction Stop | Out-Null
try {
    Set-Content -LiteralPath $outsideRead -Value "MXC_OUTSIDE_SECRET" -Encoding Ascii
    Set-Content -LiteralPath $siblingRead -Value "MXC_SIBLING_SECRET" -Encoding Ascii

    Write-Host ("Repository: {0}" -f $root)
    Write-Host ("Codex: {0}" -f $versionOutput)
    Write-Host "Sandbox: MXC; permission profile: repo-locked"

    # A launch/config error can return exit=1 for ALL commands. Never count it as a denial.
    $r = Invoke-Mxc -Command @("cmd.exe", "/d", "/c", "echo MXC_PROFILE_READY")
    Assert-UsableResult -Result $r -TestName "MXC profile preflight"
    if ($r.Output -notmatch "MXC_PROFILE_READY") {
        throw "MXC preflight returned success without the expected marker: $($r.Output)"
    }
    Write-Host "[PASS] MXC profile preflight - shell command executed"

    # The first file-system check must succeed before any negative test is counted.
    $insideReadCommand = 'type "' + (Join-Path $root "AGENTS.md") + '"'
    $r = Invoke-Mxc -Command @("cmd.exe", "/d", "/c", $insideReadCommand)
    Assert-UsableResult -Result $r -TestName "Read inside repository"
    $readOk = $r.Output.Contains("# Agent Instructions")
    Add-Check "Read inside repository" $readOk ("exit=" + $r.ExitCode)
    if (-not $readOk) {
        throw "Read inside repository did not return expected content: $($r.Output)"
    }

    $insideWriteCommand = 'echo MXC_INSIDE_OK > "' + $insideFile + '"'
    $r = Invoke-Mxc -Command @("cmd.exe", "/d", "/c", $insideWriteCommand)
    Assert-UsableResult -Result $r -TestName "Write inside repository"
    $insideOk = (Test-Path -LiteralPath $insideFile) -and ((Get-Content -LiteralPath $insideFile -Raw).Trim() -eq "MXC_INSIDE_OK")
    Add-Check "Write inside repository" $insideOk ("exit=" + $r.ExitCode)
    if (-not $insideOk) {
        throw "Sandbox reported success but did not produce the expected workspace file. Command output: $($r.Output)"
    }

    $outsideReadCommand = 'type "' + $outsideRead + '"'
    $r = Invoke-Mxc -Command @("cmd.exe", "/d", "/c", $outsideReadCommand)
    Add-Check "Deny read outside repository" (Test-ExplicitDenial -Result $r) ("exit=" + $r.ExitCode + "; " + $r.Output)

    $outsideWriteCommand = 'echo MXC_BAD_WRITE > "' + $outsideWrite + '"'
    $r = Invoke-Mxc -Command @("cmd.exe", "/d", "/c", $outsideWriteCommand)
    Add-Check "Deny write outside repository" ((Test-ExplicitDenial -Result $r) -and -not (Test-Path -LiteralPath $outsideWrite)) ("exit=" + $r.ExitCode + "; " + $r.Output)

    $siblingReadCommand = 'type "' + $siblingRead + '"'
    $r = Invoke-Mxc -Command @("cmd.exe", "/d", "/c", $siblingReadCommand)
    Add-Check "Deny read in sibling directory" (Test-ExplicitDenial -Result $r) ("exit=" + $r.ExitCode + "; " + $r.Output)

    if ($TestNetwork) {
        $previous = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        try {
            & curl.exe --noproxy "*" -k -I --connect-timeout 5 --max-time 10 "https://1.1.1.1" 2>&1 | Out-Null
            $normalCode = $LASTEXITCODE
        } finally {
            $ErrorActionPreference = $previous
        }
        if ($normalCode -eq 0) {
            $r = Invoke-Mxc -Command @("curl.exe","--noproxy","*","-k","-I","--connect-timeout","5","--max-time","10","https://1.1.1.1")
            Add-Check "Network egress restriction indicated" ($r.ExitCode -ne 0 -and $r.Output -notmatch "(?i)(default_permissions|failed to load config|unknown permission profile)") ("outside=0, sandbox=" + $r.ExitCode + "; " + $r.Output)
        } else {
            Write-Host ("[SKIP] Network isolation: outside baseline failed (exit={0})" -f $normalCode)
        }
    }
} finally {
    if (Test-Path -LiteralPath $insideFile) {
        Remove-Item -LiteralPath $insideFile -Force
    }
    if (Test-Path -LiteralPath $outsideDir) {
        Remove-Item -LiteralPath $outsideDir -Recurse -Force
    }
    if (Test-Path -LiteralPath $siblingDir) {
        Remove-Item -LiteralPath $siblingDir -Recurse -Force
    }
}

$failed = @($checks | Where-Object { -not $_.Passed }).Count
Write-Host ("Result: {0} passed, {1} failed" -f ($checks.Count - $failed), $failed)
if ($failed -gt 0) { exit 1 }
exit 0
