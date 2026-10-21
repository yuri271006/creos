import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import "components"
import "system" as System

ApplicationWindow {
    id: root
    visible: true
    title: "CreOS  ·  The Inner Universe"
    width: 1260
    height: 820
    minimumWidth: 1020
    minimumHeight: 710
    color: "#CCD9EC"

    property bool appOpen: true
    property bool appMinimized: false
    property bool launcherOpen: false
    property int activeAppIndex: 0
    readonly property int registeredAppCount: System.Apps.applications.length
    property string clockText: Qt.formatDateTime(new Date(), "HH:mm")
    readonly property var activeApp: System.Apps.applications[activeAppIndex]

    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: root.clockText = Qt.formatDateTime(new Date(), "HH:mm")
    }
    function openApp(index) {
        if (index < 0 || index >= System.Apps.applications.length) return
        closeAnimation.stop()
        minimizeAnimation.stop()
        launcherOpen = false
        activeAppIndex = index
        appOpen = true
        appMinimized = false
        Qt.callLater(function () { openAnimation.restart() })
    }
    function minimizeApp() {
        if (!appOpen || appMinimized) return
        minimizeAnimation.restart()
    }
    function closeApp() {
        if (!appOpen) return
        closeAnimation.restart()
    }

    Item {
        id: scene
        anchors.fill: parent
        clip: true

        // Wallpaper drawn once in CreOS and sampled as the backdrop
        // for real GPU-blurred system surfaces.
        Item {
            id: wallpaper
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0; color: creosData.wallpaper === "peach" ? "#FFE8DA" : creosData.wallpaper === "midnight" ? "#27395F" : "#D8EFF7" }
                    GradientStop { position: 0.44; color: creosData.wallpaper === "peach" ? "#F8D4DB" : creosData.wallpaper === "midnight" ? "#4D5285" : "#B8CFEF" }
                    GradientStop { position: 1; color: creosData.wallpaper === "peach" ? "#D7A5C6" : creosData.wallpaper === "midnight" ? "#75669C" : "#B5AADB" }
                }
            }
            Rectangle {
                width: parent.width * 0.9
                height: 250
                x: -parent.width * 0.18
                y: parent.height * 0.16
                rotation: -30
                radius: height / 2
                gradient: Gradient {
                    GradientStop { position: 0; color: "#64FFFFFF" }
                    GradientStop { position: 1; color: "#12FFFFFF" }
                }
            }
            Rectangle {
                width: parent.width * 1.1
                height: 340
                x: parent.width * 0.19
                y: parent.height * 0.37
                radius: height / 2
                rotation: -27
                gradient: Gradient {
                    GradientStop { position: 0; color: creosData.wallpaper === "peach" ? "#85FFF2DC" : "#93D1EFFF" }
                    GradientStop { position: 0.5; color: creosData.wallpaper === "midnight" ? "#85A0A5DB" : "#8AC7B5F2" }
                    GradientStop { position: 1; color: "#4FB9C0F6" }
                }
            }
            Rectangle {
                width: 550; height: 550; radius: 275
                x: parent.width - 340
                y: parent.height - 370
                color: "#56F7E8FF"
            }
            Rectangle {
                width: 650; height: 650; radius: 325
                x: -270; y: parent.height - 365
                color: "#36FFFFFF"
            }
            Rectangle {
                width: parent.width * 0.68; height: 140; radius: 70
                x: parent.width * 0.2; y: parent.height * 0.48
                rotation: -27; color: "#30FFFFFF"
            }
        }

        // A thin macOS-inspired global menu bar.
        Item {
            id: bar
            width: parent.width
            height: 39
            z: 10
            ShaderEffectSource {
                id: menuCapture
                anchors.fill: parent
                sourceItem: wallpaper
                sourceRect: Qt.rect(0, 0, bar.width, bar.height)
                visible: false
            }
            MultiEffect {
                anchors.fill: parent
                source: menuCapture
                blurEnabled: true
                blurMax: 24
                blur: 1
                autoPaddingEnabled: false
            }
            Rectangle { anchors.fill: parent; color: "#A8FFFFFF" }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#55FFFFFF" }
            Row {
                x: 16; anchors.verticalCenter: parent.verticalCenter
                spacing: 17
                Button {
                    id: logoButton
                    width: 89; height: 28
                    hoverEnabled: true
                    onClicked: appMenu.open()
                    background: Rectangle { radius: 8; color: logoButton.hovered || appMenu.opened ? "#98FFFFFF" : "transparent" }
                    contentItem: Text {
                        text: "◈  CreOS"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: System.Theme.fontFamily
                        font.weight: Font.Bold
                        font.pixelSize: 12
                        color: "#2D3B59"
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Tệp"
                    font.pixelSize: 11
                    color: "#455674"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Cửa sổ"
                    font.pixelSize: 11
                    color: "#455674"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Developer Preview"
                    font.pixelSize: 11
                    color: "#7888A3"
                }
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 22
                anchors.verticalCenter: parent.verticalCenter
                spacing: 19
                Text { text: "◈"; font.pixelSize: 14; color: "#556987" }
                Text { text: "●  CREOS"; font.pixelSize: 10; font.weight: Font.DemiBold; color: "#657794"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: clockText; font.pixelSize: 11; font.weight: Font.DemiBold; color: "#354863"; anchors.verticalCenter: parent.verticalCenter }
            }
        }
        Popup {
            id: appMenu
            x: 16; y: 35
            width: 224
            height: 139
            padding: 7
            z: 20
            closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
            background: Rectangle { radius: 15; color: "#F2F9FF"; border.color: "#FFFFFFFF" }
            Column {
                anchors.fill: parent; spacing: 4
                Repeater {
                    model: [
                        {label:"Giới thiệu CreOS", action:"about"},
                        {label:"Thu nhỏ cửa sổ", action:"minimize"},
                        {label:"Thoát CreOS", action:"quit"}
                    ]
                    delegate: Button {
                        required property var modelData
                        width: parent.width
                        height: 37
                        hoverEnabled: true
                        onClicked: {
                            appMenu.close()
                            if (modelData.action === "about") root.openApp(0)
                            else if (modelData.action === "minimize") root.minimizeApp()
                            else Qt.quit()
                        }
                        background: Rectangle { radius: 9; color: parent.hovered ? "#E3EEFF" : "transparent" }
                        contentItem: Text {
                            text: modelData.label
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12
                            font.pixelSize: 12
                            color: "#3C4B65"
                        }
                    }
                }
            }
        }

        // Desktop icon remains useful after closing an app.
        Item {
            x: 43; y: 85; width: 84; height: 100
            Column {
                anchors.centerIn: parent; spacing: 8
                CreosMark {
                    size: 58
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Rectangle {
                    width: 77; height: 24; radius: 10
                    color: "#83FFFFFF"
                    Text { anchors.centerIn: parent; text: "CreOS"; color: "#3B4E6C"; font.pixelSize: 11; font.weight: Font.DemiBold }
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openApp(0)
            }
        }

        Item {
            id: workspace
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: bar.bottom
            anchors.bottom: dock.top
            anchors.bottomMargin: 6
            clip: false

            function keepWindowVisible() {
                if (appWindow.maximized) {
                    appWindow.x = 10
                    appWindow.y = 10
                    appWindow.width = width - 20
                    appWindow.height = height - 20
                } else {
                    appWindow.width = Math.min(appWindow.width, width - 22)
                    appWindow.height = Math.min(appWindow.height, height - 22)
                    appWindow.x = Math.max(8, Math.min(appWindow.x, width - appWindow.width - 8))
                    appWindow.y = Math.max(8, Math.min(appWindow.y, height - appWindow.height - 8))
                }
            }
            onWidthChanged: Qt.callLater(keepWindowVisible)
            onHeightChanged: Qt.callLater(keepWindowVisible)

            AppWindow {
                id: appWindow
                visible: root.appOpen && !root.appMinimized
                width: Math.min(948, workspace.width - 65)
                height: Math.min(578, workspace.height - 35)
                x: (workspace.width - width) / 2
                y: Math.max(13, (workspace.height - height) / 2)
                appTitle: root.activeApp.name
                appAppearance: root.activeApp.appearance || "system"
                backgroundSource: wallpaper
                backgroundYOffset: bar.height
                componentSource: Qt.resolvedUrl("apps/" + root.activeApp.component)
                onCloseRequested: root.closeApp()
                onMinimizeRequested: root.minimizeApp()
            }
            ParallelAnimation {
                id: openAnimation
                NumberAnimation {
                    target: appWindow; property: "opacity"
                    from: 0; to: 1; duration: 340; easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: appWindow; property: "scale"
                    from: 0.90; to: 1; duration: 445; easing.type: Easing.OutBack
                }
            }
            SequentialAnimation {
                id: minimizeAnimation
                ParallelAnimation {
                    NumberAnimation { target: appWindow; property: "opacity"; to: 0; duration: 280; easing.type: Easing.InCubic }
                    NumberAnimation { target: appWindow; property: "scale"; to: 0.77; duration: 290; easing.type: Easing.InCubic }
                }
                ScriptAction { script: { root.appMinimized = true; appWindow.opacity = 1; appWindow.scale = 1 } }
            }
            SequentialAnimation {
                id: closeAnimation
                ParallelAnimation {
                    NumberAnimation { target: appWindow; property: "opacity"; to: 0; duration: 210; easing.type: Easing.InCubic }
                    NumberAnimation { target: appWindow; property: "scale"; to: 0.96; duration: 240; easing.type: Easing.InCubic }
                }
                ScriptAction { script: { root.appOpen = false; appWindow.opacity = 1; appWindow.scale = 1 } }
            }
            Component.onCompleted: openAnimation.start()
        }

        // Dynamic Dock — built from the same application registry as Launchpad.
        Item {
            id: dock
            z: 15
            width: System.Apps.applications.length * 65 + 91
            height: 78
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15

            ShaderEffectSource {
                id: dockCapture
                anchors.fill: parent
                sourceItem: wallpaper
                sourceRect: Qt.rect(dock.x, dock.y, dock.width, dock.height)
                visible: false
            }
            MultiEffect {
                anchors.fill: parent
                source: dockCapture
                blurEnabled: true
                blurMax: 24
                blur: 1
                autoPaddingEnabled: false
            }
            Rectangle {
                anchors.fill: parent
                radius: 24
                color: "#B7FFFFFF"
                border.width: 1
                border.color: "#F6FFFFFF"
            }
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 16; anchors.rightMargin: 16
                height: 1; color: "#CFFFFFFF"
            }
            Row {
                anchors.centerIn: parent
                spacing: 6
                Repeater {
                    model: System.Apps.applications
                    delegate: Item {
                        id: pinnedItem
                        required property var modelData
                        required property int index
                        width: 59; height: 65
                        AppIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: dockHit.containsMouse ? 0 : 7
                            size: dockHit.containsMouse ? 51 : 45
                            glyph: pinnedItem.modelData.glyph
                            tint: pinnedItem.modelData.tint
                            Behavior on y { NumberAnimation { duration: 215; easing.type: Easing.OutBack } }
                            Behavior on size { NumberAnimation { duration: 215; easing.type: Easing.OutBack } }
                        }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 1
                            width: 4; height: 4; radius: 2
                            color: root.appOpen && root.activeAppIndex === pinnedItem.index ?
                                   "#4C587A" : "transparent"
                        }
                        MouseArea {
                            id: dockHit
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.openApp(pinnedItem.index)
                        }
                    }
                }
                Rectangle {
                    width: 1; height: 38
                    color: "#A0B2CC"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item {
                    width: 59; height: 65
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: launcherHit.containsMouse ? 0 : 7
                        width: launcherHit.containsMouse ? 51 : 45
                        height: width
                        radius: 15
                        color: "#ECFFFFFF"
                        border.color: "#FFFFFF"
                        Behavior on y { NumberAnimation { duration: 215; easing.type: Easing.OutBack } }
                        Behavior on width { NumberAnimation { duration: 215; easing.type: Easing.OutBack } }
                        Text {
                            anchors.centerIn: parent
                            text: "▦"
                            font.pixelSize: 27
                            color: "#6876AB"
                        }
                    }
                    MouseArea {
                        id: launcherHit
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.launcherOpen = !root.launcherOpen
                    }
                }
            }
        }

        // Launchpad shares its app model and icons with Dock.
        Item {
            id: launcherLayer
            z: 13
            width: 425
            height: 355
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: dock.top
            anchors.bottomMargin: 13
            visible: root.launcherOpen || launcherOpacity.running
            opacity: root.launcherOpen ? 1 : 0
            scale: root.launcherOpen ? 1 : 0.94
            transformOrigin: Item.Bottom
            Behavior on opacity {
                NumberAnimation { id: launcherOpacity; duration: 210; easing.type: Easing.OutCubic }
            }
            Behavior on scale {
                NumberAnimation { duration: 290; easing.type: Easing.OutBack }
            }

            ShaderEffectSource {
                id: libraryCapture
                anchors.fill: parent
                sourceItem: wallpaper
                sourceRect: Qt.rect(launcherLayer.x, launcherLayer.y,
                                    launcherLayer.width, launcherLayer.height)
                visible: false
            }
            MultiEffect {
                anchors.fill: parent
                source: libraryCapture
                blurEnabled: true; blurMax: 24; blur: 1
                autoPaddingEnabled: false
            }
            Rectangle {
                anchors.fill: parent
                radius: 25
                color: "#E2FFFFFF"
                border.color: "#F6FFFFFF"
                border.width: 1
            }
            Column {
                anchors.fill: parent
                anchors.margins: 21
                spacing: 12
                Text {
                    text: "Thư viện ứng dụng"
                    font.pixelSize: 19
                    font.weight: Font.DemiBold
                    color: "#34455D"
                }
                Text {
                    text: System.Apps.applications.length + " ứng dụng · Chọn để mở trong CreOS"
                    font.pixelSize: 11
                    color: "#7788A3"
                }
                Grid {
                    columns: 4
                    spacing: 10
                    Repeater {
                        model: System.Apps.applications
                        delegate: Item {
                            id: launcherItem
                            required property var modelData
                            required property int index
                            width: 88; height: 107
                            Column {
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: 10; spacing: 8
                                AppIcon {
                                    size: 56
                                    glyph: launcherItem.modelData.glyph
                                    tint: launcherItem.modelData.tint
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: launcherItem.modelData.name
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: "#425373"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.openApp(launcherItem.index)
                            }
                        }
                    }
                }
            }
        }
    }
}
