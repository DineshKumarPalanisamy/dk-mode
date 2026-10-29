# Opening a PR

Every step that writes to git, the forge, or the tracker is a hard gate. Prepare everything, then stop and ask.

The repo's git and PR rules are in `.dk/repo/facts.md` (Git and PR): base branch, branch name, commit format, PR command, tracker. A `TODO` there: use the repo's own docs or recent `git log` for the pattern, and say which you used. No git in the repo: skip steps 1, 3a, 5 and 6, list the changed files with one line each, and say "no git: no commit or PR".

1. Check the branch. Work goes on a branch named per facts.md, cut from the base branch. Never commit on the base branch itself.
2. Review your own diff: `git diff <base>...HEAD` plus the working tree. Remove debug code, stray files, and unrelated edits. No secret values, keys, or personal data in the diff, in test data, or in logs.
3. Confirm "End of every task" in `dk-mode/SKILL.md` is done for this diff: a `verify` result and an `interrogate` report under `.dk/artifacts/<id>/` that match the current `HEAD` and working tree. If not, run it now, before any commit. The "small task" shortcut never skips it.
3a. Group the work into small commits in proof order: failing test first, then the fix. Message format from facts.md. In PowerShell, write the message to a file and run `git commit -F <file>`; a here-string piped to `-F -` fails. Stage named paths only: local overlays (config a start script rewrote, files listed in facts.md Conventions) must not ship.
4. Draft the PR description in `.dk/artifacts/<id>/pr.md`:
   - What changed and why, in 3 to 5 lines.
   - One line per "Done means" check with its evidence.
   - Manual checks still needed (a shared environment, key rotation, ops steps), with who does them.
   - Deployment notes.
5. If the start message got a yes for commit, push, and PR, go straight on. If not, stop once: show the commit list and the PR draft and ask for all three together.
6. After approval: push, create the PR with the command in facts.md, link the work item, and set the description. Then read the PR back with the same tool and confirm the work item link and every description line are there. Some CLIs keep only the first line of a multi-line description; check, and fix with one argument per line. Report the real PR URL from the tool output, never a built one.
7. Last line of the final reply, after the PR exists: ask "Do you want QA test steps for this change?" Do not post them anywhere unless the user says yes and says where (a tracker comment is a hard gate).
   - On yes, write at most 5 numbered steps for a tester who uses the UI, not code.
   - Each step starts with the screen path, joined by arrows: `Settings → Users → New user`. Then one short action and the expected result.
   - Plain words only. No class names, file paths, or config keys unless the tester must check them in a portal.
   - If the change has no UI (config, pipeline, infra), say how the tester sees it instead: a browser call, a failed PR check, or a portal page path written the same way.
8. Trouble check, after the PR exists. If this session had a user correction, a repeated failure (same step failed 2 or more times), or a wait over 20 minutes, run `reflect` for this task now without asking, and show its Accepted table with the final reply. It edits nothing until the user approves rows. If none of the three happened, skip it and say "reflect: not needed" in one line.
