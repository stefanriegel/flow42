#!/usr/bin/env python3
import json
import re
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[1]
errors = []
workflow = json.loads((root / "core" / "workflow.json").read_text(encoding="utf-8"))
for name in workflow["commands"]:
    ignored = subprocess.run(
        ["git", "check-ignore", "-q", f"skills/{name}/SKILL.md"], cwd=root
    ).returncode
    if ignored == 0:
        errors.append(f"canonical skill is ignored by Git: {name}")
for path in root.glob("skills/*/SKILL.md"):
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n") or "\ndescription:" not in text.split("---", 2)[1]:
        errors.append(f"invalid frontmatter: {path.relative_to(root)}")
    if "[TODO:" in text:
        errors.append(f"placeholder: {path.relative_to(root)}")
for path in (root / ".codex-plugin" / "plugin.json", root / ".claude-plugin" / "plugin.json", root / "core" / "workflow.json"):
    try:
        json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"invalid JSON {path.relative_to(root)}: {exc}")
for template in root.glob("templates/*"):
    text = template.read_text(encoding="utf-8")
    unknown = set(re.findall(r"{{([^}]+)}}", text)) - {"work_id", "title", "work_type", "timestamp"}
    if unknown:
        errors.append(f"unknown placeholders in {template.name}: {sorted(unknown)}")
if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)
print("validation ok")
