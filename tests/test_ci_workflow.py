import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "ci.yml"


class CiWorkflowTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.workflow = WORKFLOW.read_text(encoding="utf-8")

    def test_native_jobs_cover_both_release_targets(self):
        self.assertIn("native-windows-x64:", self.workflow)
        self.assertIn("name: Native Windows x64", self.workflow)
        self.assertIn("runs-on: windows-latest", self.workflow)
        self.assertIn("native-linux-aarch64:", self.workflow)
        self.assertIn("name: Native Linux AArch64", self.workflow)
        self.assertIn("runs-on: ubuntu-24.04-arm", self.workflow)
        self.assertIn("needs: native-windows-x64", self.workflow)

    def test_native_jobs_build_and_run_release_validation(self):
        self.assertIn("build/verify-toolchain.ps1", self.workflow)
        self.assertIn("build/create-release.ps1", self.workflow)
        self.assertIn("deploy/verify-release.sh", self.workflow)
        self.assertIn("panel-text", self.workflow)
        self.assertIn("init-db", self.workflow)
        self.assertIn("create-order smoke-user smoke-name 10", self.workflow)
        self.assertIn("support-total smoke-user", self.workflow)
        self.assertIn("tests.test_native_cli tests.test_native_core tests.test_native_protocol_contracts", self.workflow)
        self.assertIn("YUL_NATIVE_BINARY", self.workflow)
        self.assertIn("YUL_CORE_LIBRARY", self.workflow)

    def test_native_tests_fail_when_they_are_skipped(self):
        self.assertIn("-match 'skipped='", self.workflow)
        self.assertIn("grep -Eq 'skipped='", self.workflow)

    def test_all_github_actions_are_pinned_to_commit_shas(self):
        actions = re.findall(r"^\s+uses:\s+([^\s]+)$", self.workflow, flags=re.MULTILINE)
        self.assertGreaterEqual(len(actions), 4)
        for action in actions:
            self.assertRegex(action, r"^[^@]+@[0-9a-f]{40}$")

    def test_native_artifacts_do_not_select_runtime_data_files(self):
        windows_upload = self.workflow.split("Upload Windows native artifact", 1)[1].split(
            "Build Linux AArch64 release package", 1
        )[0]
        release_upload = self.workflow.split("Upload Linux AArch64 release package", 1)[1].split(
            "native-linux-aarch64:", 1
        )[0]
        for upload in (windows_upload, release_upload):
            self.assertNotIn(".local-vending.ini", upload)
            self.assertNotIn("config.ini", upload)
            self.assertNotIn("*.db", upload)
            self.assertNotIn("*.db-shm", upload)
            self.assertNotIn("*.db-wal", upload)


if __name__ == "__main__":
    unittest.main()
