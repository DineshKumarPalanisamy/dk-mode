# Plan format

Path: the plan folder named in `.dk/repo/facts.md` (Where docs live), as `<plan folder>/<id>-<kebab-title>/plan.md`. If facts.md names none, use `.dk/plans/<id>-<kebab-title>/plan.md` (local, not committed). If the folder already has a plan, read it and update it. Do not overwrite it without asking.

## Blocking-question gate

Before writing tasks, list every open question and split them.

- **Blocking**: the answer changes the shape of more than one task. When unsure, treat as blocking for: data scope or tenancy, security or secrets, external or message contracts, a stored format or migration, a missing entity, an integration with no precedent, and every topic in `.dk/repo/risk-checks.md` (Blocking topics).
- **Non-blocking**: a local choice. Pick a default, tag the task `(deferred: <topic>)`, and list it under Deferred unknowns.

First check whether you can answer a question yourself by reading code or running something. Only questions no experiment can settle go to the human.

Ask all blocking questions in one turn, then stop. Outcomes:

- Answered: record as D1, D2, ... in Decisions.
- The human defers it: put it in group 1; tasks that wait on it get `(blocked: 1.x / OQ-n)`.
- "Just plan it": continue on assumptions, each listed under Assumptions.
- No blockers: say so in one line and continue.

## File shape

```markdown
---
plan: <id>-<kebab-title>
source: <tracker> <id>
status: planning | ready | blocked
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
next: 2.1
---

# <id>: <title>

<2 to 4 lines: the problem, the fix in one sentence, links to the work item.>

Requirements: R1 ..., R2 ... (one per acceptance criterion).

Done means:
- <check 1, runnable>
- <check 2>

## 1. Blocking questions
- [ ] 1.1 <question> (OQ-1)

## 2. <first slice, an end-to-end tracer>
- [ ] 2.1 <one-line task> (R1) [proof: unit]

## N. Verification
- [ ] N.1 <the real command and the expected result> [proof: integration]

## Decisions
| # | Question | Answer | Date | Reason |

## Deferred unknowns
## Assumptions
## Out of scope
```

## Rules

- Group 1 holds deferred blockers only. Delete it if empty. The first work slice is group 2.
- Every task traces to a requirement `(R1)` and names its proof: `[proof: unit | integration | e2e | manual (reason)]`.
- A task touches at most about 8 files and adds at most 2 new abstractions.
- Order slices so each one can be checked on its own. Put the failing test before the fix.
- Add a task for each check in `.dk/repo/risk-checks.md` that applies.
- The last group is Verification, with real commands.
- Mark done tasks with evidence: `- [x] 2.1 ... <!-- done: <evidence> -->`. The first unchecked task is where work resumes.
