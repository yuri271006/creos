"""CreOS Developer Preview launcher."""
from __future__ import annotations

import json
import sys
from pathlib import Path
from PySide6.QtCore import QObject, Property, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

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
    app = QGuiApplication(sys.argv)
    app.setApplicationName("CreOS")
    engine = QQmlApplicationEngine()
    store = ReleaseStore()
    engine.rootContext().setContextProperty("releaseStore", store)
    engine.load(QUrl.fromLocalFile(str(BASE / "ui" / "Main.qml")))
    if not engine.rootObjects():
        print("CreOS: không tải được giao diện QML.", file=sys.stderr)
        return 1
    return app.exec()

if __name__ == "__main__":
    raise SystemExit(main())
