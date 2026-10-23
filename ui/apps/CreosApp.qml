import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../system" as System

// CreOS system information. No roadmap, sample content or preview panels.
Item {
    id: about
    clip: true
    Rectangle {
        anchors.fill: parent
        color: "#F1F7FC"
    }
    Flickable {
        anchors.fill: parent
        anchors.margins: 24
        contentWidth: width
        contentHeight: body.height + 16
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        Column {
            id: body
            width: parent.width - 8
            spacing: 17
            Row {
                width: parent.width
                spacing: 15
                CreosMark { size: 63 }
                Column {
                    spacing: 5
                    Text {
                        text: "CreOS"
                        font.family: System.Theme.fontFamily
                        font.pixelSize: 29
                        font.weight: Font.DemiBold
                        color: "#293950"
                    }
                    Text {
                        text: "Không gian của riêng bạn."
                        font.pixelSize: 12
                        color: "#8193AB"
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 125
                radius: 18
                color: "#E0ECF8"
                border.color: "#F8FFFFFF"
                Column {
                    x: 19; y: 19
                    spacing: 10
                    Text {
                        text: "THÔNG TIN HỆ THỐNG"
                        font.pixelSize: 10
                        font.letterSpacing: 1.4
                        font.weight: Font.Bold
                        color: "#899AB3"
                    }
                    Text {
                        text: "CreOS  " + releaseStore.latestVersion
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                        color: "#334763"
                    }
                    Text {
                        text: "Ứng dụng desktop chạy trên Ubuntu · PySide6 / Qt Quick"
                        font.pixelSize: 11
                        color: "#778CA6"
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 12
                Repeater {
                    model: [
                        {symbol:"▣", title:"Desktop", detail:"Cửa sổ, Dock và quản lý đa nhiệm"},
                        {symbol:"✧", title:"CreOS UI", detail:"Giao diện chung cho mọi ứng dụng"}
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        width: (body.width - 12) / 2
                        height: 92
                        radius: 17
                        color: "#F8FFFFFF"
                        border.width: 1
                        border.color: "#FFFFFFFF"
                        Row {
                            x: 14
                            y: 14
                            spacing: 13
                            Text {
                                text: modelData.symbol
                                font.pixelSize: 28
                                color: "#778FD0"
                            }
                            Column {
                                spacing: 8
                                Text {
                                    text: modelData.title
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: "#334763"
                                }
                                Text {
                                    width: Math.max(90, (body.width - 12) / 2 - 68)
                                    wrapMode: Text.Wrap
                                    text: modelData.detail
                                    font.pixelSize: 10
                                    color: "#8192AC"
                                }
                            }
                        }
                    }
                }
            }

            Text {
                topPadding: 6
                text: "ỨNG DỤNG ĐÃ CÀI ĐẶT"
                color: "#8799B2"
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 1.4
            }

            Rectangle {
                width: parent.width
                height: System.Apps.applications.length * 54 + 14
                radius: 18
                color: "#E9FFFFFF"
                border.color: "#FFFFFFFF"
                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    Repeater {
                        model: System.Apps.applications
                        delegate: Row {
                            required property var modelData
                            width: parent.width
                            height: 54
                            spacing: 12
                            AppIcon {
                                size: 33
                                appId: modelData.id
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                Text {
                                    text: modelData.name
                                    font.pixelSize: 12
                                    color: "#394B67"
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: modelData.subtitle
                                    font.pixelSize: 10
                                    color: "#8696AE"
                                }
                            }
                        }
                    }
                }
            }

            Row {
                spacing: 12
                SystemButton {
                    text: "GitHub CreOS"
                    symbol: "↗"
                    primary: true
                    onClicked: Qt.openUrlExternally(releaseStore.repository)
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "© 2026 CreOS"
                    font.pixelSize: 10
                    color: "#95A6BB"
                }
            }
        }
    }
}
