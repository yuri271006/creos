import QtQuick
import QtQuick.Controls
Button {
    id: control
    property bool selected: false
    property string symbol: "◆"
    property string caption: ""
    implicitHeight: 52; implicitWidth: 196; hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    background: Rectangle {
        radius: 17
        color: control.selected ? "#45FFFFFF" : (control.hovered ? "#1CFFFFFF" : "#00FFFFFF")
        border.width: control.selected ? 1 : 0; border.color: "#55FFFFFF"
        Behavior on color { ColorAnimation { duration: 220; easing.type: Easing.OutCubic } }
        Rectangle {
            visible: control.selected; width: 3; height: 20; radius: 2
            anchors.verticalCenter: parent.verticalCenter; x: 1; color: "#B9D9FF"
        }
    }
    contentItem: Item {
        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin: 17; spacing: 15
            Text { text: control.symbol; font.pixelSize: 18; color: control.selected ? "#E8F5FF" : "#AFC3DF"; width: 20 }
            Text { text: control.caption; font.pixelSize: 14; font.weight: control.selected ? Font.DemiBold : Font.Medium; color: control.selected ? "#FFFFFF" : "#B9C9E2" }
        }
    }
}
