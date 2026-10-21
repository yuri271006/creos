import QtQuick
import QtQuick.Controls
import "../system" as System

// Shared, draggable/resizable macOS-inspired CreOS application chrome.
// Child apps can customize their content, never the core close/min/max behavior.
Rectangle {
    id: frame
    property string appTitle: "CreOS"
    property url componentSource
    property string appAppearance: "system"
    property bool maximized: false
    property real oldX: 0
    property real oldY: 0
    property real oldWidth: 880
    property real oldHeight: 560
    signal closeRequested()
    signal minimizeRequested()
    property int minimumPanelWidth: 680
    property int minimumPanelHeight: 400

    radius: System.Theme.radiusWindow
    color: frame.appAppearance === "custom" ? "#FFFFFFFF" : "#EBF9FBFF"
    border.color: "#E5FFFFFF"
    border.width: 1
    clip: true
    antialiasing: true

    function toggleMaximize() {
        if (!maximized) {
            oldX = x
            oldY = y
            oldWidth = width
            oldHeight = height
            maximized = true
            x = 8
            y = 9
            width = Math.max(minimumPanelWidth, parent.width - 16)
            height = Math.max(minimumPanelHeight, parent.height - 19)
        } else {
            maximized = false
            width = Math.min(oldWidth, parent.width - 24)
            height = Math.min(oldHeight, parent.height - 24)
            x = Math.min(oldX, parent.width - width - 8)
            y = Math.min(oldY, parent.height - height - 8)
        }
    }

    Behavior on width { NumberAnimation { duration: System.Theme.durationNormal; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: System.Theme.durationNormal; easing.type: Easing.OutCubic } }

    Rectangle {
        id: titlebar
        height: 53; width: parent.width
        color: "#F2FFFFFF"
        radius: System.Theme.radiusWindow
        Rectangle {
            anchors.bottom: parent.bottom; width: parent.width; height: 14; color: "#F2FFFFFF"
        }
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: "#BCCBDDDC"
        }
        DragHandler {
            target: frame
            enabled: !frame.maximized
            xAxis.minimum: 6
            xAxis.maximum: Math.max(6, frame.parent.width - frame.width - 6)
            yAxis.minimum: 6
            yAxis.maximum: Math.max(6, frame.parent.height - frame.height - 6)
        }
        Row {
            anchors.verticalCenter: parent.verticalCenter
            x: 19
            spacing: 9
            Repeater {
                model: [
                    {color: "#FF605C", symbol: "×", action: "close"},
                    {color: "#FFBD44", symbol: "−", action: "minimize"},
                    {color: "#00C84A", symbol: "+", action: "maximize"}
                ]
                delegate: Rectangle {
                    required property var modelData
                    width: 13; height: 13; radius: 7
                    color: modelData.color
                    border.width: 1
                    border.color: "#2B2B2B28"
                    Text {
                        anchors.centerIn: parent
                        text: modelData.symbol
                        visible: trafficHover.containsMouse
                        color: "#67444C"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }
                    MouseArea {
                        id: trafficHover
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.action === "close") frame.closeRequested()
                            else if (modelData.action === "minimize") frame.minimizeRequested()
                            else frame.toggleMaximize()
                        }
                    }
                }
            }
        }
        Text {
            anchors.centerIn: parent
            text: frame.appTitle
            font.family: System.Theme.fontFamily
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: System.Theme.ink
        }
        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            width: 65; height: 24; radius: 11
            color: "#90FFFFFF"; border.color: "#B5FFFFFF"
            Text {
                anchors.centerIn: parent
                text: "CreOS"
                color: System.Theme.secondary
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }
        }
    }

    Loader {
        id: appLoader
        anchors.top: titlebar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        source: frame.componentSource
        asynchronous: false
        onStatusChanged: {
            if (status === Loader.Error)
                console.error("CreOS: cannot load app", source)
        }
    }

    Rectangle {
        id: resizeHandle
        visible: !frame.maximized
        width: 23; height: 23
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "transparent"
        property real initialWidth: 0
        property real initialHeight: 0
        Text {
            anchors.centerIn: parent
            text: "◢"
            font.pixelSize: 12
            color: "#8A9BAD"
        }
        DragHandler {
            target: null
            cursorShape: Qt.SizeFDiagCursor
            onActiveChanged: {
                if (active) {
                    resizeHandle.initialWidth = frame.width
                    resizeHandle.initialHeight = frame.height
                }
            }
            onTranslationChanged: {
                if (active && frame.parent) {
                    frame.width = Math.max(frame.minimumPanelWidth,
                        Math.min(frame.parent.width - frame.x - 6, resizeHandle.initialWidth + translation.x))
                    frame.height = Math.max(frame.minimumPanelHeight,
                        Math.min(frame.parent.height - frame.y - 6, resizeHandle.initialHeight + translation.y))
                }
            }
        }
    }
}
