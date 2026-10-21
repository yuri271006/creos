import QtQuick

// Original CreOS identity, not an Apple logo.
Item {
    id: mark
    property real size: 50
    width: size
    height: size
    Rectangle {
        anchors.fill: parent
        radius: size * 0.28
        antialiasing: true
        gradient: Gradient {
            GradientStop { position: 0; color: "#94DDF9" }
            GradientStop { position: 0.5; color: "#839DF1" }
            GradientStop { position: 1; color: "#B78DE4" }
        }
        border.width: 1
        border.color: "#CDFFFFFF"
    }
    Rectangle {
        width: size * 0.63; height: size * 0.55
        x: size * 0.22; y: size * 0.17
        radius: size * 0.19
        rotation: -24
        color: "#63FFFFFF"
        border.width: 1
        border.color: "#A6FFFFFF"
        antialiasing: true
    }
    Text {
        anchors.centerIn: parent
        text: "C"
        color: "#F9FFFFFF"
        font.pixelSize: size * 0.56
        font.weight: Font.DemiBold
        font.family: "Noto Sans"
    }
}
