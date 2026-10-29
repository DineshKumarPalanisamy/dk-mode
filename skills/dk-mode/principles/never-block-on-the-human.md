# Never Block on the Human

The human supervises asynchronously. Agents must stay unblocked. Make reasonable decisions, proceed, and let the human course-correct after the fact.

**Why:** Every permission pause stalls the pipeline and makes the human the bottleneck. Since code changes are reversible and reviewable, a wrong decision usually costs less than blocking.

**Pattern:**
- **Proceed, then present.** Do the work, show the result. Don't ask "should I do X?" Do X, explain why.
- **Make the system self-healing.** When you notice a problem, log it and fix it in the next round.
- **Ask once, up front, in a batch.** Everything only the human can do (admin commands, sign-ins, secrets, approvals for commit, push, PR) goes into one message at the start of the task, after a preflight has found every blocker. Then run to the end.
- **Never ask "shall I continue?" between steps.** The playbook already says what comes next. Report progress and keep going.
- **Never ask what you can look up.** Code, data, and the repo docs (`.dk/repo/facts.md`, Where docs live) answer "how does this work" and "where is this screen". The human answers only choices and grants.
- **A repeated blocker becomes a check.** If a run stopped on something a script could have detected, add it to the repo's preflight before closing the task.

**Failure mode this prevents:** in one real story there were about 15 separate stops: a URL ACL, secrets, an IDE sign-in, a host window, a feature flag, an IP allow list, and a "go ahead?" after every step. One preflight plus one start message would have been two stops.

**Boundaries:**
- **Irreversible or outward actions** still require confirmation, given once in the start message where possible. That is the full "Hard gates" list in `dk-mode/SKILL.md`: commit, push, PR, any tracker write, shared or production data, secrets.
- **Reversible actions** (write code, edit notes, split tasks) should proceed without blocking.
- **Product direction** comes from the human. *Execution* should not block.
