import QtQuick
import QtQuick.Controls
import "../system" as System

// Standard clickable target: at least 42px, with lightweight state feedback.
Button {
    id: control
    property bool primary: false
    property bool destructive: false
    property bool quiet: false
    property string symbol: ""
    implicitWidth: 126
    implicitHeight: System.Theme.minimumTarget
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true
    font.family: System.Theme.fontFamily
    font.pixelSize: 12
    font.weight: Font.DemiBold
    background: Rectangle {
        radius: 13
        color: control.primary ? (control.down ? "#205BCA" : control.hovered ? "#2369E6" : System.Theme.accent) :
              control.destructive ? (control.hovered ? "#FBE5E9" : "#FEF0F1") :
              control.quiet ? (control.hovered ? "#E6EBF4" : "transparent") :
              (control.down ? "#E1E7F2" : control.hovered ? "#EAF0FA" : System.Theme.inset)
        Behavior on color { ColorAnimation { duration: System.Theme.durationQuick } }
    }
    contentItem: Item {
        Row {
            spacing: 7
            anchors.centerIn: parent
            Text {
                text: control.text
                color: control.primary ? "#FFFFFF" :
                       control.destructive ? System.Theme.danger : System.Theme.ink
                font.family: System.Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
            Text {
                visible: control.symbol.length > 0
                text: control.symbol
                font.pixelSize: 13
                color: control.primary ? "#FFFFFF" : System.Theme.secondary
            }
        }
    }
}
