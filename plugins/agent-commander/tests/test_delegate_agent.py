import json
import plistlib
import os
import stat
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


PLUGIN_ROOT = Path(__file__).resolve().parents[1]
SCRIPT = PLUGIN_ROOT / "scripts" / "delegate_agent.py"


class DelegateAgentCliTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.bin_dir = Path(self.temp_dir.name) / "bin"
        self.bin_dir.mkdir()
        self.args_log = Path(self.temp_dir.name) / "args.json"
        self.env = os.environ.copy()
        self.env["PATH"] = f"{self.bin_dir}{os.pathsep}{self.env.get('PATH', '')}"
        self.env["ARGS_LOG"] = str(self.args_log)
        self.env["AGENT_COMMANDER_APPLICATIONS_DIR"] = self.temp_dir.name

    def tearDown(self):
        self.temp_dir.cleanup()

    def install_fake(self, name, body):
        path = self.bin_dir / name
        path.write_text(f"#!/bin/sh\n{body}\n", encoding="utf-8")
        path.chmod(path.stat().st_mode | stat.S_IXUSR)

    def invoke(self, *args):
        if args[0] in {"run", "follow-up"} and "--access" not in args:
            args = (*args, "--access", "read-only")
        return subprocess.run(
            [sys.executable, str(SCRIPT), *args],
            text=True,
            capture_output=True,
            env=self.env,
            timeout=10,
        )

    def test_execute_mode_does_not_force_read_only_provider_options(self):
        for provider, executable in [("claude-code", "claude"), ("opencode", "opencode"),
                                     ("pi", "pi"), ("omp", "omp"), ("command-code", "command-code")]:
            with self.subTest(provider=provider):
                self.install_fake(executable, "printf '%s\\n' \"$@\" > \"$ARGS_LOG\"")
                result = self.invoke("run", "--provider", provider, "--access", "execute",
                                     "--cwd", self.temp_dir.name, "--prompt", "Implement the authorized change")
                self.assertEqual(result.returncode, 0, result.stderr)
                argv = self.args_log.read_text().splitlines()
                for flag in ("--tools", "--permission-mode", "--agent", "--no-lsp"):
                    self.assertNotIn(flag, argv)
                self.assertFalse(any("You are a read-only" in value for value in argv))
                self.assertTrue(any("Implement the authorized change" in value for value in argv))

    def test_default_access_allows_execution(self):
        self.install_fake("pi", "printf '%s\\n' \"$@\" > \"$ARGS_LOG\"")
        result = subprocess.run([sys.executable, str(SCRIPT), "run", "--provider", "pi",
                                 "--cwd", self.temp_dir.name, "--prompt", "Implement"],
                                text=True, capture_output=True, env=self.env, timeout=10)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("--tools", self.args_log.read_text().splitlines())

    def test_desktop_execute_overlay_preserves_provider_permissions(self):
        app = self.install_desktop()
        result = self.invoke("follow-up", "--provider", "deepseek-harness", "--desktop-app", str(app),
                             "--access", "execute", "--session-id", "dsh-exact-1",
                             "--cwd", self.temp_dir.name, "--prompt", "Implement")
        self.assertEqual(result.returncode, 0, result.stderr)
        patch = json.loads(Path(str(self.args_log) + ".patch").read_text())
        ids = {row.get("id") for row in patch}
        self.assertEqual(ids, {"credentials", "authorization", "deepseek-account"})
        self.assertNotIn("read-only", self.args_log.read_text())

    def test_command_code_run_returns_normalized_result_and_safe_flags(self):
        self.install_fake(
            "command-code",
            "printf '%s\\n' \"$@\" > \"$ARGS_LOG\"\n"
            "printf '%s\\n' '{\"type\":\"event\",\"event\":{\"type\":\"start\"}}'\n"
            "printf '%s\\n' '{\"type\":\"result\",\"subtype\":\"success\",\"sessionId\":\"cc-1\",\"finalText\":\"review complete\"}'",
        )

        result = self.invoke(
            "run", "--provider", "command-code", "--cwd", self.temp_dir.name,
            "--prompt", "Review the parser",
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["status"], "completed")
        self.assertEqual(payload["session_ref"], {"provider": "command-code", "id": "cc-1"})
        self.assertEqual(payload["summary"], "review complete")
        argv = self.args_log.read_text(encoding="utf-8").splitlines()
        self.assertIn("--no-auto-update", argv)
        self.assertIn("--output-format", argv)
        self.assertNotIn("--yolo", argv)

    def test_opencode_follow_up_uses_exact_session_and_plan_agent(self):
        self.install_fake(
            "opencode",
            "printf '%s\\n' \"$@\" > \"$ARGS_LOG\"\n"
            "printf '%s\\n' '{\"type\":\"text\",\"sessionID\":\"oc-7\",\"part\":{\"type\":\"text\",\"text\":\"second answer\"}}'",
        )

        result = self.invoke(
            "follow-up", "--provider", "opencode", "--session-id", "oc-7",
            "--cwd", self.temp_dir.name, "--prompt", "Check the edge case",
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["summary"], "second answer")
        argv = self.args_log.read_text(encoding="utf-8").splitlines()
        self.assertIn("--session", argv)
        self.assertIn("oc-7", argv)
        self.assertIn("--agent", argv)
        self.assertIn("plan", argv)
        self.assertNotIn("--continue", argv)
        self.assertNotIn("--auto", argv)

    def test_claude_code_follow_up_is_read_only_and_resumes_exact_session(self):
        self.install_fake(
            "claude",
            "printf 'env=%s\\n' \"$DISABLE_AUTOUPDATER\" > \"$ARGS_LOG\"\n"
            "printf '%s\\n' \"$@\" >> \"$ARGS_LOG\"\n"
            "printf '%s\\n' '{\"type\":\"result\",\"subtype\":\"success\",\"is_error\":false,\"result\":\"claude review\",\"session_id\":\"cl-9\"}'",
        )

        result = self.invoke(
            "follow-up", "--provider", "claude-code", "--session-id", "cl-9",
            "--cwd", self.temp_dir.name, "--prompt", "Check the edge case",
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["status"], "completed")
        self.assertEqual(payload["summary"], "claude review")
        self.assertEqual(payload["session_ref"], {"provider": "claude-code", "id": "cl-9"})
        argv = self.args_log.read_text(encoding="utf-8").splitlines()
        self.assertIn("env=1", argv)
        self.assertIn("--resume", argv)
        self.assertIn("cl-9", argv)
        self.assertIn("--permission-mode", argv)
        self.assertIn("plan", argv)
        self.assertIn("--tools", argv)
        self.assertIn("Read,Glob,Grep", argv)
        self.assertNotIn("--continue", argv)
        self.assertNotIn("--dangerously-skip-permissions", argv)

    def test_pi_run_limits_tools_and_reads_json_event_stream(self):
        self.install_fake(
            "pi",
            "printf '%s\\n' \"$@\" > \"$ARGS_LOG\"\n"
            "printf '%s\\n' '{\"type\":\"session\",\"id\":\"pi-3\"}'\n"
            "printf '%s\\n' '{\"type\":\"message_update\",\"assistantMessageEvent\":{\"type\":\"text_delta\",\"delta\":\"hello \"}}'\n"
            "printf '%s\\n' '{\"type\":\"message_update\",\"assistantMessageEvent\":{\"type\":\"text_delta\",\"delta\":\"world\"}}'",
        )

        result = self.invoke(
            "run", "--provider", "pi", "--cwd", self.temp_dir.name,
            "--prompt", "Explain the module",
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["summary"], "hello world")
        self.assertEqual(payload["session_ref"]["id"], "pi-3")
        argv = self.args_log.read_text(encoding="utf-8").splitlines()
        self.assertIn("--tools", argv)
        self.assertIn("read,grep,find,ls", argv)

    def test_omp_follow_up_uses_read_only_tools_and_committed_answer(self):
        events = [
            {"type": "session", "id": "omp-exact-1"},
            {"type": "message_update", "assistantMessageEvent":
                {"type": "text_delta", "delta": "discarded draft"}},
            {"type": "message_end", "message": {"role": "assistant", "content":
                [{"type": "text", "text": "final answer"}]}},
        ]
        self.install_fake(
            "omp",
            "printf '%s\\n' \"$@\" > \"$ARGS_LOG\"\n" +
            "if [ \"$1\" = --patch ]; then cp \"$2\" \"$ARGS_LOG.patch\"; fi\n" +
            "\n".join("printf '%s\\n' '" + json.dumps(event) + "'" for event in events),
        )
        result = self.invoke(
            "follow-up", "--provider", "omp", "--session-id", "omp-exact-1",
            "--cwd", self.temp_dir.name, "--prompt", "Inspect the parser",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["summary"], "final answer")
        self.assertEqual(payload["session_ref"], {"provider": "omp", "id": "omp-exact-1"})
        argv = self.args_log.read_text().splitlines()
        self.assertIn("read,grep,glob", argv)
        self.assertIn("--no-extensions", argv)
        self.assertIn("--no-lsp", argv)
        self.assertIn("--resume", argv)
        self.assertIn("omp-exact-1", argv)
        self.assertNotIn("--continue", argv)
        self.assertNotIn("--plan-yolo", argv)

    def install_desktop(self):
        app = Path(self.temp_dir.name) / "DeepSeek Harness 2.app"
        contents = app / "Contents"
        launcher = contents / "Resources/runtime/cli/bin/dsh"
        launcher.parent.mkdir(parents=True)
        (contents / "Info.plist").write_bytes(plistlib.dumps({
            "CFBundleIdentifier": "com.deepseek.dsh",
            "CFBundleShortVersionString": "0.2.1-rc.2",
        }))
        launcher.write_text(
            "#!/bin/sh\n" +
            "printf '%s\\n' \"$@\" > \"$ARGS_LOG\"\n" +
            "if [ \"$1\" = --patch ]; then cp \"$2\" \"$ARGS_LOG.patch\"; fi\n" +
            "printf '%s\\n' '{\"type\":\"session\",\"sessionId\":\"dsh-exact-1\"}'\n" +
            "printf '%s\\n' '{\"type\":\"final\",\"text\":\"desktop answer\"}'\n"
        )
        launcher.chmod(0o755)
        return app

    def test_official_desktop_runs_headless_and_resumes_exact_session(self):
        app = self.install_desktop()
        result = self.invoke(
            "follow-up", "--provider", "deepseek-harness", "--desktop-app", str(app),
            "--cwd", self.temp_dir.name, "--session-id", "dsh-exact-1",
            "--prompt", "Inspect the parser",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["summary"], "desktop answer")
        self.assertEqual(payload["session_ref"]["id"], "dsh-exact-1")
        argv = self.args_log.read_text().splitlines()
        self.assertIn("headless", argv)
        self.assertIn("--json", argv)
        self.assertIn("--patch", argv)
        self.assertIn("--session-id", argv)
        self.assertIn("dsh-exact-1", argv)
        patch = json.loads(Path(str(self.args_log) + ".patch").read_text())
        runner = next(row for row in patch if row.get("id") == "headless-runner")
        self.assertIn("commanderReadOnly", runner["inject"])
        permission = next(row for row in patch if row.get("id") == "permission")
        self.assertEqual(permission["config"]["defaultPreset"], "read-only")
        self.assertIn("read-only", permission["config"]["presets"])
        for name in ("credentials", "authorization", "deepseek-account"):
            self.assertFalse(next(row for row in patch if row.get("id") == name)["disabled"])
        self.assertFalse(Path(argv[argv.index("--patch") + 1]).exists())

    def test_desktop_check_reports_bundled_cli_without_npm(self):
        app = self.install_desktop()
        result = self.invoke("check", "--provider", "deepseek-harness", "--desktop-app", str(app))
        self.assertEqual(result.returncode, 0, result.stderr)
        provider = json.loads(result.stdout)["providers"][0]
        self.assertTrue(provider["available"])
        self.assertEqual(provider["discovery"], "official-desktop")
        self.assertEqual(provider["version"], "0.2.1-rc.2")
        self.assertFalse(provider["experimental"])

    def test_desktop_auto_discovery_uses_official_bundle(self):
        app = self.install_desktop()
        result = self.invoke("check", "--provider", "deepseek-harness")
        provider = json.loads(result.stdout)["providers"][0]
        self.assertEqual(provider["discovery"], "official-desktop")
        self.assertTrue(provider["executable"].startswith(str(app.resolve())))

    def test_desktop_nonzero_exit_remains_failed_with_final_text(self):
        app = self.install_desktop()
        launcher = app / "Contents/Resources/runtime/cli/bin/dsh"
        launcher.write_text(launcher.read_text() + "exit 1\n")
        result = self.invoke("run", "--provider", "deepseek-harness", "--desktop-app", str(app),
                             "--cwd", self.temp_dir.name, "--prompt", "Inspect")
        self.assertEqual(result.returncode, 5)
        self.assertEqual(json.loads(result.stdout)["status"], "failed")

    def test_desktop_rejects_unofficial_bundle(self):
        app = self.install_desktop()
        info = app / "Contents/Info.plist"
        info.write_bytes(plistlib.dumps({"CFBundleIdentifier": "third.party.dsh"}))
        result = self.invoke("run", "--provider", "deepseek-harness", "--desktop-app", str(app),
                             "--cwd", self.temp_dir.name, "--prompt", "Inspect")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.args_log.exists())

    def test_deepseek_harness_execution_is_explicitly_blocked(self):
        result = self.invoke(
            "run", "--provider", "deepseek-harness", "--cwd", self.temp_dir.name,
            "--prompt", "Inspect this repository",
        )

        self.assertEqual(result.returncode, 2)
        self.assertTrue(result.stdout, result.stderr)
        payload = json.loads(result.stdout)
        self.assertEqual(payload["status"], "unsupported")
        self.assertIn("experimental", payload["error"])

    def test_deepseek_harness_check_uses_offline_npm_cache_when_dsh_is_not_on_path(self):
        self.install_fake(
            "npm",
            "printf '%s\\n' \"$@\" > \"$ARGS_LOG\"\n"
            "printf '%s\\n' '0.1.5-rc.1'",
        )

        result = self.invoke("check", "--provider", "deepseek-harness")

        self.assertEqual(result.returncode, 0, result.stderr)
        provider = json.loads(result.stdout)["providers"][0]
        self.assertTrue(provider["available"])
        self.assertEqual(provider["discovery"], "npm-cache")
        self.assertEqual(provider["version"], "0.1.5-rc.1")
        argv = self.args_log.read_text(encoding="utf-8").splitlines()
        self.assertEqual(
            argv,
            [
                "exec",
                "--offline",
                "--yes=false",
                "--package=@deepseek-ai/dsh",
                "--",
                "dsh",
                "--version",
            ],
        )

    def test_follow_up_requires_explicit_session_id(self):
        result = self.invoke(
            "follow-up", "--provider", "pi", "--cwd", self.temp_dir.name,
            "--prompt", "Continue",
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("--session-id", result.stderr)

    def test_check_reports_all_provider_availability(self):
        for executable in ("command-code", "claude", "opencode", "pi", "omp", "dsh"):
            self.install_fake(executable, "printf '%s\\n' 'fake 1.0.0'")

        result = self.invoke("check", "--provider", "all")

        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        providers = {item["provider"]: item for item in payload["providers"]}
        self.assertEqual(
            set(providers),
            {"command-code", "claude-code", "opencode", "pi", "omp", "deepseek-harness"},
        )
        self.assertTrue(all(item["available"] for item in providers.values()))
        self.assertTrue(providers["deepseek-harness"]["experimental"])

    def test_timeout_must_be_positive(self):
        self.install_fake("pi", "printf '%s\\n' '{\"type\":\"session\",\"id\":\"pi-1\"}'")

        result = self.invoke(
            "run", "--provider", "pi", "--cwd", self.temp_dir.name,
            "--prompt", "Inspect", "--timeout", "0",
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("positive integer", result.stderr)


if __name__ == "__main__":
    unittest.main()
