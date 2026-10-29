# Refactoring

Use when the structure changes and the behavior must not. You own the contract. Different from Feature (adds behavior) and Bug fix (corrects behavior). If the cleanup finds a real bug or a missing feature, split it out: ship the structural change first, then route the rest to `playbooks/bug-fix.md` or `playbooks/feature.md`.

1. Pin the behavior first. Run `how` over the affected code to learn the contract: entry points, every caller, inputs and outputs. Then write a characterization test, a snapshot, or a small script that records current outputs, before any structure moves. A build or a lint pass is not a pin. No coverage in the area: write the pin before touching anything.
2. Name the target shape: the classes, types, and call graph you would write today. If it crosses a function boundary or has more than one valid shape, run `architect`. The new shape must delete branches or invalid states, not add indirection.
3. Write `plan.md` per `references/plan-format.md`. Read `.dk/repo/risk-checks.md` and add a task for each check that applies.
4. Subtract first (`principles/subtract-before-you-add.md`): dead code, one-caller wrappers, redundant validators, orphan references. Then the smallest change that reaches the target (`principles/laziness-protocol.md`).
5. Move in small steps. Run the pin after each one (`principles/sequence-verifiable-units.md`). For an API reshape, migrate every caller and delete the old API in the same change (`principles/migrate-callers-then-delete.md`). No shims, no parallel old and new paths. Check every rename with a search: renames miss usages in strings, config, views, and reflection.
6. Verify the whole change with `verify` on the real surface, plus the pin. For a larger reshape, diff old and new outputs on the same inputs.
7. Check it is worth keeping (`principles/minimize-reader-load.md`). If the diff does not lower reader load somewhere, revert it.
8. Run "End of every task" steps 2 to 4 in `dk-mode/SKILL.md` (interrogate full, fix, delta). The verify above counts as its step 1; do not run it twice.
9. Run `playbooks/opening-a-pr.md`. Commit order: subtraction, then the reshape, then follow-on cleanup. Each commit keeps the pin green.

**Reply:** the structure that changed, the pin, the equivalence proof, the reader-load change, and what you reverted. No new behavior.
