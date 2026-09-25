from pathlib import Path
import os
import shutil
import subprocess
import unittest
import uuid

ROOT = Path(__file__).resolve().parents[1]
LUAU = Path(os.environ.get("LUAU", ROOT.parent / ".tools/luau/luau.exe"))


class RuntimeTests(unittest.TestCase):
    def execute(self, fixture: str, marker: str, source: str, expected: str):
        if not LUAU.is_file():
            self.skipTest("Set LUAU to the official Luau CLI executable")
        directory = ROOT / (".runtime-test-" + uuid.uuid4().hex)
        directory.mkdir()
        try:
            text = (ROOT / "tests" / fixture).read_text(encoding="utf-8")
            self.assertEqual(text.count(marker), 1)
            script = directory / "test.lua"
            script.write_text(text.replace(marker, source), encoding="utf-8")
            result = subprocess.run([str(LUAU), str(script)], capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertIn(expected, result.stdout)
            print(result.stdout.strip())
        finally:
            if directory.resolve().parent != ROOT.resolve() or not directory.name.startswith(".runtime-test-"):
                raise RuntimeError("Unsafe temporary directory")
            shutil.rmtree(directory)

    def test_loader_update_and_failure_paths(self):
        self.execute("loader_cases.lua", "--[[LOADER]]", (ROOT / "loader.lua").read_text(encoding="utf-8"), "LOADER_TESTS_PASSED 24")

    def test_local_backend_download_cancel_and_diagnostics(self):
        source = (ROOT / "src/backend.lua").read_text(encoding="utf-8")
        source = source.replace("__IMAGE_DECODER__", "TestDecoder").replace("__IMAGE_PLANNER__", "TestPlanner")
        self.execute("backend_cases.lua", "--[[BACKEND]]", source, "BACKEND_TESTS_PASSED 8")

    def test_public_gui_options_cancel_and_tool_behavior(self):
        source = (ROOT / "src/client.lua").read_text(encoding="utf-8")
        def section(start, end):
            self.assertEqual(source.count(start), 1)
            self.assertEqual(source.count(end), 1)
            return start + source.split(start, 1)[1].split(end, 1)[0]
        initial = "\n".join(next(line for line in source.splitlines() if line.startswith(prefix))
                            for prefix in ("local infiniteBlocks =", "local toolMode =", "local selectedBlock, speed, yaw ="))
        boundaries = {
            "STARTUP": ("local ENV =", "local Adapter ="),
            "TOGGLE_CALLBACK": ("connect(infiniteButton.Activated, function()", "local function updateBlockCaption()"),
            "BEGIN_BUILD": ("local function beginBuild(origin)", "local function equipPlacementTool()"),
            "CONFIG": ("local samplingIndex, detailIndex =", "local programmaticText ="),
            "QUALITY": ("local qualityPresets =", "local previewFiles, activePreviewPath ="),
            "OPTIONS": ("connect(qualityButton.Activated, function()", "connect(toolModeButton.Activated, function()"),
            "SETTINGS": ("local function conversionSettings()", "connect(convertButton.Activated, function()"),
            "NUMBERS": ("local function numberField(", "local function drawPreview("),
            "PLACEMENT": ("local function equipPlacementTool()", "connect(placeButton.Activated, equipPlacementTool)"),
            "KEYS": ("connect(UserInputService.InputBegan, function(inputObject, processed)", "connect(player.CharacterRemoving, function()"),
            "PROGRESS": ("local function resetProgress(", "local function fitPanel("),
            "TELEMETRY": ("local function sendTelemetry(", "local function createManualToolSelector()"),
            "SPEEDS": ("connect(speedButton.Activated, function()", "local function numberField("),
            "MODES": ("connect(toolModeButton.Activated, function()", "connect(infiniteButton.Activated, function()"),
            "MANUAL_SELECTOR": ("local function createManualToolSelector()", "local function beginBuild(origin)"),
        }
        fixture = (ROOT / "tests/gui_cases.lua").read_text(encoding="utf-8")
        for name, pair in boundaries.items():
            fixture = fixture.replace("--[[" + name + "]]", section(*pair))
        for name in ("INITIAL_OPTION", "SPEED_INITIAL"):
            fixture = fixture.replace("--[[" + name + "]]", initial)
        self.execute("integration_shell.lua", "--[[INTEGRATION]]", fixture, "GUI_OPTION_TESTS_PASSED 30")


if __name__ == "__main__":
    unittest.main()
