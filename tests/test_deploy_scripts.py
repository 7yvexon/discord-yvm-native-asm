import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class DeployScriptTests(unittest.TestCase):
    def test_linux_release_contains_sqlite_maintenance_fallback(self):
        verifier = (ROOT / "deploy" / "verify-release.sh").read_text(encoding="utf-8")
        maintenance = (ROOT / "deploy" / "sqlite-maintenance.sh").read_text(encoding="utf-8")
        self.assertIn("deploy/sqlite-maintenance.sh", verifier)
        self.assertIn("command -v sqlite3", verifier)
        self.assertIn("python3 -c 'import sqlite3'", verifier)
        self.assertIn("source.backup(target)", maintenance)
        self.assertIn("PRAGMA integrity_check;", maintenance)

    def test_operational_scripts_use_shared_maintenance_and_safe_rollback(self):
        healthcheck = (ROOT / "deploy" / "healthcheck.sh").read_text(encoding="utf-8")
        backup = (ROOT / "deploy" / "backup.sh").read_text(encoding="utf-8")
        restore = (ROOT / "deploy" / "restore.sh").read_text(encoding="utf-8")
        rollback = (ROOT / "deploy" / "rollback.sh").read_text(encoding="utf-8")
        self.assertIn("sqlite-maintenance.sh", healthcheck)
        self.assertIn("sqlite-maintenance.sh", backup)
        self.assertIn("sqlite-maintenance.sh", restore)
        trusted_rollback = (ROOT / "deploy" / "rollback-trusted.sh").read_text(encoding="utf-8")
        self.assertIn("direct release rollback is disabled", rollback)
        self.assertIn("/usr/local/sbin/yul-vending-machine-verify-trusted-release", trusted_rollback)
        self.assertIn("healthcheck.sh", trusted_rollback)
        self.assertIn("restore_previous", trusted_rollback)
        self.assertIn('#!/bin/sh', trusted_rollback)
        self.assertIn("PATH=/usr/sbin:/usr/bin:/sbin:/bin", trusted_rollback)
        self.assertIn('/bin/sh "$trusted_verifier" "$release" "$trusted_digest" "$target"', trusted_rollback)
        self.assertIn("restore_previous", restore)
        self.assertIn("if ! systemctl start", restore)

    def test_install_requires_external_trust_and_stages_before_promote(self):
        install = (ROOT / "deploy" / "install.sh").read_text(encoding="utf-8")
        trusted_install = (ROOT / "deploy" / "install-trusted.sh").read_text(encoding="utf-8")
        trusted_verify = (ROOT / "deploy" / "verify-trusted-release.sh").read_text(encoding="utf-8")
        self.assertIn("direct release installation is disabled", install)
        self.assertIn("trusted SHA256SUMS digest", trusted_install)
        self.assertIn("release-staging", trusted_install)
        self.assertIn("mv -- \"$stage\"", trusted_install)
        self.assertIn("/usr/local/sbin/yul-vending-machine-verify-trusted-release", trusted_install)
        self.assertIn("/usr/local/share/yul-vending-machine/yul-vending-machine.service", trusted_install)
        self.assertIn('#!/bin/sh', trusted_install)
        self.assertIn("PATH=/usr/sbin:/usr/bin:/sbin:/bin", trusted_install)
        self.assertIn('/bin/sh "$trusted_verifier" "$stage" "$trusted_digest" "$release_id"', trusted_install)
        self.assertIn("SHA256SUMS\"", trusted_verify)
        self.assertIn('#!/bin/sh', trusted_verify)
        self.assertIn("PATH=/usr/sbin:/usr/bin:/sbin:/bin", trusted_verify)
        self.assertIn("release checksum manifest is not trusted", trusted_verify)
        self.assertIn("sha256sum --strict --check SHA256SUMS", trusted_verify)
        self.assertIn("trusted digest must be under the protected trust directory", trusted_verify)
        self.assertIn("post_digest", trusted_verify)
        self.assertIn("trusted_digest_name", trusted_verify)
        self.assertIn('if [ "$trusted_digest_name" != "$release_id.SHA256SUMS.sha256" ]; then', trusted_verify)
        self.assertIn("trusted digest filename does not match release id", trusted_verify)
        self.assertIn("digest_line_count", trusted_verify)
        self.assertIn("nonempty_digest_lines", trusted_verify)
        self.assertIn("SHA256SUMS[[:space:]]*$", trusted_verify)
        self.assertIn("checksum manifest does not cover exactly the release files", trusted_verify)
        self.assertIn("release contains a non-regular file", trusted_verify)
        self.assertNotIn('/bin/sh "$release/deploy/verify-release.sh"', trusted_verify)
        self.assertIn("PATH=/usr/sbin:/usr/bin:/sbin:/bin", trusted_verify)

    def test_linux_release_verifier_enforces_elf_hardening(self):
        verifier = (ROOT / "deploy" / "verify-release.sh").read_text(encoding="utf-8")
        self.assertIn("readelf is required for ELF hardening verification", verifier)
        self.assertIn("GNU_RELRO", verifier)
        self.assertIn("GNU_STACK", verifier)
        self.assertIn("BIND_NOW", verifier)
        self.assertIn("native core is missing GNU_RELRO", verifier)
        self.assertIn("local symbol or debug sections", verifier)
        self.assertIn("native launcher must be stripped", verifier)
        self.assertIn("deploy/yul-vending-machine.service", verifier)
        self.assertIn("duplicate checksum manifest path", verifier)
        self.assertIn("checksum manifest does not cover exactly the release files", verifier)
        self.assertIn("release contains a non-regular file", verifier)
        self.assertIn('source_commit":"[0-9a-fA-F]{40}', verifier)

    def test_linux_release_verifier_uses_allowed_websocket_hosts(self):
        verifier = (ROOT / "deploy" / "verify-release.sh").read_text(encoding="utf-8")
        self.assertIn("DISCORD_GATEWAY_URL=wss://gateway.discord.gg/?v=10&encoding=json", verifier)
        self.assertIn("PUSHBULLET_STREAM_URL=wss://stream.pushbullet.com/websocket", verifier)
        self.assertNotIn("DISCORD_GATEWAY_URL=wss://127.0.0.1/", verifier)
        self.assertNotIn("PUSHBULLET_STREAM_URL=wss://127.0.0.1/", verifier)

    def test_aarch64_build_enables_pie_relro_now_and_stripping(self):
        powershell = (ROOT / "build" / "build-aarch64.ps1").read_text(encoding="utf-8")
        shell = (ROOT / "build" / "build.sh").read_text(encoding="utf-8")
        for script in (powershell, shell):
            self.assertIn("-pie", script)
            self.assertIn("-z relro", script)
            self.assertIn("-z now", script)
            self.assertIn("-z noexecstack", script)
            self.assertIn("llvm-strip", script)
            self.assertIn("--strip-unneeded", script)

    def test_core_build_enables_relro_now_and_stripping(self):
        powershell = (ROOT / "build" / "build-core.ps1").read_text(encoding="utf-8")
        self.assertIn("-z relro", powershell)
        self.assertIn("-z now", powershell)
        self.assertIn("-z noexecstack", powershell)
        self.assertIn("llvm-strip", powershell)
        self.assertIn("--strip-unneeded", powershell)

    def test_release_creation_stops_on_build_failure_and_checks_source_commit(self):
        creator = (ROOT / "build" / "create-release.ps1").read_text(encoding="utf-8")
        self.assertGreaterEqual(creator.count("if ($LASTEXITCODE -ne 0)"), 3)
        self.assertIn("-ExpectedSourceCommit $resolvedCommit", creator)
        self.assertIn('if ($LASTEXITCODE -ne 0) { throw "release verification failed" }', creator)
        self.assertIn("SHA256SUMS.sha256", creator)
        self.assertIn("$rootChecksumPath", creator)
        self.assertIn('Where-Object { $_.FullName -ne $rootChecksumPath }', creator)
        self.assertNotIn('Where-Object { $_.Name -ne "SHA256SUMS" }', creator)
        verifier = (ROOT / "build" / "verify-release.ps1").read_text(encoding="utf-8")
        self.assertIn("$rootManifest", verifier)
        self.assertIn('if ($file.FullName -eq $rootManifest) { continue }', verifier)

    def test_shell_release_files_use_lf_line_endings(self):
        attributes = (ROOT / ".gitattributes").read_text(encoding="utf-8")
        self.assertIn("*.sh text eol=lf", attributes)
        self.assertIn("*.service text eol=lf", attributes)
        for script in (ROOT / "deploy").glob("*.sh"):
            self.assertNotIn(b"\r", script.read_bytes(), script)

    def test_release_creation_rejects_crlf_shell_scripts(self):
        creator = (ROOT / "build" / "create-release.ps1").read_text(encoding="utf-8")
        self.assertIn('$releaseShellScripts = Get-ChildItem -LiteralPath (Join-Path $release "deploy") -File -Filter "*.sh" -Recurse', creator)
        self.assertIn("[System.IO.File]::ReadAllBytes($script.FullName)", creator)
        self.assertIn("if ($scriptBytes -contains [byte]13)", creator)
        self.assertIn("release shell script must use LF line endings", creator)


if __name__ == "__main__":
    unittest.main()
