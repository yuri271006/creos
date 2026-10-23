# CreOS Human Interface · Application contract

## CreOS owns the operating-system layer

The CreOS shell (`ui/Main.qml`) provides a fullscreen desktop, global menu, a compact dock that overlays maximized app windows, launcher, app registry and application transitions. `ui/components/AppWindow.qml` provides the **same** window chrome for every app: close, minimize, maximize, drag, resize, single-contour rounded corners and a stable window background (without fragile full-window GPU masks).

Built-in apps **must not recreate window controls**. Apps only supply QML content.

## Shared design language

- `ui/system/Theme.qml`: typography, colors, radii, durations and spacing.
- `ui/components/SystemButton.qml`, `SidebarItem.qml`, `GlassPanel.qml`: controls.
- `ui/components/AppIcon.qml`: shared SVG icon renderer for Desktop, Dock and Launchpad.
- `ui/system/Apps.qml`: id, display name, component and appearance. Icon SVG asset filenames correspond to application ids.

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
  "appearance": "system"
}
```

Add the vector asset \`ui/assets/icons/example.svg\` (96 × 96, rounded background with transparent outside corners). \`AppIcon.qml\` resolves it using the application's \`id\`. Avoid font glyph icons. The same registry populates **Dock** and **Launchpad**. Each registered app gets its **own CreOS AppWindow** with independent visibility, z-order, minimize/maximize and 8-way resizing. Clicking its icon opens or focuses that window.

## Data

Built-in apps needing persistent data should add carefully scoped, validated methods to `state_store.py`. Its data is written to the user's XDG data directory outside the repo. **Never store user notes within Git-tracked project files.** No app sandbox exists yet, so only run trusted application code.

## Motion principles

- Interactive hover feedback: 140–220 ms.
- Navigation: 260–340 ms, OutCubic.
- Window enter/exit: ~250–450 ms (scale and opacity).
- Do not introduce dragging delay by attaching generic `Behavior on x/y` to moving windows.
- Never place rectangular ShaderEffect/MultiEffect surfaces behind rounded Dock or Launchpad panels; this caused visible square corners. Blur must be properly masked or replaced by a single rounded translucent surface. Test with GPU and software rendering.

## Current boundaries

CreOS 1.0.1 implements independent on-screen windows, z-order, focusing and 8-direction resizing for each registered app. App processes still run inside the same Qt/Python process; isolation, safe third-party sandboxing and task switching remain future work.
