# Fix Root Causes

Adapted from pstack `principle-fix-root-causes` (MIT, see `<dk>/NOTICE.md`).

When debugging, fix the fault, not the place where it showed up. The symptom is where a wrong state became visible. The root cause is the first place the system did something it should not do, or failed to handle a state it should handle.

**Why:** A symptom fix hides the evidence and lets the fault show up somewhere else. The code then carries a workaround for a bug nobody named.

**Pattern:**
- Reproduce first.
- Ask "why" at each step until the answer is a wrong decision in the code, not a result of an earlier one.
- When stuck, instrument. Read the actual error and the actual state. Do not guess.
- Ask whether the state that caused the symptom is allowed. If the system may be in that state, the code that broke on it is the root cause: handle the state there. If the state should never exist, a check where it broke hides the bug: find what produced the state. Null checks, retries, swallowed exceptions, clamped values, and dropped state are the usual ways to hide a bug.
- When something fails only after a restart, suspect saved state first: config files, caches, lock files, serialized state.
- Fix the pattern, not just the instance. Find every place with the same fault and fix them all.
- If a workaround needs a paragraph of comment to justify it, the code is wrong. Fix the code.
- If the deciding fact took a deep dig to find, propose the cheap, always-on signal (a log line, a preflight check) that would have shown it at first look.
- Two fixes on the same belief failed: stop and run `principles/attack-the-premise.md`.
