<#
.SYNOPSIS
    Thin wrapper around the OutSystems LifeTime Deployment API v2.

.DESCRIPTION
    Reads the LifeTime URL, environments and token variable name from the
    deployment config (see ../config.example.json). The token value is read
    from that environment variable and is never printed.
    Runs in Windows PowerShell 5.1 and in PowerShell 7 (pwsh) on macOS/Linux.

.EXAMPLE
    ./lifetime.ps1 -Action envs
    ./lifetime.ps1 -Action find-modules -Modules Order_BL,Order_API
    ./lifetime.ps1 -Action app-versions -AppKey <key>
    ./lifetime.ps1 -Action tag -AppKey <key> -Version 0.25 -Notes ORD-12
    ./lifetime.ps1 -Action plan -VersionKeys k1,k2 -Notes "ORD-12 ORD-15"
    ./lifetime.ps1 -Action plan-info -DeploymentKey <key>
    ./lifetime.ps1 -Action running
    ./lifetime.ps1 -Action start -DeploymentKey <key>
    ./lifetime.ps1 -Action status -DeploymentKey <key>
#>
param(
  [Parameter(Mandatory)][ValidateSet('envs','find-modules','app-versions','tag','plan','plan-info','running','start','status')]
  [string]$Action,
  [string[]]$Modules,
  [string]$AppKey,
  [string]$Version,
  [string[]]$VersionKeys,
  [string]$Notes,
  [string]$DeploymentKey,
  [string]$Config
)
$ErrorActionPreference = 'Stop'

# --- Config: explicit path, env var, project file, user file (first found wins)
$homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
$candidates = @($Config, $env:OUTSYSTEMS_DEPLOY_CONFIG, '.outsystems/lifetime-deploy.json',
  (Join-Path $homeDir '.outsystems-ai-skills/lifetime-deploy.json')) | Where-Object { $_ }
$cfgPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $cfgPath) { throw 'No deployment config found. Copy config.example.json to ~/.outsystems-ai-skills/lifetime-deploy.json and fill it in.' }
$cfg = (Get-Content $cfgPath -Raw -Encoding UTF8 | ConvertFrom-Json).lifetime

$Source = $cfg.sourceEnvironment
$Target = $cfg.targetEnvironment
if (@($cfg.forbiddenTargets) -contains $Target) { throw "Target '$Target' is in forbiddenTargets. Refusing." }
$BaseUrl = $cfg.url.TrimEnd('/') + '/lifetimeapi/rest/v2'

$tokenVar = if ($cfg.tokenEnvVar) { $cfg.tokenEnvVar } else { 'LIFETIME_API_TOKEN' }
$token = [Environment]::GetEnvironmentVariable($tokenVar)
if (-not $token -and $env:OS -eq 'Windows_NT') { $token = [Environment]::GetEnvironmentVariable($tokenVar, 'User') }
if (-not $token) { throw "$tokenVar is not set (LifeTime service account token)." }
$headers = @{ Authorization = "Bearer $token"; Accept = 'application/json' }

function Invoke-LT([string]$Method, [string]$Path, $Body = $null) {
  $p = @{ Method = $Method; Uri = "$BaseUrl$Path"; Headers = $headers }
  if ($null -ne $Body) { $p.Body = ($Body | ConvertTo-Json -Depth 10); $p.ContentType = 'application/json' }
  $r = Invoke-RestMethod @p
  # Windows PowerShell 5.1 returns a JSON array as one object; unroll it so pipelines see each item.
  foreach ($x in $r) { $x }
}

function Get-EnvKey([string]$Name) {
  $e = Invoke-LT GET '/environments/' | Where-Object { $_.Name -eq $Name }
  if (-not $e) { throw "Environment '$Name' not found in LifeTime." }
  $e.Key
}

