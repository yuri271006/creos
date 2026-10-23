import QtQuick
import QtQuick.Controls
import "../system" as System

Item {
    id: tabs
    property var options: []
    property int selectedIndex: 0
    signal activated(int index)
    implicitHeight: 40
    implicitWidth: 220

    Rectangle {
        anchors.fill: parent
        radius: 13
        color: System.Theme.inset
    }
    Row {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 3
        Repeater {
            model: tabs.options
            delegate: Button {
                id: tab
                required property string modelData
                required property int index
                width: (tabs.width - 8 - Math.max(0, tabs.options.length - 1) * 3) / Math.max(1, tabs.options.length)
                height: tabs.height - 8
                hoverEnabled: true
                focusPolicy: Qt.StrongFocus
                onClicked: tabs.activated(index)
                background: Rectangle {
                    radius: 10
                    color: tabs.selectedIndex === tab.index ? System.Theme.surface :
                        (tab.hovered ? "#DCE3EE" : "transparent")
                    Behavior on color { ColorAnimation { duration: System.Theme.durationQuick } }
                }
                contentItem: Text {
                    text: tab.modelData
                    color: tabs.selectedIndex === tab.index ? System.Theme.ink : System.Theme.secondary
                    font.family: System.Theme.fontFamily
                    font.weight: tabs.selectedIndex === tab.index ? Font.DemiBold : Font.Normal
                    font.pixelSize: System.Theme.typeCaption
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
