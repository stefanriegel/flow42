#!/usr/bin/env python3
"""Dependency-free Flow42 repository state helper."""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
ID_RE = re.compile(r"^[a-z0-9][a-z0-9-]{0,62}$")
WORKFLOW = json.loads((ROOT / "core" / "workflow.json").read_text(encoding="utf-8"))
STAGES = WORKFLOW["stages"]
SIDE_STATES = set(WORKFLOW["side_states"])
GATED_TRANSITIONS = {
    "intent-gate": "intent",
    "spec-gate": "spec",
    "plan-gate": "plan",
}


def fail(message: str) -> None:
    raise SystemExit(f"flow42: {message}")


def git_root() -> Path:
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"], text=True, capture_output=True
    )
    if result.returncode:
        fail("run this command inside a Git repository")
    return Path(result.stdout.strip()).resolve()


def safe_work_id(value: str) -> str:
    value = value.strip().lower().replace("_", "-").replace(" ", "-")
    value = re.sub(r"[^a-z0-9-]+", "", value)
    value = re.sub(r"-+", "-", value).strip("-")
    if not ID_RE.fullmatch(value):
        fail("work ID must be 1-63 lowercase letters, numbers, or hyphens")
    return value


def render(template: Path, values: dict[str, str]) -> str:
    text = template.read_text(encoding="utf-8")
    for key, value in values.items():
        text = text.replace("{{" + key + "}}", value)
    return text


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(content, encoding="utf-8")
    tmp.replace(path)


def scalar(value: str) -> Any:
    value = value.strip()
    if value == "[]":
        return []
    if value == "{}":
        return {}
    if value in ("true", "false"):
        return value == "true"
    if value.isdigit():
        return int(value)
    if len(value) >= 2 and value[0] == value[-1] == '"':
        return json.loads(value)
    return value


def load_status(path: Path) -> dict[str, Any]:
    """Read Flow42's deliberately small, flat YAML status format."""
    if not path.is_file():
        fail(f"missing status file: {path}")
    result: dict[str, Any] = {}
    for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line or raw[:1].isspace():
            fail(f"unsupported status.yml syntax at line {number}")
        key, value = line.split(":", 1)
        result[key] = scalar(value)
    return result


def dump_status(status: dict[str, Any]) -> str:
    lines = []
    for key, value in status.items():
        if isinstance(value, (list, dict)):
            encoded = json.dumps(value, separators=(",", ":"))
        elif isinstance(value, bool):
            encoded = str(value).lower()
        elif isinstance(value, int):
            encoded = str(value)
        else:
            encoded = json.dumps(str(value), ensure_ascii=False)
        lines.append(f"{key}: {encoded}")
    return "\n".join(lines) + "\n"


def work_dir(repo: Path, work_id: str) -> Path:
    target = (repo / ".flow42" / safe_work_id(work_id)).resolve()
    if repo not in target.parents:
        fail("unsafe work path")
    return target


def artifact_hash(path: Path) -> str:
    if not path.is_file():
        fail(f"missing approval artifact: {path.name}")
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save_transition(target: Path, status: dict[str, Any], old_stage: str, actor: str) -> None:
    now = dt.datetime.now(dt.timezone.utc).isoformat()
    revision = int(status.get("state_revision", 0)) + 1
    status["state_revision"] = revision
    status["updated_at"] = now
    atomic_write(target / "status.yml", dump_status(status))
    event = {
        "revision": revision,
        "timestamp": now,
        "actor": actor,
        "from": old_stage,
        "to": status["stage"],
    }
    history = target / "history.jsonl"
    with history.open("a", encoding="utf-8") as stream:
        stream.write(json.dumps(event, sort_keys=True) + "\n")


def validate_approvals(target: Path, status: dict[str, Any]) -> list[str]:
    invalid = []
    for name in ("intent", "spec", "plan"):
        expected = status.get(f"{name}_approval_hash")
        if expected and artifact_hash(target / f"{name}.md") != expected:
            invalid.append(name)
    return invalid


def cmd_new(args: argparse.Namespace) -> None:
    repo = git_root()
    work_id = safe_work_id(args.work_id)
    target = (repo / ".flow42" / work_id).resolve()
    if repo not in target.parents:
        fail("unsafe work path")
    if target.exists():
        fail(f"work item already exists: {target.relative_to(repo)}")
    now = dt.datetime.now(dt.timezone.utc).isoformat()
    values = {
        "work_id": work_id,
        "title": args.title.strip(),
        "work_type": args.type,
        "timestamp": now,
    }
    for name in ("intent.md", "spec.md", "plan.md", "evidence.md", "decisions.md", "status.yml"):
        atomic_write(target / name, render(ROOT / "templates" / name, values))
    print(target.relative_to(repo))


def cmd_hash(args: argparse.Namespace) -> None:
    path = Path(args.path).resolve()
    if not path.is_file():
        fail(f"not a file: {path}")
    print(hashlib.sha256(path.read_bytes()).hexdigest())


def cmd_status(args: argparse.Namespace) -> None:
    target = work_dir(git_root(), args.work_id)
    status = load_status(target / "status.yml")
    status["invalid_approvals"] = validate_approvals(target, status)
    print(json.dumps(status, indent=2, sort_keys=True))


