# Bug fix

You own this task. Plan, review, verify. Delegate reading and bulk work to subagents. Stay in the lead.

Be scientific. Every shipped line traces to runtime evidence. A change that "might help" is a hypothesis, not a fix, and it does not ship. When evidence refutes a hypothesis, revert what it motivated. Ship the smallest change the evidence justifies.

1. Reproduce it yourself on the surface where it fails, using the `verify` skill. If the local app cannot reach the failing state, synthesize the trigger (a test, a local fake endpoint, seeded local data). Ask the user only with a specific reason the local surface cannot reach it. A unit test is not the repro. If the surface cannot be reached yet, mark the step `skip: <reason>`, not done.
2. Find the cause by elimination. Seed hypotheses with `how` over the affected code and `git log -L` / `git log -S` for regression history. For each pass, take the test that rules out the most, get runtime evidence, and eliminate. Add logging and read it when state is unclear. Do not guess. Confirm the surviving mechanism with evidence before step 3. Two fixes on the same belief failed: stop and run `principles/attack-the-premise.md` before a third.
3. Plan the fix. Write `plan.md` per `references/plan-format.md`. Run the blocking-question gate. If the fix crosses a function boundary, run `architect` first. A new option or helper on a shared service counts as crossing a boundary, even when the first version lived in one controller. Read `.dk/repo/risk-checks.md` and add a task for each check that applies.
4. Write the failing test first when a cheap local test exists (`tdd` skill). Then the fix.
5. Verify on the same surface as step 1 with `verify`. The original repro now passes. "Inconclusive" or wrong surface is not a pass. Unit tests show branch behavior, not bug absence.
6. Sweep for the same pattern elsewhere (`principles/fix-root-causes.md`). Fix each hit or list it as deferred with a reason. Sweep twice: for the cause, and for the trigger of any workaround or guard you added (the same screen's popups and sibling grids first). If 2 or more callers of one shared component hit it, put the fix in that component (step 3: run `architect`), not a copy per caller.
7. Run "End of every task" steps 2 to 4 in `dk-mode/SKILL.md` (interrogate full, fix, delta). The verify above counts as its step 1; do not run it twice.
8. Run `playbooks/opening-a-pr.md`.

**Reply:** what was broken, root cause, fix, how you verified. Quote the decisive failing and passing output.
