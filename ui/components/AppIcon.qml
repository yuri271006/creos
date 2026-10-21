import QtQuick

// Lightweight shared app glyph used in Dock and Launchpad.
Item {
    id: icon
    property real size: 46
    property string glyph: "✦"
    property color tint: "#7183DD"
    width: size
    height: size

    Rectangle {
        anchors.fill: parent
        radius: size * 0.28
        color: icon.tint
        antialiasing: true
        border.width: 1
        border.color: "#95FFFFFF"
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.lighter(icon.tint, 1.23) }
            GradientStop { position: 1; color: Qt.darker(icon.tint, 1.08) }
        }
        Rectangle {
            x: size * 0.11; y: size * 0.07
            width: size * 0.78; height: size * 0.37
            radius: size * 0.19
            color: "#31FFFFFF"
        }
    }
    Text {
        anchors.centerIn: parent
        text: icon.glyph
        font.pixelSize: icon.size * 0.53
        font.weight: Font.DemiBold
        color: "#FCFFFFFF"
    }
}
