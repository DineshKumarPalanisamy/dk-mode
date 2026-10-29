# Make Operations Idempotent

Adapted from pstack `principle-make-operations-idempotent` (MIT, see `<dk>/NOTICE.md`).

An operation should reach the same end state however many times it runs, and wherever the last run stopped. Like a lift button: pressing it twice still calls one lift.

**Why:** Jobs, message handlers, scripts, migrations, and retries run where crashes and restarts are normal. If leftover state changes the next run's result, every restart becomes a debugging session.

**Pattern:**
- **Work from current state, not from intent.** Read what exists, compare it to the goal, apply only the difference. A repeat run then finds nothing to do.
- **Make leftovers recognizable.** A lock, a temp file, a half-written row, or a claimed job must be judged stale by the next run, wherever the last run stopped. Write to a temp name and rename into place. Compare by content or key, not by order of creation.
- **Use natural keys for inserts** (upsert, `IF NOT EXISTS`, a unique constraint) so a retry cannot create a duplicate.
- **Seed and cleanup scripts too.** Tag the rows a script creates so a rerun can find and replace them.

**The test:**
1. What happens if this runs twice in a row?
2. What happens if the previous run crashed at each step?
3. Does a rerun reach the same end state?

If any answer is "it depends on what was left behind", add a reconcile step.
