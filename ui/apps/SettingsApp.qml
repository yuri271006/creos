import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../system" as System

Item {
    id: settings
    clip: true
    readonly property var wallpapers: [
        { id: "aurora", title: "Aurora", subtitle: "Xanh lam dịu nhẹ", top: "#DAF1FB", bottom: "#B9A9E1" },
        { id: "peach", title: "Sunrise", subtitle: "Hồng đào ấm áp", top: "#FFE9DC", bottom: "#E1B7CF" },
        { id: "midnight", title: "Midnight", subtitle: "Tím xanh sâu thẳm", top: "#253459", bottom: "#685D90" }
    ]

    Rectangle {
        anchors.fill: parent
        color: "#EBF8FBFF"
    }
    Flickable {
        anchors.fill: parent
        anchors.margins: 26
        contentWidth: width
        contentHeight: layout.height + 24
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
            id: layout
            width: parent.width
            spacing: 18
            Column {
                spacing: 7
                Text {
                    text: "Cài đặt CreOS"
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                    color: System.Theme.ink
                }
                Text {
                    text: "Biến không gian nhỏ này thành nơi thật sự thuộc về bạn."
                    font.pixelSize: 12
                    color: System.Theme.secondary
                }
            }

            Rectangle {
                width: parent.width
                height: 54
                radius: 16
                color: "#A9FFFFFF"
                border.color: "#FFFFFFFF"
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 17; spacing: 13
                    Text { text: "✦"; color: "#8295D8"; font.pixelSize: 23 }
                    Column {
                        spacing: 4
                        Text {
                            text: "Giao diện & cá nhân hóa"
                            color: System.Theme.ink
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: "Hình nền được áp dụng ngay trên Desktop"
                            color: System.Theme.secondary
                            font.pixelSize: 10
                        }
                    }
                }
            }

            Text {
                text: "HÌNH NỀN"
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 1.6
                color: "#8498B2"
            }

            Row {
                width: parent.width
                spacing: 13
                Repeater {
                    model: settings.wallpapers
                    delegate: Rectangle {
                        id: wallpaperCard
                        required property var modelData
                        width: (layout.width - 26) / 3
                        height: 181
                        radius: 19
                        color: creosData.wallpaper === modelData.id ? "#D7E5FF" : "#A6FFFFFF"
                        border.width: creosData.wallpaper === modelData.id ? 2 : 1
                        border.color: creosData.wallpaper === modelData.id ? "#7A97ED" : "#FFFFFF"
                        Behavior on color { ColorAnimation { duration: 230 } }

                        Rectangle {
                            x: 9; y: 9
                            width: parent.width - 18
                            height: 108
                            radius: 13
                            clip: true
                            gradient: Gradient {
                                GradientStop { position: 0; color: wallpaperCard.modelData.top }
                                GradientStop { position: 1; color: wallpaperCard.modelData.bottom }
                            }
                            Rectangle {
                                width: parent.width * 0.85
                                height: 33
                                x: 2
                                y: 34
                                radius: 16
                                rotation: -23
                                color: "#43FFFFFF"
                            }
                            Rectangle {
                                width: 80
                                height: 80
                                radius: 40
                                x: parent.width - 49
                                y: 29
                                color: "#43FFFFFF"
                            }
                        }
                        Text {
                            x: 12; y: 126
                            text: modelData.title
                            color: "#3A4B68"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                        Text {
                            x: 12; y: 148
                            text: modelData.subtitle
                            color: "#8E9CB3"
                            font.pixelSize: 10
                        }
                        Text {
                            visible: creosData.wallpaper === modelData.id
                            anchors.right: parent.right
                            anchors.rightMargin: 13
                            y: 126
                            text: "✓"
                            color: "#5E78D8"
                            font.pixelSize: 17
                            font.weight: Font.Bold
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: creosData.setWallpaper(modelData.id)
                        }
                    }
                }
            }
            Text {
                text: "Thay đổi sẽ được lưu tự động cho lần mở CreOS tiếp theo."
                font.pixelSize: 11
                color: "#92A1B7"
            }

            Rectangle {
                width: parent.width
                height: 132
                radius: 19
                color: "#BEFFFFFF"
                border.color: "#FFFFFFFF"
                Column {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 13
                    Text {
                        text: "THÔNG TIN HỆ THỐNG"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1.3
                        color: "#94A4BA"
                    }
                    Row {
                        width: parent.width
                        spacing: 22
                        Column {
                            width: (parent.width - 44) / 3
                            spacing: 7
                            Text { text: "Phiên bản"; color: "#92A0B4"; font.pixelSize: 10 }
                            Text { text: releaseStore.latestVersion; color: "#3D5071"; font.pixelSize: 13; font.weight: Font.DemiBold }
                        }
                        Column {
                            width: (parent.width - 44) / 3
                            spacing: 7
                            Text { text: "Ứng dụng"; color: "#92A0B4"; font.pixelSize: 10 }
                            Text { text: System.Apps.applications.length + " app"; color: "#3D5071"; font.pixelSize: 13; font.weight: Font.DemiBold }
                        }
                        Column {
                            width: (parent.width - 44) / 3
                            spacing: 7
                            Text { text: "Dữ liệu ghi chú"; color: "#92A0B4"; font.pixelSize: 10 }
                            Text { text: creosData.notes.length + " ghi chú"; color: "#3D5071"; font.pixelSize: 13; font.weight: Font.DemiBold }
                        }
                    }
                }
            }
        }
    }
}
