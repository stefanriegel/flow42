import importlib.util
import os
import subprocess
import tempfile
import unittest
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("flow42_cli", ROOT / "scripts" / "flow42.py")
FLOW42 = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(FLOW42)


class Flow42Tests(unittest.TestCase):
    def run_cli(self, repo, *args, check=True):
        return subprocess.run(
            ["python3", str(ROOT / "scripts" / "flow42.py"), *args],
            cwd=repo, text=True, capture_output=True, check=check,
        )

    def test_safe_work_id(self):
        self.assertEqual(FLOW42.safe_work_id("Reliable Retries"), "reliable-retries")

    def test_rejects_empty_work_id(self):
        with self.assertRaises(SystemExit):
            FLOW42.safe_work_id("../../")

    def test_new_creates_expected_artifacts(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            subprocess.run(["git", "init", "-q"], cwd=repo, check=True)
            result = subprocess.run(
                ["python3", str(ROOT / "scripts" / "flow42.py"), "new", "retry", "Reliable retry", "--type", "feature"],
                cwd=repo,
                text=True,
                capture_output=True,
                check=True,
            )
            target = repo / ".flow42" / "retry"
            self.assertEqual(result.stdout.strip(), ".flow42/retry")
            self.assertEqual(
                {p.name for p in target.iterdir()},
                {"intent.md", "spec.md", "plan.md", "evidence.md", "decisions.md", "status.yml"},
            )
            self.assertIn("Reliable retry", (target / "intent.md").read_text())

    def test_transition_requires_current_artifact_approval(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            subprocess.run(["git", "init", "-q"], cwd=repo, check=True)
            self.run_cli(repo, "new", "retry", "Reliable retry")
            self.run_cli(repo, "transition", "retry", "intent-gate")
            denied = self.run_cli(repo, "transition", "retry", "drafting-spec", check=False)
            self.assertNotEqual(denied.returncode, 0)
            self.assertIn("intent approval is required", denied.stderr)
            self.run_cli(repo, "approve", "retry", "intent", "--actor", "stefan")
            self.run_cli(repo, "transition", "retry", "drafting-spec")
            status = json.loads(self.run_cli(repo, "status", "retry").stdout)
            self.assertEqual(status["stage"], "drafting-spec")
            self.assertEqual(status["invalid_approvals"], [])

    def test_changed_artifact_invalidates_approval(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            subprocess.run(["git", "init", "-q"], cwd=repo, check=True)
            self.run_cli(repo, "new", "retry", "Reliable retry")
            self.run_cli(repo, "transition", "retry", "intent-gate")
            self.run_cli(repo, "approve", "retry", "intent", "--actor", "stefan")
            with (repo / ".flow42" / "retry" / "intent.md").open("a") as stream:
                stream.write("\nchanged\n")
            denied = self.run_cli(repo, "transition", "retry", "drafting-spec", check=False)
            self.assertIn("changed after approval", denied.stderr)

    def test_block_and_resume_round_trip(self):
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            subprocess.run(["git", "init", "-q"], cwd=repo, check=True)
            self.run_cli(repo, "new", "retry", "Reliable retry")
            self.run_cli(repo, "block", "retry", "waiting for dependency")
            resumed = self.run_cli(repo, "resume", "retry")
            self.assertEqual(resumed.stdout.strip(), "draft-intent")
            history = (repo / ".flow42" / "retry" / "history.jsonl").read_text().splitlines()
            self.assertEqual(len(history), 2)


if __name__ == "__main__":
    unittest.main()
