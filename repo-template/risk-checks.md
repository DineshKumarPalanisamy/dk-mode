# Risk checks

Use while planning (add a task per check that applies), while implementing, and in `interrogate`. Each check: when it applies, what to look for, and the proof that clears it. Filled by `/dk-init`; edit by hand any time. The general checks below hold in most repos; add this repo's detail where it says `TODO`, and delete a check that cannot apply here.

## Repo-specific checks

### TODO: name of a risky area in this repo

- Applies: TODO (which files, layers, or kinds of change).
- Look for: TODO (the concrete mistake).
- Proof: TODO (the command or test that clears it).

## Secrets

- Applies: config, logging, URLs, HTTP clients, test data, scripts.
- Look for: secret values in source, config files, URLs, query strings, logs, exception messages, or API documents. A key committed in source must be rotated; deleting it from the branch is not enough.
- Repo detail: TODO (where secrets are allowed to live here, for example user secrets or env vars).
- Proof: grep the diff for the value shape; a test that captures the request or log line and asserts absence.

## Data isolation

- Applies: queries, caches, background jobs, anything that reads data for one tenant, user, or dataset.
- Look for: a query or call without the scope filter; data from one scope showing up in another.
- Repo detail: TODO (what the scope is here, or "n/a").
- Proof: a two-scope negative test (scope B cannot see scope A data).

## Idempotency and retries

- Applies: anything that can run twice: retries, re-submits, replays, jobs, migrations.
- Look for: a retry without a duplicate guard; a transaction held across a remote call.
- Proof: run the operation twice; one effect.

## Contracts

- Applies: DTOs, public HTTP APIs, messages, stored formats, responses parsed from another service.
- Look for: a non-additive change without a version bump; a caller not updated in the same release; a parser that breaks on a missing or extra field.
- Proof: a round-trip or contract test; a list of every caller and its status.

## Authorization

- Applies: a new or changed endpoint.
- Look for: an endpoint without the auth its neighbors use, a new anonymous endpoint, a missing permission check. Each needs a stated reason in the plan.

## Async and timeouts

- Applies: request paths and background work.
- Look for: blocking on async code (`.Result`, `.Wait()`), a new external call with no timeout, a loop or buffer with no upper bound.

## Injection

- Applies: any string-built query, command, path, or HTML.
- Look for: values concatenated into SQL, shell, or markup. Judge each hit where the value is bound.
- Proof: the sweep re-finds known sites; each hit is fixed, not reachable, or deferred with a tracked item.

## Migrations

- Applies: schema or data scripts, storage layout changes.
- Look for: a script that is not rerunnable; a change that silently wipes or orphans data.
- Proof: apply the script twice to a local copy.

## Security class fixes

- Applies: injection, auth, key handling, scope filters.
- Look for: only the reported instance fixed. Sweep for the whole pattern and list every hit with its status. An open sweep on a security class blocks the PR.

## Blocking topics

Topics where an open question always blocks planning (`dk-mode/references/plan-format.md`), on top of the general list there.

- TODO

## Repo gates

Actions that need the user's yes in this repo, on top of the `dk-mode` hard gates. "None" if there are none.

- TODO

## Verdict

Default rule is in `interrogate`: a critical finding blocks. Write a stricter rule here only if this repo needs one.
