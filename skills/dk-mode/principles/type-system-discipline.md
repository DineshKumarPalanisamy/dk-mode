# Type System Discipline

Make the compiler reject impossible states, mixed-up values, and unhandled cases. A check the compiler runs on every build beats a check a reviewer must remember.

**Why:** A runtime guard catches a bad value only on the path that runs it. A type stops the bad value from being written at all. Fewer states to handle also means fewer special-case branches.

**Pattern:**
- **Make illegal states unrepresentable.** If two fields must change together, put them in one type. Model "pending, paid, refunded" as one closed set of cases (a discriminated union, a sealed record hierarchy, an enum with data), not as three booleans that can all be true.
- **Give meaning to primitives.** `CustomerId` and `OrderId` are both strings or ints underneath, but they must not be swapped. Give each its own small type (in C# a `readonly record struct CustomerId(Guid Value)`). Validate once when the value is created, then trust the type. Two parameters of the same primitive type that mean different things are a bug waiting for a caller.
- **External data is untyped until parsed.** Request bodies, JSON, queue messages, CLI args, config, environment variables, database rows. One parse function at each boundary turns raw input into the typed model, or fails. Code inside works with the typed model only. `principles/boundary-discipline.md` says where the boundary is.
- **Handle every case.** Switch on the closed set and let the compiler warn on a missing case (C# switch expressions with nullable and warnings as errors, TypeScript `never`, Rust `match`). Do not add a `default` that hides a new case.
- **Derive types from the source that owns the shape.** When an OpenAPI spec, a protobuf file, a database migration, or a generated client owns a shape, generate or derive from it. A hand-written copy drifts. See `principles/encode-lessons-in-structure.md`.

**The test:** Can a caller build a value this code cannot handle, and still compile? If yes, tighten the type before adding a runtime check.
