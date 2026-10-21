import QtQuick
import QtQuick.Controls
Button {
    id: control
    property bool emphasized: false
    property string symbol: "↗"
    hoverEnabled: true; focusPolicy: Qt.StrongFocus
    implicitHeight: 43; implicitWidth: 155
    font.pixelSize: 13; font.weight: Font.DemiBold
    background: Rectangle {
        radius: 15
        color: control.emphasized ? (control.hovered ? "#EAF5FF" : "#FFFFFF") : (control.hovered ? "#35FFFFFF" : "#19FFFFFF")
        border.width: 1
        border.color: control.emphasized ? "#FFFFFF" : "#37FFFFFF"
        Behavior on color { ColorAnimation { duration: 180 } }
    }
    contentItem: Item {
        Row {
            spacing: 9; anchors.centerIn: parent
            Text { text: control.text; color: control.emphasized ? "#142440" : "#EAF2FF"; font.pixelSize: 13; font.weight: Font.DemiBold }
            Text { text: control.symbol; color: control.emphasized ? "#142440" : "#D6E5FF"; font.pixelSize: 14 }
        }
    }
}
