---
name: how
description: Explain how code in this repo works before changing it. Use for "how does X work", tracing a flow or every caller of a method, code walkthroughs, and "where should this live / which layer owns this". Read-only.
---

# How

Adapted from pstack `how` (MIT, see `<dk>/NOTICE.md`).

Explore the codebase to answer "how does X work?". For "why is it built this way" (a past decision, a guard, a threshold), use the `why` skill instead. Write at the level of a senior engineer onboarding onto a subsystem: enough to build a working mental model, not annotated source code. Read-only. Never edit files.

## Step 0. Repo starting points

- Read `.dk/repo/facts.md`: Solution and projects (the layer map), Where docs live, and Feature lookup (a command or doc index, if the repo has one). Missing or `TODO`: say so, suggest `/dk-init`, and start from the code.
- Feature docs can be out of date. Confirm against code.
- A change to a method, message, or URL shape: find every caller, including other solutions, scripts, jobs, and config files (the ones facts.md lists under Solution and projects and External services). Callers outside the main solution are easy to miss.

## Step 1. Assess complexity

If the scope is ambiguous, state your reading and explore. The user can redirect.

- **Simple** (one module, one method, a narrow question): one explainer explores and explains in one pass. Go to Step 2b.
- **Complex** (a subsystem across projects or solutions, a cross-cutting flow): parallel explorers, then one explainer. Go to Step 2a.

When in doubt, take the simple path.

## Step 2a. Explore (complex only)

Split the question into 2 to 4 angles, each a distinct slice (for example: the entry point, the callers, the config and deployment, the tests). Spawn all explorers in one message with `subagent_type: "Explore"`, `model: "sonnet"`, `run_in_background: true`. Cap each at about 25 tool calls; ask for file paths and line numbers, not pasted code. Each gets `references/explorer-prompt.md` with its angle filled in. Then go to Step 3.

## Step 2b. Direct explain (simple only)

Spawn one `Explore` subagent (`model: "sonnet"`) with `references/explainer-prompt.md`, without the explorer-findings section. For a very small question, do it yourself instead. Go to Step 4.

## Step 3. Synthesize (complex only)

Spawn one `Explore` subagent (`model: "opus"`) with `references/explainer-prompt.md` and every explorer's findings filled in.

## Step 4. Present

Present the explainer's output. Light edits for clarity are fine. Do not rewrite it. Keep the "Open questions" visible.

## Output format

Sections from `references/explainer-prompt.md`, dropping any that do not apply: Overview, Key Concepts, How It Works, Where Things Live, Gotchas.
