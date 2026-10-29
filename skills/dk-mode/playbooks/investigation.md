# Investigation

Use when the user asks a question, not for a change: "what is wrong with X", "how does Y behave", "why is Z like this", "which option should we pick". You own the answer. Read-only: no code change, no commit, no PR.

If the answer leads to a change, stop at the answer. The change is a new task: route it to `playbooks/bug-fix.md`, `playbooks/feature.md`, or `playbooks/refactoring.md`.

1. Write the question as one sentence, and "Done means" as the evidence that would answer it (a trace, a log line, a query result, a cited commit). If the question rests on a belief the code may not support, test that belief first (`principles/attack-the-premise.md`).
2. Route by question type. Run the ones that apply in parallel:
   - What the code does, where it lives, who calls it: `how`.
   - Why the code has this shape, what decision or incident caused it: `why`.
   - What happens at runtime (a wrong value, an error, a slow call): reproduce it on the real surface with `verify`. Reading the code is a hypothesis; the run is the evidence (`principles/fix-root-causes.md`: instrument, do not guess).
   - A choice between options: list each option with its cost and risk, measured where you can.
3. Keep bulk reading in subagents (`principles/guard-the-context-window.md`). Check each subagent's key claim yourself before you repeat it.
4. Label every claim: measured, cited, inferred, or guess. A question you could not answer stays open, with what you searched.
5. Save long evidence (traces, query output, logs) under `.dk/artifacts/<id>/` and cite the path.

No `interrogate`, no "End of every task": nothing changed. If you edited a file by mistake, revert it and say so.

**Reply:** the answer in the first line. Then the evidence for it, the open questions, and, for a choice, a small table of options with your pick and the reason. If the premise was wrong, say so plainly.
