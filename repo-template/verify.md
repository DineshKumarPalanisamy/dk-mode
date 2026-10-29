# Verify facts

How to start, drive, and clean up this app locally. Read by the shared `verify` skill. Filled by `/dk-init` or `/create-verification-skill`; edit by hand any time. A line with `TODO` is a gap, not a fact.

## Preflight

- TODO: the one command that checks every known local blocker (for example `pwsh -File .dk/repo/scripts/preflight.ps1 -Id <id>`), or the list of prerequisites to check: tools, containers, ports free, models pulled.

## Hosts

| Surface | Start command | Port | Ready when |
|---|---|---|---|
| TODO | TODO | TODO | TODO |

Who owns each host: TODO (started by the agent per task, or started by the user and reused read-only).

## Doctor

- TODO: the read-only checks that say a host is worth driving: health URL, version or build, port owner.

## Allowed local data

- TODO: the local databases, containers, datasets, or accounts the agent may read and write without asking. Everything else is a hard gate.

## Sign-in and secrets

- TODO: how the agent signs in, and where it reads each secret (env var or secret store name). Names only, never values.

## Drive

- TODO: how to exercise the main features (HTTP calls, a script, a browser recipe). Feature recipes go in `.dk/repo/features/` when there are more than a few.

## Evidence to capture

- TODO: what proves a change here (response bodies, logs, files written, rows read back), and slow steps with their expected time.

## Cleanup

- TODO: what to stop and what to restore after a run. Evidence stays in `.dk/artifacts/<id>/verify/`.

## Known local failures

| Symptom | Cause | Fix |
|---|---|---|
| TODO | TODO | TODO |

## Helpers

- TODO: repo scripts in `.dk/repo/scripts/` or the repo's own scripts, with their invocation. "None" if there are none.
