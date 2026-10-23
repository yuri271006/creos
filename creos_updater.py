"""Safe release-based updater for installed CreOS builds.

Checks GitHub Releases without blocking Qt. Automatically stages an update
after validating GitHub's SHA-256 asset digest. Installation is user-approved.
Never execute a source commit or automatically overwrite running binaries.
"""
from __future__ import annotations
import hashlib
import json
import os
import platform
import re
import subprocess
import threading
import urllib.request
from pathlib import Path
from PySide6.QtCore import QObject, Property, QTimer, Signal, Slot
from creos_profile import base_data_dir

REPO = "yuri271006/creos"
API = f"https://api.github.com/repos/{REPO}/releases/latest"
MAX_BYTES = 900 * 1024 * 1024


def newer_version(latest: str, installed: str) -> bool:
    def parts(s: str) -> tuple[int, ...]:
        if not re.fullmatch(r"v?\d+(?:\.\d+){1,3}", s):
            raise ValueError("Version không hợp lệ.")
        return tuple(int(n) for n in s.lstrip("v").split("."))
    return parts(latest) > parts(installed)


def appropriate_asset(assets: list[dict], version: str, system: str) -> dict | None:
    name = f"CreOS-Setup-{version}.exe" if system == "Windows" else f"creos_{version}_amd64.deb"
    for asset in assets:
        if asset.get("name") == name:
            digest = asset.get("digest") or ""
            url = asset.get("browser_download_url") or ""
            if (re.fullmatch(r"sha256:[a-fA-F0-9]{64}", digest)
                and url.startswith(f"https://github.com/{REPO}/releases/download/")
                and 0 < int(asset.get("size", 0)) <= MAX_BYTES):
                return asset
    return None


class UpdateManager(QObject):
    changed = Signal()
    _checked = Signal(object)
    _downloaded = Signal(object)
    _progress = Signal(int)

    def __init__(self, current_version: str, parent=None, auto_check: bool = True):
        super().__init__(parent)
        self._current = current_version
        self._available = ""
        self._status = "Đã sẵn sàng"
        self._busy = False
        self._ready_path: Path | None = None
        self._asset: dict | None = None
        self._checked.connect(self._finish_check)
        self._downloaded.connect(self._finish_download)
        self._progress.connect(self._show_progress)
        self._timer = QTimer(self)
        self._timer.setInterval(6 * 60 * 60 * 1000)
        self._timer.timeout.connect(self.checkNow)
        if auto_check:
            self._timer.start()
            QTimer.singleShot(9000, self.checkNow)

    @Property(str, constant=True)
    def currentVersion(self) -> str:
        return self._current

    @Property(str, notify=changed)
    def availableVersion(self) -> str:
        return self._available

    @Property(str, notify=changed)
    def status(self) -> str:
        return self._status

    @Property(bool, notify=changed)
    def busy(self) -> bool:
        return self._busy

    @Property(bool, notify=changed)
    def ready(self) -> bool:
        return self._ready_path is not None and self._ready_path.is_file()

    def _set(self, status: str, busy: bool) -> None:
        self._status = status
        self._busy = busy
        self.changed.emit()

    @Slot()
    def checkNow(self) -> None:
        if self._busy or platform.system() not in {"Linux", "Windows"}:
            return
        self._set("Đang kiểm tra bản cập nhật...", True)

        def work():
            try:
                request = urllib.request.Request(API, headers={
                    "Accept": "application/vnd.github+json",
                    "User-Agent": f"CreOS/{self._current}",
                })
                with urllib.request.urlopen(request, timeout=16) as response:
                    data = json.load(response)
                tag = data.get("tag_name", "").lstrip("v")
                if not newer_version(tag, self._current):
                    self._checked.emit({"latest": ""})
                    return
                asset = appropriate_asset(data.get("assets", []), tag, platform.system())
                self._checked.emit({"latest": tag, "asset": asset})
            except Exception as exc:
                self._checked.emit({"error": str(exc)})

        threading.Thread(target=work, daemon=True).start()

    @Slot(object)
    def _finish_check(self, result: dict) -> None:
        if "error" in result:
            self._set("Chưa kiểm tra được cập nhật (kết nối mạng/GitHub).", False)
            return
        self._available = result.get("latest", "")
        self._asset = result.get("asset")
        if not self._available:
            self._set("CreOS đã là bản mới nhất.", False)
        elif not self._asset:
            self._set("Có phiên bản mới nhưng chưa có bộ cài phù hợp.", False)
        else:
            self._set("Có CreOS " + self._available + ". Đang tải bộ cài...", True)
            self._download_in_thread()
        self.changed.emit()

    def _download_in_thread(self) -> None:
        asset = dict(self._asset)
        version = self._available

        def work():
            folder = base_data_dir() / "updates"
            final = folder / asset["name"]
            temporary = folder / (asset["name"] + ".partial")
            try:
                folder.mkdir(parents=True, exist_ok=True)
                h = hashlib.sha256()
                request = urllib.request.Request(asset["browser_download_url"], headers={
                    "User-Agent": "CreOS-Updater",
                })
                received = 0
                expected_size = int(asset["size"])
                with urllib.request.urlopen(request, timeout=40) as response, temporary.open("wb") as out:
                    while True:
                        chunk = response.read(1024 * 1024)
                        if not chunk:
                            break
                        received += len(chunk)
                        if received > MAX_BYTES or received > expected_size:
                            raise ValueError("Bộ cài vượt dung lượng khai báo.")
                        out.write(chunk)
                        h.update(chunk)
                        self._progress.emit(int(received * 100 / expected_size))
                if received != expected_size:
                    raise ValueError("Tải chưa đầy đủ.")
                if h.hexdigest().lower() != asset["digest"].split(":", 1)[1].lower():
                    raise ValueError("SHA-256 không khớp. Hủy bản cập nhật.")
                os.replace(temporary, final)
                self._downloaded.emit({"path": str(final), "version": version})
            except Exception as exc:
                try:
                    temporary.unlink(missing_ok=True)
                except OSError:
                    pass
                self._downloaded.emit({"error": str(exc)})

        threading.Thread(target=work, daemon=True).start()

    @Slot(int)
    def _show_progress(self, pct: int) -> None:
        if self._busy:
            self._status = "Đang tải cập nhật: " + str(pct) + "%"
            self.changed.emit()

    @Slot(object)
    def _finish_download(self, result: dict) -> None:
        if "error" in result:
            self._set("Không tải được: " + result["error"][:160], False)
            return
        self._ready_path = Path(result["path"])
        self._set("Đã tải và kiểm tra SHA-256. Sẵn sàng cài CreOS " + result["version"], False)

    @Slot(result=bool)
    def installUpdate(self) -> bool:
        """Open OS installer after explicit user click; never elevate silently."""
        if not self.ready:
            self._set("Chưa có bộ cài hợp lệ.", False)
            return False
        try:
            if platform.system() == "Windows":
                os.startfile(str(self._ready_path))
            else:
                subprocess.Popen(["xdg-open", str(self._ready_path)],
                                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            self._set("Đã mở bộ cài. Hãy lưu công việc rồi đóng CreOS.", False)
            return True
        except (OSError, ValueError) as exc:
            self._set("Không thể mở bộ cài: " + str(exc), False)
            return False
