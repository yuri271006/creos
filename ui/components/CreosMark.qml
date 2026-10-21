import QtQuick
Item {
    id: mark
    property real size: 44
    width: size; height: size
    Rectangle {
        anchors.fill: parent; radius: size * 0.29
        gradient: Gradient {
            GradientStop { position: 0; color: "#B4E7FF" }
            GradientStop { position: 0.48; color: "#83A9FF" }
            GradientStop { position: 1; color: "#BC91FA" }
        }
        border.width: 1; border.color: "#99FFFFFF"
    }
    Rectangle {
        width: size * 0.53; height: size * 0.53; radius: size * 0.19
        x: size * 0.25; y: size * 0.15; rotation: -22
        color: "#76FFFFFF"; border.width: 1; border.color: "#99FFFFFF"
    }
    Text { anchors.centerIn: parent; text: "C"; font.pixelSize: size * 0.57; font.weight: Font.DemiBold; color: "#152449" }
}
