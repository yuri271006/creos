# CreOS — The Inner Universe

CreOS is an experimental **desktop-within-a-desktop** running as one Ubuntu application. Its own menu bar, Dock, Launchpad and app windows use a shared CreOS interface, inspired by macOS/iOS but independently designed.

## 0.1.3-dev · Window Visibility Fix

The first built-in applications are now accessible from **Dock** and **Launchpad**:

| App | Works now |
|---|---|
| CreOS | About, release history, system UI reference |
| Ghi chú (Notes) | Create/edit/delete notes, autosave locally |
| Máy tính (Calculator) | +, −, ×, ÷, %, change sign, delete, clear |
| Đồng hồ (Clock) | Local time, stopwatch, lap list |
| Cài đặt (Settings) | Switch between Aurora, Sunrise and Midnight desktop wallpaper |

**Notes and wallpaper settings survive restarts.** Data is saved under `$XDG_DATA_HOME/CreOS/state.json` (usually `~/.local/share/CreOS/state.json`), outside the repository. Git pull doesn't overwrite it.

All these apps share CreOS-owned window controls. A custom-designed app may style its own content but still belongs to the CreOS shell.

### Running on Ubuntu

Requires Python 3.10+ and `python3-venv`.

Open the cloned repo in VS Code. In the integrated terminal:

```bash
bash run.sh
```

The script creates `.venv`, installs PySide6 and starts CreOS. Internet is needed for the first dependency installation. If Ubuntu reports a missing Qt xcb platform plugin, try `sudo apt install libxcb-cursor0 libxkbcommon-x11-0`.

### Updating from GitHub

Use **Fetch origin → Pull origin** in GitHub Desktop or run:

```bash
git pull
bash run.sh
```

Close an existing CreOS window before relaunching. The source update isn't live hot-reload.

### UI & architecture

- `ui/Main.qml` — desktop, application switching, menu, wallpaper, Dock and Launchpad.
- `ui/components/AppWindow.qml` — shared window chrome, rounded alpha-mask, animations and backdrop.
- `ui/components/AppIcon.qml` — reusable application icon.
- `ui/system/Theme.qml` — CreOS UI tokens.
- `ui/system/Apps.qml` — centralized application registry.
- `ui/apps/*App.qml` — app content, **without its own OS window controls**.
- `state_store.py` — local persistent notes and wallpaper state.
- `data/releases.json` — release versions and roadmap.
- `tests/test_state_store.py` — persistence tests.
- `ui/system/APP_GUIDE.md` — how to build the next CreOS app.

### Preview limitations

This is **developer preview**, not a real new operating system. The preview can display only one embedded app window at a time (switching is available from Dock and Launchpad). The frosted glass visual uses Qt Quick; it is not pixel-identical to Apple's Liquid Glass. Graphics quality/performance vary by Qt installation and GPU/driver. The outer Ubuntu window frame is controlled by the Ubuntu window manager; CreOS-owned inner windows use the shared rounded shell.

The GitHub Actions workflow contains a virtual-display QML smoke test and data-store unit tests. **Until CI and real Ubuntu screenshots are verified, full visual/runtime compatibility is not guaranteed.**
