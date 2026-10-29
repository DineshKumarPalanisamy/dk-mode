<!-- dk:begin (written by the DK installer; edits inside this block are lost on the next install) -->
# DK mode

This repo uses the DK skills: `.claude/skills/<name>` are junctions to the shared DK clone at `{{DK}}` (called `<dk>` in the skills). Facts about this repo live in `.dk/repo/`.

- For any story, bug, plan, implementation, review, or verification task, use `/dk-mode` and the skills it names: `how`, `why`, `architect`, `tdd`, `verify`, `interrogate`, `reflect`.
- Read `.dk/repo/facts.md` before the first edit, `.dk/repo/risk-checks.md` before planning or review, `.dk/repo/verify.md` before verify. Missing or mostly `TODO`: say so and suggest `/dk-init`.
- Never edit files under `.claude/skills/`: every repo shares them. Repo facts go to `.dk/repo/`. Evidence goes to `.dk/artifacts/<id>/`.
- The repo's own `CLAUDE.md` and `AGENTS.md` rules still apply in full.
<!-- dk:end -->
