<#
.SYNOPSIS
    Structural checks to run before every release.

.DESCRIPTION
    - plugin.json and marketplace.json parse and carry the same version
    - every skills/<folder>/SKILL.md has frontmatter whose name equals the folder name
    - every description is non-empty and at most 1024 characters (Kiro's limit)
    - every skill is mentioned in AGENTS.md and README.md
    - every eval scenario references an existing skill

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\validate.ps1
#>
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Errors = @()

function Read-Json($path) { Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json }

# Manifests
$plugin = Read-Json (Join-Path $Root ".claude-plugin\plugin.json")
$market = Read-Json (Join-Path $Root ".claude-plugin\marketplace.json")
$marketVersion = ($market.plugins | Where-Object { $_.name -eq $plugin.name }).version
if ($plugin.version -ne $marketVersion) {
    $Errors += "Version mismatch: plugin.json $($plugin.version) vs marketplace.json $marketVersion"
}
$changelog = Get-Content (Join-Path $Root "CHANGELOG.md") -Raw -Encoding UTF8
if ($changelog -notmatch [regex]::Escape("[$($plugin.version)]")) {
    $Errors += "CHANGELOG.md has no entry for version $($plugin.version)"
}

# Skills
$agents = Get-Content (Join-Path $Root "AGENTS.md") -Raw -Encoding UTF8
$readme = Get-Content (Join-Path $Root "README.md") -Raw -Encoding UTF8
$skillNames = @()
foreach ($dir in Get-ChildItem (Join-Path $Root "skills") -Directory) {
    $file = Join-Path $dir.FullName "SKILL.md"
    if (-not (Test-Path $file)) { $Errors += "$($dir.Name): SKILL.md missing"; continue }
    $text = Get-Content $file -Raw -Encoding UTF8
    if ($text -notmatch '(?s)^---\r?\n(.*?)\r?\n---') { $Errors += "$($dir.Name): no frontmatter"; continue }
    $front = $Matches[1]
    $name = if ($front -match '(?m)^name:\s*(.+)$') { $Matches[1].Trim() } else { "" }
    $desc = if ($front -match '(?m)^description:\s*(.+)$') { $Matches[1].Trim() } else { "" }
    if ($name -ne $dir.Name) { $Errors += "$($dir.Name): frontmatter name '$name' does not match folder" }
    if (-not $desc) { $Errors += "$($dir.Name): description missing" }
    elseif ($desc.Length -gt 1024) { $Errors += "$($dir.Name): description is $($desc.Length) chars (max 1024)" }
    if ($agents -notmatch [regex]::Escape($dir.Name)) { $Errors += "$($dir.Name): not referenced in AGENTS.md" }
    if ($readme -notmatch [regex]::Escape($dir.Name)) { $Errors += "$($dir.Name): not referenced in README.md" }
    $skillNames += $dir.Name
    Write-Host ("OK  {0,-32} description {1,4} chars" -f $dir.Name, $desc.Length)
}

# Evals
$evals = Read-Json (Join-Path $Root "evals\scenarios.json")
foreach ($s in $evals.scenarios) {
    if ($skillNames -notcontains $s.skill) { $Errors += "eval '$($s.id)': unknown skill '$($s.skill)'" }
    if (-not $s.expectations -or $s.expectations.Count -eq 0) { $Errors += "eval '$($s.id)': no expectations" }
}
Write-Host "Eval scenarios: $($evals.scenarios.Count)"

if ($Errors.Count) {
    Write-Host ""
    $Errors | ForEach-Object { Write-Host "ERROR $_" -ForegroundColor Red }
    exit 1
}
Write-Host "All checks passed (version $($plugin.version))." -ForegroundColor Green
