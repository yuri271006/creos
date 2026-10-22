# CreOS Human Interface · Application contract

## CreOS owns the operating-system layer

The CreOS shell (`ui/Main.qml`) provides wallpaper, global menu, dock, launcher, app registry and application transitions. `ui/components/AppWindow.qml` provides the **same** window chrome for every app: close, minimize, maximize, drag, resize, rounded corners and frosted backdrop (without a full-window GPU mask).

Built-in apps **must not recreate window controls**. Apps only supply QML content.

## Shared design language

- `ui/system/Theme.qml`: typography, colors, radii, durations and spacing.
- `ui/components/SystemButton.qml`, `SidebarItem.qml`, `GlassPanel.qml`: controls.
- `ui/components/AppIcon.qml`: dock/launcher icons.
- `ui/system/Apps.qml`: id, display name, source component, icon tint/glyph and appearance.

Apps may use:
- **system** appearance, inheriting the common style.
- **custom** appearance for its content (CreOS still controls the surrounding window).

## Adding an app

Create `ui/apps/ExampleApp.qml`:

```qml
import QtQuick
import "../system" as System

Item {
    Rectangle {
        anchors.fill: parent
        color: System.Theme.surface
    }
}
```

Register an entry in `ui/system/Apps.qml`:

```js
{
  "id": "example",
  "name": "Example",
  "subtitle": "My CreOS app",
  "component": "ExampleApp.qml",
  "appearance": "system",
  "glyph": "✦",
  "tint": "#819BD8"
}
```

The same registry populates **Dock** and **Launchpad**; clicking loads the component inside the CreOS-owned AppWindow.

## Data

Built-in apps needing persistent data should add carefully scoped, validated methods to `state_store.py`. Its data is written to the user's XDG data directory outside the repo. **Never store user notes within Git-tracked project files.** No app sandbox exists yet, so only run trusted application code.

## Motion principles

- Interactive hover feedback: 140–220 ms.
- Navigation: 260–340 ms, OutCubic.
- Window enter/exit: ~250–450 ms (scale and opacity).
- Do not introduce dragging delay by attaching generic `Behavior on x/y` to moving windows.
- Keep blur regions bounded, and test performance with GPU and software fallback.

## Current boundaries

CreOS 0.1.2-dev currently shows **one app window at a time**. Real multiwindow z-order/focus and app-process isolation are future work; do not market them as implemented.
