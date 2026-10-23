import QtQuick
import QtQuick.Controls
import "../components"
import "../system" as System

Item {
    id: settings
    clip: true
    readonly property var wallpapers: [
        {id:"aurora", name:"Aurora", detail:"Xanh trong trẻo", start:"#D4EAF7", end:"#AFA9DD"},
        {id:"peach", name:"Sunrise", detail:"Hồng ấm áp", start:"#FCE0D2", end:"#DCA8CB"},
        {id:"midnight", name:"Midnight", detail:"Tím trầm lắng", start:"#263C65", end:"#75649C"}
    ]

    AppPage {
        heading: "Cài đặt"
        caption: "Cá nhân hóa không gian CreOS."
        Flickable {
            anchors.fill: parent
            clip: true
            contentWidth: width
            contentHeight: settingsBody.height + 20
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Column {
                id: settingsBody
                width: parent.width - 5
                spacing: 16

                SectionLabel { text: "GIAO DIỆN" }
                SurfaceCard {
                    width: parent.width
                    height: 83
                    Row {
                        x: 17
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 14
                        Rectangle {
                            width: 44; height: 44; radius: 14
                            color: System.Theme.accentSoft
                            Text {
                                anchors.centerIn: parent
                                text: "◈"
                                font.pixelSize: 22
                                color: System.Theme.accent
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6
                            Text {
                                text: "Hình nền Desktop"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                color: System.Theme.ink
                            }
                            Text {
                                text: "Chọn hình nền, thay đổi được áp dụng ngay."
                                font.pixelSize: 11
                                color: System.Theme.secondary
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: 12
                    Repeater {
                        model: settings.wallpapers
                        delegate: SurfaceCard {
                            id: tile
                            required property var modelData
                            width: (settingsBody.width - 24) / 3
                            height: 180
                            border.width: creosData.wallpaper === modelData.id ? 2 : 1
                            border.color: creosData.wallpaper === modelData.id ?
                                          System.Theme.accent : System.Theme.subtleLine
                            Rectangle {
                                id: preview
                                x: 10; y: 10
                                width: parent.width - 20
                                height: 104
                                radius: 14
                                clip: true
                                gradient: Gradient {
                                    GradientStop { position: 0; color: tile.modelData.start }
                                    GradientStop { position: 1; color: tile.modelData.end }
                                }
                                Rectangle {
                                    x: preview.width * 0.18
                                    y: 34
                                    width: preview.width * 0.75
                                    height: 26
                                    rotation: -18
                                    radius: 13
                                    color: "#55FFFFFF"
                                }
                                Rectangle {
                                    x: preview.width - 66; y: 42
                                    width: 74; height: 74
                                    radius: 37
                                    color: "#35FFFFFF"
                                }
                            }
                            Column {
                                x: 12; y: 122
                                spacing: 5
                                Text {
                                    text: tile.modelData.name
                                    color: System.Theme.ink
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: tile.modelData.detail
                                    color: System.Theme.secondary
                                    font.pixelSize: 10
                                }
                            }
                            Rectangle {
                                visible: creosData.wallpaper === tile.modelData.id
                                width: 23; height: 23
                                radius: 12
                                color: System.Theme.accent
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                y: 123
                                Text { anchors.centerIn: parent; text: "✓"; font.pixelSize: 13; color: "#FFFFFF" }
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: creosData.setWallpaper(tile.modelData.id)
                            }
                        }
                    }
                }
                Text {
                    text: "Lựa chọn được lưu tự động trên máy Ubuntu."
                    font.pixelSize: 11
                    color: System.Theme.muted
                }

                SectionLabel {
                    topPadding: 7
                    text: "VỀ THIẾT BỊ"
                }
                SurfaceCard {
                    width: parent.width
                    height: 150
                    Column {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 14
                        Repeater {
                            model: [
                                {name:"Phiên bản CreOS", value:releaseStore.latestVersion},
                                {name:"Ứng dụng đã cài", value:System.Apps.applications.length + " ứng dụng"},
                                {name:"Ghi chú đã lưu", value:creosData.notes.length + " ghi chú"}
                            ]
                            delegate: Item {
                                required property var modelData
                                width: parent.width
                                height: 25
                                Text {
                                    text: modelData.name
                                    anchors.left: parent.left
                                    color: System.Theme.secondary
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: modelData.value
                                    anchors.right: parent.right
                                    color: System.Theme.ink
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