def cmd_approve(args: argparse.Namespace) -> None:
    target = work_dir(git_root(), args.work_id)
    status = load_status(target / "status.yml")
    stage = str(status.get("stage"))
    expected_stage = f"{args.artifact}-gate"
    if stage != expected_stage:
        fail(f"{args.artifact} approval requires stage {expected_stage}, found {stage}")
    digest = artifact_hash(target / f"{args.artifact}.md")
    status[f"{args.artifact}_approval_hash"] = digest
    status[f"{args.artifact}_approved_by"] = args.actor
    status[f"{args.artifact}_approved_at"] = dt.datetime.now(dt.timezone.utc).isoformat()
    print(digest)

    atomic_write(target / "status.yml", dump_status(status))


def cmd_transition(args: argparse.Namespace) -> None:
    target = work_dir(git_root(), args.work_id)
    status = load_status(target / "status.yml")
    old_stage = str(status.get("stage"))
    new_stage = args.stage
    if old_stage in SIDE_STATES:
        fail(f"cannot transition terminal/side state {old_stage}; use resume")
    if new_stage in SIDE_STATES:
        fail("use block or abandon for side states")
    try:
        expected = STAGES[STAGES.index(old_stage) + 1]
    except (ValueError, IndexError):
        fail(f"no forward transition from {old_stage}")
    if new_stage != expected:
        fail(f"invalid transition {old_stage} -> {new_stage}; expected {expected}")
    gate = GATED_TRANSITIONS.get(old_stage)
    if gate:
        expected_hash = status.get(f"{gate}_approval_hash")
        if not expected_hash:
            fail(f"{gate} approval is required")
        if artifact_hash(target / f"{gate}.md") != expected_hash:
            fail(f"{gate} changed after approval; approve it again")
    status["stage"] = new_stage
    save_transition(target, status, old_stage, args.actor)
    print(new_stage)


def cmd_block(args: argparse.Namespace) -> None:
    target = work_dir(git_root(), args.work_id)
    status = load_status(target / "status.yml")
    old_stage = str(status.get("stage"))
    status["resume_stage"] = old_stage
    status["stage"] = "blocked"
    status["blockers"] = [args.reason]
    save_transition(target, status, old_stage, args.actor)
    print("blocked")


def cmd_resume(args: argparse.Namespace) -> None:
    target = work_dir(git_root(), args.work_id)
    status = load_status(target / "status.yml")
    if status.get("stage") != "blocked":
        fail("resume requires blocked state")
    invalid = validate_approvals(target, status)
    if invalid:
        fail("approval invalidated: " + ", ".join(invalid))
    resume_stage = str(status.pop("resume_stage", ""))
    if resume_stage not in STAGES:
        fail("blocked work item has no valid resume stage")
    status["stage"] = resume_stage
    status["blockers"] = []
    save_transition(target, status, "blocked", args.actor)
    print(resume_stage)


def cmd_doctor(_: argparse.Namespace) -> None:
    repo = git_root()
    findings = {
        "git": shutil.which("git"),
        "gh": shutil.which("gh"),
        "glab": shutil.which("glab"),
        "config": str(repo / ".flow42" / "config.yml") if (repo / ".flow42" / "config.yml").is_file() else None,
    }
    remote = subprocess.run(
        ["git", "remote", "get-url", "origin"], cwd=repo, text=True, capture_output=True
    )
    findings["origin"] = remote.stdout.strip() if remote.returncode == 0 else None
    print(json.dumps(findings, indent=2, sort_keys=True))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="flow42")
    sub = parser.add_subparsers(required=True)
    new = sub.add_parser("new", help="create a work item")
    new.add_argument("work_id")
    new.add_argument("title")
    new.add_argument("--type", choices=("greenfield", "feature", "bug", "refactor", "maintenance"), default="feature")
    new.set_defaults(func=cmd_new)
    digest = sub.add_parser("hash", help="SHA-256 an artifact")
    digest.add_argument("path")
    digest.set_defaults(func=cmd_hash)
    status = sub.add_parser("status", help="show persisted work-item state")
    status.add_argument("work_id")
    status.set_defaults(func=cmd_status)
    approve = sub.add_parser("approve", help="bind a human approval to an artifact hash")
    approve.add_argument("work_id")
    approve.add_argument("artifact", choices=("intent", "spec", "plan"))
    approve.add_argument("--actor", required=True)
    approve.set_defaults(func=cmd_approve)
    transition = sub.add_parser("transition", help="perform the next valid lifecycle transition")
    transition.add_argument("work_id")
    transition.add_argument("stage", choices=STAGES)
    transition.add_argument("--actor", default="flow42")
    transition.set_defaults(func=cmd_transition)
    block = sub.add_parser("block", help="persist a recoverable blocker")
    block.add_argument("work_id")
    block.add_argument("reason")
    block.add_argument("--actor", default="flow42")
    block.set_defaults(func=cmd_block)
    resume = sub.add_parser("resume", help="resume a consistent blocked work item")
    resume.add_argument("work_id")
    resume.add_argument("--actor", default="flow42")
    resume.set_defaults(func=cmd_resume)
    doctor = sub.add_parser("doctor", help="inspect local prerequisites")
    doctor.set_defaults(func=cmd_doctor)
    return parser


def main() -> None:
    args = build_parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
