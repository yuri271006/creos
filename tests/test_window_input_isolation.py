"""Input isolation contract for overlapped CreOS app windows.

Static guardrails complement GUI smoke tests; a real desktop interaction
test is still needed for Qt WebEngine and pointer-grab behavior.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
FRAME = (ROOT / "ui/components/AppWindow.qml").read_text(encoding="utf-8")
MAIN = (ROOT / "ui/Main.qml").read_text(encoding="utf-8")


class WindowInputIsolationTests(unittest.TestCase):
    def test_only_active_window_controls_are_enabled(self):
        self.assertIn("property bool activeWindow: false", FRAME)
        self.assertIn("onActiveWindowChanged:", FRAME)
        self.assertIn("body.item.enabled = activeWindow", FRAME)
        self.assertIn("onLoaded: if (item) item.enabled = host.activeWindow", FRAME)

    def test_inactive_windows_block_click_and_wheel(self):
        self.assertIn("id: inactiveInputBarrier", FRAME)
        self.assertIn("visible: !host.activeWindow && host.loaded", FRAME)
        self.assertIn("mouse.accepted = true", FRAME)
        self.assertGreaterEqual(FRAME.count("wheel.accepted = true"), 2)
        self.assertIn("z: 90", FRAME)

    def test_shell_exclusively_selects_window(self):
        self.assertIn("activeWindow: windowRecord.opened && !windowRecord.minimized", MAIN)
        self.assertIn("root.activeAppIndex === index", MAIN)
        self.assertIn("z: windowRecord.order", MAIN)
        self.assertIn("root.focusApp(index)", MAIN)

    def test_resize_requires_active_window(self):
        self.assertEqual(FRAME.count("enabled: host.activeWindow"), 8)


if __name__ == "__main__":
    unittest.main()
