"""Regression checks for the fullscreen CreOS shell and app motion contract.

These are static safety checks; QML smoke testing is handled separately.
"""
from pathlib import Path
import json
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ShellContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.desktop = (ROOT / "ui/Main.qml").read_text(encoding="utf-8")
        cls.chrome = (ROOT / "ui/components/AppWindow.qml").read_text(encoding="utf-8")
        cls.about = (ROOT / "ui/apps/CreosApp.qml").read_text(encoding="utf-8")
        cls.release = json.loads((ROOT / "data/releases.json").read_text(encoding="utf-8"))

    def test_fullscreen_is_default_with_f11_exit(self):
        self.assertIn("visibility: Window.FullScreen", self.desktop)
        self.assertIn('sequence: "F11"', self.desktop)
        self.assertIn("function toggleFullscreen()", self.desktop)

    def test_dock_overlays_workspace(self):
        self.assertIn("anchors.bottom: scene.bottom", self.desktop)
        self.assertNotIn("anchors.bottom: dock.top", self.desktop.split("id: workspace", 1)[1].split("id: dock", 1)[0])
        self.assertIn("height: 61", self.desktop)
        self.assertIn("z: 15", self.desktop)

    def test_multiple_windows_and_motion(self):
        self.assertIn("id: appWindows", self.desktop)
        self.assertIn("delegate: AppWindow", self.desktop)
        self.assertIn("target: motionOffset", self.chrome)
        self.assertIn('property: "opacity"', self.chrome)
        self.assertIn('property: "scale"', self.chrome)

    def test_single_corner_contour_and_resize(self):
        self.assertIn("id: surface", self.chrome)
        self.assertEqual(8, self.chrome.count("ResizeHandle {"))
        self.assertNotIn("maskSource:", self.chrome)
        self.assertNotIn("radius: 21", self.chrome)

    def test_no_preview_or_roadmap_in_interface(self):
        self.assertNotIn("Developer Preview", self.desktop)
        self.assertNotIn("ROADMAP", self.about)
        self.assertNotIn("Bản phát hành", self.about)
        self.assertEqual("1.3.0", self.release["version"])


if __name__ == "__main__":
    unittest.main()
