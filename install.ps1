<#
.SYNOPSIS
  Install the Agent Squad skills into Claude Code, Codex and Antigravity.

.DESCRIPTION
  Every agent becomes a slash command (/arjun, /ben, /sara, ... and /squad for group mode).
    Claude Code : ~/.claude/skills/<name>/          + ~/.claude/agents/squad-<name>.md (sub-agents for parallel group mode)
    Codex       : ~/.codex/skills/<name>/           + ~/.codex/prompts/<name>.md       (/name prompt)
    Antigravity : ~/.gemini/config/skills/<name>/   (skills are native slash commands)
  With -Scope Project, skills go into the repo instead (.claude/skills, .agents/skills).

  Safe and re-runnable: installed folders carry a .agent-squad marker; the installer only overwrites
  or removes things it created, and refuses to clobber a same-named skill you made yourself (-Force overrides).
  (ASCII-only on purpose: Windows PowerShell 5.1 reads .ps1 files as ANSI.)

.EXAMPLE
  ./install.ps1                              # every agent detected on this machine, all skills
.EXAMPLE
  ./install.ps1 -Claude -Codex               # only these hosts
.EXAMPLE
  ./install.ps1 -Agents arjun,sara       # only these skills (+ squad)
.EXAMPLE
  ./install.ps1 -Scope Project -ProjectDir C:\code\myapp
.EXAMPLE
  ./install.ps1 -Uninstall                   # remove everything this installer created
.EXAMPLE
  ./install.ps1 -List                        # show the roster
#>
[CmdletBinding()]
param(
  [switch]$Claude,
  [switch]$Codex,
  [switch]$Antigravity,
  [switch]$All,
  [string[]]$Agents,
  [ValidateSet('User', 'Project')][string]$Scope = 'User',
  [string]$ProjectDir = (Get-Location).Path,
  [switch]$Uninstall,
  [switch]$List,
  [switch]$DryRun,
  [switch]$Force,
  [string]$HomeDir = $HOME
)

$ErrorActionPreference = 'Stop'
$Src       = $PSScriptRoot
$SkillsSrc = Join-Path $Src 'skills'
$Marker    = '.agent-squad'
$FileTag   = '<!-- agent-squad:managed -->'
$Utf8      = New-Object System.Text.UTF8Encoding $false

$registryPath = Join-Path $Src 'squad.json'
if (-not (Test-Path $registryPath)) { throw "squad.json not found next to the installer ($Src)." }
$registry = Get-Content $registryPath -Raw | ConvertFrom-Json
$version  = $registry.version

# ---------------------------------------------------------------- roster
if ($List) {
  Write-Host "Agent Squad v$version" -ForegroundColor Cyan
  foreach ($a in $registry.agents) { Write-Host ('  /{0,-9} {1,-24} {2}' -f $a.name, $a.title, $a.domain) }
  $o = $registry.orchestrator
  Write-Host ('  /{0,-9} {1,-24} {2}' -f $o.name, $o.title, $o.domain) -ForegroundColor Yellow
  Write-Host ''
  Write-Host 'Workflows (/squad <workflow> <task>):' -ForegroundColor Cyan
  foreach ($p in $registry.workflows.PSObject.Properties) {
    $stages = ($p.Value | ForEach-Object { ($_ -join ' + ') }) -join ' > '
    Write-Host ('  {0,-8} {1}' -f $p.Name, $stages)
  }
  return
}

$allNames = @($registry.agents | ForEach-Object { $_.name })
if ($Agents) {
  $Agents = @($Agents | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ })
  $unknown = @($Agents | Where-Object { $allNames -notcontains $_ -and $_ -ne 'squad' })
  if ($unknown.Count) { throw ("Unknown agent(s): {0}. Valid: {1}" -f ($unknown -join ', '), ($allNames -join ', ')) }
  $selected = @($Agents | Where-Object { $_ -ne 'squad' })
} else {
  $selected = $allNames
}
$selected += 'squad'   # the orchestrator always ships; it degrades gracefully if agents are missing

foreach ($n in $selected) {
  if (-not (Test-Path (Join-Path $SkillsSrc "$n/SKILL.md"))) { throw "Missing source skill: skills/$n/SKILL.md" }
}

# ---------------------------------------------------------------- helpers
function Write-Step($msg, $color = 'Gray') { Write-Host "  $msg" -ForegroundColor $color }

