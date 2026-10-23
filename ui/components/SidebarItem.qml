import QtQuick
import QtQuick.Controls
import "../system" as System

Button {
    id: control
    property string glyph: "•"
    property bool selected: false
    implicitHeight: 43
    implicitWidth: 176
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true
    background: Rectangle {
        radius: 12
        color: control.selected ? System.Theme.accentSoft :
               control.hovered ? "#DFE6F0" : "transparent"
        Behavior on color { ColorAnimation { duration: System.Theme.durationQuick } }
    }
    contentItem: Item {
        Row {
            x: 13
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            Text {
                text: control.glyph
                width: 19
                font.pixelSize: 18
                color: control.selected ? System.Theme.accent : System.Theme.secondary
            }
            Text {
                text: control.text
                color: control.selected ? System.Theme.accent : System.Theme.ink
                font.pixelSize: 12
                font.weight: control.selected ? Font.DemiBold : Font.Medium
                font.family: System.Theme.fontFamily
            }
        }
    }
}
