#requires -Version 5.1
<#
.SYNOPSIS
    Initializes a repository created from the LLM-friendly project template.

.DESCRIPTION
    Replaces template placeholders in the core project files and creates the
    local runtime directory used by agent/orchestrator tooling.

    Safe to run without administrator rights.

    The script is intentionally conservative:
      - it does not install dependencies,
      - it does not commit or push,
      - it does not modify files outside the repository,
      - it does not overwrite already-resolved placeholders with new values
        unless -Force is supplied.

.PARAMETER ProjectName
    Human-readable project name.

.PARAMETER Purpose
    One- or two-sentence project purpose.

.PARAMETER ProjectType
    Example: Python, Data/SQL, Web/TypeScript, Generic.

.PARAMETER PrimaryLanguage
    Example: Python 3.13, Python + SQL, TypeScript, R.

.PARAMETER ExternalSystems
    Comma-separated or short free-text description. Use "None" if not applicable.

.PARAMETER Force
    Allow replacement even when the template appears to have been initialized.

.EXAMPLE
    .\scripts\init-project.ps1

.EXAMPLE
    .\scripts\init-project.ps1 `
        -ProjectName "Options Research Database" `
        -Purpose "Research database for options and market-data analysis." `
        -ProjectType "Python / Data" `
        -PrimaryLanguage "Python 3.13 + SQL" `
        -ExternalSystems "GitHub, market-data providers"
#>

[CmdletBinding()]
param(
    [string]$ProjectName,
    [string]$Purpose,
    [string]$ProjectType,
    [string]$PrimaryLanguage,
    [string]$ExternalSystems,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-RepoRoot {
    $scriptDir = Split-Path -Parent $MyInvocation.ScriptName
    return (Resolve-Path (Join-Path $scriptDir "..")).Path
}

function Read-Value {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt,
        [string]$Default = ""
    )

    if ([string]::IsNullOrWhiteSpace($Default)) {
        do {
            $value = Read-Host $Prompt
        } until (-not [string]::IsNullOrWhiteSpace($value))
        return $value.Trim()
    }

    $value = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $Default
    }
    return $value.Trim()
}

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Replace-Placeholders {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [hashtable]$Values
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Required template file not found: $Path"
    }

    $content = [System.IO.File]::ReadAllText($Path)

    foreach ($key in $Values.Keys) {
        $token = "{{${key}}}"
        $content = $content.Replace($token, [string]$Values[$key])
    }

    Write-Utf8NoBom -Path $Path -Content $content
}

$repoRoot = Get-RepoRoot
Set-Location $repoRoot

$projectFile = Join-Path $repoRoot ".agent\PROJECT.md"
if (-not (Test-Path -LiteralPath $projectFile)) {
    throw "This does not look like the expected template repository. Missing: .agent\PROJECT.md"
}

$projectText = [System.IO.File]::ReadAllText($projectFile)
$hasPlaceholder = $projectText.Contains("{{PROJECT_NAME}}")

if (-not $hasPlaceholder -and -not $Force) {
    Write-Host ""
    Write-Host "This repository appears to have already been initialized." -ForegroundColor Yellow
    Write-Host "Use -Force only if you intentionally want to replace any remaining template placeholders."
    exit 1
}

Write-Host ""
Write-Host "LLM-Friendly Project Initializer" -ForegroundColor Cyan
Write-Host "Repository: $repoRoot"
Write-Host ""

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $defaultName = Split-Path $repoRoot -Leaf
    $ProjectName = Read-Value -Prompt "Project name" -Default $defaultName
}

if ([string]::IsNullOrWhiteSpace($Purpose)) {
    $Purpose = Read-Value -Prompt "Project purpose (1-2 sentences)"
}

if ([string]::IsNullOrWhiteSpace($ProjectType)) {
    Write-Host ""
    Write-Host "Suggested project types:"
    Write-Host "  1) Python"
    Write-Host "  2) Data / SQL"
    Write-Host "  3) Web / TypeScript"
    Write-Host "  4) Research / Analysis"
    Write-Host "  5) Generic"
    $ProjectType = Read-Value -Prompt "Project type" -Default "Generic"
}

if ([string]::IsNullOrWhiteSpace($PrimaryLanguage)) {
    $PrimaryLanguage = Read-Value -Prompt "Primary language / stack" -Default "To be defined"
}

if ([string]::IsNullOrWhiteSpace($ExternalSystems)) {
    $ExternalSystems = Read-Value -Prompt "External systems" -Default "None"
}

$createdDate = (Get-Date).ToString("yyyy-MM-dd")

$values = @{
    "PROJECT_NAME"     = $ProjectName
    "PROJECT_PURPOSE"  = $Purpose
    "PROJECT_TYPE"     = $ProjectType
    "PRIMARY_LANGUAGE" = $PrimaryLanguage
    "EXTERNAL_SYSTEMS" = $ExternalSystems
    "CREATED_DATE"     = $createdDate
}

$templateFiles = @(
    "README.md",
    ".agent\PROJECT.md",
    ".agent\DECISIONS.md"
)

foreach ($relativePath in $templateFiles) {
    $fullPath = Join-Path $repoRoot $relativePath
    Replace-Placeholders -Path $fullPath -Values $values
    Write-Host "Updated: $relativePath"
}

# Replace placeholders in any other text file that may contain them.
$additionalFiles = Get-ChildItem -Path $repoRoot -Recurse -File | Where-Object {
    $_.FullName -notmatch "[\\/]\.git[\\/]" -and
    $_.FullName -notmatch "[\\/]\.collab[\\/]" -and
    $_.Extension -in @(".md", ".txt", ".yaml", ".yml", ".json", ".toml")
}

foreach ($file in $additionalFiles) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    if ($content -match "\{\{(PROJECT_NAME|PROJECT_PURPOSE|PROJECT_TYPE|PRIMARY_LANGUAGE|EXTERNAL_SYSTEMS|CREATED_DATE)\}\}") {
        Replace-Placeholders -Path $file.FullName -Values $values
        Write-Host "Updated: $($file.FullName.Substring($repoRoot.Length + 1))"
    }
}


// Security settings are repository files and need no per-user path substitution.
// Do not auto-trust a cloned repository or modify user-level Codex/Claude settings.
$agentSecurityFiles = @(".codex\config.toml", ".claude\settings.json")
foreach ($relativePath in $agentSecurityFiles) {
    $securityFile = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $securityFile)) {
        Write-Warning ("Agent security configuration missing: " + $relativePath)
    }
}

# Create local runtime structure.
$collabDir = Join-Path $repoRoot ".collab"
$sessionsDir = Join-Path $collabDir "sessions"

New-Item -ItemType Directory -Force -Path $sessionsDir | Out-Null

$statePath = Join-Path $collabDir "state.json"
if (-not (Test-Path -LiteralPath $statePath)) {
    $state = [ordered]@{
        project_name = $ProjectName
        initialized_at = (Get-Date).ToString("o")
        current_task = $null
        phase = "idle"
        files_changed = @()
        tests = [ordered]@{
            passed = $null
            failed = $null
        }
        next_action = $null
    } | ConvertTo-Json -Depth 5

    Write-Utf8NoBom -Path $statePath -Content $state
}

$summaryPath = Join-Path $collabDir "summary.md"
if (-not (Test-Path -LiteralPath $summaryPath)) {
    $summary = @"
# Current Session Summary

## Objective

No active task.

## Completed

- Project initialized.

## Current State

Idle.

## Next Action

Define the first task.
"@
    Write-Utf8NoBom -Path $summaryPath -Content $summary
}

Write-Host ""
Write-Host "Initialization complete." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Review .agent\PROJECT.md"
Write-Host "  2. Review .agent\ARCHITECTURE.md"
Write-Host "  3. Add project-specific rules if needed"
Write-Host "  4. Start implementing under src\"
Write-Host "  5. Add tests under tests\"
Write-Host ""
Write-Host "Review docs\AGENT_SECURITY.md and verify your sandbox before coding."
Write-Host "No commit or push was performed."