function Write-Text($path, $text) {
  if ($DryRun) { Write-Step "[dry-run] write $path" DarkGray; return }
  New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
  [System.IO.File]::WriteAllText($path, $text, $Utf8)
}

function Get-SkillParts($name) {
  $raw = [System.IO.File]::ReadAllText((Join-Path $SkillsSrc "$name/SKILL.md"))
  $m = [regex]::Match($raw, '(?s)^---\r?\n(.*?)\r?\n---\r?\n(.*)$')
  if (-not $m.Success) { throw "skills/$name/SKILL.md has no YAML frontmatter." }
  $desc = [regex]::Match($m.Groups[1].Value, '(?m)^description:\s*(.+)$').Groups[1].Value.Trim()
  return @{ Description = $desc; Body = $m.Groups[2].Value }
}

function Test-Ours($path) {
  if (-not (Test-Path $path)) { return $true }
  if ((Get-Item $path).PSIsContainer) { return (Test-Path (Join-Path $path $Marker)) }
  return ((Get-Content $path -Raw) -match [regex]::Escape($FileTag))
}

function Copy-SkillFolder($name, $destRoot) {
  $dest = Join-Path $destRoot $name
  if (-not (Test-Ours $dest) -and -not $Force) {
    Write-Step "skip $dest (a skill with this name exists and was not installed by Agent Squad; use -Force)" Yellow
    return $null
  }
  if ($DryRun) { Write-Step "[dry-run] copy skills/$name -> $dest" DarkGray; return $dest }
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Copy-Item -Path (Join-Path $SkillsSrc "$name/*") -Destination $dest -Recurse -Force
  [System.IO.File]::WriteAllText((Join-Path $dest $Marker), "agent-squad $version`n", $Utf8)
  return $dest
}

function Write-ManagedFile($path, $text) {
  if (-not (Test-Ours $path) -and -not $Force) {
    Write-Step "skip $path (exists and was not created by Agent Squad; use -Force)" Yellow
    return
  }
  Write-Text $path $text
}

function Remove-Ours($path) {
  if (-not (Test-Path $path)) { return }
  if (-not (Test-Ours $path)) { Write-Step "keep $path (not created by Agent Squad)" Yellow; return }
  if ($DryRun) { Write-Step "[dry-run] remove $path" DarkGray; return }
  Remove-Item -Recurse -Force $path
  Write-Step "removed $path" DarkGray
}

function ConvertTo-YamlString($s) { return '"' + ($s -replace '\\', '\\' -replace '"', '\"') + '"' }

function New-ClaudeSubagent($name, $skillDir) {
  $p = Get-SkillParts $name
  $skillPath = ($skillDir -replace '\\', '/')
  return @"
---
name: squad-$name
description: $(ConvertTo-YamlString $p.Description)
---
$FileTag
You are running as a sub-agent of the Agent Squad. Your full skill folder is $skillPath
(read any references it links to). When Leo (the Squad Lead) briefs you with a stage number, you are in
group mode: follow the "Group mode" section below exactly and finish by writing your handoff file.

$($p.Body)
"@
}

