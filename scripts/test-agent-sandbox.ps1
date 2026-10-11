#requires -Version 5.1
<#
.SYNOPSIS
    Runs reversible positive/negative tests for the Codex repo-locked profile.
.DESCRIPTION
    Run on a Windows host with Codex >= 0.162.0 and a working MXC backend.
    Tests sandboxed shell commands, not all agent tools or external MCP servers.
    Creates uniquely named disposable probes and deletes only those probes.
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
        $output = & $codexExe -c "windows.sandbox=mxc" sandbox --cd $root --permission-profile repo-locked -- @Command 2>&1 | Out-String
        return [pscustomobject]@{
            ExitCode = $LASTEXITCODE
            Output = [string]$output
        }
    } finally {
        $ErrorActionPreference = $previous
    }
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

    $r = Invoke-Mxc -Command @("cmd.exe","/d","/c",'type "' + (Join-Path $root "AGENTS.md") + '"')
    Add-Check "Read inside repository" ($r.ExitCode -eq 0 -and $r.Output.Contains("# Agent Instructions")) ("exit=" + $r.ExitCode)

    $r = Invoke-Mxc -Command @("cmd.exe","/d","/c",'echo MXC_INSIDE_OK > "' + $insideFile + '"')
    $insideOk = (Test-Path -LiteralPath $insideFile) -and ((Get-Content -LiteralPath $insideFile -Raw).Trim() -eq "MXC_INSIDE_OK")
    Add-Check "Write inside repository" ($r.ExitCode -eq 0 -and $insideOk) ("exit=" + $r.ExitCode)

    $r = Invoke-Mxc -Command @("cmd.exe","/d","/c",'type "' + $outsideRead + '"')
    Add-Check "Deny read outside repository" ($r.ExitCode -ne 0 -and -not $r.Output.Contains("MXC_OUTSIDE_SECRET")) ("exit=" + $r.ExitCode)

    $r = Invoke-Mxc -Command @("cmd.exe","/d","/c",'echo MXC_BAD_WRITE > "' + $outsideWrite + '"')
    Add-Check "Deny write outside repository" ($r.ExitCode -ne 0 -and -not (Test-Path -LiteralPath $outsideWrite)) ("exit=" + $r.ExitCode)

    $r = Invoke-Mxc -Command @("cmd.exe","/d","/c",'type "' + $siblingRead + '"')
    Add-Check "Deny read in sibling directory" ($r.ExitCode -ne 0 -and -not $r.Output.Contains("MXC_SIBLING_SECRET")) ("exit=" + $r.ExitCode)

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
            Add-Check "Deny outgoing network from sandboxed command" ($r.ExitCode -ne 0) ("outside=0, sandbox=" + $r.ExitCode)
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
