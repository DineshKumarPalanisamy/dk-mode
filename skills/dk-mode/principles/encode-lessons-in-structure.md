# Encode Lessons in Structure

Adapted from pstack `principle-encode-lessons-in-structure` (MIT, see `<dk>/NOTICE.md`).

A rule written as text is easy to miss. A script check runs every time without anyone remembering it.

**Pattern:**
When the same mistake or user correction happens a second time:
1. Ask: can a script, a test, or a check catch it?
2. If yes, add it, and delete the text rule. The first place to look is the repo's preflight (named in `.dk/repo/verify.md`, scripts in `.dk/repo/scripts/`): one more `USER` or `AGENT` line. For a rule about the skills themselves, `<dk>/check.py`.
3. If no (it needs judgment), make the text rule shorter and more visible, and add the failure that caused it, with the task id.

**Close the loop in the same task.** "I'll keep that in mind" does not persist. Edit the repo facts, the script, or the skill now (a skill edit needs the user's yes, see `reflect`), or tell the user in the final reply which file should change.

**Examples:**
- Admin steps found one by one (a Windows feature, a registry key, a URL ACL) became preflight `USER` lines.
- A port held by another session became a preflight port-owner check.
