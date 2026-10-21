import QtQuick
import QtQuick.Controls
import "../system" as System

Button {
    id: control
    property bool primary: false
    property string symbol: "↗"
    implicitHeight: 37
    implicitWidth: 132
    hoverEnabled: true
    font.family: System.Theme.fontFamily
    focusPolicy: Qt.StrongFocus
    background: Rectangle {
        radius: System.Theme.radiusSmall
        color: control.primary
            ? (control.hovered ? "#3D5BCE" : System.Theme.accent)
            : (control.hovered ? "#E7FFFFFF" : "#AEFFFFFF")
        border.width: 1
        border.color: control.primary ? "#4261C5" : "#FFFFFFFF"
        Behavior on color { ColorAnimation { duration: System.Theme.durationQuick } }
    }
    contentItem: Row {
        spacing: 8
        anchors.centerIn: parent
        Text {
            text: control.text
            font.pixelSize: 11
            font.family: System.Theme.fontFamily
            font.weight: Font.DemiBold
            color: control.primary ? "#FFFFFF" : System.Theme.ink
        }
        Text {
            text: control.symbol
            font.pixelSize: 12
            color: control.primary ? "#FFFFFF" : System.Theme.secondary
        }
    }
}
