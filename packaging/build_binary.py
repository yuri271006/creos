"""Build a self-contained CreOS directory on the current OS.

Usage: python packaging/build_binary.py
Runs on Ubuntu and Windows GitHub-hosted runners.
"""
from __future__ import annotations
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def main() -> None:
    cmd = [
        sys.executable, "-m", "PyInstaller",
        "--noconfirm", "--clean", "--onedir", "--windowed",
        "--name", "CreOS",
        "--collect-all", "PySide6.QtWebEngineQuick",
        "--collect-all", "PySide6.QtWebEngineCore",
        "--add-data", f"{ROOT / 'ui'}{os.pathsep}ui",
        "--add-data", f"{ROOT / 'data'}{os.pathsep}data",
        "--distpath", str(ROOT / "dist"),
        "--workpath", str(ROOT / "build"),
        "--specpath", str(ROOT / "build"),
        str(ROOT / "main.py"),
    ]
    subprocess.check_call(cmd, cwd=ROOT)
    print("CreOS standalone bundle:", ROOT / "dist" / "CreOS")

if __name__ == "__main__":
    main()
