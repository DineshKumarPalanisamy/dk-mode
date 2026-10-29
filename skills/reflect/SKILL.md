---
name: reflect
description: Learn from finished work in this repo. Reads one or more past Claude Code sessions (by session id or task id), finds mistakes, user corrections, slow steps, and facts that were found the hard way, and proposes concrete edits to the repo facts in .dk/repo/, the shared DK skills, a preflight check, or memory. Use for "reflect", "what went wrong in X", "learn from this session", "improve the skills from this task", or after a PR is open.
---

# Reflect

Adapted from pstack `reflect` (MIT, see `<dk>/NOTICE.md`).

Three reviewers on different models read the same session timeline, each with a different lens. A synthesizer turns their findings into a short list of edits. The user approves the list row by row. Only then do you edit. The deliverable is better skills and better repo facts, not a report.

Two homes for a fix. Know which one before you propose it:

- **Repo facts**: `.dk/repo/*.md` and `.dk/repo/scripts/`. Owned by this repo. A fact true only here (a port, a command, a trap in this codebase) goes here.
- **Shared skills**: `<dk>/skills/` (the folder the `.claude/skills/<name>` junctions point to). Every repo uses them. Only a rule that holds in any repo goes here, written without this repo's names. Say "shared skill, affects every repo" in the row.

## Step 1. Pick the sessions

- A task id: `python .claude/skills/reflect/scripts/digest.py find <id>`. It lists sessions of this repo that worked on it, newest first. Use all of them for that task, unless the user names one.
- A session id, or no argument: the given session, or the current one.
- Only this repo's folder in `~/.claude/projects/`. Never read other projects' transcripts.

## Step 2. Digest

`python .claude/skills/reflect/scripts/digest.py digest <session-id> [<session-id> ...]` writes `.dk/artifacts/reflect/<first-8>/digest.md`: user messages, waits for the user, tool calls, errors, and slow commands, with time stamps. It masks secret-shaped values. Run it from the repo root (or pass `--repo <path>`). Reviewers read the digest; they open the raw `.jsonl` only to check one specific moment.

Skip the run if the session is trivial: no user correction, no error, no wait over 5 minutes, no step over 5 minutes. Say so in one line.

## Step 3. Reviewers

Spawn in one message, each `subagent_type: "general-purpose"`, `run_in_background: true`, read-only by instruction. Each gets `references/reviewer-prompt.md` with the digest path and its lens filled in.

| Lens | Model | Looks for |
|---|---|---|
| Judgment | `opus` | Mistakes, user corrections, wrong decisions, rules the agent skipped. The general rule behind each. |
| Tooling | `sonnet` | Commands, paths, flags, and build or test facts found by trial and error. Context the user typed in that a tool could have fetched. |
| Divergent | `fable` | What did not happen but should have: skipped checks, missed callers, a lucky pass, a skill that should have fired. |

## Step 4. Synthesize

One `general-purpose` subagent, `model: "opus"`, with `references/synthesizer.md` and the three reviewer outputs pasted in. It returns Accepted, Rejected, and Backlog.

Then check the Accepted list yourself:
- Open each target file and confirm the problem is real and not already covered.
- If `.dk/repo/facts.md` (Where docs live) names a lessons file the team keeps, search it for the same problem. If it is already a lesson there, the lesson did not stop it, so the fix must be a skill edit, a facts edit, or a preflight check, not another lesson.
- A rule a script can check goes to the repo preflight (`.dk/repo/scripts/`) or `<dk>/check.py`, not to more text (`dk-mode/principles/encode-lessons-in-structure.md`).
- A user preference about style or reply shape goes to memory, not to a skill.
- A row that edits a shared skill must not name this repo's products, hosts, ports, or ids. Move such detail to `.dk/repo/`.

## Step 5. Ask, then apply

Show the Accepted table and ask which rows to apply. This is the only stop. Do not edit before the answer.

For each approved row:
- Small edit (one bullet, one sentence, a wrong fact): edit the file directly.
- A preflight check: add one check to the repo preflight, then run it once to prove it prints.
- A description change: edit the `description:` line; keep trigger words first.
- A new section over about 10 lines: draft it, show it, then apply.
- Memory: write or update the memory file and its line in `MEMORY.md`.

Backlog rows: shared-skill items go to `<dk>/backlog.md`, repo items to `.dk/repo/backlog.md`. One line each, with the date. Never to the tracker.

Then run `python <dk>/check.py --repo .`. It must print `ok`. A shared-skill edit is a change in the DK clone: tell the user to commit and push it there.

## Output

- Applied: file and one line on what changed, per row.
- Backlog: one line per item.
- Rejected: one line per item with the reason.
