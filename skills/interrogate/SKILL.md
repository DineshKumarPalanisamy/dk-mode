---
name: interrogate
description: Adversarial multi-model review of a change in this repo. Use for "interrogate", "review my branch", "review this diff", "is this safe to merge", "challenge this", "find blind spots". Several reviewers on different models check the same diff, plus the repo risk checks in .dk/repo/risk-checks.md; the lead sorts findings into act on, consider, noted, dismissed. Does not change code.
---

# Interrogate

Adapted from pstack `interrogate` (MIT, see `<dk>/NOTICE.md`).

Spawn one reviewer per model to review the same change. The signal comes from model diversity, not personas. The deliverable is a verdict. Do not apply changes.

## Modes

| Mode | When | Reviewers | Diff |
|---|---|---|---|
| **full** | First review of a diff, or a change made for a new reason (new requirement, PR comment) | A, B, C (all three) | `git diff <base>...HEAD` plus working tree (`<base>` from `.dk/repo/facts.md`, Git and PR) |
| **delta** | Only the fixes for the last report's "Act on" items | One reviewer, `sonnet` | Only the fix: `git diff <reviewed-sha>` plus working tree. Add the last report's path so it can check each "Act on" item is closed |

Delta mode is the default after a fix round. Use full again only if the fix grew past the "Act on" items or touches a file the last full review did not see. Each report records the commit it reviewed (`reviewed: <sha>`, plus `+ working tree` when relevant) so the next run can diff from it.

No git in the repo: the scope is the list of files this task changed. Write it to `.dk/artifacts/<id>/review/files.txt` with one line per file and what changed. Reviewers read those files in full. Delta mode lists only the files the fix touched, and records `reviewed: <timestamp>` instead of a sha.

## Step 1. Scope

- The user names files, a diff, or a PR: use that. For a PR, fetch its source branch and diff against its target.
- On a work branch: `git diff <base>...HEAD`, plus uncommitted changes if the user is reviewing work in progress.
- Save the diff to `.dk/artifacts/<id>/review/diff.patch` (delta mode: `delta-<n>.patch`). Reviewers read it from there. Pass the path, never the diff text.
- Scan added lines for secret values first. A real secret on an added line is critical. Never print the value; show the first 4 characters and `...`.

## Step 2. Intent

Write one paragraph: what the change must do. Take it from the work item acceptance criteria, `plan.md`, commit messages, and the code. If unsure, ask before reviewing.

## Step 3. Reviewers

Spawn in one message, each `subagent_type: "general-purpose"`, `run_in_background: true`, read-only by instruction. Delta mode spawns only B:

| Reviewer | Model | When |
|---|---|---|
| A | `opus` | full mode |
| B | `sonnet` | full and delta mode |
| C | `fable` | full mode |

Each gets `references/reviewer-prompt.md` filled with: the intent, the diff path, `references/rubric.md`, `references/code-quality-review.md`, and `.dk/repo/risk-checks.md` (pass the path). If risk-checks.md is missing, say so in the report and suggest `/dk-init`; the reviewers still apply the rubric.

Optional, in the same message: a review-time test subagent, if `.dk/repo/facts.md` (Subagents) names one. Its tests are evidence, not a verdict.

## Step 4. Synthesize

1. Parse every finding.
2. Consensus: raised by two or more models independently is the strongest signal.
3. Lone findings: still read them, weight accordingly.
4. Merge duplicates and note which models raised them.
5. Note disagreements.

## Step 5. Lead judgment

You are the lead, a practical senior engineer, not a neutral aggregator. Follow `references/lead-judgment.md`. Before keeping a finding, trace its execution path in the real code. Before dismissing a security or correctness finding, trace it too.

Buckets: **Act on** (would block a real PR), **Consider**, **Noted**, **Dismissed** (with a one-line reason).

Verdict rule: any critical finding in Act on blocks. Warnings only: approve with comments. Nits or nothing: approve. `.dk/repo/risk-checks.md` (Verdict) can make this stricter, never looser.

## Output

Write to `.dk/artifacts/<id>/review/interrogate_<YYYY-MM-DD>.md` and show it:

- Mode (full or delta) and `reviewed: <sha>`.
- Intent (the paragraph).
- Reviewers: model and number of findings each.
- Act on: each with location, which models raised it, and why it matters.
- Consider, Noted, Dismissed.
- Agreement map: where models agreed and where they split.
- Verdict: Block, Approve with comments, or Approve.
