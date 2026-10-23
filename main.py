"""CreOS application launcher."""
from __future__ import annotations

import json
import sys
from pathlib import Path
from PySide6.QtCore import QObject, Property, QTimer, QUrl, QCoreApplication, Qt
from PySide6.QtWebEngineQuick import QtWebEngineQuick
from PySide6.QtWidgets import QApplication
from setup_wizard import authenticate_desktop
from creos_updater import UpdateManager
from PySide6.QtQml import QQmlApplicationEngine
from state_store import CreosData
from files_store import CreosFiles

BASE = Path(__file__).resolve().parent

class ReleaseStore(QObject):
    def __init__(self):
        super().__init__()
        self._data = json.loads((BASE / "data" / "releases.json").read_text(encoding="utf-8"))

    @Property(str, constant=True)
    def latestVersion(self):
        return self._data["version"]

    @Property(str, constant=True)
    def channel(self):
        return self._data["channel"]

    @Property(str, constant=True)
    def repository(self):
        return self._data["repository"]

    @Property("QVariantList", constant=True)
    def releases(self):
        return self._data["releases"]

def main():
    smoke_test = "--smoke-test" in sys.argv
    qt_args = [arg for arg in sys.argv if arg != "--smoke-test"]
    # Qt WebEngine must share a rendering context with Qt Quick.
    QCoreApplication.setAttribute(Qt.AA_ShareOpenGLContexts)
    QtWebEngineQuick.initialize()
    app = QApplication(qt_args)
    app.setApplicationName("CreOS")
    if not smoke_test and not authenticate_desktop():
        return 0
    engine = QQmlApplicationEngine()
    messages = []

    def on_warnings(errors):
        for err in errors:
            message = err.toString()
            messages.append(message)
            print("CreOS QML:", message, file=sys.stderr)

    engine.warnings.connect(on_warnings)
    store = ReleaseStore()
    creos_data = CreosData()
    file_store = CreosFiles(BASE)
    update_manager = UpdateManager(store.latestVersion, auto_check=not smoke_test)
    creos_data.dataError.connect(lambda message: print("CreOS data:", message, file=sys.stderr))
    engine.rootContext().setContextProperty("releaseStore", store)
    engine.rootContext().setContextProperty("creosData", creos_data)
    engine.rootContext().setContextProperty("fileStore", file_store)
    engine.rootContext().setContextProperty("updateManager", update_manager)
    engine.load(QUrl.fromLocalFile(str(BASE / "ui" / "Main.qml")))
    if not engine.rootObjects():
        print("CreOS: không tải được giao diện QML.", file=sys.stderr)
        return 1

    if smoke_test:
        # Exercise every registered application, not just the first screen.
        window = engine.rootObjects()[0]
        app_count = int(window.property("registeredAppCount"))
        for index in range(app_count):
            QTimer.singleShot(250 + index * 470,
                              lambda current=index: window.setProperty("smokeAppIndex", current))

        def verify_multiwindow():
            visible = int(window.property("visibleAppCount"))
            if visible != app_count:
                messages.append(
                    f"Expected {app_count} app windows concurrently, got {visible}"
                )

        QTimer.singleShot(4100, verify_multiwindow)
        QTimer.singleShot(4500, app.quit)
        code = app.exec()
        if messages:
            print(f"CreOS: {len(messages)} QML warning(s) detected.", file=sys.stderr)
            return 1
        print("CreOS: smoke test passed.")
        return code

    return app.exec()

if __name__ == "__main__":
    raise SystemExit(main())
