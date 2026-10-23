"""Create an Ubuntu .deb installer from dist/CreOS produced by PyInstaller."""
from __future__ import annotations
import json
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
META = json.loads((ROOT / "data" / "releases.json").read_text(encoding="utf-8"))
VERSION = META["version"]
PACKAGE = ROOT / "dist" / f"creos_{VERSION}_amd64.deb"
STAGING = ROOT / "build" / "deb-root"

DESKTOP = """[Desktop Entry]
Type=Application
Name=CreOS
Comment=CreOS Desktop Workspace
Exec=/opt/creos/CreOS
Icon=creos
Terminal=false
Categories=Utility;
StartupNotify=true
"""
CONTROL = f"""Package: creos
Version: {VERSION}
Architecture: amd64
Maintainer: CreOS Project <noreply@github.com>
Section: utils
Priority: optional
Depends: libglib2.0-0, libx11-6, libxcb1, libxcb-cursor0, libxcb-shape0, libxcb-xkb1, libxcb-xinerama0, libxcb-icccm4, libxcb-image0, libxcb-keysyms1, libxcb-render-util0, libxcb-randr0, libxcb-xfixes0, libx11-xcb1, libnss3, libxkbcommon0, libxkbcommon-x11-0, libpulse0, libasound2t64 | libasound2
Description: CreOS desktop workspace for Ubuntu
 Full desktop-style workspace, file manager and in-app applications.
"""

def main():
    bundle = ROOT / "dist" / "CreOS"
    if not (bundle / "CreOS").is_file():
        raise SystemExit("Build dist/CreOS first: python packaging/build_binary.py")
    if STAGING.exists():
        shutil.rmtree(STAGING)
    install = STAGING / "opt" / "creos"
    shutil.copytree(bundle, install)
    desktop = STAGING / "usr" / "share" / "applications" / "creos.desktop"
    desktop.parent.mkdir(parents=True, exist_ok=True)
    desktop.write_text(DESKTOP, encoding="utf-8")
    icon = STAGING / "usr" / "share" / "icons" / "hicolor" / "scalable" / "apps" / "creos.svg"
    icon.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(ROOT / "packaging" / "creos.svg", icon)
    control = STAGING / "DEBIAN" / "control"
    control.parent.mkdir(parents=True, exist_ok=True)
    control.write_text(CONTROL, encoding="utf-8")
    # Restrict installer control dir, leave app executables executable.
    PACKAGE.parent.mkdir(parents=True, exist_ok=True)
    subprocess.check_call(["dpkg-deb", "--build", "--root-owner-group",
                           str(STAGING), str(PACKAGE)])
    print(PACKAGE)

if __name__ == "__main__":
    main()
