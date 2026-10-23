pragma Singleton
import QtQuick

// CreOS Human Interface · v2. Tokens are the only approved source of app UI styling.
// One design language, native-feeling controls, predictable sizes and short motion.
QtObject {
    readonly property color canvas: "#F3F5F9"
    readonly property color surface: "#FFFFFF"
    readonly property color inset: "#F0F2F7"
    readonly property color sidebar: "#EEF1F7"
    readonly property color ink: "#172337"
    readonly property color secondary: "#65748A"
    readonly property color muted: "#8A99AC"
    readonly property color accent: "#3177F4"
    readonly property color accentSoft: "#E6EFFD"
    readonly property color positive: "#248D6C"
    readonly property color danger: "#D9515A"
    readonly property color line: "#DCE3ED"
    readonly property color subtleLine: "#E9EDF3"
    readonly property color glass: "#E6F9FBFF"
    readonly property color glassStrong: "#F2FFFFFF"
    readonly property color sidebarGlass: "#E9F3F8FF"
    readonly property color wallpaperTop: "#D7EAF6"
    readonly property color wallpaperBottom: "#CFCAE9"
    readonly property color dockGlass: "#F1FFFFFF"
    readonly property color shadow: "#241A305A"

    readonly property int radiusSmall: 11
    readonly property int radiusMedium: 16
    readonly property int radiusLarge: 22
    readonly property int radiusWindow: 22
    readonly property int space: 16
    readonly property int gapSmall: 8
    readonly property int gapMedium: 14
    readonly property int gapLarge: 24
    readonly property int minimumTarget: 42
    readonly property int durationQuick: 120
    readonly property int durationNormal: 220
    readonly property int durationSlow: 320
    readonly property string fontFamily: "Noto Sans"
    // System type scale: all components use the same visual hierarchy.
    readonly property int typeTitle: 25
    readonly property int typeHeading: 20
    readonly property int typeBody: 13
    readonly property int typeAction: 12
    readonly property int typeCaption: 11
    readonly property int typeLabel: 10

    // Kept as an interface contract for future accessibility settings.
    readonly property bool reduceMotion: false
}
