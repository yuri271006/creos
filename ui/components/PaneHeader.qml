import QtQuick
import "../system" as System

// Standard heading for apps with a split-pane or compact navigation layout.
Item {
    id: root
    property string heading: ""
    property string detail: ""
    implicitHeight: detail.length ? 54 : 37
    Column {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: 5
        Text {
            width: parent.width
            text: root.heading
            color: System.Theme.ink
            font.family: System.Theme.fontFamily
            font.pixelSize: System.Theme.typeHeading
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Text {
            visible: root.detail.length > 0
            width: parent.width
            text: root.detail
            color: System.Theme.secondary
            font.family: System.Theme.fontFamily
            font.pixelSize: System.Theme.typeCaption
            elide: Text.ElideRight
        }
    }
}
