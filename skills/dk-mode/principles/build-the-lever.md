# Build the Lever

When the work is not trivial, write the tool that does it or proves it, instead of doing it by hand. Edits, migrations, analyses, and checks all count, not only bulk work.

**Why:** A script does the work the same way every time and reruns for free. A reviewer can read it and run it again. Work done by hand can only be checked by doing it again. A script turns "trust me" into "run this".

**Pattern:**
- Skip the lever only when the task is a few obvious edits you can see at a glance. The bar is "trivial", not "repeated": a one-off still earns a lever when the lever is what makes the work checkable.
- Do the first unit by hand to learn the recipe. Then write the tool, run it on that same unit, and diff the result against your hand-made version.
- Pick the smallest tool that fits: a codemod or a regex script for edits, a generator for repeated files, a query (for example a dump into SQLite) for analysis, a rerunnable script for a check.
- A script that handles every unit in one pass beats a fan-out of subagents doing the same edit by hand. Run it yourself.
- When subagents must do the work, write the recipe as one file they all read: the steps, the success check, and the files they must not touch. Keep that file outside their write scope.
- Make the tool safe to rerun (`principles/make-operations-idempotent.md`). Commit it when the work outlives the session.
- Keep it small: a script, never a framework (`principles/laziness-protocol.md`).

**The test:** If you cite this principle, a script, codemod, generator, or recipe file is in the diff or in `.dk/artifacts/<id>/`. If none is there, you did not apply it.

Not the same as `principles/encode-lessons-in-structure.md`, which turns a repeated mistake into a lasting guardrail. This one is about doing and checking the work in front of you. For scripting the proof itself, see `principles/prove-it-works.md`.
