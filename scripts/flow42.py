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

ROOT = Path(__file__).resolve().parents[1]
ID_RE = re.compile(r"^[a-z0-9][a-z0-9-]{0,62}$")


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


def cmd_new(args: argparse.Namespace) -> None:
    repo = git_root()
    work_id = safe_work_id(args.work_id)
    target = (repo / ".sdlc" / work_id).resolve()
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


def cmd_doctor(_: argparse.Namespace) -> None:
    repo = git_root()
    findings = {
        "git": shutil.which("git"),
        "gh": shutil.which("gh"),
        "glab": shutil.which("glab"),
        "config": str(repo / ".sdlc" / "config.yml") if (repo / ".sdlc" / "config.yml").is_file() else None,
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
    doctor = sub.add_parser("doctor", help="inspect local prerequisites")
    doctor.set_defaults(func=cmd_doctor)
    return parser


def main() -> None:
    args = build_parser().parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
