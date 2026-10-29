"""Lint for the DK skills. Finds problems a reader would not spot.

  python check.py                 the DK clone: file references, em dashes, control characters, SKILL.md frontmatter,
                                  non-ASCII in .ps1 (breaks Windows PowerShell 5.1),
                                  names from denylist.local.txt (git-ignored, optional)
  python check.py --repo <path>   also the repo: junctions to these skills, .dk/repo files, references inside them

Prints ok, or one line per problem. Exit 1 on any problem.
"""
import os
import re
import sys
from pathlib import Path

DK = Path(__file__).resolve().parent
SKILLS = DK / "skills"
REF = re.compile(r"`([A-Za-z0-9_.\-/\\<>~]+\.(?:md|ps1|py|cjs|mjs|json))`")
SKIP_COMMON = r"[<>*~]|^\.\.\.|^(plan|resume|SKILL|MEMORY|pr)\.md$"
SKIP_DK = re.compile(SKIP_COMMON + r"|^\.dk/(repo|artifacts|plans)/|^docs/|^src/")
SKIP_REPO = re.compile(SKIP_COMMON + r"|^\.dk/(artifacts|plans)/")
CTRL = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f]")
EM_DASH = "\u2014"
# Names that must never reach the shared clone. Kept in a local, git-ignored file: one regex per line, # for comments.
# No file means no denylist check.
DENY_FILE = DK / "denylist.local.txt"
DENY_TERMS = [l.strip() for l in DENY_FILE.read_text(encoding="utf-8").splitlines()] if DENY_FILE.exists() else []
DENY_TERMS = [t for t in DENY_TERMS if t and not t.startswith("#")]
DENY = re.compile("|".join(DENY_TERMS), re.I) if DENY_TERMS else None
DENY_SKIP = {"NOTICE.md", DENY_FILE.name}
TEXT = {".md", ".ps1", ".py", ".cjs", ".mjs", ".mdc", ".json", ".txt", ""}
problems = []


def rel(p, root):
    try:
        return p.relative_to(root).as_posix()
    except ValueError:
        return str(p)


def scan_text(f, root, deny):
    text = f.read_text(encoding="utf-8", errors="replace")
    name = rel(f, root)
    for n, line in enumerate(text.splitlines(), 1):
        if EM_DASH in line:
            problems.append(f"{name}:{n} em dash")
        if CTRL.search(line):
            problems.append(f"{name}:{n} control character")
        if f.suffix == ".ps1" and any(ord(c) > 127 for c in line):
            problems.append(f"{name}:{n} non-ASCII character in a .ps1 file")
        if deny and DENY and f.name not in DENY_SKIP:
            m = DENY.search(line)
            if m:
                problems.append(f"{name}:{n} denylisted name '{m.group(0)}'")
    return text


def resolves(ref, md, roots):
    ref = ref.replace("\\", "/")
    for prefix in (".claude/skills/", "skills/"):
        if ref.startswith(prefix):
            ref = ref[len(prefix):]
    return any((r / ref).exists() for r in [md.parent] + roots)


def check_refs(md, text, root, roots, skip):
    for n, line in enumerate(text.splitlines(), 1):
        for ref in REF.findall(line):
            if ("/" in ref or "\\" in ref) and not skip.search(ref.replace("\\", "/")) and not resolves(ref, md, roots):
                problems.append(f"{rel(md, root)}:{n} missing file `{ref}`")


def check_dk():
    for f in sorted(DK.rglob("*")):
        if not f.is_file() or ".git" in f.parts or "__pycache__" in f.parts or f.suffix not in TEXT:
            continue
        text = scan_text(f, DK, deny=True)
        if f.suffix == ".md" and SKILLS in f.parents:
            skill = SKILLS / f.relative_to(SKILLS).parts[0]
            check_refs(f, text, DK, [skill, SKILLS, DK], SKIP_DK)
    for d in sorted(p for p in SKILLS.iterdir() if p.is_dir()):
        md = d / "SKILL.md"
        if not md.exists():
            problems.append(f"skills/{d.name} has no SKILL.md")
            continue
        head = md.read_text(encoding="utf-8").split("\n---", 1)[0]
        if not head.startswith("---"):
            problems.append(f"skills/{d.name}/SKILL.md has no frontmatter")
            continue
        if not re.search(rf"^name: {re.escape(d.name)}\s*$", head, re.M):
            problems.append(f"skills/{d.name}/SKILL.md frontmatter name is not '{d.name}'")
        if not re.search(r"^description: \S", head, re.M):
            problems.append(f"skills/{d.name}/SKILL.md frontmatter has no description")


def check_repo(repo):
    if not repo.is_dir():
        problems.append(f"repo not found: {repo}")
        return
    for d in sorted(p for p in SKILLS.iterdir() if (p / "SKILL.md").exists()):
        link = repo / ".claude" / "skills" / d.name
        if not os.path.lexists(link):
            problems.append(f"repo: .claude/skills/{d.name} missing: run install.ps1 -Repo {repo}")
        elif Path(os.path.realpath(link)) != Path(os.path.realpath(d)):
            problems.append(f"repo: .claude/skills/{d.name} points to {os.path.realpath(link)}, not {d}")
    facts = repo / ".dk" / "repo"
    for name in (p.name for p in (DK / "repo-template").glob("*.md")):
        if not (facts / name).exists():
            problems.append(f"repo: .dk/repo/{name} missing: run install.ps1 -Repo {repo}")
    if facts.is_dir():
        for f in sorted(facts.rglob("*")):
            if f.is_file() and f.suffix in TEXT:
                text = scan_text(f, repo, deny=False)
                if f.suffix == ".md":
                    check_refs(f, text, repo, [facts, repo, SKILLS], SKIP_REPO)


args = sys.argv[1:]
check_dk()
if args[:1] == ["--repo"] and len(args) > 1:
    check_repo(Path(args[1]).resolve())
elif args:
    sys.exit(__doc__)
print("\n".join(problems) if problems else "ok")
sys.exit(1 if problems else 0)
