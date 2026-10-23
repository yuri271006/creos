import QtQuick

// Same CreOS identity in the Desktop shortcut and About window.
Item {
    id: mark
    property real size: 50
    width: size
    height: size
    AppIcon {
        anchors.fill: parent
        size: parent.width
        appId: "about-creos"
    }
}
