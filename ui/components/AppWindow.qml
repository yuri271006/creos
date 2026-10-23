import QtQuick
import QtQuick.Controls
import "../system" as System

// Stable CreOS window chrome: one frame, one border, no nested GPU masks.
// Per-app content is loaded underneath the shared title bar.
Item {
    id: host
    property string appTitle: ""
    property url componentSource
    property string appAppearance: "system"
    property Item backgroundSource: null
    property real backgroundYOffset: 0
    property bool maximized: false
    property bool loaded: false
    property int minimumPanelWidth: 500
    property int minimumPanelHeight: 355
    property real restoreX: 0
    property real restoreY: 0
    property real restoreWidth: 760
    property real restoreHeight: 460
    property string exitKind: ""

    signal closeRequested()
    signal minimizeRequested()
    signal focused()
    signal exitFinished(string kind)

    transformOrigin: Item.Center

    function animateIn() {
        leaveAnimation.stop()
        enterAnimation.stop()
        opacity = 0
        scale = 0.94
        enterAnimation.start()
    }
    function animateOut(reason) {
        if (leaveAnimation.running) return
        enterAnimation.stop()
        exitKind = reason
        leaveAnimation.start()
    }
    function toggleMaximize() {
        if (!parent) return
        focused()
        geometryAnimation.stop()
        if (!maximized) {
            restoreX = x; restoreY = y
            restoreWidth = width; restoreHeight = height
            maximized = true
            animateGeometry(5, 5, parent.width - 10, parent.height - 10)
        } else {
            maximized = false
            var w = Math.min(restoreWidth, parent.width - 12)
            var h = Math.min(restoreHeight, parent.height - 12)
            animateGeometry(Math.max(5, Math.min(restoreX, parent.width - w - 5)),
                            Math.max(5, Math.min(restoreY, parent.height - h - 5)),
                            w, h)
        }
    }
    function animateGeometry(px, py, pw, ph) {
        animationX.to = px
        animationY.to = py
        animationW.to = pw
        animationH.to = ph
        geometryAnimation.start()
    }

    ParallelAnimation {
        id: enterAnimation
        NumberAnimation {
            target: host; property: "opacity"; from: 0; to: 1
            duration: 260; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: host; property: "scale"; from: 0.94; to: 1
            duration: 360; easing.type: Easing.OutCubic
        }
    }
    SequentialAnimation {
        id: leaveAnimation
        ParallelAnimation {
            NumberAnimation { target: host; property: "opacity"; to: 0; duration: 200; easing.type: Easing.InCubic }
            NumberAnimation { target: host; property: "scale"; to: 0.95; duration: 210; easing.type: Easing.InCubic }
        }
        ScriptAction { script: host.exitFinished(host.exitKind) }
    }
    ParallelAnimation {
        id: geometryAnimation
        NumberAnimation {
            id: animationX; target: host; property: "x"
            duration: 290; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: animationY; target: host; property: "y"
            duration: 290; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: animationW; target: host; property: "width"
            duration: 290; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: animationH; target: host; property: "height"
            duration: 290; easing.type: Easing.OutCubic
        }
    }

    // A single rounded rectangle is the *only* outside contour.
    // The corners cannot double because there is no second border/shadow shape.
    Rectangle {
        id: surface
        anchors.fill: parent
        radius: 22
        antialiasing: true
        color: "#EEF6FD"
        border.width: 1
        border.color: "#C4D0E4"

        // Top system bar: rounded top, squared bottom. No strokes on corners.
        Rectangle {
            id: bar
            x: 1
            y: 1
            width: parent.width - 2
            height: 49
            radius: 21
            antialiasing: true
            color: "#F5F9FD"
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 24
                color: parent.color
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#DCE5EF"
            }

            // Only the background of title bar is a drag target.
            // Buttons remain independently clickable.
            DragHandler {
                target: host
                enabled: !host.maximized
                snapMode: DragHandler.NoSnap
                xAxis.minimum: 5
                xAxis.maximum: host.parent ? Math.max(5, host.parent.width - host.width - 5) : 5
                yAxis.minimum: 5
                yAxis.maximum: host.parent ? Math.max(5, host.parent.height - host.height - 5) : 5
                onActiveChanged: if (active) host.focused()
            }
            TapHandler {
                onDoubleTapped: host.toggleMaximize()
                onTapped: host.focused()
            }

            Row {
                x: 19
                anchors.verticalCenter: parent.verticalCenter
                spacing: 9
                Repeater {
                    model: [
                        {fill:"#FF605C", mark:"×", cmd:"close"},
                        {fill:"#FFBD44", mark:"−", cmd:"min"},
                        {fill:"#35C759", mark:"+", cmd:"maximize"}
                    ]
                    delegate: Item {
                        required property var modelData
                        width: 14
                        height: 14
                        Rectangle {
                            anchors.fill: parent
                            radius: 7
                            color: modelData.fill
                            border.width: 1
                            border.color: "#3F000000"
                            Text {
                                anchors.centerIn: parent
                                text: modelData.mark
                                font.pixelSize: 10
                                color: "#784856"
                                opacity: hit.containsMouse ? 1 : 0
                            }
                        }
                        MouseArea {
                            id: hit
                            anchors.fill: parent
                            anchors.margins: -3
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                host.focused()
                                if (modelData.cmd === "close") host.closeRequested()
                                else if (modelData.cmd === "min") host.minimizeRequested()
                                else host.toggleMaximize()
                            }
                        }
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                text: host.appTitle
                font.pixelSize: 12
                font.family: System.Theme.fontFamily
                font.weight: Font.DemiBold
                color: "#566680"
            }
        }

        Loader {
            id: body
            x: 1; y: bar.height
            width: surface.width - 2
            height: surface.height - bar.height - 22
            active: host.loaded
            source: host.componentSource
            onStatusChanged: {
                if (status === Loader.Error)
                    console.error("CreOS: QML app failed:", host.appTitle, source)
            }
        }
        Rectangle {
            id: bottom
            x: 1
            y: surface.height - 22
            width: surface.width - 2
            height: 21
            radius: 21
            antialiasing: true
            color: "#EFF7FD"
            Rectangle {
                width: parent.width
                height: 11
                color: parent.color
            }
            Text {
                x: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "CREOS · SYSTEM"
                font.pixelSize: 8
                font.letterSpacing: 1
                color: "#93A4BA"
            }
        }
        Rectangle {
            visible: body.status === Loader.Error
            x: 1
            y: bar.height
            width: surface.width - 2
            height: surface.height - bar.height - 22
            color: "#FFFFFF"
            Column {
                anchors.centerIn: parent
                spacing: 10
                Text {
                    text: "Không tải được " + host.appTitle
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 20
                    color: "#A3485A"
                }
                Text {
                    text: "Mở Terminal trong VS Code để xem chi tiết."
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 12
                    color: "#6B7C94"
                }
            }
        }
    }

    // Passive tap to raise window, without blocking app control input.
    TapHandler {
        onTapped: host.focused()
        gesturePolicy: TapHandler.DragThreshold
    }

    ResizeHandle {
        windowItem: host; horizontal: -1; vertical: -1
        x: 0; y: 0; width: 16; height: 16
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host; horizontal: 1; vertical: -1
        x: host.width - 16; y: 0; width: 16; height: 16
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host; horizontal: -1; vertical: 1
        x: 0; y: host.height - 16; width: 16; height: 16
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host; horizontal: 1; vertical: 1
        x: host.width - 17; y: host.height - 17; width: 17; height: 17
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host; horizontal: -1; vertical: 0
        x: 0; y: 16; width: 9; height: host.height - 32
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host; horizontal: 1; vertical: 0
        x: host.width - 9; y: 16; width: 9; height: host.height - 32
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host; horizontal: 0; vertical: -1
        x: 16; y: 0; width: host.width - 32; height: 9
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host; horizontal: 0; vertical: 1
        x: 16; y: host.height - 9; width: host.width - 32; height: 9
        onPressed: host.focused()
    }
}
