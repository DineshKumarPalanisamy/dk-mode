# Sources

One section per evidence category. An investigator gets the section for its category. Map each MCP tool in the session to the category of its main evidence. Record any tool that could fit two categories in Sources consulted.

## Source control

Always present. The most complete source, tied directly to the code.

Holds: commit messages and diffs, PR descriptions and review threads, code comments and TODOs, ADRs, tests (their names often name the edge case that forced a change), files changed in the same commits, changelogs.

```bash
git log --follow --oneline -- <file>          # history through renames
git log -S '<exact text>' -- <file>           # commits that added or removed this text
git log -G '<regex>' -- <file>                # same, for a pattern
git blame -L <start>,<end> <file>             # last commit per line
git show <hash>                               # one commit in full
rg -n -C2 '(TODO|FIXME|HACK|NOTE)' <file>     # notes near the target
rg -l '<symbol>' --glob '*[Tt]est*'           # related tests
rg -l -i 'decision record|ADR' --glob '*.md'  # design records
```

PRs: use the PR tool from `.dk/repo/facts.md` (Git and PR), for example `gh pr view <n> --json title,body,comments,reviews` on GitHub, or the Azure DevOps MCP or `az repos pr show --id <n>` on Azure DevOps. Read the review threads, not just the description.

## Work item tracker

Best for the business or product reason, when the push came from outside engineering. Examples: Azure DevOps Boards, Jira, GitHub Issues, Linear.

Open every work item id from the anchor. Read the description, acceptance criteria, discussion, and linked items (parent, related, duplicates). Then search by key terms from the code (the constant, the feature name, the error text) in the date range when the code appeared.

## Docs and wiki

Best for design reasons written before the code. Examples: a repo `docs/` folder, ADRs, an Azure DevOps wiki, Confluence, Notion, SharePoint.

Start from Where docs live in `.dk/repo/facts.md`. Search by feature name and by the terms in the PR. Note the doc's date against the commit date: a doc written after the code may describe it, not explain it.

## Team chat

Best for decisions made in conversation that never reached a doc. Examples: Teams, Slack. Important when the PR and work item trail is thin.

Search the feature name, the PR number, and the error text in the weeks around the commit date. Quote the message with its channel, author, and date.

## Monitoring

Best for the runtime facts that drove the code: timeouts, retries, rate limits, circuit breakers, scaling. Examples: Azure Monitor and Application Insights, Log Analytics, Datadog, Grafana.

Look at the signal the code reacts to (latency, failure rate, throttling) in the window before the commit. Read-only queries only.

## Error tracking

Best for the specific exceptions that drove defensive code: catch blocks, null guards, type checks, retries. Examples: Application Insights exceptions, Sentry.

Search the exception type or message the guard handles, and its first-seen and last-seen dates against the commit date.

## Analytics

Best for product and data facts: flag-gated code, experiments, data migrations, "where did this number come from". Examples: a data warehouse, Databricks, BigQuery, a feature flag service.

Query read-only. Report the table, the time window, and the summary numbers that bear on the question.

## Incident context

Add this section when the target looks defensive.

- Work items: search for incident, outage, sev, postmortem, hotfix tags or words near the commit date.
- Chat: incident channels around the commit date.
- Git: messages like "fix for incident", "add guard", "revert" followed by "re-apply", and a merge the same day as the PR opened.
