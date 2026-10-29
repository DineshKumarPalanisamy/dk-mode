# Perf issue

Use when something is slow, times out, or uses too much CPU, memory, database time, or money. You own the numbers. Every fix ties to a measurement. Reading the source is not measuring.

1. Write the claim you expect to ship, in real words ("the search endpoint returns in under 500 ms at p95 with 50k rows"). That sentence is "Done means".
2. Capture a baseline on the real surface with `verify`: the same endpoint, screen, or job the user waits on, with realistic data size. Save the raw output under `.dk/artifacts/<id>/perf/baseline/`. Vet it with `references/benchmark-checklist.md` before you plan from it.
3. Find the limiter. Profile in a separate run you do not report (a profiler slows the work down): CPU per process, a runtime profiler or trace, SQL query plans and timings, I/O wait. Map the hot spot to source with `how`. Do not claim a ceiling you have not run.
4. Pick the fix. Try these in order, cheapest first, and stop at the first one that meets the target:
   1. Don't do it. Stop work whose result nothing uses.
   2. Do it, but don't do it again (cache, memoize, batch the repeated call).
   3. Do it less (fewer rows, fewer round trips, a narrower query).
   4. Do it later (defer, lazy load, move to a background job).
   5. Do it when nobody waits (precompute, warm up).
   6. Do it concurrently.
   7. Do it cheaper (a better algorithm, an index, a faster API).
5. Write `plan.md` per `references/plan-format.md`. Read `.dk/repo/risk-checks.md` and add a task for each check that applies. If the fix crosses a function boundary, run `architect` first. A cache or a background job changes behavior (staleness, ordering, retries): name that change in the plan.
6. Fix one thing at a time and measure after each (`principles/sequence-verifiable-units.md`). A change that did not move the number gets reverted, unless the limiter explains why and the next step needs it.
7. Measure after the fix, same surface, same data, same settings as the baseline. Save it under `.dk/artifacts/<id>/perf/after/`. Compare with a script, not by eye (`principles/build-the-lever.md`). Run the checklist again. "Inconclusive" or a different surface is not a pass.
8. Run "End of every task" in `dk-mode/SKILL.md`. Step 1 must also show the feature still works, not only that it is faster.
9. Run `playbooks/opening-a-pr.md`. Put one primary number in the PR (before, after, delta, run count). Link the artifacts for the rest.

**Reply:** the baseline, the result, the delta with run count and range, the limiter, and the artifact paths. Say plainly if a result is inconclusive.
