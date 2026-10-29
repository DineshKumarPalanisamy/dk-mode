# Session pickup

Adapted from pstack `session-pickup` (MIT, see `<dk>/NOTICE.md`).

You own the resume point. Read what the last session left. Do not redo it.

1. Read the resume files, in this order. Stop reading when you know where work stopped.
   - `resume.md` in the plan folder (written by `playbooks/pause-safely.md`; folder from `references/plan-format.md`).
   - `plan.md` in the same folder: its `next:` field and the last `- [x]` task with its `<!-- done: ... -->` evidence.
   - `.dk/artifacts/<id>/verify/` and `.dk/artifacts/<id>/review/`: the newest preflight, verify evidence, and interrogate report.
   - `git log --oneline <base>..HEAD` and `git status --short` (skip both when the repo has no git).
2. Only if those do not answer it: find the last transcript in `~/.claude/projects/<repo-slug>/*.jsonl` that names the id (`python .claude/skills/reflect/scripts/digest.py find <id>`). Parse it in a `sonnet` subagent and keep only a short timeline. Never read other project folders.
3. Write down: what is done (with its evidence), what is pending, and the first next step. A claim from the last session is a lead, not proof. Recheck only the claims the remaining work depends on.
4. Check what is still running: hosts by the PIDs in `.dk/artifacts/<id>/verify/*.pid`, ports from `.dk/repo/verify.md`. Reuse a healthy host. Do not restart it.
5. Go back to the matched playbook at the resume step. Do not re-run intake, the repro, or a passing build when no code changed since.

**Reply:** where the last session stopped, what you reused and what you redid (ideally nothing), and the next step.
