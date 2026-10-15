<#
.SYNOPSIS
    Installs (or updates) the OutSystems AI Skills into the local
    Claude Code skills directory.

.PARAMETER Source
    Path to a local checkout of this repository to copy from, instead of
    cloning the latest version from GitHub.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -Source .
#>
[CmdletBinding()]
param(
    [string]$Source
)

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/maiurnarendra/outsystems-ai-skills.git"
$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"

$TmpDir = $null
try {
    if ($Source) {
        $RepoDir = $Source
    } else {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            throw "git is required but not found on PATH. Install git or pass -Source <path-to-checkout>."
        }
        $TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())
        New-Item -ItemType Directory -Path $TmpDir | Out-Null
        Write-Host "Cloning $RepoUrl..."
        git clone --depth 1 $RepoUrl (Join-Path $TmpDir "repo")
        $RepoDir = Join-Path $TmpDir "repo"
    }

    $SourceSkills = Join-Path $RepoDir "skills"
    if (-not (Test-Path $SourceSkills)) {
        throw "'skills' folder not found under $RepoDir"
    }

    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
    foreach ($skill in Get-ChildItem $SourceSkills -Directory) {
        $Target = Join-Path $SkillsDir $skill.Name
        if (Test-Path $Target) {
            Remove-Item -Recurse -Force $Target
        }
        Copy-Item -Recurse -Force $skill.FullName $Target
        Write-Host "Installed '$($skill.Name)'"
    }

    Write-Host "Done. Start a new Claude Code session for the skills to load."
}
finally {
    if ($TmpDir -and (Test-Path $TmpDir)) {
        Remove-Item -Recurse -Force $TmpDir
    }
}
