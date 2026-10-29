<#
Installs the DK skills into a repo. Safe to run again (repair). Works in PowerShell 7 and Windows PowerShell 5.1.

  pwsh -File <dk>\install.ps1 [-Repo <path>] [-Cursor]   install or repair (default repo: current folder)
  pwsh -File <dk>\install.ps1 [-Repo <path>] -Uninstall  remove junctions and the CLAUDE.local.md block; keeps .dk\repo
  pwsh -File <dk>\install.ps1 -All                       repair every repo in <dk>\repos.txt (run after git pull)

<dk> is the folder this script is in. Skills are read from <dk>\skills, never from a fixed path.
<dk>\repos.txt lists the repos this clone is installed in, one path per line. Install adds a line, uninstall removes it.
It is git-ignored: the paths belong to this machine.

Install does:
  1. Junction <repo>\.claude\skills\<name> -> <dk>\skills\<name> for each skill. Throws, before any change,
     if a real folder with a skill's name is already there.
  2. Copies <dk>\repo-template\* to <repo>\.dk\repo\ only for files that do not exist yet.
  3. Writes or updates the marked DK block in <repo>\CLAUDE.local.md.
  4. With git: adds exclude lines to .git\info\exclude. Without git: skips this step.
  5. With -Cursor: copies the Cursor rule, and .cursorignore when the repo has none.
#>
param(
    [string]$Repo = (Get-Location).Path,
    [switch]$Uninstall,
    [switch]$Cursor,
    [switch]$All
)

$ErrorActionPreference = 'Stop'
$dk = $PSScriptRoot
$skillsSrc = Join-Path $dk 'skills'
$registry = Join-Path $dk 'repos.txt'
$utf8 = New-Object System.Text.UTF8Encoding $false
$log = New-Object System.Collections.Generic.List[string]