function New-CodexPrompt($name, $skillDir) {
  $p = Get-SkillParts $name
  $skillPath = ($skillDir -replace '\\', '/')
  return @"
---
description: $(ConvertTo-YamlString $p.Description)
argument-hint: "<task>"
---
$FileTag
Load and follow the skill at ``$skillPath/SKILL.md`` (read it in full first; its references sit
alongside it). This slash command is a request to act as that agent now.

Task: `$ARGUMENTS
"@
}

# ---------------------------------------------------------------- targets
$detected = [ordered]@{
  Claude      = Test-Path (Join-Path $HomeDir '.claude')
  Codex       = Test-Path (Join-Path $HomeDir '.codex')
  Antigravity = Test-Path (Join-Path $HomeDir '.gemini')
}
$explicit = $Claude -or $Codex -or $Antigravity
$do = [ordered]@{
  Claude      = $All -or $Claude      -or (-not $explicit -and $detected.Claude)
  Codex       = $All -or $Codex       -or (-not $explicit -and $detected.Codex)
  Antigravity = $All -or $Antigravity -or (-not $explicit -and $detected.Antigravity)
}

if ($Scope -eq 'Project') {
  $ProjectDir = (Resolve-Path $ProjectDir).Path
  $paths = @{
    Claude      = @{ Skills = Join-Path $ProjectDir '.claude/skills'; Agents = Join-Path $ProjectDir '.claude/agents' }
    Codex       = @{ Skills = Join-Path $ProjectDir '.agents/skills'; Prompts = $null }
    Antigravity = @{ Skills = Join-Path $ProjectDir '.agents/skills' }
  }
} else {
  $paths = @{
    Claude      = @{ Skills = Join-Path $HomeDir '.claude/skills'; Agents = Join-Path $HomeDir '.claude/agents' }
    Codex       = @{ Skills = Join-Path $HomeDir '.codex/skills';  Prompts = Join-Path $HomeDir '.codex/prompts' }
    Antigravity = @{ Skills = Join-Path $HomeDir '.gemini/config/skills' }
  }
}

$action = if ($Uninstall) { 'Uninstall' } else { 'Install' }
Write-Host "== Agent Squad v$version :: $action ($Scope scope) ==" -ForegroundColor Cyan
if ($Scope -eq 'User') { Write-Host "HOME: $HomeDir" } else { Write-Host "Project: $ProjectDir" }
Write-Host ('detected -> Claude:{0}  Codex:{1}  Antigravity:{2}' -f $detected.Claude, $detected.Codex, $detected.Antigravity)
if ($DryRun) { Write-Host '(dry run - nothing will be written)' -ForegroundColor DarkYellow }

$done = @()
$sharedSkillsDone = @{}

# ---------------------------------------------------------------- uninstall
if ($Uninstall) {
  foreach ($host_ in $do.Keys) {
    if (-not $do[$host_]) { continue }
    Write-Host "[$host_]" -ForegroundColor Green
    $t = $paths[$host_]
    foreach ($n in $selected) {
      Remove-Ours (Join-Path $t.Skills $n)
      if ($host_ -eq 'Claude' -and $n -ne 'squad') { Remove-Ours (Join-Path $t.Agents "squad-$n.md") }
      if ($host_ -eq 'Codex' -and $t.Prompts) { Remove-Ours (Join-Path $t.Prompts "$n.md") }
    }
    $done += $host_
  }
  Write-Host '----------------------------------------'
  if ($done.Count) { Write-Host ('Removed from: ' + ($done -join ', ')) -ForegroundColor Cyan }
  else { Write-Host 'Nothing selected. Pass -All or -Claude/-Codex/-Antigravity.' -ForegroundColor Yellow }
  return
}

# ---------------------------------------------------------------- install
foreach ($host_ in $do.Keys) {
  if (-not $do[$host_]) { continue }
  Write-Host "[$host_]" -ForegroundColor Green
  $t = $paths[$host_]

  foreach ($n in $selected) {
    $key = "$($t.Skills)|$n"
    if ($sharedSkillsDone.ContainsKey($key)) {
      $skillDir = $sharedSkillsDone[$key]            # Codex + Antigravity share .agents/skills in project scope
    } else {
      $skillDir = Copy-SkillFolder $n $t.Skills
      if (-not $skillDir) { continue }
      $sharedSkillsDone[$key] = $skillDir
    }

    if ($host_ -eq 'Claude' -and $n -ne 'squad') {
      Write-ManagedFile (Join-Path $t.Agents "squad-$n.md") (New-ClaudeSubagent $n $skillDir)
    }
    if ($host_ -eq 'Codex' -and $t.Prompts) {
      Write-ManagedFile (Join-Path $t.Prompts "$n.md") (New-CodexPrompt $n $skillDir)
    }
  }

  $extra = switch ($host_) {
    'Claude'      { "sub-agents -> $($t.Agents)" }
    'Codex'       { if ($t.Prompts) { "prompts -> $($t.Prompts)" } else { 'skills only (project scope)' } }
    'Antigravity' { 'native skill slash commands' }
  }
  Write-Step "skills -> $($t.Skills) ; $extra"
  $done += $host_
}

Write-Host '----------------------------------------'
if (-not $done.Count) {
  Write-Host 'No agent hosts detected. Re-run with -All, or -Claude / -Codex / -Antigravity.' -ForegroundColor Yellow
  return
}
Write-Host ('Installed ' + $selected.Count + ' skills into: ' + ($done -join ', ')) -ForegroundColor Cyan
Write-Host ('Commands: ' + (($selected | ForEach-Object { "/$_" }) -join '  '))
Write-Host 'Start a NEW agent session to load them. Try:  /arjun design a URL shortener   or   /squad feature add password reset'
