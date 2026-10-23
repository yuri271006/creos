"""Local CreOS profile, password verification and data-volume quota.

CreOS is an app inside Ubuntu/Windows, not a disk partition. The user
chooses a 2–8 GiB logical ceiling on CreOS/data; bytes are used on demand.
"""
from __future__ import annotations
import hashlib
import hmac
import json
import os
import platform
import re
import secrets
from pathlib import Path

MIN_GIB = 2
MAX_GIB = 8
GIB = 1024 ** 3
SCHEME = "scrypt-v1"


def base_data_dir() -> Path:
    override = os.environ.get("CREOS_DATA_HOME")
    if override:
        return Path(override).expanduser().resolve()
    if platform.system() == "Windows":
        root = os.environ.get("LOCALAPPDATA") or os.environ.get("APPDATA")
        return (Path(root) if root else Path.home() / "AppData" / "Local") / "CreOS"
    root = os.environ.get("XDG_DATA_HOME")
    return (Path(root).expanduser() if root else Path.home() / ".local" / "share") / "CreOS"


def profile_path() -> Path:
    return base_data_dir() / "profile.json"


def profile_exists() -> bool:
    return profile_path().is_file()


def validate_username(username: str) -> str:
    name = username.strip()
    if not (2 <= len(name) <= 40) or any(ord(c) < 32 for c in name):
        raise ValueError("Tên người dùng phải có từ 2 đến 40 ký tự.")
    return name


def validate_password(password: str) -> None:
    if len(password) < 8:
        raise ValueError("Mật khẩu phải có ít nhất 8 ký tự.")
    if len(password) > 256:
        raise ValueError("Mật khẩu quá dài.")


def validate_quota(gib: int) -> int:
    if type(gib) is not int or not (MIN_GIB <= gib <= MAX_GIB):
        raise ValueError("Dung lượng CreOS phải từ 2 đến 8 GB.")
    return gib


def create_profile(username: str, password: str, quota_gib: int, *, path: Path | None = None) -> None:
    name = validate_username(username)
    validate_password(password)
    quota = validate_quota(quota_gib)
    destination = path or profile_path()
    destination.parent.mkdir(parents=True, exist_ok=True)
    salt = secrets.token_bytes(24)
    derived = hashlib.scrypt(password.encode("utf-8"), salt=salt, n=2**14, r=8, p=1, dklen=32)
    doc = {
        "schema": 1, "name": name, "quota_gib": quota,
        "password_scheme": SCHEME, "salt": salt.hex(), "password_hash": derived.hex(),
    }
    # Never overwrite an existing profile, particularly on upgrades.
    with destination.open("x", encoding="utf-8") as stream:
        json.dump(doc, stream, ensure_ascii=False, indent=2)
    if os.name == "posix":
        destination.chmod(0o600)
    (destination.parent / "data").mkdir(exist_ok=True)


def load_profile(*, path: Path | None = None) -> dict:
    target = path or profile_path()
    content = json.loads(target.read_text(encoding="utf-8"))
    if content.get("password_scheme") != SCHEME:
        raise ValueError("Định dạng mật khẩu không được hỗ trợ.")
    validate_username(content["name"])
    validate_quota(content["quota_gib"])
    if not re.fullmatch(r"[0-9a-f]{48}", content["salt"]):
        raise ValueError("Dữ liệu bảo mật không hợp lệ.")
    if not re.fullmatch(r"[0-9a-f]{64}", content["password_hash"]):
        raise ValueError("Dữ liệu bảo mật không hợp lệ.")
    return content


def verify_password(password: str, *, path: Path | None = None) -> bool:
    profile = load_profile(path=path)
    derived = hashlib.scrypt(
        password.encode("utf-8"), salt=bytes.fromhex(profile["salt"]),
        n=2**14, r=8, p=1, dklen=32,
    )
    return hmac.compare_digest(derived, bytes.fromhex(profile["password_hash"]))


def quota_bytes() -> int:
    if not profile_exists():
        # Developer runs without a configured profile keep a sane default.
        return MIN_GIB * GIB
    return load_profile()["quota_gib"] * GIB


def volume_usage(root: Path) -> int:
    """Count regular files only; skip symlink traversal and directory links."""
    total = 0
    if not root.exists():
        return total
    for base, dirs, names in os.walk(root, followlinks=False):
        dirs[:] = [n for n in dirs if not (Path(base) / n).is_symlink()]
        for name in names:
            file = Path(base) / name
            if file.is_symlink():
                continue
            try:
                if file.is_file():
                    total += file.stat().st_size
            except OSError:
                continue
    return total


def within_quota(root: Path, old_size: int, new_size: int, maximum: int | None = None) -> bool:
    limit = quota_bytes() if maximum is None else maximum
    return volume_usage(root) - old_size + new_size <= limit
