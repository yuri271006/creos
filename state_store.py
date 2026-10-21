"""Persistent state shared by small CreOS applications.

Only local files under the user's XDG data directory are used; no network.
"""
from __future__ import annotations

import json
import os
from datetime import datetime
from pathlib import Path
from uuid import uuid4

from PySide6.QtCore import QObject, Property, Signal, Slot

WALLPAPERS = {"aurora", "peach", "midnight"}


def data_directory() -> Path:
    root = os.environ.get("XDG_DATA_HOME")
    base = Path(root).expanduser() if root else Path.home() / ".local" / "share"
    return base / "CreOS"


class CreosData(QObject):
    notesChanged = Signal()
    wallpaperChanged = Signal()
    dataError = Signal(str)

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self.path = data_directory() / "state.json"
        self._notes: list[dict] = []
        self._wallpaper = "aurora"
        self._load()

    def _load(self) -> None:
        try:
            if not self.path.exists():
                return
            data = json.loads(self.path.read_text(encoding="utf-8"))
            if not isinstance(data, dict):
                return
            raw = data.get("notes", [])
            if isinstance(raw, list):
                self._notes = [
                    {
                        "id": item["id"],
                        "title": str(item.get("title", ""))[:200],
                        "body": str(item.get("body", ""))[:100000],
                        "updated": str(item.get("updated", "")),
                    }
                    for item in raw[:1000]
                    if isinstance(item, dict) and isinstance(item.get("id"), str)
                ]
            choice = data.get("wallpaper", "aurora")
            if choice in WALLPAPERS:
                self._wallpaper = choice
        except (OSError, ValueError, TypeError, KeyError) as exc:
            self.dataError.emit(f"Không thể đọc dữ liệu CreOS: {exc}")

    def _save(self) -> None:
        temp = self.path.with_suffix(".tmp")
        try:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            temp.write_text(
                json.dumps(
                    {"notes": self._notes, "wallpaper": self._wallpaper},
                    ensure_ascii=False, indent=2,
                ),
                encoding="utf-8",
            )
            os.replace(temp, self.path)
        except OSError as exc:
            self.dataError.emit(f"Không thể lưu dữ liệu CreOS: {exc}")
            try:
                temp.unlink(missing_ok=True)
            except OSError:
                pass

    @Property("QVariantList", notify=notesChanged)
    def notes(self) -> list[dict]:
        return [dict(note) for note in self._notes]

    @Slot(result=str)
    def createNote(self) -> str:
        identity = str(uuid4())
        self._notes.insert(0, {
            "id": identity, "title": "Ghi chú mới", "body": "",
            "updated": datetime.now().strftime("%d/%m/%Y %H:%M"),
        })
        self._save()
        self.notesChanged.emit()
        return identity

    @Slot(str, result="QVariantMap")
    def getNote(self, identity: str) -> dict:
        for note in self._notes:
            if note["id"] == identity:
                return dict(note)
        return {}

    @Slot(str, str, str)
    def saveNote(self, identity: str, title: str, body: str) -> None:
        for note in self._notes:
            if note["id"] == identity:
                title = title[:200]
                body = body[:100000]
                if note["title"] == title and note["body"] == body:
                    return
                note["title"] = title
                note["body"] = body
                note["updated"] = datetime.now().strftime("%d/%m/%Y %H:%M")
                self._save()
                self.notesChanged.emit()
                return

    @Slot(str)
    def deleteNote(self, identity: str) -> None:
        old_length = len(self._notes)
        self._notes = [n for n in self._notes if n["id"] != identity]
        if len(self._notes) != old_length:
            self._save()
            self.notesChanged.emit()

    @Property(str, notify=wallpaperChanged)
    def wallpaper(self) -> str:
        return self._wallpaper

    @Slot(str)
    def setWallpaper(self, choice: str) -> None:
        if choice not in WALLPAPERS or choice == self._wallpaper:
            return
        self._wallpaper = choice
        self._save()
        self.wallpaperChanged.emit()
