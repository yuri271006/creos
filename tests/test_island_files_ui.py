"""CreOS Island and Files UI wiring regression checks."""
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UI = ROOT / "ui"


class IslandAndFilesUiTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.desktop = (UI / "Main.qml").read_text(encoding="utf-8")
        cls.island = (UI / "components/CreosIsland.qml").read_text(encoding="utf-8")
        cls.files = (UI / "apps/FilesApp.qml").read_text(encoding="utf-8")
        cls.registry = (UI / "system/Apps.qml").read_text(encoding="utf-8")

    def test_island_replaces_full_width_bar(self):
        self.assertIn("CreosIsland {", self.desktop)
        self.assertNotIn("id: bar", self.desktop)
        self.assertIn("anchors.top: scene.top", self.desktop)
        self.assertIn("z: 40", self.desktop)

    def test_island_animations_and_shortcuts(self):
        self.assertIn("Behavior on width", self.island)
        self.assertIn("Behavior on height", self.island)
        self.assertIn('cmd:"files"', self.island)
        self.assertIn('cmd:"settings"', self.island)
        self.assertIn("notifyIsland(", self.desktop)

    def test_files_registered_and_backend_is_exposed(self):
        self.assertIn('"id": "files"', self.registry)
        self.assertIn('"component": "FilesApp.qml"', self.registry)
        self.assertIn('root.openApp(System.Apps.findIndex("files"))', self.desktop)
        self.assertIn("fileStore.selectArea(", self.files)
        self.assertIn("fileStore.saveText(", self.files)

    def test_files_uses_system_design(self):
        self.assertIn("System.Theme", self.files)
        self.assertIn("SurfaceCard {", self.files)
        self.assertIn("SidebarItem {", self.files)


if __name__ == "__main__":
    unittest.main()
