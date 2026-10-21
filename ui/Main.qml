import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"
import "system" as System

// One Ubuntu window containing its own miniature CreOS desktop.
// Desktop, menu bar, app chrome, launcher and dock are owned by CreOS.
ApplicationWindow {
    id: root
    visible: true
    width: 1220
    height: 790
    minimumWidth: 980
    minimumHeight: 660
    color: "#DCE8F5"
    title: "CreOS — The Inner Universe"

    property bool appOpen: true
    property bool appMinimized: false
    property bool launcherOpen: false
    property string clockText: Qt.formatDateTime(new Date(), "HH:mm")
    property int activeAppIndex: 0
    readonly property var activeApp: System.Apps.applications[activeAppIndex]

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.clockText = Qt.formatDateTime(new Date(), "HH:mm")
    }
    function openApp(index) {
        if (index < 0 || index >= System.Apps.applications.length)
            return
        activeAppIndex = index
        launcherOpen = false
        appOpen = true
        appMinimized = false
        windowIntro.restart()
    }
    function openCreos() { openApp(0) }

    Item {
        id: desktop
        anchors.fill: parent
        clip: true

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0; color: System.Theme.wallpaperTop }
                GradientStop { position: 0.50; color: "#B8CDEA" }
                GradientStop { position: 1; color: System.Theme.wallpaperBottom }
            }
        }
        Rectangle {
            id: auroraBlue
            width: 780; height: 780; radius: 390
            x: -240; y: -260
            color: "#778CD8EF"
            opacity: 0.55
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: -150; duration: 18000; easing.type: Easing.InOutSine }
                NumberAnimation { to: -240; duration: 18000; easing.type: Easing.InOutSine }
            }
        }
        Rectangle {
            width: 730; height: 730; radius: 365
            x: desktop.width - 380; y: desktop.height - 580
            color: "#91E3BFEA"
            opacity: 0.7
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: desktop.height - 650; duration: 14000; easing.type: Easing.InOutSine }
                NumberAnimation { to: desktop.height - 580; duration: 14000; easing.type: Easing.InOutSine }
            }
        }
        Rectangle {
            width: 560; height: 560; radius: 280
            x: desktop.width * 0.33; y: desktop.height * 0.24
            color: "#83FBF8FF"
            opacity: 0.55
            rotation: 19
        }
        Rectangle {
            width: desktop.width * 1.15
            height: 248
            x: -45
            y: desktop.height * 0.33
            radius: 124
            rotation: -19
            color: "#45FFFFFF"
        }

        // CreOS owns the OS menu bar; apps cannot replace system controls.
        Rectangle {
            id: topBar
            width: parent.width
            height: 39
            color: "#C7FFFFFF"
            border.color: "#A7FFFFFF"
            border.width: 1
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                spacing: 17
                Button {
                    id: systemMenuButton
                    implicitWidth: 83
                    implicitHeight: 28
                    hoverEnabled: true
                    onClicked: systemPopup.open()
                    background: Rectangle {
                        radius: 9
                        color: systemMenuButton.hovered || systemPopup.opened ? "#82FFFFFF" : "transparent"
                    }
                    contentItem: Text {
                        text: "✦  CreOS"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: System.Theme.ink
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Giới thiệu"
                    font.pixelSize: 11
                    color: System.Theme.ink
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Developer Preview"
                    font.pixelSize: 11
                    color: "#75849B"
                }
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 23
                anchors.verticalCenter: parent.verticalCenter
                spacing: 18
                Text {
                    text: "◈"
                    color: "#697B98"
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "●  SYSTEM"
                    color: "#60718F"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: root.clockText
                    color: System.Theme.ink
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Popup {
            id: systemPopup
            parent: desktop
            x: 20
            y: 37
            width: 212
            height: 136
            padding: 8
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            background: Rectangle {
                radius: 16
                color: "#EDF9FCFF"
                border.color: "#EDFFFFFF"
            }
            Column {
                anchors.fill: parent
                spacing: 5
                Button {
                    width: parent.width; height: 36
                    text: "Giới thiệu CreOS"
                    onClicked: { systemPopup.close(); root.openCreos() }
                    background: Rectangle { radius: 9; color: parent.hovered ? "#DCEBFF" : "transparent" }
                }
                Button {
                    width: parent.width; height: 36
                    text: root.appMinimized || !root.appOpen ? "Hiện ứng dụng" : "Thu nhỏ ứng dụng"
                    onClicked: {
                        systemPopup.close()
                        if (!root.appOpen || root.appMinimized) root.openCreos()
                        else root.appMinimized = true
                    }
                    background: Rectangle { radius: 9; color: parent.hovered ? "#DCEBFF" : "transparent" }
                }
                Button {
                    width: parent.width; height: 36
                    text: "Thoát CreOS"
                    onClicked: Qt.quit()
                    background: Rectangle { radius: 9; color: parent.hovered ? "#DCEBFF" : "transparent" }
                }
            }
        }

        // An OS desktop shortcut, also useful after closing the app window.
        Item {
            id: shortcut
            x: 38; y: 65
            width: 102; height: 116
            Column {
                anchors.centerIn: parent
                spacing: 7
                CreosMark {
                    size: 64
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Rectangle {
                    width: 96; height: 23; radius: 10
                    color: "#76FFFFFF"
                    Text {
                        anchors.centerIn: parent
                        text: "CreOS"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: System.Theme.ink
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onDoubleClicked: root.openCreos()
                onClicked: root.openCreos()
            }
        }

        Item {
            id: workspace
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: topBar.bottom
            anchors.bottom: dock.top
            anchors.bottomMargin: 7
            clip: true

            function adjustWindow() {
                if (appWindow.maximized) {
                    appWindow.x = 8
                    appWindow.y = 9
                    appWindow.width = width - 16
                    appWindow.height = height - 19
                } else {
                    if (appWindow.width > width - 20) appWindow.width = width - 20
                    if (appWindow.height > height - 20) appWindow.height = height - 20
                    if (appWindow.x + appWindow.width > width - 6) appWindow.x = Math.max(6, width - appWindow.width - 6)
                    if (appWindow.y + appWindow.height > height - 6) appWindow.y = Math.max(6, height - appWindow.height - 6)
                }
            }
            onWidthChanged: Qt.callLater(adjustWindow)
            onHeightChanged: Qt.callLater(adjustWindow)

            Rectangle {
                visible: appWindow.visible
                x: appWindow.x + 9
                y: appWindow.y + 13
                width: appWindow.width
                height: appWindow.height
                radius: 26
                color: "#201E315A"
            }
            AppWindow {
                id: appWindow
                visible: root.appOpen && !root.appMinimized
                width: Math.min(960, workspace.width - 42)
                height: Math.min(555, workspace.height - 28)
                x: (workspace.width - width) / 2
                y: Math.max(11, (workspace.height - height) / 2)
                appTitle: root.activeApp.name
                componentSource: Qt.resolvedUrl("apps/" + root.activeApp.component)
                onCloseRequested: root.appOpen = false
                onMinimizeRequested: root.appMinimized = true
            }
            ParallelAnimation {
                id: windowIntro
                NumberAnimation {
                    target: appWindow
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: System.Theme.durationNormal
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: appWindow
                    property: "scale"
                    from: 0.965
                    to: 1
                    duration: System.Theme.durationSlow
                    easing.type: Easing.OutBack
                }
            }
            Component.onCompleted: windowIntro.start()
        }

        // Floating CreOS dock.
        Rectangle {
            id: dock
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 14
            width: 179
            height: 75
            radius: 24
            color: System.Theme.dockGlass
            border.width: 1
            border.color: "#F3FFFFFF"

            Row {
                anchors.centerIn: parent
                spacing: 13
                Item {
                    id: aboutDockTile
                    width: 59
                    height: 60
                    CreosMark {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: aboutDockHover.containsMouse ? 1 : 5
                        size: aboutDockHover.containsMouse ? 49 : 44
                        Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        Behavior on size { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 1
                        width: 4; height: 4; radius: 2
                        color: root.appOpen ? "#59677D" : "transparent"
                    }
                    MouseArea {
                        id: aboutDockHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openCreos()
                    }
                }
                Rectangle {
                    width: 1; height: 39
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#ACBED1"
                }
                Item {
                    width: 59; height: 60
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: launcherHit.containsMouse ? 2 : 6
                        width: launcherHit.containsMouse ? 49 : 44
                        height: width
                        radius: 15
                        color: "#EDFFFFFF"
                        border.color: "#FFFFFF"
                        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        Text {
                            anchors.centerIn: parent
                            text: "▦"
                            color: "#7280BD"
                            font.pixelSize: 25
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

        // App library/Launchpad: registered apps appear here.
        Rectangle {
            id: launcher
            visible: root.launcherOpen
            width: 335; height: 240
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: dock.top
            anchors.bottomMargin: 14
            radius: 26
            color: "#E9F6FAFF"
            border.width: 1
            border.color: "#FFFFFFFF"
            Column {
                anchors.fill: parent
                anchors.margins: 19
                spacing: 14
                Text {
                    text: "Thư viện ứng dụng"
                    color: System.Theme.ink
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                }
                Text {
                    text: "Các ứng dụng hiện có trong CreOS"
                    color: System.Theme.secondary
                    font.pixelSize: 11
                }
                Row {
                    spacing: 20
                    Repeater {
                        model: System.Apps.applications
                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: 84; height: 100
                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                CreosMark {
                                    size: 55
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: modelData.name
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: System.Theme.ink
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.openApp(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
