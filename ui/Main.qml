import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import "components"
import "system" as System

ApplicationWindow {
    id: root
    visible: true
    title: "CreOS"
    width: 1260
    height: 820
    minimumWidth: 900
    minimumHeight: 600
    // Fullscreen inside Ubuntu by default; F11 restores a resizable window.
    visibility: Window.FullScreen
    function toggleFullscreen() {
        if (visibility === Window.FullScreen) showNormal()
        else showFullScreen()
    }
    Shortcut { sequence: "F11"; onActivated: root.toggleFullscreen() }
    color: "#CCD9EC"

    property bool launcherOpen: false
    property int activeAppIndex: 0
    property int nextWindowOrder: 0
    readonly property int registeredAppCount: System.Apps.applications.length
    // Test hook also proves multiple windows stay open simultaneously.
    property int smokeAppIndex: -1
    onSmokeAppIndexChanged: if (smokeAppIndex >= 0) openApp(smokeAppIndex)
    readonly property int visibleAppCount: windowStates.filter(function(entry) {
        return entry.opened && !entry.minimized
    }).length
    property string clockText: Qt.formatDateTime(new Date(), "HH:mm")

    // Each app has its own, independently managed window and z-order.
    // Replacing the array ensures QML bindings react to state changes.
    property var windowStates: System.Apps.applications.map(function(app, index) {
        return { opened: false, minimized: false, order: 0 }
    })

    function windowState(index) {
        if (index < 0 || index >= windowStates.length)
            return { opened: false, minimized: false, order: 0 }
        return windowStates[index]
    }
    function updateWindow(index, opened, minimized, bringForward) {
        if (index < 0 || index >= windowStates.length) return
        var updated = windowStates.slice()
        var previous = updated[index]
        updated[index] = {
            opened: opened,
            minimized: minimized,
            order: bringForward ? ++nextWindowOrder : previous.order
        }
        windowStates = updated
        if (bringForward) activeAppIndex = index
    }
    function openApp(index) {
        if (index < 0 || index >= registeredAppCount) return
        var previous = windowState(index)
        var win = appWindows.itemAt(index)
        launcherOpen = false
        if (!previous.opened || previous.minimized) {
            // Set the initial pose *before* the window becomes visible.
            if (win) {
                win.opacity = 0
                win.scale = 0.94
            }
            updateWindow(index, true, false, true)
            Qt.callLater(function() {
                if (win) win.animateIn()
            })
        } else {
            updateWindow(index, true, false, true)
        }
    }
    function focusApp(index) {
        if (windowState(index).opened && !windowState(index).minimized)
            updateWindow(index, true, false, true)
    }
    function minimizeApp(index) {
        var state = windowState(index)
        if (!state.opened || state.minimized) return
        var win = appWindows.itemAt(index)
        if (win) win.animateOut("minimize")
        else finishExit(index, "minimize")
    }
    function closeApp(index) {
        var state = windowState(index)
        if (!state.opened || state.minimized) return
        var win = appWindows.itemAt(index)
        if (win) win.animateOut("close")
        else finishExit(index, "close")
    }
    function finishExit(index, kind) {
        updateWindow(index, kind !== "close", kind === "minimize", false)
        if (index === activeAppIndex) {
            var best = -1
            var top = -1
            for (var i = 0; i < windowStates.length; i++) {
                var state = windowStates[i]
                if (state.opened && !state.minimized && state.order > top) {
                    top = state.order
                    best = i
                }
            }
            if (best >= 0) activeAppIndex = best
        }
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: root.clockText = Qt.formatDateTime(new Date(), "HH:mm")
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
                    text: "CreOS"
                    font.pixelSize: 11
                    color: "#455674"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.visibleAppCount + " cửa sổ"
                    font.pixelSize: 11
                    color: "#455674"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Hệ thống"
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
                        {label:"Cài đặt CreOS", action:"settings"},
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
                            else if (modelData.action === "settings") root.openApp(System.Apps.findIndex("settings"))
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

        // CreOS Window Manager: one AppWindow per registered app.
        // Windows can overlap, be dragged/resized, minimized and restored.
        Item {
            id: workspace
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: bar.bottom
            // Dock floats above workspace; maximized apps use the full height.
            anchors.bottom: scene.bottom
            clip: true

            function keepAllVisible() {
                for (var i = 0; i < appWindows.count; ++i) {
                    var w = appWindows.itemAt(i)
                    if (!w) continue
                    if (w.maximized) {
                        w.x = 7
                        w.y = 7
                        w.width = width - 14
                        w.height = height - 14
                    } else {
                        w.width = Math.min(w.width, width - 18)
                        w.height = Math.min(w.height, height - 18)
                        w.x = Math.max(6, Math.min(w.x, width - w.width - 6))
                        w.y = Math.max(6, Math.min(w.y, height - w.height - 6))
                    }
                }
            }
            onWidthChanged: Qt.callLater(keepAllVisible)
            onHeightChanged: Qt.callLater(keepAllVisible)

            Repeater {
                id: appWindows
                model: System.Apps.applications
                delegate: AppWindow {
                    id: appFrame
                    required property var modelData
                    required property int index
                    readonly property var windowRecord: root.windowState(index)

                    visible: windowRecord.opened && !windowRecord.minimized
                    loaded: windowRecord.opened || windowRecord.minimized
                    z: windowRecord.order
                    width: Math.min(940, workspace.width - 80)
                    height: Math.min(635, workspace.height - 90)
                    x: Math.max(9, (workspace.width - width) / 2 + index * 34 - 45)
                    y: Math.max(8, (workspace.height - height) / 2 + index * 24 - 26)
                    appTitle: modelData.name
                    appAppearance: modelData.appearance || "system"
                    backgroundSource: wallpaper
                    backgroundYOffset: bar.height
                    componentSource: Qt.resolvedUrl("apps/" + modelData.component)

                    onFocused: root.focusApp(index)
                    onCloseRequested: root.closeApp(index)
                    onMinimizeRequested: root.minimizeApp(index)
                    onExitFinished: function(kind) { root.finishExit(index, kind) }


                }
            }
        }

        // Dynamic Dock — built from the same application registry as Launchpad.
        Item {
            id: dock
            z: 15
            width: System.Apps.applications.length * 49 + 71
            height: 61
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 9

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
                radius: 19
                color: "#C3FFFFFF"
                border.width: 1
                border.color: "#F6FFFFFF"
            }
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 13; anchors.rightMargin: 13
                height: 1; color: "#CFFFFFFF"
            }
            Row {
                anchors.centerIn: parent
                spacing: 4
                Repeater {
                    model: System.Apps.applications
                    delegate: Item {
                        id: pinnedItem
                        required property var modelData
                        required property int index
                        width: 45; height: 52
                        AppIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: dockHit.containsMouse ? 0 : 5
                            size: dockHit.containsMouse ? 42 : 36
                            glyph: pinnedItem.modelData.glyph
                            tint: pinnedItem.modelData.tint
                            Behavior on y { NumberAnimation { duration: 215; easing.type: Easing.OutBack } }
                            Behavior on size { NumberAnimation { duration: 215; easing.type: Easing.OutBack } }
                        }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 1
                            width: 3; height: 3; radius: 2
                            color: root.windowState(pinnedItem.index).opened ?
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
                    width: 1; height: 31
                    color: "#A0B2CC"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item {
                    width: 45; height: 52
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: launcherHit.containsMouse ? 0 : 5
                        width: launcherHit.containsMouse ? 42 : 36
                        height: width
                        radius: 12
                        color: "#ECFFFFFF"
                        border.color: "#FFFFFF"
                        Behavior on y { NumberAnimation { duration: 215; easing.type: Easing.OutBack } }
                        Behavior on width { NumberAnimation { duration: 215; easing.type: Easing.OutBack } }
                        Text {
                            anchors.centerIn: parent
                            text: "▦"
                            font.pixelSize: 22
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
