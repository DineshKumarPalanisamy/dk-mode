"""Turn Claude Code session transcripts into short timelines that reflect reviewers can read.

  python digest.py [--repo <path>] find <task-id>                 list sessions of this repo that mention the id, newest first
  python digest.py [--repo <path>] digest <session-id|path> [...]  write <repo>/.dk/artifacts/reflect/<first-session-8>/digest.md

The repo is --repo or the current folder. Reads only that repo's folder in ~/.claude/projects.
Redacts secret-shaped values. Never writes outside .dk/artifacts/reflect.
"""
import datetime as dt
import json
import re
import sys
from pathlib import Path

REPO = Path.cwd()
PROJECT = None


def project_folder(repo):
    return Path.home() / ".claude" / "projects" / re.sub(r"[^A-Za-z0-9]", "-", str(repo))
SECRET = [
    (re.compile(r"(?i)(AccountKey|SharedAccessKey|password|pwd|secret|token|apikey|api_key|code)=([^;&\s\"']{4})[^;&\s\"']*"), r"\1=\2..."),
    (re.compile(r"(?i)(Bearer\s+)([A-Za-z0-9._-]{4})[A-Za-z0-9._-]+"), r"\1\2..."),
    (re.compile(r"\b(\d{4})\d{8,15}\b"), r"\1...[digits]"),
]
LONG = re.compile(r"[A-Za-z0-9+/]{40,}={0,2}")
IDLE_GAP_MIN = 5


def _long(m):
    v = m.group(0)
    looks_random = any(c.isdigit() for c in v) and any(c.isupper() for c in v) and any(c.islower() for c in v)
    return v[:4] + "...[redacted]" if looks_random and v.count("/") <= len(v) // 10 else v


def redact(text):
    for rx, rep in SECRET:
        text = rx.sub(rep, text)
    return LONG.sub(_long, text)


def trim(text, n):
    text = " ".join(str(text).split())
    return text if len(text) <= n else text[:n] + " ..."


def ts(rec):
    t = rec.get("timestamp")
    return dt.datetime.fromisoformat(t.replace("Z", "+00:00")) if t else None


def resolve(arg):
    p = Path(arg)
    if p.is_file():
        return p
    hits = sorted(PROJECT.glob(f"{arg}*.jsonl"))
    if not hits:
        sys.exit(f"no transcript for {arg} in {PROJECT}")
    return hits[0]


def records(path):
    with open(path, encoding="utf-8") as f:
        for line in f:
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def is_human(rec):
    return rec.get("type") == "user" and not rec.get("isMeta") and (rec.get("origin") or {}).get("kind") == "human"


def human_text(rec):
    c = rec["message"]["content"]
    if isinstance(c, str):
        return c
    return " ".join(x.get("text", "[image]" if x.get("type") == "image" else "") for x in c if x.get("type") in ("text", "image"))


def tool_summary(name, inp):
    if name in ("Bash", "PowerShell"):
        return f"{name}: {trim(inp.get('command', ''), 220)}"
    if name in ("Read", "Write", "Edit"):
        return f"{name}: {inp.get('file_path', '')}"
    if name in ("Grep", "Glob"):
        return f"{name}: {trim(inp.get('pattern', ''), 80)} in {inp.get('path', '.')}"
    if name == "Skill":
        return f"Skill: {inp.get('skill')} {trim(inp.get('args', ''), 80)}"
    if name == "Agent":
        return f"Agent: type={inp.get('subagent_type', 'default')} model={inp.get('model', 'inherit')} bg={inp.get('run_in_background', True)} :: {trim(inp.get('description', ''), 80)}"
    return f"{name}: {trim(json.dumps(inp)[:200], 160)}"


