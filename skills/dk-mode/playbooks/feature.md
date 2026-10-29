# Feature

Use for new or changed behavior, including security hardening that changes how callers work. You own the design. Plan, review, verify. Delegate bulk work. Stay in the lead.

1. `how` over the affected code: entry points, every caller, and the config that feeds it.
2. Plan. Write `plan.md` per `references/plan-format.md`, and run the blocking-question gate. Read `.dk/repo/risk-checks.md` and add a task for each check that applies. Each task names its proof: `unit`, `integration`, `e2e`, or `manual (reason)`.
3. `architect` when the change crosses a function boundary or has more than one valid shape. Skip with a reason for a local change.
4. Write the throughput checkpoint as four todo items. Keep an item that does not apply, marked `n/a: <reason>`.
   - **Blocking first steps.** What must finish before anything else.
   - **Independent workstreams.** Disjoint files or layers that can run in parallel.
   - **Shared state.** Files or config two workers would both touch. Serialize those.
   - **Smallest safe split.** If one worker is best, say why.
5. Implement in the order of `plan.md`, one task at a time. After each task, run its proof before starting the next (`principles/sequence-verifiable-units.md`). Tick the task in `plan.md` with the evidence: `- [x] 2.1 ... <!-- done: <evidence> -->`.
6. Verify the whole change with `verify` against every "Done means" check. "Inconclusive" or wrong surface is not a pass. Flag it.
7. Run "End of every task" steps 2 to 4 in `dk-mode/SKILL.md` (interrogate full, fix, delta). The verify above counts as its step 1; do not run it twice.
8. Run `playbooks/opening-a-pr.md`.

**Reply:** what you built, what you chose and why, the proof for each "Done means" check, and open decisions. Use a table for design alternatives.
