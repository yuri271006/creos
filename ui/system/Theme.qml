pragma Singleton
import QtQuick

// CreOS System UI: one source of truth for all built-in apps.
QtObject {
    readonly property color ink: "#243049"
    readonly property color secondary: "#697990"
    readonly property color muted: "#94A2B6"
    readonly property color accent: "#526DDA"
    readonly property color accentSoft: "#E9EDFF"
    readonly property color positive: "#1B9674"
    readonly property color line: "#66FFFFFF"
    readonly property color subtleLine: "#D9E2ED"
    readonly property color glass: "#BDEFF6FF"
    readonly property color glassStrong: "#E4FFFFFF"
    readonly property color sidebarGlass: "#A9F2F7FF"
    readonly property color surface: "#F6FAFF"
    readonly property color wallpaperTop: "#D7EAF6"
    readonly property color wallpaperBottom: "#CFCAE9"
    readonly property color dockGlass: "#BCEFF6FF"
    readonly property color shadow: "#241A305A"
    readonly property int radiusSmall: 12
    readonly property int radiusMedium: 17
    readonly property int radiusLarge: 25
    readonly property int radiusWindow: 21
    readonly property int space: 16
    readonly property int durationQuick: 170
    readonly property int durationNormal: 280
    readonly property int durationSlow: 460
    readonly property string fontFamily: "Noto Sans"
}