switch ($Action) {
  'envs' {
    Invoke-LT GET '/environments/' | Select-Object Name, Key | Format-Table -AutoSize | Out-String
  }
  'find-modules' {
    # Module -> application comes from the module's status in the source environment.
    $envs = Invoke-LT GET '/environments/'
    $srcKey = ($envs | Where-Object Name -eq $Source).Key
    $mods = Invoke-LT GET '/modules/?IncludeEnvStatus=true'
    $apps = Invoke-LT GET '/applications/?IncludeEnvStatus=true'
    $rows = foreach ($m in $Modules) {
      $mod = $mods | Where-Object Name -eq $m | Select-Object -First 1
      $appKey = ($mod.ModuleStatusInEnv | Where-Object EnvironmentKey -eq $srcKey | Select-Object -First 1).ApplicationKey
      $app = $apps | Where-Object Key -eq $appKey | Select-Object -First 1
      if (-not $app) { [pscustomobject]@{ Module = $m; Application = '(not found)' }; continue }
      $st = @{}
      foreach ($s in $app.AppStatusInEnvs) {
        $en = ($envs | Where-Object Key -eq $s.EnvironmentKey).Name
        $st[$en] = "$($s.BaseApplicationVersionLabel)$(if ($s.IsModified) { '+' })"
      }
      [pscustomobject]@{ Module = $m; Application = $app.Name; AppKey = $app.Key; Source = $st[$Source]; Target = $st[$Target] }
    }
    $rows | ConvertTo-Json -Depth 4
  }
  'app-versions' {
    Invoke-LT GET "/applications/$AppKey/versions/" | Select-Object Version, Key, CreatedOn | ConvertTo-Json
  }
  'tag' {
    # Tags the current state of the app in the source environment; returns the new ApplicationVersionKey.
    $envKey = Get-EnvKey $Source
    Invoke-LT POST "/environments/$envKey/applications/$AppKey/versions/" @{ ChangeLog = $Notes; Version = $Version; MobileVersions = @() } | ConvertTo-Json
  }
  'plan' {
    # Creates (saves) a deployment plan. It is NOT started.
    $body = @{
      ApplicationOperations = @($VersionKeys | ForEach-Object { @{ ApplicationVersionKey = $_ } })
      Notes = $Notes
      SourceEnvironmentKey = (Get-EnvKey $Source)
      TargetEnvironmentKey = (Get-EnvKey $Target)
    }
    Invoke-LT POST '/deployments/' $body | ConvertTo-Json
  }
  'plan-info' {
    Invoke-LT GET "/deployments/$DeploymentKey/" | ConvertTo-Json -Depth 10
  }
  'running' {
    # Deployments to the target from the last 2 days that are still in progress.
    $tgtKey = Get-EnvKey $Target
    $since = (Get-Date).AddDays(-2).ToString('yyyy-MM-dd')
    $rows = foreach ($d in (Invoke-LT GET "/deployments/?MinDate=$since" | Where-Object TargetEnvironmentKey -eq $tgtKey)) {
      $st = (Invoke-LT GET "/deployments/$($d.Key)/status/").DeploymentStatus
      if ($st -in 'running', 'needs_user_intervention') { [pscustomobject]@{ Key = $d.Key; Notes = $d.Notes; CreatedOn = $d.CreatedOn; Status = $st } }
    }
    if ($rows) { $rows | ConvertTo-Json } else { 'none' }
  }
  'start' {
    $d = (Invoke-LT GET "/deployments/$DeploymentKey/").Deployment
    if ($d.TargetEnvironmentKey -ne (Get-EnvKey $Target)) { throw "Plan $DeploymentKey does not target '$Target'. Refusing." }
    # RedeployOutdated=true also republishes consumer apps left outdated by the deployment (e.g. Core apps).
    Invoke-LT POST "/deployments/$DeploymentKey/start/?RedeployOutdated=true" | Out-Null
    'started'
  }
  'status' {
    Invoke-LT GET "/deployments/$DeploymentKey/status/" | ConvertTo-Json -Depth 6
  }
}
