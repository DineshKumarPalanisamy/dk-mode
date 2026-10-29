# Guard the Context Window

The context window is finite and non-renewable within a session. Every token should be worth its cost.

**Why:** Context overflow degrades reasoning quality, creates compression artifacts, and halts progress.

**Pattern:**
- **Isolate large payloads.** Route verbose outputs, screenshots, and large documents to subagents. The main context gets summaries, not raw data.
- **Keep frequently used content inline.** Templates and references used on every invocation belong in the skill file, not in separate files that cost a read each time.
- **Write bulk output to files.** Build logs, test output, and HTTP captures go under `.dk/artifacts/<id>/verify/`. Read back only the lines that matter (the error, the counts, the assertion).
- **Size phases and cap scope.** Limit files per phase, set turn budgets, account for mechanism costs.