def find(story):
    rows = []
    for p in PROJECT.glob("*.jsonl"):
        branch, first, hit = "", "", False
        for rec in records(p):
            b = rec.get("gitBranch") or ""
            if not branch and b:
                branch = b
            if b != branch and b.startswith(story):
                hit = True
            if is_human(rec):
                t = human_text(rec)
                first = first or trim(t, 90)
                hit = hit or story in t
        if hit:
            rows.append((p.stat().st_mtime, p.stem, p.stat().st_size // 1024, branch, first))
    for mtime, stem, kb, branch, first in sorted(rows, reverse=True):
        day = dt.datetime.fromtimestamp(mtime).strftime("%m-%d %H:%M")
        print(f"{day}  {stem}  {kb}KB  {branch}  :: {redact(first)}")


def digest_one(path, out):
    recs = list(records(path))
    times = [t for t in (ts(r) for r in recs) if t]
    start = min(times) if times else None
    pending, errors, stops, branches = {}, 0, 0, []
    lines, last_t = [], start
    for r in recs:
        t = ts(r)
        if r.get("gitBranch") and r["gitBranch"] not in branches:
            branches.append(r["gitBranch"])
        if not t or r.get("isSidechain"):
            continue
        stamp = f"[{int((t - start).total_seconds() // 60):>4}m]"
        msg = r.get("message") or {}
        content = msg.get("content")
        if is_human(r):
            gap = (t - last_t).total_seconds() / 60 if last_t else 0
            if gap >= IDLE_GAP_MIN:
                stops += 1
                lines.append(f"{stamp} ---- waited {gap:.0f} min for the user ----")
            lines.append(f"{stamp} USER: {trim(human_text(r), 700)}")
            last_t = t
        elif r.get("type") == "assistant" and isinstance(content, list):
            for x in content:
                if x.get("type") == "text" and x.get("text", "").strip():
                    lines.append(f"{stamp} ASSISTANT: {trim(x['text'], 450)}")
                elif x.get("type") == "tool_use":
                    pending[x["id"]] = (t, tool_summary(x["name"], x.get("input") or {}))
                    lines.append(f"{stamp} TOOL {pending[x['id']][1]}")
        elif r.get("type") == "user" and isinstance(content, list):
            for x in content:
                if x.get("type") != "tool_result":
                    continue
                began, what = pending.pop(x.get("tool_use_id"), (None, ""))
                secs = (t - began).total_seconds() if began else 0
                body = x.get("content")
                body = " ".join(y.get("text", "") for y in body if isinstance(y, dict)) if isinstance(body, list) else str(body)
                if x.get("is_error"):
                    errors += 1
                    lines.append(f"{stamp}   ERROR after {secs:.0f}s: {trim(body, 300)}")
                elif secs >= 60:
                    lines.append(f"{stamp}   took {secs:.0f}s")
            last_t = t
        if r.get("type") == "assistant":
            last_t = t
    subs = sorted((path.parent / path.stem / "subagents").glob("*.meta.json"))
    head = [
        f"# Session {path.stem}",
        f"- Branches: {', '.join(branches) or 'n/a'}",
        f"- Start {start:%Y-%m-%d %H:%M} UTC, last event {max(times):%H:%M}, wall {(max(times) - start).total_seconds() / 60:.0f} min" if start else "- No timestamps",
        f"- Waits for the user of {IDLE_GAP_MIN}+ min: {stops}. Tool errors: {errors}. Subagent transcripts: {len(subs)}",
        "",
    ]
    out.write(redact("\n".join(head + lines)) + "\n\n")


def main():
    global REPO, PROJECT
    if len(sys.argv) > 2 and sys.argv[1] == "--repo":
        REPO = Path(sys.argv[2]).resolve()
        del sys.argv[1:3]
    PROJECT = project_folder(REPO)
    if not PROJECT.is_dir():
        sys.exit(f"no transcripts folder {PROJECT}")
    if len(sys.argv) < 3 or sys.argv[1] not in ("find", "digest"):
        sys.exit(__doc__)
    if sys.argv[1] == "find":
        return find(sys.argv[2])
    paths = [resolve(a) for a in sys.argv[2:]]
    folder = REPO / ".dk" / "artifacts" / "reflect" / paths[0].stem[:8]
    folder.mkdir(parents=True, exist_ok=True)
    target = folder / "digest.md"
    with open(target, "w", encoding="utf-8") as out:
        for p in paths:
            digest_one(p, out)
    print(f"{target}  {target.stat().st_size // 1024}KB")


if __name__ == "__main__":
    main()
