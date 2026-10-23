import QtQuick
import "../system" as System

// Shared page shell. Children belong to contentSlot, never to the OS chrome.
Item {
    id: root
    property string heading: ""
    property string caption: ""
    default property alias pageContent: contentSlot.data
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: System.Theme.canvas
    }
    Column {
        id: pageHeader
        x: 26; y: 22
        width: root.width - 52
        spacing: 6
        Text {
            text: root.heading
            font.family: System.Theme.fontFamily
            font.pixelSize: 25
            font.weight: Font.DemiBold
            color: System.Theme.ink
        }
        Text {
            visible: root.caption.length > 0
            width: parent.width
            elide: Text.ElideRight
            text: root.caption
            font.family: System.Theme.fontFamily
            font.pixelSize: 12
            color: System.Theme.secondary
        }
    }
    Item {
        id: contentSlot
        x: 24
        y: 100
        width: root.width - 48
        height: Math.max(1, root.height - 120)
        clip: true
    }
}
