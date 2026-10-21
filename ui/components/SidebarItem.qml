import QtQuick
import QtQuick.Controls
import "../system" as System

Button {
    id: control
    property string glyph: "●"
    property bool selected: false
    implicitHeight: 42
    implicitWidth: 178
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    font.family: System.Theme.fontFamily

    background: Rectangle {
        radius: System.Theme.radiusSmall
        color: control.selected ? "#E7FFFFFF" : (control.hovered ? "#80FFFFFF" : "#00FFFFFF")
        border.width: control.selected ? 1 : 0
        border.color: "#90FFFFFF"
        Behavior on color { ColorAnimation { duration: System.Theme.durationQuick } }
    }
    contentItem: Row {
        spacing: 12
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 13
        Text {
            text: control.glyph
            width: 18
            font.pixelSize: 17
            color: control.selected ? System.Theme.accent : "#7A8AA1"
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: control.text
            font.family: System.Theme.fontFamily
            font.pixelSize: 12
            font.weight: control.selected ? Font.DemiBold : Font.Medium
            color: System.Theme.ink
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
