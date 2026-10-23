import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../system" as System

// Every built-in application lives inside its own CreOS-managed window.
// The window has ONE rounded outline, 8 resizable edges/corners and
// independent enter/exit animations. Apps only provide Loader content.
Item {
    id: host
    property string appTitle: "Ứng dụng"
    property url componentSource
    property string appAppearance: "system"
    property Item backgroundSource: null
    property real backgroundYOffset: 0
    property bool maximized: false
    property bool loaded: false
    readonly property int minimumPanelWidth: 580
    readonly property int minimumPanelHeight: 370
    property real restoreX: 0
    property real restoreY: 0
    property real restoreWidth: 0
    property real restoreHeight: 0
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
        scale = 0.92
        enterAnimation.restart()
    }
    function animateOut(reason) {
        enterAnimation.stop()
        exitKind = reason
        leaveAnimation.restart()
    }
    function toggleMaximize() {
        if (!parent) return
        focused()
        geometryAnimation.stop()
        if (!maximized) {
            restoreX = x
            restoreY = y
            restoreWidth = width
            restoreHeight = height
            maximized = true
            animateGeometry(7, 7, parent.width - 14, parent.height - 14)
        } else {
            maximized = false
            var targetWidth = Math.min(restoreWidth, parent.width - 18)
            var targetHeight = Math.min(restoreHeight, parent.height - 18)
            animateGeometry(Math.max(8, Math.min(restoreX, parent.width - targetWidth - 8)),
                            Math.max(8, Math.min(restoreY, parent.height - targetHeight - 8)),
                            targetWidth, targetHeight)
        }
    }
    function animateGeometry(xValue, yValue, wValue, hValue) {
        movingX.to = xValue
        movingY.to = yValue
        sizingW.to = wValue
        sizingH.to = hValue
        geometryAnimation.restart()
    }

    ParallelAnimation {
        id: enterAnimation
        NumberAnimation {
            target: host; property: "opacity"
            from: 0; to: 1
            duration: 280; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: host; property: "scale"
            from: 0.92; to: 1
            duration: 370; easing.type: Easing.OutBack
        }
    }
    SequentialAnimation {
        id: leaveAnimation
        ParallelAnimation {
            NumberAnimation {
                target: host; property: "opacity"
                to: 0; duration: 210; easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: host; property: "scale"
                to: 0.94; duration: 230; easing.type: Easing.InCubic
            }
        }
        ScriptAction {
            script: {
                host.exitFinished(host.exitKind)
                host.opacity = 1
                host.scale = 1
            }
        }
    }
    ParallelAnimation {
        id: geometryAnimation
        NumberAnimation {
            id: movingX; target: host; property: "x"
            duration: 315; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: movingY; target: host; property: "y"
            duration: 315; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: sizingW; target: host; property: "width"
            duration: 315; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            id: sizingH; target: host; property: "height"
            duration: 315; easing.type: Easing.OutCubic
        }
    }

    // A single soft shadow, with no extra outlined layer behind the frame.
    Rectangle {
        x: 3; y: 9
        width: host.width; height: host.height
        radius: 25
        color: "#2C24364F"
        opacity: 0.38
    }
    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 24
        antialiasing: true
        clip: true
        color: "#EFF7FC"
        border.width: 1
        border.color: "#A6FFFFFF"

        // Wallpaper texture is blurred behind the frosted material.
        // The app content is NOT masked or placed behind a GPU layer.
        ShaderEffectSource {
            id: backgroundGrab
            anchors.fill: parent
            sourceItem: host.backgroundSource
            sourceRect: Qt.rect(host.x, host.y + host.backgroundYOffset,
                                host.width, host.height)
            textureSize: Qt.size(Math.max(1, Math.round(host.width / 2)),
                                 Math.max(1, Math.round(host.height / 2)))
            live: true
            visible: false
        }
        MultiEffect {
            anchors.fill: parent
            source: backgroundGrab
            visible: host.backgroundSource !== null
            blurEnabled: true
            blurMax: 20
            blur: 0.88
            autoPaddingEnabled: false
        }
        Rectangle {
            anchors.fill: parent
            color: host.appAppearance === "custom" ? "#E9FFFFFF" : "#E9F8FBFF"
        }

        // The top material is rounded at the top and squared at the bottom.
        Rectangle {
            id: titleBar
            width: panel.width - 2
            x: 1
            height: 50
            radius: 23
            antialiasing: true
            color: "#E3FFFFFF"
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 23
                color: parent.color
            }
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 1
                color: "#A4DBE4F2"
            }

            DragHandler {
                id: moving
                target: host
                enabled: !host.maximized
                xAxis.minimum: 6
                xAxis.maximum: Math.max(6, host.parent ? host.parent.width - host.width - 6 : 6)
                yAxis.minimum: 6
                yAxis.maximum: Math.max(6, host.parent ? host.parent.height - host.height - 6 : 6)
                onActiveChanged: if (active) host.focused()
            }
            TapHandler {
                gesturePolicy: TapHandler.ReleaseWithinBounds
                onTapped: host.focused()
                onDoubleTapped: host.toggleMaximize()
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 9
                Repeater {
                    model: [
                        { fill: "#FF615E", label: "×", operation: "close" },
                        { fill: "#FFBD44", label: "−", operation: "min" },
                        { fill: "#36CA58", label: "+", operation: "max" }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        width: 14; height: 14
                        radius: 7
                        color: modelData.fill
                        border.color: "#36576163"
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: "#715E61"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            opacity: buttonHit.containsMouse ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 110 } }
                        }
                        MouseArea {
                            id: buttonHit
                            anchors.fill: parent
                            anchors.margins: -3
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                host.focused()
                                if (modelData.operation === "close") host.closeRequested()
                                else if (modelData.operation === "min") host.minimizeRequested()
                                else host.toggleMaximize()
                            }
                        }
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                text: host.appTitle
                font.family: System.Theme.fontFamily
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: "#53617A"
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: "◈  CreOS"
                color: "#8494AD"
                font.pixelSize: 10
            }
        }

        Loader {
            id: appLoader
            active: host.loaded
            anchors.top: titleBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: footer.top
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            source: host.componentSource
            onStatusChanged: {
                if (status === Loader.Error)
                    console.error("CreOS app loading error:", source)
            }
        }

        // One continuous bottom rounded surface, without a second contour.
        Rectangle {
            id: footer
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            height: 21
            radius: 22
            color: "#E7F7FBFF"
            antialiasing: true
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 11
                color: parent.color
            }
            Text {
                x: 17
                anchors.verticalCenter: parent.verticalCenter
                text: "◈  CREOS"
                color: "#8D9FB7"
                font.pixelSize: 9
                font.letterSpacing: 1
            }
        }
        Rectangle {
            visible: appLoader.status === Loader.Error
            anchors.fill: appLoader
            color: "#F7F9FC"
            Column {
                anchors.centerIn: parent
                spacing: 8
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Không tải được ứng dụng"
                    color: "#A25166"
                    font.pixelSize: 20
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Kiểm tra Terminal trong VS Code."
                    color: "#7A8BA2"
                    font.pixelSize: 12
                }
            }
        }
    }

    // Passive focus detection does not obstruct app buttons or text fields.
    TapHandler {
        onTapped: host.focused()
        gesturePolicy: TapHandler.ReleaseWithinBounds
    }

    // Eight independent resize hit zones; disabled while maximized.
    ResizeHandle {
        windowItem: host
        horizontal: -1; vertical: -1
        x: 0; y: 0; width: 16; height: 16
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host
        horizontal: 1; vertical: -1
        x: host.width - width; y: 0; width: 16; height: 16
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host
        horizontal: -1; vertical: 1
        x: 0; y: host.height - height; width: 16; height: 16
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host
        horizontal: 1; vertical: 1
        x: host.width - width; y: host.height - height; width: 21; height: 21
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host
        horizontal: -1; vertical: 0
        x: 0; y: 16; width: 8; height: host.height - 32
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host
        horizontal: 1; vertical: 0
        x: host.width - width; y: 16; width: 8; height: host.height - 32
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host
        horizontal: 0; vertical: -1
        x: 16; y: 0; width: host.width - 32; height: 8
        onPressed: host.focused()
    }
    ResizeHandle {
        windowItem: host
        horizontal: 0; vertical: 1
        x: 16; y: host.height - height; width: host.width - 32; height: 8
        onPressed: host.focused()
    }
}