function Norm([string]$p) { ([IO.Path]::GetFullPath(($p -replace '^\\\\\?\\', ''))).TrimEnd('\') }
function Say([string]$line) { $log.Add($line) }
function Read-Text([string]$p) { [IO.File]::ReadAllText($p) }
function Write-Text([string]$p, [string]$text) { [IO.File]::WriteAllText($p, $text, $utf8) }
function Get-JunctionTarget($item) {
    if (-not $item -or $item.LinkType -ne 'Junction') { return $null }
    Norm (@($item.Target)[0])
}
function Get-Registry {
    if (-not (Test-Path -LiteralPath $registry)) { return @() }
    @(Get-Content -LiteralPath $registry | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}
function Set-Registry([string[]]$paths) {
    $text = ($paths | Sort-Object -Unique) -join "`n"
    if ($text) { Write-Text $registry ($text + "`n") } elseif (Test-Path -LiteralPath $registry) { Remove-Item -LiteralPath $registry }
}

if ($All) {
    if ($Uninstall) { throw '-All repairs only. Uninstall one repo at a time with -Repo.' }
    $repos = @(Get-Registry)
    if (-not $repos.Count) { Write-Host "No repos in $registry yet. Install one with -Repo <path>."; return }
    $failed = 0
    foreach ($r in $repos) {
        if (-not (Test-Path -LiteralPath $r -PathType Container)) { Write-Host "SKIP $r (folder not found; remove the line from repos.txt if it is gone)"; continue }
        $rule = Join-Path $r '.cursor\rules\dk-mode.mdc'
        $withCursor = (Test-Path -LiteralPath $rule) -and ((Read-Text $rule) -match 'DK skills')
        try { & $PSCommandPath -Repo $r -Cursor:$withCursor }
        catch { $failed++; Write-Host "FAILED $r : $($_.Exception.Message)" }
    }
    if ($failed) { throw "$failed repo(s) failed. See the lines above." }
    return
}

if (-not (Test-Path -LiteralPath $Repo -PathType Container)) { throw "Repo folder not found: $Repo" }
$repoPath = Norm (Resolve-Path -LiteralPath $Repo).Path
if ($repoPath -ieq (Norm $dk)) { throw "Repo is the DK clone itself: $repoPath" }
if (Test-Path -LiteralPath (Join-Path $repoPath '.dk\install.ps1')) {
    throw "$repoPath has its own .dk\install.ps1 (a per-repo DK copy). Use that copy, or remove it first."
}

$skillsDst = Join-Path $repoPath '.claude\skills'
$names = @(Get-ChildItem -LiteralPath $skillsSrc -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') } | ForEach-Object { $_.Name })
$claudeLocal = Join-Path $repoPath 'CLAUDE.local.md'
$blockPattern = '(?s)\r?\n?<!-- dk:begin.*?<!-- dk:end -->\r?\n?'
$ourSkills = (Norm $skillsSrc) + '\'

function Get-OurJunctions {
    if (-not (Test-Path -LiteralPath $skillsDst)) { return @() }
    @(Get-ChildItem -LiteralPath $skillsDst -Force | Where-Object {
        $t = Get-JunctionTarget $_
        $t -and $t.StartsWith($ourSkills, [StringComparison]::OrdinalIgnoreCase)
    })
}

if ($Uninstall) {
    foreach ($j in Get-OurJunctions) { $j.Delete(); Say "removed junction .claude\skills\$($j.Name)" }
    if (Test-Path -LiteralPath $claudeLocal) {
        $text = Read-Text $claudeLocal
        $rest = [regex]::Replace($text, $blockPattern, "`n")
        if ($rest -ne $text) {
            if ($rest.Trim()) { Write-Text $claudeLocal ($rest.Trim() + "`n"); Say 'removed DK block from CLAUDE.local.md' }
            else { Remove-Item -LiteralPath $claudeLocal; Say 'removed CLAUDE.local.md (it held only the DK block)' }
        }
    }
    $rule = Join-Path $repoPath '.cursor\rules\dk-mode.mdc'
    if ((Test-Path -LiteralPath $rule) -and ((Read-Text $rule) -match 'DK skills')) { Remove-Item -LiteralPath $rule; Say 'removed .cursor\rules\dk-mode.mdc' }
    $ci = Join-Path $repoPath '.cursorignore'
    if ((Test-Path -LiteralPath $ci) -and ((Read-Text $ci) -match '^# dk skills')) { Remove-Item -LiteralPath $ci; Say 'removed .cursorignore' }
    $rest = @(Get-Registry | Where-Object { $_ -ine $repoPath })
    if ($rest.Count -ne @(Get-Registry).Count) { Set-Registry $rest; Say 'removed from repos.txt' }
    Say 'kept .dk\repo (repo-owned facts) and .dk\artifacts. Exclude lines in .git\info\exclude stay (harmless).'
    Write-Host "DK uninstall, repo $repoPath"
    $log | ForEach-Object { Write-Host "  $_" }
    return
}

foreach ($n in $names) {
    $item = Get-Item -LiteralPath (Join-Path $skillsDst $n) -Force -ErrorAction SilentlyContinue
    if ($item -and $item.LinkType -ne 'Junction') {
        throw "$($item.FullName) exists and is not a junction. A repo skill already uses the name '$n'. Nothing was changed."
    }
}

New-Item -ItemType Directory -Force -Path $skillsDst | Out-Null
foreach ($j in Get-OurJunctions) {
    if ($names -notcontains $j.Name) { $j.Delete(); Say "removed stale junction .claude\skills\$($j.Name)" }
}
$ok = 0
foreach ($n in $names) {
    $link = Join-Path $skillsDst $n
    $target = Join-Path $skillsSrc $n
    $item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
    if ($item) {
        $t = Get-JunctionTarget $item
        if ($t -ieq (Norm $target) -and (Test-Path -LiteralPath $t)) { $ok++; continue }
        $item.Delete()
        New-Item -ItemType Junction -Path $link -Target $target | Out-Null
        Say "repaired junction .claude\skills\$n (was $t)"
        continue
    }
    New-Item -ItemType Junction -Path $link -Target $target | Out-Null
    Say "junction .claude\skills\$n -> $target"
}
if ($ok) { Say "$ok junction(s) already correct" }

$tplRoot = Join-Path $dk 'repo-template'
$factsRoot = Join-Path $repoPath '.dk\repo'
foreach ($f in Get-ChildItem -LiteralPath $tplRoot -Recurse -File) {
    $rel = $f.FullName.Substring((Norm $tplRoot).Length + 1)
    $to = Join-Path $factsRoot $rel
    if (Test-Path -LiteralPath $to) { Say "kept .dk\repo\$rel"; continue }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $to) | Out-Null
    Copy-Item -LiteralPath $f.FullName -Destination $to
    Say "created .dk\repo\$rel from template"
}

$block = (Read-Text (Join-Path $dk 'local\CLAUDE.local.md')).Replace('{{DK}}', (Norm $dk)).Replace("`r`n", "`n").Trim()
if (Test-Path -LiteralPath $claudeLocal) {
    $text = Read-Text $claudeLocal
    if ([regex]::IsMatch($text, $blockPattern)) {
        $new = [regex]::Replace($text, $blockPattern, { param($m) "`n" + $block + "`n" }, 'Singleline').TrimStart("`r", "`n")
    } else {
        $new = $text.TrimEnd() + "`n`n" + $block + "`n"
    }
    if ($new -ceq $text) { Say 'CLAUDE.local.md: DK block up to date' } else { Write-Text $claudeLocal $new; Say 'CLAUDE.local.md: DK block written' }
} else {
    Write-Text $claudeLocal ($block + "`n")
    Say 'created CLAUDE.local.md with the DK block'
}

$cursorFiles = @()
if ($Cursor) {
    $ruleDir = Join-Path $repoPath '.cursor\rules'
    New-Item -ItemType Directory -Force -Path $ruleDir | Out-Null
    Copy-Item -LiteralPath (Join-Path $dk 'local\dk-mode.mdc') -Destination (Join-Path $ruleDir 'dk-mode.mdc') -Force
    $cursorFiles += '.cursor/rules/dk-mode.mdc'
    Say 'copied .cursor\rules\dk-mode.mdc'
    $ci = Join-Path $repoPath '.cursorignore'
    if (-not (Test-Path -LiteralPath $ci)) {
        Copy-Item -LiteralPath (Join-Path $dk 'local\.cursorignore') -Destination $ci
        $cursorFiles += '.cursorignore'
        Say 'copied .cursorignore'
    } elseif ((Read-Text $ci) -match '^# dk skills') { $cursorFiles += '.cursorignore' }
    else { Say 'SKIP .cursorignore: the repo already has one. Merge <dk>\local\.cursorignore by hand.' }
}

if (Test-Path -LiteralPath (Join-Path $repoPath '.git')) {
    $exclude = $null
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $p = git -C $repoPath rev-parse --git-path info/exclude 2>$null
        if ($LASTEXITCODE -eq 0 -and $p) { $exclude = if ([IO.Path]::IsPathRooted($p)) { $p } else { Join-Path $repoPath $p } }
    }
    if (-not $exclude) { $exclude = Join-Path $repoPath '.git\info\exclude' }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $exclude) | Out-Null
    $lines = @('.dk/', 'CLAUDE.local.md') + $cursorFiles + ($names | ForEach-Object { ".claude/skills/$_" })
    $current = if (Test-Path -LiteralPath $exclude) { @(Get-Content -LiteralPath $exclude) } else { @() }
    $missing = @($lines | Where-Object { $current -notcontains $_ })
    if ($missing.Count) {
        Add-Content -LiteralPath $exclude -Value (@('', '# DK skills (local only, see the DK README)') + $missing)
        Say "git exclude: added $($missing.Count) line(s)"
    } else { Say 'git exclude: up to date' }
} else {
    Say 'git: no .git folder, skipped exclude lines'
}

$known = @(Get-Registry)
if (@($known | Where-Object { $_ -ieq $repoPath }).Count) { Say 'repos.txt: listed' }
else { Set-Registry ($known + $repoPath); Say 'repos.txt: added (install.ps1 -All repairs every listed repo)' }

Write-Host "DK install, repo $repoPath, skills from $(Norm $dk)"
$log | ForEach-Object { Write-Host "  $_" }
Write-Host "  next: run /dk-init in Claude Code to fill .dk\repo, then: python `"$(Join-Path (Norm $dk) 'check.py')`" --repo `"$repoPath`""
