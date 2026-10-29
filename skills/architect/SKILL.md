---
name: architect
description: Design before coding in this repo. Sketch the caller's usage, types, signatures, and module boundaries with not-implemented bodies, compare two different designs, pick one, then implement against it. Use for "design this", "architect this", or any change that crosses a function boundary or has more than one valid shape.
---

# Architect

Adapted from pstack `architect` (MIT, see `<dk>/NOTICE.md`). pstack runs Phase B through `arena`; here two design subagents run in parallel instead.

Design before implementing. Sketch types, method signatures, class shapes, and module boundaries with not-implemented bodies (`throw new NotImplementedException()` in C#, `raise NotImplementedError` in Python, `throw new Error("not implemented")` in TypeScript) and `TODO` pseudocode. Compare at least two designs, pick one, then fill in code against it. If implementation proves the sketch wrong, throw it out and redesign.

Open a todo list with one entry per phase: Ground, Sketch, Agree, Implement, Scrap.

## Phase A. Ground

Run `how` over every subsystem the change touches, including all callers and their config. Naming a file is not grounding. Read `.dk/repo/facts.md` for the language version, framework, and package limits of each touched project, and `.dk/repo/risk-checks.md`.

Skip Phase A only for greenfield code with no surrounding system.

## Phase B. Sketch

Spawn two design subagents in one message, `subagent_type: "general-purpose"`, one with `model: "opus"` and one with `model: "sonnet"`, both `run_in_background: true`. Each gets `references/runner-prompt.md`, the task, the Phase A findings, and its own output folder `.dk/artifacts/<id>/design/candidate-a/` or `candidate-b/`. They write sketch files there, not in the source tree.

The two candidates must differ in shape, not in detail (for example: a header key versus a managed identity; change the caller versus add a wrapper). If both come back the same, say so. That is a signal the constraints forced the answer.

Screen each candidate against `references/design-red-flags.md`. Reject or revise shallow modules, information leakage, temporal decomposition, and pass-through methods.

Pick a base. Prefer the design that hides more behind a smaller public surface and needs fewer changes to callers. Take good parts from the other. Write the result to `technical-design.md` in the plan folder (`dk-mode/references/plan-format.md`), shaped by `references/rationale-template.md`.

## Phase C. Agree

Default: go straight to implementation.

Stop and show the design first when:

- The user asked for a checkpoint.
- A choice needs someone outside the code: a cloud setting, a key rotation, an ops step, a caller owned by another team.
- The design changes a public contract, a stored format, or a security boundary.

If the human pushes back on the shape, treat it as new Phase A evidence. Ground again and redo Phase B.

## Phase D. Implement against the sketch

Replace the not-implemented bodies with code. The sketch is the contract.

A deviation from the sketch is a signal. If a method needs a parameter the sketch did not have, ask whether the sketch was wrong, a requirement was missed, or the code is overreaching. Record accepted deviations in the "Implementation reconciliation" section of `technical-design.md` before the next task.

## Phase E. Scrap when the design is wrong

The signal is a pattern, not one instance:

- The same workaround in several unrelated places.
- Several unrelated edge cases that each need a special branch.
- Casts, `object` / `any`, or nullable fields that are always set, needed to compile.
- Callers that must know the internals to use it.
- Two or more deviations of the same shape in Phase D.

When you scrap: run `how` over what was built, redesign as if the new constraints were known on day one, make the new sketch smaller than the old one, and go back to Phase B.

## Outputs

- `technical-design.md` in the plan folder, per `references/rationale-template.md`, including the caller's usage and the synthesis decision.
- Sketch files under `.dk/artifacts/<id>/design/` (not committed).
