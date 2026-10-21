import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../system" as System

// Built-in About CreOS app: only content lives here.
// CreOS provides its surrounding window, animations and controls.
Item {
    id: app
    property int tab: 0
    property int selectedRelease: 0
    readonly property color ink: System.Theme.ink
    readonly property color secondary: System.Theme.secondary
    readonly property var release: releaseStore.releases[selectedRelease]
    clip: true

    Rectangle {
        anchors.fill: parent
        color: "#F2F8FCFF"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: sidebar
            Layout.preferredWidth: 190
            Layout.fillHeight: true
            color: "#B5EDF4FD"
            border.color: "#BCFFFFFF"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 5
                Row {
                    width: parent.width
                    height: 64
                    spacing: 11
                    CreosMark { size: 39; anchors.verticalCenter: parent.verticalCenter }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 3
                        Text {
                            text: "CreOS"
                            font.family: System.Theme.fontFamily
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: app.ink
                        }
                        Text {
                            text: "TRUNG TÂM HỆ THỐNG"
                            font.pixelSize: 8
                            font.letterSpacing: 0.7
                            color: "#8897AD"
                        }
                    }
                }
                Text {
                    text: "THƯ VIỆN"
                    topPadding: 15
                    bottomPadding: 6
                    leftPadding: 9
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                    color: System.Theme.muted
                }
                SidebarItem {
                    width: parent.width
                    glyph: "◈"
                    text: "Tổng quan"
                    selected: app.tab === 0
                    onClicked: app.tab = 0
                }
                SidebarItem {
                    width: parent.width
                    glyph: "▤"
                    text: "Bản phát hành"
                    selected: app.tab === 1
                    onClicked: app.tab = 1
                }
                SidebarItem {
                    width: parent.width
                    glyph: "✧"
                    text: "Bộ giao diện"
                    selected: app.tab === 2
                    onClicked: app.tab = 2
                }
            }
            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 19
                spacing: 7
                Rectangle { width: parent.width; height: 1; color: "#BDD0E4" }
                Text {
                    text: "●  " + releaseStore.channel
                    color: "#5787A5"
                    font.pixelSize: 10
                }
                Text {
                    text: "Version " + releaseStore.latestVersion
                    color: System.Theme.muted
                    font.pixelSize: 10
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    Layout.leftMargin: 27
                    Layout.rightMargin: 25
                    spacing: 10
                    Column {
                        Layout.fillWidth: true
                        spacing: 5
                        Text {
                            text: "CREOS / " + (app.tab === 0 ? "TỔNG QUAN" : app.tab === 1 ? "PHÁT HÀNH" : "SYSTEM UI")
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.2
                            color: System.Theme.muted
                        }
                        Text {
                            text: app.tab === 0 ? "Xin chào, CreOS." : app.tab === 1 ? "Các bản phát hành" : "Ngôn ngữ thiết kế"
                            font.family: System.Theme.fontFamily
                            font.pixelSize: 20
                            font.weight: Font.DemiBold
                            color: app.ink
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 116; Layout.preferredHeight: 29
                        radius: 14
                        color: "#D8EDEEFF"
                        border.color: "#F8FFFFFF"
                        Text {
                            anchors.centerIn: parent
                            text: "●  DEVELOPER"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            color: "#5977B6"
                        }
                    }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 25
                    Layout.rightMargin: 25
                    Layout.bottomMargin: 15
                    currentIndex: app.tab

                    // Overview — macOS "About" inspired editorial layout.
                    Item {
                        Flickable {
                            anchors.fill: parent
                            contentWidth: width
                            contentHeight: overviewColumn.height + 14
                            boundsBehavior: Flickable.StopAtBounds
                            clip: true
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                            Column {
                                id: overviewColumn
                                width: parent.width - 7
                                spacing: 13

                                Rectangle {
                                    id: introduction
                                    width: parent.width
                                    height: 216
                                    radius: 23
                                    clip: true
                                    gradient: Gradient {
                                        GradientStop { position: 0; color: "#F5EAF5FF" }
                                        GradientStop { position: 0.6; color: "#DFE6FB" }
                                        GradientStop { position: 1; color: "#E1D9F5" }
                                    }
                                    border.color: "#E9FFFFFF"
                                    border.width: 1
                                    Rectangle {
                                        width: 235; height: 235; radius: 118
                                        x: parent.width - 177; y: -92
                                        color: "#50FFFFFF"
                                        border.width: 1; border.color: "#8FFFFFFF"
                                    }
                                    Rectangle {
                                        width: 168; height: 168; radius: 84
                                        x: parent.width - 134; y: 18
                                        color: "#43B3B7ED"
                                        border.width: 1; border.color: "#9FFFFFFF"
                                    }
                                    CreosMark {
                                        size: 90
                                        x: introduction.width - 132
                                        y: 59
                                    }
                                    Column {
                                        x: 23
                                        y: 23
                                        spacing: 11
                                        Rectangle {
                                            width: 161; height: 25; radius: 12
                                            color: "#A9FFFFFF"; border.color: "#FFFFFFFF"
                                            Text {
                                                anchors.centerIn: parent
                                                text: "✦  HELLO, INNER UNIVERSE"
                                                color: "#6D80A9"
                                                font.pixelSize: 9
                                                font.weight: Font.DemiBold
                                            }
                                        }
                                        Text {
                                            text: "Một thế giới nhỏ.\nTrong thế giới của bạn."
                                            color: "#344264"
                                            font.family: System.Theme.fontFamily
                                            font.pixelSize: 25
                                            font.weight: Font.DemiBold
                                            lineHeight: 1.11
                                        }
                                        Text {
                                            text: "CreOS — nền tảng cho những ý tưởng lớn lên thành ứng dụng."
                                            color: "#7583A1"
                                            width: Math.min(introduction.width - 170, 400)
                                            wrapMode: Text.Wrap
                                            font.pixelSize: 11
                                        }
                                    }
                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 25
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 13
                                        text: "v" + releaseStore.latestVersion + "   ·   FIRST LIGHT"
                                        color: "#7886A4"
                                        font.pixelSize: 10
                                        font.weight: Font.Medium
                                    }
                                }
                                Row {
                                    width: parent.width
                                    spacing: 12
                                    Repeater {
                                        model: [
                                            {label:"PHIÊN BẢN",value:releaseStore.latestVersion,foot:"Developer Preview",icon:"◇"},
                                            {label:"NỀN TẢNG",value:"Ubuntu",foot:"Chạy trong một cửa sổ",icon:"▧"},
                                            {label:"THIẾT KẾ",value:"System UI",foot:"Bộ giao diện chung",icon:"✧"}
                                        ]
                                        delegate: Rectangle {
                                            required property var modelData
                                            width: (overviewColumn.width - 24) / 3
                                            height: 113
                                            radius: 19
                                            color: "#ECFFFFFF"
                                            border.color: "#FFFFFFFF"
                                            Text {
                                                x: 15; y: 12
                                                text: modelData.icon + "   " + modelData.label
                                                color: "#8797AF"
                                                font.pixelSize: 9
                                                font.weight: Font.DemiBold
                                            }
                                            Text {
                                                x: 15; y: 42
                                                text: modelData.value
                                                color: "#334565"
                                                font.pixelSize: 18
                                                font.weight: Font.DemiBold
                                            }
                                            Text {
                                                x: 15; y: 82
                                                text: modelData.foot
                                                color: "#8493A9"
                                                font.pixelSize: 10
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    width: parent.width
                                    height: 116
                                    radius: 19
                                    color: "#E7FFFFFF"
                                    border.color: "#F8FFFFFF"
                                    Text {
                                        x: 18; y: 15
                                        text: "Hành trình của CreOS"
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        color: app.ink
                                    }
                                    Text {
                                        x: 18; y: 39
                                        width: parent.width - 36
                                        wrapMode: Text.Wrap
                                        text: "Khởi đầu từ giao diện • Kế tiếp là desktop và các ứng dụng sống cùng nhau."
                                        color: app.secondary
                                        font.pixelSize: 11
                                    }
                                    SystemButton {
                                        x: 18; y: 73
                                        implicitHeight: 31
                                        implicitWidth: 153
                                        text: "Xem các bản dựng"
                                        symbol: "→"
                                        onClicked: app.tab = 1
                                    }
                                }
                            }
                        }
                    }

                    // Releases — clearly separate the real preview from plans.
                    Item {
                        Column {
                            anchors.fill: parent
                            spacing: 13
                            Rectangle {
                                width: parent.width; height: 86; radius: 19
                                gradient: Gradient {
                                    GradientStop { position: 0; color: "#E8EDFDFE" }
                                    GradientStop { position: 1; color: "#EEE4F7" }
                                }
                                border.color: "#FFFFFF"
                                Text {
                                    x: 19; y: 17
                                    text: "Release Notes"
                                    font.family: System.Theme.fontFamily
                                    font.pixelSize: 22
                                    font.weight: Font.DemiBold
                                    color: app.ink
                                }
                                Text {
                                    x: 19; y: 52
                                    text: "Phiên bản hiện tại và lộ trình phát triển"
                                    font.pixelSize: 11
                                    color: app.secondary
                                }
                            }
                            Row {
                                width: parent.width
                                height: parent.height - 99
                                spacing: 12
                                Flickable {
                                    id: releaseScroll
                                    width: Math.max(187, parent.width * 0.39)
                                    height: parent.height
                                    clip: true
                                    contentWidth: width
                                    contentHeight: releaseColumn.height
                                    boundsBehavior: Flickable.StopAtBounds
                                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                    Column {
                                        id: releaseColumn
                                        width: releaseScroll.width - 6
                                        spacing: 9
                                        Repeater {
                                            model: releaseStore.releases
                                            delegate: Rectangle {
                                                required property var modelData
                                                required property int index
                                                width: releaseColumn.width
                                                height: 107
                                                radius: 18
                                                color: app.selectedRelease === index ? "#D5E2F9" : (releaseHit.containsMouse ? "#F9FFFFFF" : "#D6FFFFFF")
                                                border.width: 1
                                                border.color: app.selectedRelease === index ? "#A1B8EC" : "#FAFFFFFF"
                                                Behavior on color { ColorAnimation { duration: System.Theme.durationQuick } }
                                                MouseArea {
                                                    id: releaseHit
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: app.selectedRelease = index
                                                }
                                                Text {
                                                    x: 14; y: 12
                                                    text: "v" + modelData.version
                                                    font.pixelSize: 17
                                                    font.weight: Font.DemiBold
                                                    color: app.ink
                                                }
                                                Rectangle {
                                                    x: 14; y: 42
                                                    width: modelData.type === "current" ? 75 : 65
                                                    height: 20; radius: 10
                                                    color: modelData.type === "current" ? "#D5F1E9" : "#E9EDF4"
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.type === "current" ? "BẢN HIỆN TẠI" : "DỰ KIẾN"
                                                        font.pixelSize: 8
                                                        font.weight: Font.DemiBold
                                                        color: modelData.type === "current" ? "#238569" : "#8190A5"
                                                    }
                                                }
                                                Text {
                                                    x: 14; y: 77
                                                    width: parent.width - 28
                                                    elide: Text.ElideRight
                                                    text: modelData.name
                                                    font.pixelSize: 11
                                                    color: app.secondary
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width - releaseScroll.width - parent.spacing
                                    height: parent.height
                                    radius: 19
                                    color: "#EDFFFFFF"
                                    border.color: "#FFFFFFFF"
                                    Flickable {
                                        anchors.fill: parent
                                        anchors.margins: 18
                                        contentWidth: width
                                        contentHeight: releaseDetail.height + 12
                                        clip: true
                                        boundsBehavior: Flickable.StopAtBounds
                                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                        Column {
                                            id: releaseDetail
                                            width: parent.width
                                            spacing: 11
                                            Rectangle {
                                                width: 88; height: 25; radius: 12
                                                color: app.release.type === "current" ? "#D7F2E9" : "#EEF0F6"
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: app.release.type === "current" ? "DEVELOPER" : "ROADMAP"
                                                    font.pixelSize: 9
                                                    font.weight: Font.Bold
                                                    color: app.release.type === "current" ? "#249375" : "#8089A4"
                                                }
                                            }
                                            Text {
                                                text: "v" + app.release.version
                                                color: app.ink
                                                font.pixelSize: 27
                                                font.weight: Font.DemiBold
                                            }
                                            Text {
                                                text: app.release.name
                                                font.pixelSize: 13
                                                color: app.secondary
                                            }
                                            Rectangle {
                                                width: parent.width; height: 1
                                                color: "#DDE6F0"
                                            }
                                            Text {
                                                width: parent.width
                                                wrapMode: Text.Wrap
                                                text: app.release.description
                                                color: app.secondary
                                                font.pixelSize: 11
                                                lineHeight: 1.4
                                            }
                                            Text {
                                                text: "ĐIỂM NỔI BẬT"
                                                topPadding: 8
                                                bottomPadding: 1
                                                color: System.Theme.muted
                                                font.pixelSize: 9
                                                font.weight: Font.Bold
                                                font.letterSpacing: 0.8
                                            }
                                            Repeater {
                                                model: app.release.highlights
                                                delegate: Row {
                                                    required property string modelData
                                                    width: releaseDetail.width
                                                    spacing: 9
                                                    Rectangle {
                                                        width: 6; height: 6; radius: 3
                                                        y: 5
                                                        color: "#8BA5E8"
                                                    }
                                                    Text {
                                                        width: releaseDetail.width - 15
                                                        text: modelData
                                                        wrapMode: Text.Wrap
                                                        color: app.ink
                                                        font.pixelSize: 11
                                                        lineHeight: 1.3
                                                    }
                                                }
                                            }
                                            Text {
                                                text: "Trạng thái: " + app.release.status
                                                color: System.Theme.muted
                                                font.pixelSize: 10
                                                topPadding: 7
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Contract between the operating shell and independent apps.
                    Item {
                        Flickable {
                            anchors.fill: parent
                            contentWidth: width
                            contentHeight: designColumn.height + 12
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                            Column {
                                id: designColumn
                                width: parent.width - 7
                                spacing: 13
                                Rectangle {
                                    width: parent.width; height: 120; radius: 21
                                    gradient: Gradient {
                                        GradientStop { position: 0; color: "#F0E9FB" }
                                        GradientStop { position: 1; color: "#E3EFFD" }
                                    }
                                    border.color: "#FFFFFFFF"
                                    Text {
                                        x: 20; y: 18
                                        text: "CreOS Human Interface"
                                        font.pixelSize: 21
                                        font.weight: Font.DemiBold
                                        color: app.ink
                                    }
                                    Text {
                                        x: 20; y: 57
                                        width: parent.width - 42
                                        wrapMode: Text.Wrap
                                        text: "Một ngôn ngữ thị giác thống nhất cho mọi ứng dụng — nhưng vẫn dành chỗ cho sáng tạo."
                                        font.pixelSize: 11
                                        color: app.secondary
                                    }
                                }
                                Row {
                                    width: parent.width; spacing: 12
                                    Repeater {
                                        model: [
                                            {glyph:"◩",title:"CreOS quản lý",body:"Dock, menu bar, cửa sổ, chuyển động và hành vi hệ thống."},
                                            {glyph:"✦",title:"Ứng dụng lựa chọn",body:"Theo giao diện CreOS hoặc tự thiết kế phần nội dung."}
                                        ]
                                        delegate: Rectangle {
                                            required property var modelData
                                            width: (designColumn.width - 12) / 2
                                            height: 109; radius: 18
                                            color: "#EDFFFFFF"; border.color: "#FFFFFF"
                                            Text {
                                                x: 15; y: 12; text: modelData.glyph + "  " + modelData.title
                                                font.pixelSize: 13; font.weight: Font.DemiBold
                                                color: app.ink
                                            }
                                            Text {
                                                x: 15; y: 43
                                                width: parent.width - 30
                                                wrapMode: Text.Wrap
                                                text: modelData.body
                                                font.pixelSize: 11
                                                color: app.secondary
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    width: parent.width; height: 128; radius: 18
                                    color: "#EDFFFFFF"; border.color: "#FFFFFFFF"
                                    Text {
                                        x: 16; y: 15
                                        text: "Chất liệu · Glass"
                                        color: app.ink
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                    }
                                    Row {
                                        x: 16; y: 47; spacing: 13
                                        Repeater {
                                            model: [
                                                {label:"Frost", color:"#C9FFFFFF"},
                                                {label:"Pearl", color:"#F9FFFFFF"},
                                                {label:"Lavender", color:"#C5D0F6"},
                                                {label:"Sky", color:"#C3E5F8"}
                                            ]
                                            delegate: Column {
                                                required property var modelData
                                                spacing: 5
                                                Rectangle {
                                                    width: 70; height: 40; radius: 12
                                                    color: modelData.color
                                                    border.color: "#FFFFFF"
                                                    border.width: 1
                                                }
                                                Text {
                                                    width: 70
                                                    text: modelData.label
                                                    horizontalAlignment: Text.AlignHCenter
                                                    color: "#8899AE"
                                                    font.pixelSize: 9
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    width: parent.width; height: 106; radius: 18
                                    color: "#EBFFFFFF"; border.color: "#FFFFFF"
                                    Text {
                                        x: 16; y: 15
                                        text: "Nút bấm · System components"
                                        color: app.ink; font.pixelSize: 13; font.weight: Font.DemiBold
                                    }
                                    Row {
                                        x: 16; y: 50; spacing: 10
                                        SystemButton {
                                            text: "Xem GitHub"; symbol: "↗"; primary: true
                                            onClicked: Qt.openUrlExternally(releaseStore.repository)
                                        }
                                        SystemButton {
                                            text: "Bản phát hành"; symbol: "→"
                                            onClicked: app.tab = 1
                                        }
                                    }
                                }
                                Text {
                                    width: parent.width
                                    wrapMode: Text.Wrap
                                    text: "Dành cho lập trình viên: thiết kế chung trong ui/system/Theme.qml, đăng ký app tại ui/system/Apps.qml."
                                    color: "#899AAF"
                                    font.pixelSize: 10
                                    bottomPadding: 5
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
