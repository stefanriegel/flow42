#!/usr/bin/env python3
import json
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[1]
workflow = json.loads((root / "core" / "workflow.json").read_text())
missing = [name for name in workflow["commands"] if not (root / "skills" / name / "SKILL.md").is_file()]
if missing:
    print("missing skills: " + ", ".join(missing), file=sys.stderr)
    raise SystemExit(1)
for manifest in (root / ".claude-plugin" / "plugin.json", root / ".codex-plugin" / "plugin.json"):
    data = json.loads(manifest.read_text())
    if data.get("name") != "flow42":
        print(f"invalid plugin name in {manifest}", file=sys.stderr)
        raise SystemExit(1)
print(f"parity ok: {len(workflow['commands'])} commands, 2 harness manifests")
