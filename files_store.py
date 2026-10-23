"""CreOS Files: safe read-only sys and writable user-owned data.

sys maps to selected project files in the installed CreOS directory; it does
NOT expose arbitrary Ubuntu /sys or the host filesystem.
data lives under the XDG data directory and never under the Git repository.
"""
from __future__ import annotations

from datetime import datetime
from pathlib import Path
import os
import tempfile

from PySide6.QtCore import QObject, Property, Signal, Slot

from state_store import data_directory

MAX_TEXT_BYTES = 512 * 1024
VISIBLE_LIMIT = 500
ALLOWED_TEXT = {".txt", ".md", ".json", ".qml", ".py", ".js", ".css", ".html", ".yaml", ".yml", ".toml", ".sh", ".svg", ".csv"}
SYSTEM_VISIBLE = {"ui", "data", "main.py", "state_store.py", "requirements.txt", "run.sh", "README.md"}


class CreosFiles(QObject):
    changed = Signal()
    messageChanged = Signal()

    def __init__(self, system_root: Path, user_root: Path | None = None, parent=None):
        super().__init__(parent)
        self._sys_root = system_root.resolve()
        self._data_root = (user_root if user_root is not None else data_directory() / "data").resolve()
        self._area = "data"
        self._relative = Path(".")
        self._rows: list[dict] = []
        self._message = ""
        try:
            self._data_root.mkdir(parents=True, exist_ok=True)
            self.refresh()
        except OSError as exc:
            self._error(f"Không thể tạo thư mục dữ liệu: {exc}")

    def _root(self) -> Path:
        return self._sys_root if self._area == "sys" else self._data_root

    @staticmethod
    def _validate_name(name: str) -> str:
        if not isinstance(name, str) or not name or name in {".", ".."}:
            raise ValueError("Tên tệp/thư mục không hợp lệ.")
        if name.startswith(".") or "/" in name or "\\" in name or "\x00" in name:
            raise ValueError("Tên không được chứa dấu phân cách hoặc bắt đầu bằng dấu chấm.")
        if len(name) > 160 or any(ord(char) < 32 for char in name):
            raise ValueError("Tên tệp quá dài hoặc chứa ký tự không hợp lệ.")
        return name

    def _inside(self, path: Path, *, allow_missing: bool = False) -> Path:
        root = self._root()
        # Resolve traversed symlinks and deny any file pointing outside the root.
        resolved = path.resolve(strict=not allow_missing)
        if not resolved.is_relative_to(root):
            raise ValueError("Không thể truy cập bên ngoài khu vực CreOS.")
        return resolved

    def _current(self) -> Path:
        return self._inside(self._root() / self._relative)

    def _child(self, name: str, *, missing: bool = False) -> Path:
        self._validate_name(name)
        current = self._current()
        candidate = current / name
        if candidate.is_symlink():
            raise ValueError("Không cho phép truy cập liên kết tượng trưng.")
        return self._inside(candidate, allow_missing=missing)

    def _error(self, value: str) -> None:
        self._message = value
        self.messageChanged.emit()

    @Property(str, notify=changed)
    def area(self) -> str:
        return self._area

    @Property(str, notify=changed)
    def currentPath(self) -> str:
        parts = [] if self._relative == Path(".") else list(self._relative.parts)
        return self._area + ("/" + "/".join(parts) if parts else "")

    @Property(bool, notify=changed)
    def readOnly(self) -> bool:
        return self._area == "sys"

    @Property("QVariantList", notify=changed)
    def entries(self) -> list[dict]:
        return [dict(row) for row in self._rows]

    @Property(str, notify=messageChanged)
    def message(self) -> str:
        return self._message

    @Slot(str)
    def selectArea(self, area: str) -> None:
        if area not in {"sys", "data"}:
            self._error("Khu vực không tồn tại.")
            return
        self._area = area
        self._relative = Path(".")
        self.refresh()

    @Slot()
    def refresh(self) -> None:
        try:
            current = self._current()
            rows = []
            for entry in current.iterdir():
                if entry.name.startswith(".") or entry.is_symlink():
                    continue
                if self._area == "sys" and self._relative == Path(".") and entry.name not in SYSTEM_VISIBLE:
                    continue
                if len(rows) >= VISIBLE_LIMIT:
                    break
                try:
                    stat = entry.stat()
                    rows.append({
                        "name": entry.name,
                        "directory": entry.is_dir(),
                        "size": "Thư mục" if entry.is_dir() else self._format_size(stat.st_size),
                        "updated": datetime.fromtimestamp(stat.st_mtime).strftime("%d/%m/%Y %H:%M"),
                    })
                except OSError:
                    continue
            rows.sort(key=lambda item: (not item["directory"], item["name"].casefold()))
            self._rows = rows
            self._error("")
        except (OSError, ValueError) as exc:
            self._rows = []
            self._error(str(exc))
        self.changed.emit()

    @staticmethod
    def _format_size(value: int) -> str:
        if value < 1024:
            return f"{value} B"
        if value < 1024 * 1024:
            return f"{value / 1024:.1f} KB"
        return f"{value / (1024 * 1024):.1f} MB"

    @Slot(str)
    def enter(self, name: str) -> None:
        try:
            target = self._child(name)
            if not target.is_dir():
                raise ValueError("Đây không phải thư mục.")
            self._relative = target.relative_to(self._root())
            self.refresh()
        except (ValueError, OSError) as exc:
            self._error(str(exc))

    @Slot()
    def goUp(self) -> None:
        if self._relative != Path("."):
            self._relative = self._relative.parent
            self.refresh()

    def _writable(self) -> None:
        if self._area != "data":
            raise ValueError("Khu vực sys chỉ cho phép xem.")

    @Slot(str, result=bool)
    def createFolder(self, name: str) -> bool:
        try:
            self._writable()
            self._child(name, missing=True).mkdir(exist_ok=False)
            self.refresh()
            return True
        except (ValueError, OSError) as exc:
            self._error(str(exc))
            return False

    @Slot(str, result=bool)
    def createTextFile(self, name: str) -> bool:
        try:
            self._writable()
            path = self._child(name, missing=True)
            if path.suffix.lower() not in ALLOWED_TEXT:
                raise ValueError("Chỉ hỗ trợ tạo tệp văn bản (.txt, .md, .json...).")
            with path.open("x", encoding="utf-8"):
                pass
            self.refresh()
            return True
        except (ValueError, OSError) as exc:
            self._error(str(exc))
            return False

    @Slot(str, result=str)
    def readText(self, name: str) -> str:
        try:
            path = self._child(name)
            if not path.is_file() or path.suffix.lower() not in ALLOWED_TEXT:
                raise ValueError("Tệp này không hỗ trợ xem như văn bản.")
            if path.stat().st_size > MAX_TEXT_BYTES:
                raise ValueError("Tệp lớn hơn 512 KB, không thể xem trực tiếp.")
            result = path.read_text(encoding="utf-8")
            self._error("")
            return result
        except (UnicodeError, ValueError, OSError) as exc:
            self._error(str(exc))
            return ""

    @Slot(str, str, result=bool)
    def saveText(self, name: str, content: str) -> bool:
        try:
            self._writable()
            path = self._child(name)
            if not path.is_file() or path.suffix.lower() not in ALLOWED_TEXT:
                raise ValueError("Chỉ hỗ trợ lưu tệp văn bản.")
            encoded = content.encode("utf-8")
            if len(encoded) > MAX_TEXT_BYTES:
                raise ValueError("Tệp vượt giới hạn 512 KB.")
            # Atomic save with a unique temporary file in the same directory.
            # No stale .tmp file can prevent the next save.
            tmp_name = None
            try:
                descriptor, tmp_name = tempfile.mkstemp(prefix=".creos-", dir=str(path.parent))
                with os.fdopen(descriptor, "wb") as file:
                    file.write(encoded)
                os.replace(tmp_name, path)
            finally:
                if tmp_name is not None and os.path.exists(tmp_name):
                    os.unlink(tmp_name)
            self.refresh()
            return True
        except (ValueError, OSError) as exc:
            self._error(str(exc))
            return False

    @Slot(str, str, result=bool)
    def renameEntry(self, old: str, new: str) -> bool:
        try:
            self._writable()
            source = self._child(old)
            destination = self._child(new, missing=True)
            if destination.exists():
                raise ValueError("Tên mới đã tồn tại.")
            source.rename(destination)
            self.refresh()
            return True
        except (ValueError, OSError) as exc:
            self._error(str(exc))
            return False

    @Slot(str, result=bool)
    def deleteEntry(self, name: str) -> bool:
        try:
            self._writable()
            target = self._child(name)
            if target.is_dir():
                target.rmdir()  # only delete empty directories; no recursive deletes
            elif target.is_file():
                target.unlink()
            else:
                raise ValueError("Không thể xóa mục này.")
            self.refresh()
            return True
        except (ValueError, OSError) as exc:
            self._error("Không thể xóa (thư mục phải rỗng): " + str(exc))
            return False
