"""CreOS Human Interface v2 - architecture and performance contracts.

Static checks complement the Qt/QML smoke test; they cannot prove FPS.
"""
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UI = ROOT / "ui"
APPS = ["CreosApp", "NotesApp", "CalculatorApp", "ClockApp", "SettingsApp", "BrowserApp", "FilesApp"]
COMPONENTS = ["AppPage", "SurfaceCard", "SystemButton", "SegmentedTabs", "SectionLabel"]


class HumanInterfaceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tokens = (UI / "system" / "Theme.qml").read_text(encoding="utf-8")

    def test_shared_components_exist(self):
        for component in COMPONENTS:
            with self.subTest(component=component):
                src = (UI / "components" / (component + ".qml")).read_text(encoding="utf-8")
                self.assertIn("System.Theme", src)

    def test_tokens_define_motion_and_surface(self):
        for token in [
            "readonly property color canvas", "readonly property color surface",
            "readonly property color accent", "readonly property color ink",
            "readonly property int minimumTarget", "readonly property int typeTitle",
            "readonly property int typeBody", "readonly property int typeAction",
            "readonly property int durationQuick",
            "readonly property int durationNormal",
            "readonly property int durationSlow",
        ]:
            with self.subTest(token=token):
                self.assertIn(token, self.tokens)

    def test_builtin_apps_use_system_tokens(self):
        for app in APPS:
            with self.subTest(app=app):
                code = (UI / "apps" / (app + ".qml")).read_text(encoding="utf-8")
                self.assertIn('import "../components"', code)
                self.assertIn("System.Theme", code)
                self.assertNotIn("ShaderEffectSource {", code)
                self.assertNotIn("MultiEffect {", code)

    def test_clock_updates_on_demand(self):
        src = (UI / "apps/ClockApp.qml").read_text(encoding="utf-8")
        self.assertIn("interval: 1000", src)
        self.assertIn("interval: 50", src)
        self.assertIn("running: clock.running &&", src)

    def test_browser_is_lazy_loaded(self):
        src = (UI / "apps/BrowserApp.qml").read_text(encoding="utf-8")
        self.assertIn("property bool engineStarted: false", src)
        self.assertIn("active: browser.engineStarted", src)
        self.assertIn("asynchronous: true", src)

    def test_shared_button_has_minimum_hit_area(self):
        src = (UI / "components/SystemButton.qml").read_text(encoding="utf-8")
        self.assertIn("implicitHeight: System.Theme.minimumTarget", src)


if __name__ == "__main__":
    unittest.main()
