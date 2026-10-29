# Benchmark checklist

Adapted from pstack `benchmark-checklist` (MIT, see `<dk>/NOTICE.md`).

Use before you report or act on a performance number: a baseline, a before and after, a regression claim, or a choice between options. Answer each question with evidence from a run, not a guess about the code.

For a quick ballpark the user asked for, one run is enough. Still answer questions 4 and 7, and say it is one run. A choice between options is never a ballpark.

## Before you run

- Write the sentence you expect to ship ("export is 30% faster at p50 on 60k rows"). The questions test that sentence.
- Read the measurement script or tool. Note what it times, what it counts, and what it ignores.
- Check that the machine is quiet (CPU load, other heavy processes). If you cannot make it quiet, alternate the runs so both sides see the same noise, and say so.

## The questions

1. **What limits it?** Name the limiter: one CPU core, the database, I/O, the network, a lock, a pool size, or the load generator itself. If a change did not move the number, the limiter usually explains why. Find it before you call the change useless.
2. **Was each side tuned like production?** Release build, production settings, the same pool sizes, caches as warm or cold as production, the same data and versions. A debug build, a missing index, or a commit per row on one side means you compared settings, not code.
3. **Does it break a limit?** Do the arithmetic. Bytes per second against disk and network speed. Removing a step that takes 10% of the run can make it at most about 11% faster. A result past a limit measured something else: a cache, a no-op, or a bug.
4. **Did it fail?** Count errors and non-success responses, and check the output is correct, not just present. Rejections are fast; timeouts and retries are slow. If the tool does not count errors, add a count.
5. **Does it repeat?** At least 5 runs per side, alternating A, B, A, B, so warmup and drift favor neither. Report the median and the range. A gap smaller than the run-to-run spread is no measurable difference.
6. **Does it matter end to end?** Next to any micro result, measure the path a user waits on and report the micro result as a share of it. A helper that takes 1% of a request can save at most 1%.
7. **Did the work happen?** Confirm inside the timed region that the request reached the server, the rows were written, and the result was used. Lazy code (an `IEnumerable` nobody iterates, a `Task` nobody awaits, a query never executed) produces numbers for work that never ran.

## Report

- Verdict first: faster, slower, no measurable difference, or inconclusive.
- Then the number with its unit, the run count, the range, and the limiter. For example: "p50 41 ms to 33 ms, median of 7 runs per side, range 32 to 35 ms after, bound by JSON parsing on one core."
- Call it inconclusive when you cannot name the limiter, when one side ran untuned, or when you could not answer questions 4 and 7. Name the gap.
