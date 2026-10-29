---
name: why
description: Find out why code in this repo has its shape. Use for "why does X work this way", "why did we pick Y", "why is this guard / retry / flag / threshold here", regressions, postmortems, and before removing code whose reason is unknown. Searches git history, PRs, work items, docs, chat, and monitoring in parallel, then returns a cited answer that keeps known, inferred, and unknown apart. Read-only. For what code does at runtime, use how.
---

# Why

Adapted from pstack `why` (MIT, see `<dk>/NOTICE.md`).

`how` answers what the code does. `why` answers what forces gave it this shape. Code shows what it does, not why it exists. The reason lives in commits, PRs, work items, docs, and chat, and those records are incomplete. Work like a careful investigator: say what is known, what is inferred, and what is missing. Read `references/epistemics.md` once per task; the synthesizer must follow it.

Read-only. Never edit files, comment on a PR, or change a work item.

## Step 0. Repo starting points

Read `.dk/repo/facts.md`: Git and PR (the PR tool and the work item tracker), External services (monitoring and error tracking), Where docs live. Missing or `TODO`: say so in one line, suggest `/dk-init`, and use git alone plus whatever MCP tools this session has.

## Step 1. Target and question

The target is a piece of code, a pattern, a feature, or a named decision. The question is a rationale, a tradeoff, an edge case, an outside constraint, dead code, or a history sweep. If the target is vague, guess from the conversation (open files, recent edits, what was just discussed), state your reading in one line, and go on.

If the user's question holds a guess ("I assume it is for performance?"), treat it as one candidate to test, not an answer to confirm.

## Step 2. Code anchor

Build the seed yourself before you spawn anyone:

- File paths with line ranges, and the key symbols.
- `git blame -L <start>,<end> <file>` for the last commit per line.
- `git log --follow --oneline -20 -- <file>`, and `git log -S '<exact text>' -- <file>` for when a value or guard first appeared.
- PR numbers and work item ids from commit messages (`git log -1 --format=%B <hash>`).
- PR descriptions and review threads for the commits that matter, through the PR tool from facts.md.

Every investigator and the synthesizer get this anchor.

## Step 3. Parallel investigators

Default to the full search. The goal is a coverage map; an empty search is a finding.

List the MCP tools this session has (loaded and deferred) and map each to one category in `references/sources.md`. Source control is always present (git plus the PR tool). Spawn one investigator per category that has a tool, all in one message, each owning one source. Never give one investigator two sources.

Each Agent call: `subagent_type: "general-purpose"` (MCP tools must stay available), `model: "sonnet"`, `run_in_background: true`. The prompt is `references/investigator-prompt.md` filled in, plus that category's section of `references/sources.md`, plus the code anchor and the user's question. If the target looks defensive (null checks, retries, timeouts, rate limits, feature flags, size limits), also add the "Incident context" section.

Skip a category only with a written reason that goes into Sources consulted:

- No tool for it in this session. That is a gap, not a choice: "Team chat: not searched, no chat MCP in this session."
- Provably irrelevant, a high bar: "Error tracking: not searched, the target is a build script with no runtime path."

A single-commit target whose PR body already answers the question fully may be answered inline. Say that you checked and why the other searches would add nothing.

## Step 4. Synthesize

Spawn one synthesizer: `subagent_type: "general-purpose"`, `model: "opus"`. It gets every investigator's findings (nulls included), the skipped categories with reasons, the code anchor, the question, `references/epistemics.md`, and `references/synthesizer-prompt.md`.

## Step 5. Present

Show the synthesizer's output. Light edits for clarity are fine. Do not change its confidence words.

If the question comes before a change to this code, end with a short constraint list for planning: Preserve, Change, Avoid, Risk.

## Output format

From `references/synthesizer-prompt.md`: The question, The code, What we found, What we can infer, Competing hypotheses, What we don't know, Sources consulted, Confidence. Drop a section only when it is empty, except "What we don't know" and "Sources consulted", which always stay. Follow the user's reply style (CLAUDE.md) for length.

## Common mistakes

- **Recency bias.** The latest commit is often a small edit on top of an older decision. Trace back to where the shape first appeared.
- **Code as its own proof.** "The code retries 3 times, so the author wanted 3 retries" is mechanics, not motivation.
- **A tidy story.** Two sources that disagree both go in the output.
