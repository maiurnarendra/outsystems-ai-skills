<#
.SYNOPSIS
    Installs (or updates) the OutSystems AI Skills into the local
    skills directory of Claude Code or Google Antigravity.

.PARAMETER Target
    Which agent to install for: 'claude' (default, ~/.claude/skills) or
    'antigravity' (~/.gemini/config/skills).

.PARAMETER Destination
    Install into this folder instead (e.g. a workspace's .agents\skills).

.PARAMETER Source
    Path to a local checkout of this repository to copy from, instead of
    cloning the latest version from GitHub.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -Target antigravity

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -Source . -Destination C:\work\my-app\.agents\skills
#>
[CmdletBinding()]
param(
    [ValidateSet("claude", "antigravity")]
    [string]$Target = "claude",
    [string]$Destination,
    [string]$Source
)

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/maiurnarendra/outsystems-ai-skills.git"
if ($Destination) {
    $SkillsDir = $Destination
} elseif ($Target -eq "antigravity") {
    $SkillsDir = Join-Path $env:USERPROFILE ".gemini\config\skills"
} else {
    $SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
}

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
        $TargetDir = Join-Path $SkillsDir $skill.Name
        if (Test-Path $TargetDir) {
            Remove-Item -Recurse -Force $TargetDir
        }
        Copy-Item -Recurse -Force $skill.FullName $TargetDir
        Write-Host "Installed '$($skill.Name)'"
    }

    Write-Host "Done. Skills are in $SkillsDir. Start a new agent session for them to load."
}
finally {
    if ($TmpDir -and (Test-Path $TmpDir)) {
        Remove-Item -Recurse -Force $TmpDir
    }
}
