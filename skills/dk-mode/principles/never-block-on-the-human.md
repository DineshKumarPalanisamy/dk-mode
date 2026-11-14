# Never Block on the Human

The human supervises asynchronously. Execution must stay unblocked. Decisions about the task belong to the human.

**Why:** Every permission pause stalls the pipeline. But a wrong guess about what the task should do costs more than one question.

**Pattern:**
- **Proceed, then present, for execution only.** How to build, run, and check things: do it and show the result. What the task does: ask (`dk-mode` SKILL.md step 9).
- **Make the system self-healing.** When you notice a problem, log it and fix it in the next round.
- How and when to ask: `dk-mode` SKILL.md "Start of every task" steps 5 to 9. Repeated blockers: `encode-lessons-in-structure.md`.

**Failure mode this prevents:** in one real story there were about 15 separate stops: a URL ACL, secrets, an IDE sign-in, a host window, a feature flag, an IP allow list, and a "go ahead?" after every step. One preflight plus one start message would have been two stops.

**Boundaries:** irreversible or outward actions follow the "Hard gates" list in `dk-mode/SKILL.md`.
