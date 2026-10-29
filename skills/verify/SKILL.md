---
name: verify
description: Prove a change works on the real, locally running app before calling it done. Starts the local hosts named in .dk/repo/verify.md, checks they are ours and healthy, drives the changed feature, captures evidence under .dk/artifacts/<id>/verify/, and cleans up. Use before saying any task is done, to reproduce a bug, or when asked to "verify", "prove it", "run it", "smoke test", or "integration test" a change.
---

# verify

Adapted from pstack `create-verification-skill` output (MIT, see `<dk>/NOTICE.md`). This file holds the rules. The repo's hosts, ports, commands, and traps are in `.dk/repo/verify.md`, and its feature recipes in `.dk/repo/features/` when the repo has them. Read `verify.md` first.

`verify.md` missing or mostly `TODO`: say so, suggest `/dk-init` (or `/create-verification-skill` for a full driver), and work out the launch from the repo's README and launch settings. Record what you learned in the final reply so the user can add it.

## Preflight (run first, once per task)

Run the preflight command in `verify.md` (Preflight), if it names one, and write its output to `.dk/artifacts/<id>/verify/preflight.txt`. A preflight prints one line per check: `OK`, `USER` (only the user can fix it), or `AGENT` (the agent fixes it).

- Put every `USER` line into the one start-of-task message (see `dk-mode` "Start of every task"). Do not ask for them one at a time later.
- No preflight command: check the prerequisites `verify.md` lists (tools, containers, ports free) in one pass yourself, in parallel.

## Launch

Local only: the hosts, containers, and data `verify.md` lists as allowed. Never a shared, test, or production database, environment, secret store, or cloud resource; if a proof needs one, report it as a manual check. Never print a secret value (redact to 4 characters and `...`) or a connection string (print only host, database name, key names).

Use the Hosts table in `verify.md`: the start command, the port, and the "ready when" signal for each surface.

**Keep hosts up between runs.** Start each host once per task and reuse it. Before a re-run, run Doctor; restart only when it fails or the code that host runs changed. A test-only or doc change never needs a host restart or rebuild. Rebuild only the project you changed, not the whole solution.

**Run verify in the main thread or one subagent, not both.** A verify subagent gets the host PIDs and ports from `.dk/artifacts/<id>/verify/` and must not start a second copy.

Run long-lived hosts in the background and record each PID in `.dk/artifacts/<id>/verify/<host>.pid`. A start command that keeps its output pipe open never returns: start it as a background task and run Doctor as a separate call. A host the user already runs (for example a container they started) is not yours: reuse it read-only and never stop it.

## Doctor

Run first, and again whenever something looks off. Use the checks in `verify.md` (Doctor). At minimum: the recorded PID is alive and owns the port, the health endpoint (or ready signal) answers, and the build it serves is the one you just made.

## Known local failures

Check the table in `verify.md` before you debug a local host. A new failure that cost more than 10 minutes goes into that table (or into the preflight if a script can detect it).

## Drive

Use the recipe in the matching `.dk/repo/features/*.md` file, or the Drive section of `verify.md`. Find the path yourself first: trace from the changed code up to the screen, endpoint, or command (use `how`), and read the local data for the setup it needs. Ask the user only for a sign-in or a real choice. A sign-in `verify.md` (Sign-in and secrets) says the agent can do is not one of them. For a caller of an external service, point its base URL at the capture endpoint (`scripts/capture-http.ps1`) and run the caller.

## Evidence

Everything goes under `.dk/artifacts/<id>/verify/`: build log, host log, HTTP captures (`*.jsonl`), response files, before/after documents named `<thing>.before.<ext>` and `<thing>.after.<ext>`. A before/after pair changes only the code: same config and data, old build vs new build. If anything else changed between the runs, call it "config proof", not fix proof. Proof is the real user or caller path, not an internal setter or a test-only endpoint; capture the action and the resulting state. External systems (payment gateways, vendor APIs, secret stores) are replaced by the capture endpoint or a test mode, and a test mode is trusted only after observing what it skips. A check that could not run is "not run: <reason>", never "passed". In the reply, quote the decisive lines, not whole files.

Coverage: list every surface the change touches or enables (each screen, endpoint, caller, or user of a new option), and give each one a driven check or `not run: <reason>`. Enabling an option is not proof. When a change alters how rows render (virtualization, paging, sort), also edit and save a row reached by scrolling, and read the saved value back.

## Cleanup

Kill only what this run started, by recorded PID, never by name. Evidence stays.

- Hosts: stop each recorded PID and its process tree. Stopping the shell that ran a host does not always stop the host.
- Capture endpoint: exits by itself after `-MaxRequests` or `-TimeoutSeconds`.
- Restore any local data you changed from its `.before` snapshot, and run the cleanup steps in `verify.md`.
- Confirm the evidence files still exist and nothing listens on the ports you used.
- Clean up once, at the end of the task, not after each run. During the fix loop hosts stay up.

## Helpers

| Script | What it does |
|---|---|
| `scripts/capture-http.ps1 -Port -OutFile [-MaxRequests] [-TimeoutSeconds] [-StatusCode] [-ResponseBody]` | Fake remote service. Logs method, path, query names, headers (auth values redacted), body length as JSONL |
| `scripts/cpuprofile-summary.cjs <file.cpuprofile> [top]` | Top functions by self and total time from a Chromium or Node CPU profile |
| Repo scripts in `.dk/repo/scripts/` | Listed in `verify.md` (Helpers) |
