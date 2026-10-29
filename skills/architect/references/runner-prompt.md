# Architect runner prompt

The orchestrator passes this to each design subagent in Phase B, with the task, the Phase A findings, and your output folder. Work independently. The other runner is on a different model.

You are producing one candidate design. Read `.claude/skills/architect/SKILL.md` first; that is the workflow you are inside. Write into your output folder only: a type sketch (source files with not-implemented bodies), method signatures, a module map, and a rationale shaped by `rationale-template.md`. Do not edit the source tree.

Discipline. The orchestrator compares candidates on these points.

- Caller's usage first. Write two or three real call sites from this repo (the actual caller files) before the types. Derive the types from them. If they disagree, fix the types.
- Data first. Get the core types right and the code becomes obvious.
- Interface depth. Prefer a small public surface that hides real work. Do not put transport or wire types on the public API.
- Every caller. List every caller that must change, in every solution or package, plus the config and deployment steps. A design that leaves one caller on the old path is incomplete.
- Match the project. Use only the language version, syntax, and packages the target project already compiles (see `.dk/repo/facts.md`). No new package unless the task needs it and facts.md allows it.
- Validate at boundaries, trust types inside. Business rules live in the layer facts.md names for them; entry points (controllers, endpoints, handlers) stay thin.
- One source of truth per setting. Read it once, pass the value.
- Idempotent where it can run twice or crash halfway.
- Short call chains. If tracing the flow needs more than three files, flatten it.
- Security: no secret in a URL, query string, log, exception message, or API document.

Produce the best design your model can make. Do not hedge toward a safe middle; the differences between candidates are the signal.
