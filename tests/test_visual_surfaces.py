"""CreOS icon and surface rendering contracts.

No Qt installation is needed for these regression checks; the full Qt Quick
scene still needs runtime validation on Ubuntu.
"""
import unittest
from pathlib import Path
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
UI = ROOT / "ui"
IDS = ["about-creos", "notes", "calculator", "clock", "browser", "settings", "files"]


class VisualSurfaceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.main = (UI / "Main.qml").read_text(encoding="utf-8")
        cls.app_icon = (UI / "components/AppIcon.qml").read_text(encoding="utf-8")
        cls.app_shell = (UI / "components/AppWindow.qml").read_text(encoding="utf-8")

    def test_original_vector_icons_are_valid_svg(self):
        for identity in IDS:
            with self.subTest(icon=identity):
                path = UI / "assets" / "icons" / (identity + ".svg")
                self.assertTrue(path.is_file())
                parsed = ET.parse(path)
                self.assertTrue(parsed.getroot().tag.endswith("svg"))
                self.assertGreater(path.stat().st_size, 450)

    def test_no_rectangular_blur_behind_rounded_dock_or_launcher(self):
        self.assertNotIn("dockCapture", self.main)
        self.assertNotIn("libraryCapture", self.main)
        self.assertIn("id: dock", self.main)
        self.assertIn("id: launcherLayer", self.main)
        self.assertIn('appId: pinnedItem.modelData.id', self.main)
        self.assertIn('appId: launcherItem.modelData.id', self.main)

    def test_icons_are_not_font_characters(self):
        self.assertIn("Image {", self.app_icon)
        self.assertIn("../assets/icons/", self.app_icon)
        self.assertNotIn("font.pixelSize", self.app_icon)
        self.assertIn("appId", self.app_icon)
        self.assertIn("border.width: 0", self.app_icon)
        self.assertIn("mipmap: false", self.app_icon)

    def test_svg_assets_only_paint_symbols(self):
        for identity in IDS:
            with self.subTest(icon=identity):
                source = (UI / "assets" / "icons" / (identity + ".svg")).read_text(encoding="utf-8")
                self.assertNotIn('fill="url(#base)"', source)
                self.assertNotIn('stroke-opacity=".35"', source)
                self.assertNotIn("clipPath", source)
                self.assertIn('viewBox="0 0 96 96"', source)

    def test_app_window_has_only_one_round_outline(self):
        self.assertIn("id: surface", self.app_shell)
        self.assertNotIn("maskSource:", self.app_shell)
        self.assertNotIn("layer.effect:", self.app_shell)
        self.assertEqual(8, self.app_shell.count("ResizeHandle {"))


if __name__ == "__main__":
    unittest.main()
