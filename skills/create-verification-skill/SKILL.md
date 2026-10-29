---
name: create-verification-skill
description: "Generate the repo-local verification facts and feature map that the shared verify skill drives that drives your app the way a user does, any language, framework, or platform. Use for /create-verification-skill, \"make a control skill for this repo\", \"make a driver skill for this repo\", or when a project has no scripted way to prove UI/CLI/service behavior."
---

# Create a verification skill

Adapted from pstack `create-verification-skill` (MIT, see `<dk>/NOTICE.md`).

## DK rules (override anything below)

- The `verify` skill is shared by every repo and is never edited for one repo. Write this repo's driver into `.dk/repo/`: the sections below go into `.dk/repo/verify.md` (same headings as the template from `/dk-init`), the feature map into `.dk/repo/features/`, and helper scripts into `.dk/repo/scripts/`. Never write into `.claude/skills/`.
- Local only. The driver may start local hosts and containers and use local data. It must refuse to point at a shared, test, or production database, environment, or cloud resource. Doctor checks the connection host.
- External systems (payment gateways, vendor APIs, trackers, mail) are replaced by a local fake endpoint (`.claude/skills/verify/scripts/capture-http.ps1`) or a test mode. Never send a real charge or a real message.
- Never print a secret, key, or connection-string password into evidence. Redact to the first 4 characters and `...`.
- Evidence goes to `.dk/artifacts/<id>/verify/` (git-excluded by the DK installer).
- Kill only processes this run started (record their PIDs). Never kill by name.

Every serious project needs a scripted way to drive the real app and prove behavior: launch it, exercise a feature the way a user would, and capture evidence. This skill generates that as repo facts (`.dk/repo/verify.md` plus `.dk/repo/features/`) that the shared `verify` skill reads. The DK installer junctions `verify` into `.claude/skills/`, and a project skill by that name replaces Claude Code's bundled `/verify`, which only the user can invoke, so every playbook that names the driver skill can call it ([Claude Code 2.1.200 or later](https://code.claude.com/docs/en/skills#run-and-verify-your-app)). You write the generator's output for the next agent, not for a human: it will be read cold, mid-task, by an agent that has never seen the app.

## 1. Interview the repo, not the user

Answer these from the codebase and only ask the user what you cannot observe:

- **Surface:** what does a user actually touch? A web UI, a CLI/TUI, a desktop app, an API, a mobile app, a library? A repo can have several; pick the primary one and note the rest.
- **Run:** how does the app start locally? Prefer the repo's own documented dev command (package scripts, Makefile, README quickstart). Note ports, env vars, seed data, auth.
- **Drive:** how can an agent interact with it programmatically? Existing harnesses first, Playwright/Cypress specs, expect scripts, PTY helpers, curl-able endpoints, a debug port. Only then pick a generic recipe: browser/CDP for web and Electron, a tmux/PTY harness for CLI/TUI, plain HTTP for services.
- **Observe:** what evidence can be captured? Screenshots, terminal transcripts, response bodies, logs, exit codes, DB state.
- **Isolate:** can two instances run side by side (ports, data dirs, profiles)? If not, say so in the generated skill: refusing to double-drive a shared instance beats corrupting the user's session.

If the checkout doesn't build or start as-is, fix that first (or report it precisely) before generating; a skill written against a broken base teaches wrong steps. When an irrelevant missing asset blocks startup (a static dir the API never serves, a sample config), the generated skill may create it, clearly marked as verification scaffolding, and remove it in cleanup.

## 2. Generate the driver

Fill `.dk/repo/verify.md` (create it from the DK `<dk>/repo-template/verify.md` if it is missing; keep its headings) with these sections, each grounded in what the interview actually found (no placeholders left):

- **Launch:** the exact command that starts the app for verification, and how to tell it's ready (a log line, a port answering, a prompt). Include teardown. For a short-lived CLI or TUI there is no server to keep alive: launch means build the binary (or install deps) once, then start each drive in its own isolated PTY or tmux session.
- **Doctor:** one read-only check that answers "is this instance worth driving?", process up, right version/build, port owned by us, auth valid. An agent runs this first whenever anything looks off.
- **Drive:** the harness recipe with real selectors/commands from this repo, not examples. Prefer stable handles (ARIA labels, data attributes, prompt strings, route paths) over coordinates and tab order.
- **Evidence:** what to capture for a proof and where it goes. State the proof standards: exercise the real user path, not internal setters or test-only endpoints; capture the action and the resulting state, not just the final screen; verify side effects (files written, rows inserted, messages sent) alongside what's visible; mocks only where a production boundary already isolates the external system. When the safe path is a dry-run or test mode, verify what it actually skips by observing (files, network, git refs) rather than trusting its name: some dry-runs still touch the network or open a browser.
- **Cleanup:** how to tear down instances the run created. Never kill by process name; kill what you started. Cleanup removes instances and scratch state, never the evidence: proof artifacts survive the teardown, in a location the skill names.
- **Helpers:** any script the skill ships is executable and its invocation is shown in the skill body. A helper the reader has to reverse-engineer is not a helper.

## 3. Seed the feature map

Create `.dk/repo/features/README.md` plus one file per user-facing feature you can identify (aim for the top 3-5 to start, from routes, commands, menus, or docs). Follow the shape in [`references/feature-map-example/`](references/feature-map-example/), with a README index and one file per feature. Each file answers, from the user's point of view: what the feature is, how to reach it, how to drive it with the harness, and what observable end state proves it works. The four H2s are `Sub-features`, `How to get to it (user POV)`, `Driving it with <harness>`, and `Gotchas`. The map is the repo's maintained verification source; a proof that drives one convenient entry point is incomplete when the map lists others.

## 4. Prove the driver before handing it over

Run its own instructions end to end once: launch, doctor, drive ONE mapped feature (one is enough; the map exists so later runs can cover the rest), capture evidence, clean up. After cleanup, confirm the evidence still exists at the named location, a cleanup that eats the proof fails this step. Fix what fails, and run the generated cleanup after every failed iteration too, so broken attempts don't strand processes and ports. A generated driver that was never executed is a draft, not a deliverable.

## 5. Offer the maintenance loop

Tell the user to run `/create-verification-skill` again (or `/dk-init`, which shows a diff per section) when the app changes, so the map stays honest. Suggest a cadence only if they ask.
