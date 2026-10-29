# DK mode

A personal skill set for Claude Code. Think of it as one toolbox shared by every workshop, plus a notebook that stays in each workshop. The toolbox is the skills in this folder. The notebook is `.dk/repo/` in each repo: facts about that repo only (commands, ports, risky areas).

The skills are a lean fork of pstack by Lauren Tan (MIT, see `NOTICE.md`). They are never edited for one repo. A repo's own facts never go into this folder.

## Skills

| Skill | Job |
|---|---|
| `dk-mode` | Router. Picks a playbook (bug fix, feature, refactoring, investigation, perf issue, opening a PR, pickup, pause), holds the hard gates and principles |
| `how` | Explain how code works before changing it |
| `why` | Find why code has its shape, from git, PRs, work items, docs, chat, and monitoring, with cited confidence levels |
| `architect` | Two competing designs, pick one, implement against it |
| `tdd` | Failing test first, when a cheap test exists |
| `verify` | Start local hosts, drive the change, capture evidence, clean up |
| `interrogate` | Review by three models (opus, sonnet, fable), then delta reviews on the fixes |
| `reflect` | Learn from past sessions; edits only after the user approves rows |
| `create-verification-skill` | Write a full verify driver for a repo into `.dk/repo/` |
| `dk-init` | Fill or refresh `.dk/repo/*.md` from the code (`/dk-init`) |

## Layout

```
<dk>\                          this clone (any folder; the examples use $HOME\.dk)
  skills\<name>\               shared skills
  repo-template\               templates for the per-repo facts
  local\                       CLAUDE.local.md block, optional Cursor rule and .cursorignore
  install.ps1                  install, repair, uninstall into a repo; -All repairs every listed repo
  repos.txt                    repos this clone is installed in (local, git-ignored)
  check.py                     lint for the skills and for one repo
<repo>\.claude\skills\<name>   junction -> <dk>\skills\<name>
<repo>\.dk\repo\*.md           repo facts, owned by the repo
<repo>\.dk\artifacts\<id>\     evidence, reviews, designs (local)
<repo>\CLAUDE.local.md         marked DK block: use /dk-mode, read .dk/repo
```

Nothing goes into `~/.claude/skills`. Claude Code gives personal skills priority over project skills of the same name, so a personal copy would hide a repo's own skills.

## Install, repair, remove

```powershell
git clone https://github.com/DineshKumarPalanisamy/dk-mode.git $HOME\.dk
pwsh -File $HOME\.dk\install.ps1 -Repo <repo>              # install or repair
pwsh -File $HOME\.dk\install.ps1 -Repo <repo> -Cursor      # also the Cursor rule
pwsh -File $HOME\.dk\install.ps1 -Repo <repo> -Uninstall   # remove junctions and the CLAUDE.local.md block
pwsh -File $HOME\.dk\install.ps1 -All                       # repair every repo in repos.txt
```

Any clone folder works. `install.ps1` finds the skills next to itself. It runs in PowerShell 7 and Windows PowerShell 5.1. Run it again at any time: it fixes broken junctions and changes nothing that is already right.

What install does:

1. A junction per skill in `<repo>\.claude\skills\`. If a real folder with a skill's name is there, it stops before any change.
2. `.dk\repo\` from `repo-template\`, only for files that do not exist yet. Your facts are never overwritten.
3. The DK block in `CLAUDE.local.md`, between `<!-- dk:begin` and `<!-- dk:end -->`. Text outside the block stays.
4. With git: lines in `.git\info\exclude` for `.dk/`, `CLAUDE.local.md`, and the junctions, so git never sees them. Without git: skipped, and it says so.
5. The repo path in `<dk>\repos.txt`, so `-All` can repair it later.

Uninstall removes the junctions, the block, and the `repos.txt` line. It keeps `.dk\repo` (repo data) and `.dk\artifacts`.

A repo that has its own `.dk\install.ps1` (a per-repo copy of DK) is refused.

## Add a repo

1. `pwsh -File $HOME\.dk\install.ps1 -Repo <repo>`
2. In Claude Code, in that repo: `/dk-init`. It reads the repo with a sonnet subagent, fills the empty sections, shows a diff for any filled section it would change, and lists open TODOs.
3. Review `.dk/repo/*.md` yourself. Fix what is wrong.
4. `python $HOME\.dk\check.py --repo <repo>` must print `ok`.

## How facts work

| File | Read by | Holds |
|---|---|---|
| `facts.md` | all skills | stack, projects, build, run, test, conventions, git and PR, external services, docs |
| `risk-checks.md` | planning, `interrogate` | risky areas: when a check applies, what to look for, the proof |
| `verify.md` | `verify` | hosts, ports, sign-in, drive, evidence, cleanup, known failures |

A skill that needs a fact reads the file. If the file or section is missing, the skill says so and suggests `/dk-init`. The code always wins over a stale fact. Optional extras in `.dk/repo/`: `features/` (verify recipes), `scripts/` (preflight and drivers), `backlog.md`.

By default `.dk/` is git-excluded, so the facts stay on your machine. A team can choose to commit `.dk/repo/` instead: remove `.dk/` from `.git\info\exclude` and add `.dk/artifacts/` and `.dk/plans/` to `.gitignore`.

## Update the skills

- `git pull` in the clone, then `install.ps1 -All`. The junctions point at the clone, so changed skills reach every repo at once. `-All` adds links for new skills and removes links for deleted ones.
- After you edit a skill: `python $HOME\.dk\check.py`. It checks file references, em dashes, control characters, SKILL.md frontmatter, non-ASCII in `.ps1` files, and, if `denylist.local.txt` exists, names that must never enter this shared repo. That file is git-ignored: one regex per line, `#` for comments.
