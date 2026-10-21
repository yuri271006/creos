import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../system" as System

// This app never draws its own operating-system window controls.
// CreOS supplies the outer chrome; this component owns only app content.
Item {
    id: app
    property int section: 0
    property int selectedRelease: 0
    readonly property var release: releaseStore.releases[selectedRelease]
    readonly property color ink: "#2E3C58"
    readonly property color softText: "#7B8BA3"
    clip: true

    function goTo(index) {
        if (section === index) return
        section = index
        pageMotion.restart()
    }
    ParallelAnimation {
        id: pageMotion
        NumberAnimation {
            target: pages; property: "opacity"
            from: 0; to: 1; duration: 280
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: pages; property: "scale"
            from: 0.986; to: 1; duration: 320
            easing.type: Easing.OutCubic
        }
    }
    Rectangle {
        anchors.fill: parent
        color: "#DDF9FCFF"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: sidebar
            Layout.preferredWidth: 207
            Layout.fillHeight: true
            color: "#7AE9F2FF"
            Rectangle {
                anchors.right: parent.right; width: 1; height: parent.height
                color: "#73CED8E7"
            }
            Column {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 5
                Row {
                    height: 69; spacing: 12
                    CreosMark { size: 37; anchors.verticalCenter: parent.verticalCenter }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 3
                        Text { text: "CreOS"; font.pixelSize: 16; font.weight: Font.DemiBold; color: app.ink }
                        Text { text: "SYSTEM INFORMATION"; font.pixelSize: 8; font.letterSpacing: 1; color: "#94A2B5" }
                    }
                }
                Text {
                    text: "THƯ VIỆN"
                    leftPadding: 10
                    topPadding: 15
                    bottomPadding: 9
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 1.2
                    color: "#97A6B8"
                }
                SidebarItem {
                    width: parent.width
                    glyph: "◈"
                    text: "Giới thiệu"
                    selected: app.section === 0
                    onClicked: app.goTo(0)
                }
                SidebarItem {
                    width: parent.width
                    glyph: "▤"
                    text: "Bản phát hành"
                    selected: app.section === 1
                    onClicked: app.goTo(1)
                }
                SidebarItem {
                    width: parent.width
                    glyph: "✳"
                    text: "Giao diện CreOS"
                    selected: app.section === 2
                    onClicked: app.goTo(2)
                }
            }
            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 24
                spacing: 8
                Rectangle { width: parent.width; height: 1; color: "#93C7D6E9" }
                Row {
                    spacing: 8
                    Rectangle { width: 7; height: 7; radius: 4; color: "#54B698"; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Developer Preview"; color: "#6F889B"; font.pixelSize: 10 }
                }
                Text { text: "Version " + releaseStore.latestVersion; color: "#A0ADC0"; font.pixelSize: 10 }
            }
        }

        Item {
            id: content
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                RowLayout {
                    Layout.preferredHeight: 69
                    Layout.fillWidth: true
                    Layout.leftMargin: 30
                    Layout.rightMargin: 27
                    Text {
                        Layout.fillWidth: true
                        text: app.section === 0 ? "Giới thiệu CreOS" : app.section === 1 ? "Bản phát hành" : "CreOS System UI"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        font.family: System.Theme.fontFamily
                        color: app.ink
                    }
                    Rectangle {
                        width: 87; height: 25; radius: 13
                        color: "#D9E7F2FF"
                        border.color: "#C7FFFFFF"
                        Text {
                            anchors.centerIn: parent
                            text: "◈  PREVIEW"
                            color: "#6E83B2"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#6FDCE3EF"
                }

                StackLayout {
                    id: pages
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 27
                    Layout.rightMargin: 27
                    Layout.bottomMargin: 16
                    Layout.topMargin: 12
                    currentIndex: app.section

                    // Elegant product introduction, not a dashboard.
                    Item {
                        Flickable {
                            anchors.fill: parent
                            contentWidth: width
                            contentHeight: overview.height + 18
                            boundsBehavior: Flickable.StopAtBounds
                            clip: true
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                            Column {
                                id: overview
                                width: parent.width - 7
                                spacing: 13

                                Rectangle {
                                    id: hero
                                    width: parent.width
                                    height: 252
                                    radius: 23
                                    antialiasing: true
                                    clip: true
                                    gradient: Gradient {
                                        GradientStop { position: 0; color: "#EBF5FF" }
                                        GradientStop { position: 0.55; color: "#DDEAFB" }
                                        GradientStop { position: 1; color: "#E3DAF3" }
                                    }
                                    border.width: 1
                                    border.color: "#F1FFFFFF"
                                    Rectangle {
                                        width: 245; height: 245; radius: 123
                                        x: hero.width - 171
                                        y: -89
                                        color: "#60FFFFFF"
                                        border.width: 1
                                        border.color: "#96FFFFFF"
                                    }
                                    Rectangle {
                                        width: 160; height: 160; radius: 80
                                        x: hero.width - 129
                                        y: 27
                                        color: "#50A0C7FF"
                                        border.color: "#A4FFFFFF"
                                    }
                                    CreosMark {
                                        size: 101
                                        x: hero.width - 137
                                        y: 63
                                    }
                                    Column {
                                        x: 25; y: 21; spacing: 11
                                        Text {
                                            text: "WELCOME TO THE INNER UNIVERSE"
                                            color: "#8699B5"; font.pixelSize: 9
                                            font.weight: Font.DemiBold; font.letterSpacing: 1.25
                                        }
                                        Text {
                                            text: "CreOS."
                                            color: "#304361"
                                            font.pixelSize: 45
                                            font.family: System.Theme.fontFamily
                                            font.weight: Font.DemiBold
                                        }
                                        Text {
                                            width: Math.max(200, hero.width - 190)
                                            wrapMode: Text.Wrap
                                            text: "Một không gian của riêng bạn."
                                            color: "#536C8E"
                                            font.pixelSize: 16
                                            font.weight: Font.Medium
                                        }
                                        Text {
                                            width: Math.max(210, hero.width - 190)
                                            wrapMode: Text.Wrap
                                            text: "Mỗi ý tưởng nhỏ, một ứng dụng mới.\nTất cả cùng sống trong CreOS."
                                            color: "#8193AC"
                                            font.pixelSize: 11
                                            lineHeight: 1.4
                                        }
                                    }
                                    Rectangle {
                                        x: 25; y: hero.height - 41
                                        width: 154; height: 25; radius: 12
                                        color: "#8CFFFFFF"
                                        border.color: "#CDFFFFFF"
                                        Text {
                                            anchors.centerIn: parent
                                            text: "VERSION  " + releaseStore.latestVersion
                                            color: "#6A7FA3"
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width; height: 102; radius: 19
                                    color: "#D6FFFFFF"
                                    border.width: 1
                                    border.color: "#FFFFFFFF"
                                    Row {
                                        anchors.fill: parent
                                        anchors.margins: 17
                                        spacing: 0
                                        Repeater {
                                            model: [
                                                { title:"PHIÊN BẢN", value:releaseStore.latestVersion, sub:"Developer Preview" },
                                                { title:"HỆ ĐIỀU HÀNH", value:"Ubuntu", sub:"Một cửa sổ độc lập" },
                                                { title:"PHONG CÁCH", value:"Glass UI", sub:"Thiết kế CreOS" }
                                            ]
                                            delegate: Item {
                                                required property var modelData
                                                width: (parent.width) / 3
                                                height: parent.height
                                                Column {
                                                    spacing: 6
                                                    Text { text: modelData.title; font.pixelSize: 9; font.weight: Font.Bold; color: "#99A8BA"; font.letterSpacing: 0.9 }
                                                    Text { text: modelData.value; font.pixelSize: 17; font.weight: Font.DemiBold; color: "#334663" }
                                                    Text { text: modelData.sub; font.pixelSize: 10; color: "#8D9DB4" }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width; height: 121; radius: 19
                                    color: "#C9FFFFFF"
                                    border.color: "#EBFFFFFF"
                                    Text {
                                        x: 20; y: 17
                                        text: "Bắt đầu một hành trình mới."
                                        color: "#334765"
                                        font.pixelSize: 15
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        x: 20; y: 46
                                        width: parent.width - 40
                                        wrapMode: Text.Wrap
                                        text: "CreOS sẽ phát triển từ một ứng dụng giới thiệu thành hệ sinh thái nhiều ứng dụng bên trong Ubuntu."
                                        color: "#8190A7"
                                        font.pixelSize: 11
                                    }
                                    SystemButton {
                                        x: 20; y: 80
                                        height: 30; width: 159
                                        text: "Bản phát hành"
                                        symbol: "→"
                                        onClicked: app.goTo(1)
                                    }
                                }
                            }
                        }
                    }

                    // Release timeline with compact list and readable notes.
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 13
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 91
                                radius: 18
                                color: "#D3FFFFFF"
                                border.width: 1; border.color: "#FFFFFFFF"
                                Text {
                                    x: 21; y: 17
                                    text: "Lịch sử & lộ trình"
                                    font.pixelSize: 22
                                    font.weight: Font.DemiBold
                                    color: app.ink
                                }
                                Text {
                                    x: 21; y: 52
                                    text: "Theo dõi những gì đã có và những gì CreOS đang hướng tới."
                                    font.pixelSize: 11
                                    color: app.softText
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 12

                                ListView {
                                    id: releaseList
                                    Layout.preferredWidth: Math.max(204, parent.width * 0.38)
                                    Layout.fillHeight: true
                                    clip: true
                                    spacing: 9
                                    model: releaseStore.releases
                                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                    delegate: Rectangle {
                                        required property var modelData
                                        required property int index
                                        width: releaseList.width - 7
                                        height: 104
                                        radius: 17
                                        color: app.selectedRelease === index ? "#D3E0F7" : (selectionArea.containsMouse ? "#E9FFFFFF" : "#BFFFFFFF")
                                        border.width: 1
                                        border.color: app.selectedRelease === index ? "#A9C2F0" : "#E7FFFFFF"
                                        Behavior on color { ColorAnimation { duration: 180 } }
                                        MouseArea {
                                            id: selectionArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: app.selectedRelease = index
                                        }
                                        Text {
                                            x: 15; y: 14
                                            text: "v" + modelData.version
                                            color: app.ink
                                            font.pixelSize: 16
                                            font.weight: Font.DemiBold
                                        }
                                        Text {
                                            x: 15; y: 42
                                            text: modelData.type === "current" ? "●  PHIÊN BẢN HIỆN TẠI" : "○  DỰ KIẾN"
                                            color: modelData.type === "current" ? "#288E7B" : "#8899B4"
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                        }
                                        Text {
                                            x: 15; y: 74
                                            width: parent.width - 27
                                            elide: Text.ElideRight
                                            text: modelData.name
                                            color: "#8394AF"
                                            font.pixelSize: 11
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 18
                                    color: "#DDFFFFFF"
                                    border.width: 1
                                    border.color: "#F5FFFFFF"
                                    Flickable {
                                        anchors.fill: parent
                                        anchors.margins: 21
                                        contentWidth: width
                                        contentHeight: detail.height + 18
                                        clip: true
                                        boundsBehavior: Flickable.StopAtBounds
                                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                        Column {
                                            id: detail
                                            width: parent.width
                                            spacing: 12
                                            Text {
                                                text: app.release.type === "current" ? "●  DEVELOPER PREVIEW" : "○  KẾ HOẠCH"
                                                color: app.release.type === "current" ? "#32957D" : "#8B9CB3"
                                                font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 0.6
                                            }
                                            Text {
                                                text: app.release.version
                                                color: "#354A6B"
                                                font.pixelSize: 35
                                                font.weight: Font.DemiBold
                                            }
                                            Text { text: app.release.name; font.pixelSize: 14; color: "#69809F" }
                                            Rectangle { width: parent.width; height: 1; color: "#D7E4F0" }
                                            Text {
                                                text: app.release.description
                                                width: parent.width; wrapMode: Text.Wrap
                                                font.pixelSize: 12; lineHeight: 1.43
                                                color: "#7488A4"
                                            }
                                            Text {
                                                text: "NỘI DUNG"
                                                topPadding: 7
                                                font.pixelSize: 9; font.weight: Font.Bold; font.letterSpacing: 1
                                                color: "#A2ACC2"
                                            }
                                            Repeater {
                                                model: app.release.highlights
                                                delegate: Row {
                                                    required property string modelData
                                                    width: detail.width
                                                    spacing: 9
                                                    Rectangle {
                                                        y: 6; width: 6; height: 6; radius: 3
                                                        color: "#91B0EF"
                                                    }
                                                    Text {
                                                        width: detail.width - 18
                                                        text: modelData
                                                        wrapMode: Text.Wrap
                                                        color: "#536B8D"
                                                        font.pixelSize: 11
                                                        lineHeight: 1.4
                                                    }
                                                }
                                            }
                                            Text {
                                                text: app.release.status + "  ·  " + app.release.date
                                                color: "#9CAFC3"
                                                font.pixelSize: 10
                                                topPadding: 8
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Show how the future app ecosystem inherits CreOS styling.
                    Item {
                        Flickable {
                            anchors.fill: parent
                            contentWidth: width
                            contentHeight: design.height + 8
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            Column {
                                id: design
                                width: parent.width - 7
                                spacing: 13
                                Rectangle {
                                    width: parent.width; height: 144; radius: 20
                                    gradient: Gradient {
                                        GradientStop { position: 0; color: "#E2EBFD" }
                                        GradientStop { position: 1; color: "#E4DCF5" }
                                    }
                                    border.color: "#FFFFFFFF"
                                    Text {
                                        x: 20; y: 21
                                        text: "The CreOS language."
                                        color: "#364B6A"
                                        font.pixelSize: 24
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        x: 20; y: 65
                                        width: parent.width - 40
                                        wrapMode: Text.Wrap
                                        text: "Một hệ giao diện nền tảng. Nhiều ứng dụng với cá tính khác nhau."
                                        font.pixelSize: 12; color: "#7486A4"
                                    }
                                    Text {
                                        x: 20; y: 111
                                        text: "MATERIALS   ·   MOTION   ·   COMPONENTS"
                                        font.pixelSize: 9; font.letterSpacing: 1.5
                                        color: "#93A3BC"
                                    }
                                }
                                Row {
                                    spacing: 13
                                    Repeater {
                                        model: [
                                            {title:"System Style",body:"Kế thừa màu, kính, bo góc, typography và các điều khiển CreOS.",icon:"◈"},
                                            {title:"Custom Style",body:"Sáng tạo nội dung riêng, giữ nguyên khung và hành vi cửa sổ.",icon:"✧"}
                                        ]
                                        delegate: Rectangle {
                                            required property var modelData
                                            width: (design.width - 13) / 2
                                            height: 129; radius: 19
                                            color: "#D2FFFFFF"; border.color: "#FFFFFFFF"
                                            Text { x: 16; y: 15; text: modelData.icon; font.pixelSize: 19; color: "#738DDD" }
                                            Text { x: 16; y: 49; text: modelData.title; font.pixelSize: 14; font.weight: Font.DemiBold; color: app.ink }
                                            Text {
                                                x: 16; y: 78
                                                width: parent.width - 32
                                                wrapMode: Text.Wrap
                                                text: modelData.body
                                                font.pixelSize: 11
                                                color: app.softText
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    width: parent.width; height: 141; radius: 18
                                    color: "#DBFFFFFF"; border.color: "#FFFFFF"
                                    Text { x: 17; y: 15; text: "Vật liệu · Color & Glass"; font.pixelSize: 13; font.weight: Font.DemiBold; color: app.ink }
                                    Row {
                                        x: 17; y: 50; spacing: 13
                                        Repeater {
                                            model: [
                                                { name:"Pearl", c:"#F6FAFF" }, { name:"Ice", c:"#CAE9FA" },
                                                { name:"Lilac", c:"#C4BCE9" }, { name:"Accent", c:"#7083DE" }
                                            ]
                                            delegate: Column {
                                                required property var modelData
                                                spacing: 6
                                                Rectangle {
                                                    width: 75; height: 49; radius: 13
                                                    color: modelData.c
                                                    border.color: "#FFFFFFFF"
                                                }
                                                Text {
                                                    text: modelData.name
                                                    width: 75
                                                    horizontalAlignment: Text.AlignHCenter
                                                    font.pixelSize: 10
                                                    color: "#8999AF"
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    width: parent.width; height: 104; radius: 18
                                    color: "#D4FFFFFF"; border.color: "#FFFFFF"
                                    Text { x: 17; y: 14; text: "Các điều khiển chuẩn"; font.pixelSize: 13; font.weight: Font.DemiBold; color: app.ink }
                                    Row {
                                        x: 17; y: 50; spacing: 10
                                        SystemButton {
                                            text: "Mã nguồn"
                                            primary: true
                                            symbol: "↗"
                                            onClicked: Qt.openUrlExternally(releaseStore.repository)
                                        }
                                        SystemButton {
                                            text: "Bản phát hành"
                                            symbol: "→"
                                            onClicked: app.goTo(1)
                                        }
                                    }
                                }
                                Text {
                                    width: parent.width
                                    wrapMode: Text.Wrap
                                    text: "System tokens: ui/system/Theme.qml   •   Registry: ui/system/Apps.qml"
                                    font.pixelSize: 10
                                    color: "#97A8BE"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
