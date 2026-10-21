import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "../system" as System

// CreOS owns window movement, rounded clipping, blur and window controls.
Item {
    id: host
    property string appTitle: "CreOS"
    property url componentSource
    property string appAppearance: "system"
    property Item backgroundSource: null
    property real backgroundYOffset: 0
    property bool maximized: false
    property real restoredX: 0
    property real restoredY: 0
    property real restoredWidth: 930
    property real restoredHeight: 585
    readonly property int minimumPanelWidth: 700
    readonly property int minimumPanelHeight: 425
    signal closeRequested()
    signal minimizeRequested()
    signal focused()

    function toggleMaximize() {
        if (!parent) return
        if (!maximized) {
            restoredX = x
            restoredY = y
            restoredWidth = width
            restoredHeight = height
            maximized = true
            geometryAnimation.stop()
            geometryAnimation.toX = 10
            geometryAnimation.toY = 10
            geometryAnimation.toW = parent.width - 20
            geometryAnimation.toH = parent.height - 20
            geometryAnimation.start()
        } else {
            maximized = false
            geometryAnimation.stop()
            geometryAnimation.toX = Math.max(9, Math.min(restoredX, parent.width - restoredWidth - 9))
            geometryAnimation.toY = Math.max(9, Math.min(restoredY, parent.height - restoredHeight - 9))
            geometryAnimation.toW = Math.min(restoredWidth, parent.width - 18)
            geometryAnimation.toH = Math.min(restoredHeight, parent.height - 18)
            geometryAnimation.start()
        }
    }

    // Animate geometry only on maximize / restore, never during dragging.
    ParallelAnimation {
        id: geometryAnimation
        property real toX: 0
        property real toY: 0
        property real toW: 900
        property real toH: 550
        NumberAnimation { target: host; property: "x"; to: geometryAnimation.toX; duration: 350; easing.type: Easing.OutCubic }
        NumberAnimation { target: host; property: "y"; to: geometryAnimation.toY; duration: 350; easing.type: Easing.OutCubic }
        NumberAnimation { target: host; property: "width"; to: geometryAnimation.toW; duration: 350; easing.type: Easing.OutCubic }
        NumberAnimation { target: host; property: "height"; to: geometryAnimation.toH; duration: 350; easing.type: Easing.OutCubic }
    }

    // Layer alpha mask clips *all child pixels*, including sidebar and content,
    // to the same rounded silhouette. Rectangle.clip alone is rectangular.
    Rectangle {
        id: alphaMask
        x: 0
        y: 0
        width: host.width
        height: host.height
        radius: 24
        color: "white"
        antialiasing: true
    }
    ShaderEffectSource {
        id: maskTexture
        width: host.width
        height: host.height
        sourceItem: alphaMask
        hideSource: true
        live: true
        visible: false
    }

    // Subtle, multi-layer shadow outside the masked window.
    Rectangle {
        anchors.fill: panel
        anchors.margins: -12
        anchors.topMargin: -4
        radius: 35
        color: "#10213968"
        opacity: 0.42
    }
    Rectangle {
        anchors.fill: panel
        anchors.margins: -5
        anchors.topMargin: -2
        radius: 30
        color: "#20223A63"
        opacity: 0.28
    }

    Item {
        id: panel
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: maskTexture
            maskThresholdMin: 0.46
            maskThresholdMax: 0.54
            autoPaddingEnabled: false
        }

        ShaderEffectSource {
            id: backgroundGrab
            anchors.fill: parent
            sourceItem: host.backgroundSource
            sourceRect: Qt.rect(host.x, host.y + host.backgroundYOffset, host.width, host.height)
            textureSize: Qt.size(Math.max(1, Math.round(host.width / 2)), Math.max(1, Math.round(host.height / 2)))
            live: true
            visible: false
        }
        MultiEffect {
            anchors.fill: parent
            source: backgroundGrab
            visible: host.backgroundSource !== null
            blurEnabled: true
            blurMax: 24
            blur: 0.92
            autoPaddingEnabled: false
        }
        Rectangle {
            anchors.fill: parent
            color: host.appAppearance === "custom" ? "#D9FFFFFF" : "#CFF9FBFF"
        }

        Rectangle {
            id: titlebar
            width: parent.width
            height: 52
            color: "#9FFFFFFF"
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#5BB2BED3"
            }
            // Handles move the *whole* window, without lag from Behaviors.
            DragHandler {
                target: host
                enabled: !host.maximized
                xAxis.minimum: 6
                xAxis.maximum: Math.max(6, host.parent ? host.parent.width - host.width - 6 : 6)
                yAxis.minimum: 6
                yAxis.maximum: Math.max(6, host.parent ? host.parent.height - host.height - 6 : 6)
                onActiveChanged: if (active) host.focused()
            }
            Row {
                x: 19
                anchors.verticalCenter: parent.verticalCenter
                spacing: 9
                Repeater {
                    model: [
                        { c: "#FF605B", h: "#EF4541", sign: "×", action: "close" },
                        { c: "#FFBE43", h: "#F6AA26", sign: "−", action: "min" },
                        { c: "#35CB55", h: "#21AE42", sign: "+", action: "max" }
                    ]
                    delegate: Item {
                        required property var modelData
                        width: 15
                        height: 15
                        Rectangle {
                            anchors.centerIn: parent
                            width: 13; height: 13; radius: 7
                            color: trafficArea.containsMouse ? modelData.h : modelData.c
                            border.width: 1
                            border.color: "#3F546066"
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Text {
                                anchors.centerIn: parent
                                text: modelData.sign
                                visible: trafficArea.containsMouse
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: "#66505C"
                            }
                        }
                        MouseArea {
                            id: trafficArea
                            anchors.fill: parent
                            anchors.margins: -3
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.action === "close") host.closeRequested()
                                else if (modelData.action === "min") host.minimizeRequested()
                                else host.toggleMaximize()
                            }
                        }
                    }
                }
            }
            Text {
                anchors.centerIn: parent
                text: host.appTitle
                color: "#56647C"
                font.pixelSize: 12
                font.family: System.Theme.fontFamily
                font.weight: Font.DemiBold
            }
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 17
                anchors.verticalCenter: parent.verticalCenter
                width: 78; height: 25; radius: 12
                color: "#83FFFFFF"
                border.color: "#B0FFFFFF"
                Text {
                    anchors.centerIn: parent
                    text: "◈  CreOS"
                    font.pixelSize: 10
                    color: "#637994"
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
            source: host.componentSource
            onStatusChanged: {
                if (status === Loader.Error)
                    console.error("CreOS: unable to load", host.componentSource)
            }
        }
    }

    // Anti-aliased contour remains visible over pale wallpapers.
    Rectangle {
        anchors.fill: parent
        radius: 24
        color: "transparent"
        border.width: 1
        border.color: "#DFFFFFFF"
        antialiasing: true
    }

    // Resizing gesture lives outside masked content, so it stays draggable.
    Item {
        visible: !host.maximized
        width: 25
        height: 25
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        property real widthAtStart: 0
        property real heightAtStart: 0
        Text {
            anchors.centerIn: parent
            text: "◢"
            font.pixelSize: 12
            color: "#8394AF"
        }
        DragHandler {
            target: null
            cursorShape: Qt.SizeFDiagCursor
            onActiveChanged: {
                if (active) {
                    parent.widthAtStart = host.width
                    parent.heightAtStart = host.height
                }
            }
            onTranslationChanged: {
                if (active && host.parent) {
                    host.width = Math.max(host.minimumPanelWidth,
                        Math.min(host.parent.width - host.x - 8, parent.widthAtStart + translation.x))
                    host.height = Math.max(host.minimumPanelHeight,
                        Math.min(host.parent.height - host.y - 8, parent.heightAtStart + translation.y))
                }
            }
        }
    }
}
