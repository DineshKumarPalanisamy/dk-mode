# Boundary Discipline

Adapted from pstack `principle-boundary-discipline` (MIT, see `<dk>/NOTICE.md`).

Check data where it enters the system. Trust it inside. Think of a passport check at the airport: it happens once at the border, not again at every shop inside.

**Why:** Validation spread through every layer is noise. It hides which check matters and gives a false sense of safety. Logic tied to the framework cannot be tested without the framework.

**Pattern:**
- **At the boundary** (HTTP request, config, queue message, file, database read, external API response): validate, parse into a domain type, and return a clear error.
- **Inside:** typed data, errors propagate, no re-validation. No null check deep in a call chain when the boundary already checked.
- **Across the boundary:** expose domain types, not the wire, storage, or framework types. A controller returns a model, not an entity or an SDK response object.
- **Business rules in plain functions** with no framework dependency. The controller, function trigger, or job handler stays thin: read input, call the rule, write output.

**The tests:**
- "Is this data crossing a boundary right now?" If not, the check is redundant.
- "Can this rule be a plain function the shell calls?" If yes, extract it.

Works with `principles/fix-root-causes.md`: a guard deep inside is a symptom fix unless the state it handles is legitimate.
