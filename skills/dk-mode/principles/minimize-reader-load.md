# Minimize Reader Load

Adapted from pstack `principle-minimize-reader-load` (MIT, see `<dk>/NOTICE.md`).

Code is maintainable when a reader does little work to understand it. Count two things:

- **Layers to trace:** hops between the question and the answer.
- **State to hold:** hidden or mutable values the reader must keep in mind.

The two are separate. One flat class with 50 mutable fields is as hard to read as six thin adapter layers. Line count and "clean architecture" are only proxies.

**Pattern:**
- **Collapse layers that cost more than they save:** a wrapper with one caller, an interface with one implementation and no test seam, an adapter that passes the same arguments through. Inline them.
- **Each layer must change the abstraction.** A layer that repeats the methods of the one below adds load and hides nothing.
- **Shrink state scope.** Return values over mutation, locals over fields, fields over statics. Derive a value instead of keeping two copies in sync.
- **Name the invariant once, at the boundary** (`principles/boundary-discipline.md`), not in every consumer.
- Before you add a layer or a field, ask: does it remove at least as much load somewhere else?

**The test:** can a new reader answer "where does X come from?" and "what can change X?" in under 30 seconds? If not, cut layers or cut state.

Use it in review (`interrogate`) and as the success measure of `playbooks/refactoring.md`. The context window version of the same idea is `principles/guard-the-context-window.md`.
