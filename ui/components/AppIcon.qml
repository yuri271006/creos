import QtQuick

// The tile is a single native rounded Qt shape; SVG only paints the
// inner symbol. No SVG background, shadow, bevel, masking or border.
Item {
    id: icon
    property real size: 46
    property string appId: "about-creos"
    readonly property color tileColor: {
        switch (appId) {
        case "notes": return "#F2B93C"
        case "calculator": return "#353A50"
        case "clock": return "#FFFFFF"
        case "browser": return "#1687D4"
        case "files": return "#278DEC"
        case "settings": return "#6C7792"
        default: return "#626BD6"
        }
    }
    width: size
    height: size

    Rectangle {
        anchors.fill: parent
        radius: icon.size * 0.23
        color: icon.tileColor
        antialiasing: true
        border.width: 0
    }
    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../assets/icons/" + icon.appId + ".svg")
        sourceSize.width: 192
        sourceSize.height: 192
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: false
        asynchronous: true
        cache: true
        onStatusChanged: {
            if (status === Image.Error)
                console.warn("CreOS icon could not load:", source)
        }
    }
}
