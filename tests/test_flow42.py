import importlib.util
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("flow42_cli", ROOT / "scripts" / "flow42.py")
FLOW42 = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(FLOW42)


class Flow42Tests(unittest.TestCase):
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
            target = repo / ".sdlc" / "retry"
            self.assertEqual(result.stdout.strip(), ".sdlc/retry")
            self.assertEqual(
                {p.name for p in target.iterdir()},
                {"intent.md", "spec.md", "plan.md", "evidence.md", "decisions.md", "status.yml"},
            )
            self.assertIn("Reliable retry", (target / "intent.md").read_text())


if __name__ == "__main__":
    unittest.main()
