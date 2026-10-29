# Pause safely

Adapted from pstack `pause-safely` (MIT, see `<dk>/NOTICE.md`).

Use when the user stops for the day, the session will restart, or the context is near full. Not on "keep going" or "don't stop".

1. Stop at a safe point. Finish the current small step or back it out. Start nothing new. Stop your subagents.
2. Take no gated action to pause. No commit, push, or PR unless the start message already approved it.
3. Update `plan.md`: tick done tasks with evidence, set `next:` to the first open task.
4. Write `resume.md` next to `plan.md`, at most 30 lines:
   - Goal, in one line.
   - Done, each with its evidence path under `.dk/artifacts/<id>/`.
   - Current state: branch, worktree, uncommitted files, hosts still running (PID, port) or stopped.
   - Next step, as the exact command or edit.
   - Gotchas found this session that are not yet in `.dk/repo/` or a preflight check.
5. Leave hosts running only if the user said they will be back soon. Otherwise run `verify` Cleanup.

**Reply:** what is on disk, what is uncommitted, and the first action on resume.
