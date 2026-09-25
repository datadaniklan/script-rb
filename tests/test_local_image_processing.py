"""Compile and exercise the standalone Luau RGBA planner without Roblox or HTTP."""
from pathlib import Path
import os
import subprocess
import unittest
import uuid

ROOT = Path(__file__).resolve().parents[1] / "src"
LUAU = Path(os.environ.get("LUAU", ROOT.parents[1] / ".tools/luau/luau.exe"))
COMPILER = Path(os.environ.get("LUAU_COMPILE", LUAU.with_name("luau-compile.exe")))


class LocalImagePlannerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if not LUAU.is_file() or not COMPILER.is_file():
            raise unittest.SkipTest("Official Luau CLI is unavailable")

    def test_compiles(self):
        result = subprocess.run([str(COMPILER), "--null", str(ROOT / "local_image_processing.lua")],
                                capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_local_planner(self):
        source = (ROOT / "local_image_processing.lua").read_text(encoding="utf-8")
        fixture = (ROOT.parent / "tests/test_local_image_processing.lua").read_text(encoding="utf-8")
        self.assertEqual(fixture.count("--[[LOCAL_PLANNER_SOURCE]]"), 1)
        temporary = ROOT / (".local-planner-test-" + uuid.uuid4().hex + ".lua")
        try:
            temporary.write_text(fixture.replace("--[[LOCAL_PLANNER_SOURCE]]", source), encoding="utf-8")
            result = subprocess.run([str(LUAU), str(temporary)], capture_output=True, text=True, timeout=90)
        finally:
            if temporary.parent.resolve() != ROOT.resolve() or not temporary.name.startswith(".local-planner-test-"):
                raise RuntimeError("Refusing cleanup outside the generated fixture")
            temporary.unlink(missing_ok=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("LOCAL_IMAGE_PLANNER_TESTS_PASSED 26", result.stdout)
        print(result.stdout.strip())


if __name__ == "__main__":
    unittest.main(verbosity=2)
