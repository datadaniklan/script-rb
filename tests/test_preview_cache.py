"""Exercise the actual preview journal and GUI cache callbacks without Roblox."""
from pathlib import Path
import os
import shutil
import subprocess
import unittest
import uuid

ROOT = Path(__file__).resolve().parents[1]
LUAU = Path(os.environ.get("LUAU", ROOT.parent / ".tools/luau/luau.exe"))


def section(source, start, stop):
    if source.count(start) != 1 or source.count(stop) != 1:
        raise AssertionError("Preview test source boundary changed")
    return start + source.split(start, 1)[1].split(stop, 1)[0]


class PreviewCacheTests(unittest.TestCase):
    def test_journal_boundaries_and_preview_lifecycle(self):
        if not LUAU.is_file():
            self.skipTest("Set LUAU to the official Luau CLI executable")
        backend = (ROOT / "src/backend.lua").read_text(encoding="utf-8")
        client = (ROOT / "src/client.lua").read_text(encoding="utf-8")
        source = (ROOT / "tests/test_preview_cache.lua").read_text(encoding="utf-8")
        source = source.replace("--[[JOURNAL]]", section(backend, "local function validPreviewPath", "function Backend.report"))
        source = source.replace("--[[PREVIEW]]", section(client, "local function deletePreviewFile", "local function safeError"))
        directory = ROOT / (".preview-test-" + uuid.uuid4().hex)
        directory.mkdir()
        try:
            script = directory / "preview.lua"
            script.write_text(source, encoding="utf-8")
            result = subprocess.run([str(LUAU), str(script)], text=True, capture_output=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn("PREVIEW_CACHE_CASES 11", result.stdout)
            print(result.stdout.strip())
        finally:
            if directory.resolve().parent != ROOT.resolve() or not directory.name.startswith(".preview-test-"):
                raise RuntimeError("Unsafe temporary directory")
            shutil.rmtree(directory)


if __name__ == "__main__":
    unittest.main()
