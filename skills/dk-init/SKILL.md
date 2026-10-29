---
name: dk-init
description: Fill or refresh this repo's DK facts (.dk/repo/facts.md, risk-checks.md, verify.md) from the code. Use for /dk-init, "set up dk for this repo", "fill the repo facts", "refresh .dk/repo", or when another DK skill reports that .dk/repo is missing or mostly TODO. Safe to run again; never overwrites a filled section without showing a diff.
---

# dk-init

Fills the per-repo facts layer that the shared DK skills read. The skills never change per repo; this repo's facts live in `.dk/repo/`. Running it twice on an unchanged repo changes nothing.

`<dk>` is the DK clone: the folder the `.claude/skills/dk-init` junction points to (`(Get-Item .claude/skills/dk-init).Target`, then its parent's parent). `CLAUDE.local.md` also names it.

## Step 1. Check the install

- Repo root: `git rev-parse --show-toplevel`, or the current folder when there is no git.
- `.claude/skills/dk-mode` is not a junction, or `.dk/repo/` is missing: tell the user to run `pwsh -File <dk>/install.ps1 -Repo <root>` and stop. The installer copies the templates; this skill does not.
- Read the three files in `.dk/repo/`. For each `##` section, note its state: **empty** (every non-blank line holds `TODO`) or **filled**.

## Step 2. Read the repo

Spawn one `Explore` subagent, `model: "sonnet"`, in the foreground (the next step needs its answer). Brief:

> Read-only. Do not edit any file. Report facts about the repo at `<root>` for each section heading of `<root>/.dk/repo/facts.md`, `risk-checks.md`, and `verify.md` (read those files first for the headings). Read: `CLAUDE.md`, `AGENTS.md`, `README*`, `docs/` index pages, solution files, project files (`*.csproj`, `Directory.Build.props`, `global.json`, `package.json`, `pyproject.toml`, `go.mod`), launch settings, `docker-compose*`, `Dockerfile`, test projects, `scripts/`, CI files (`.github/workflows/`, `azure-pipelines*`), and config files (`appsettings*.json`, `.env.example`). Never open `.env` or any secrets file; take key names from examples and code only. Never copy a secret value. For each fact give the file and line it came from. Write `TODO: <what is unknown>` where the repo does not say. Under risk checks, list the risky areas the README or code comments warn about (data isolation, slow steps, fragile parsing, secrets handling), each with the file that shows it. Return markdown grouped by file and heading, at most about 150 lines.

## Step 3. Merge into `.dk/repo/`

For each section:

- **Empty**: write the new facts. Keep the heading. End the section with `Source: <files>`.
- **Filled, and the new facts match**: leave it alone.
- **Filled, and the new facts differ**: do not write. Collect a unified diff (old section against proposed section) for the user.
- A fact the subagent marked `TODO` stays `TODO`. Never guess to remove a `TODO`.
- Keep facts short: one line each, commands in backticks, no prose a reader must parse twice. Never write a secret value.
- Check each command you write exists (the script file, the project path). A port or command that only one file states is labeled with that file.

Do not touch `features/`, `scripts/`, or `backlog.md` in `.dk/repo/` except to point at them.

## Step 4. Check and report

- Run `python <dk>/check.py --repo <root>`. Fix what it reports in `.dk/repo/` (never in the skills).
- List open `TODO` lines: `rg -n TODO .dk/repo` (or `Select-String`).
- Reply, short:
  - Sections written, per file.
  - Sections left alone.
  - Each proposed diff for a filled section, with one line on why, and the question "Apply these diffs?" (apply only the ones the user approves).
  - Open TODOs, grouped by file.
  - Ask the user to review `.dk/repo/` and correct anything wrong. The facts are only as good as this review.
