"""Compile the adapter and test protocol-shaped local doubles, never live remotes."""
from __future__ import annotations

from pathlib import Path
import os
import subprocess
import unittest
import uuid

ROOT = Path(__file__).resolve().parents[1] / "src"
LUAU = Path(os.environ.get("LUAU", ROOT.parents[1] / ".tools/luau/luau.exe"))
COMPILER = Path(os.environ.get("LUAU_COMPILE", LUAU.with_name("luau-compile.exe")))


class GameAdapterMockTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if not LUAU.is_file() or not COMPILER.is_file():
            raise unittest.SkipTest("Official Luau CLI is not installed in .tools/luau")

    def test_adapter_compiles(self):
        result = subprocess.run([str(COMPILER), "--null", str(ROOT / "game_adapter.lua")],
                                cwd=ROOT, text=True, capture_output=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_local_adapter_behaviors(self):
        source = (ROOT / "game_adapter.lua").read_text(encoding="utf-8")
        fixture = (ROOT.parent / "tests/test_game_adapter.lua").read_text(encoding="utf-8")
        self.assertEqual(fixture.count("--[[ADAPTER_SOURCE]]"), 1)
        temporary = ROOT / (".adapter-mock-" + uuid.uuid4().hex + ".lua")
        try:
            temporary.write_text(fixture.replace("--[[ADAPTER_SOURCE]]", source), encoding="utf-8")
            result = subprocess.run([str(LUAU), str(temporary)], cwd=ROOT,
                                    text=True, capture_output=True, timeout=90)
        finally:
            if temporary.parent.resolve() != ROOT.resolve() or not temporary.name.startswith(".adapter-mock-"):
                raise RuntimeError("Refusing cleanup outside the generated fixture path")
            temporary.unlink(missing_ok=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("MOCK_GAME_ADAPTER_TESTS_PASSED 118", result.stdout)
        print(result.stdout.strip())


if __name__ == "__main__":
    unittest.main(verbosity=2)
