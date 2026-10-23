import QtQuick
import QtQuick.Controls
import "../components"
import "../system" as System

Item {
    id: about
    clip: true

    AppPage {
        heading: "CreOS"
        caption: "Không gian của riêng bạn."
        Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: details.height + 22
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Column {
                id: details
                width: parent.width - 5
                spacing: 16

                SurfaceCard {
                    width: parent.width
                    height: 120
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 20
                        spacing: 17
                        CreosMark { size: 78 }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Text {
                                text: "CreOS"
                                font.pixelSize: 26
                                font.weight: Font.DemiBold
                                color: System.Theme.ink
                            }
                            Text {
                                text: "Phiên bản " + releaseStore.latestVersion
                                color: System.Theme.secondary
                                font.pixelSize: 13
                            }
                            Text {
                                text: "The Inner Universe"
                                color: System.Theme.muted
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                SectionLabel { text: "THÔNG TIN HỆ THỐNG" }
                SurfaceCard {
                    width: parent.width
                    height: 141
                    Column {
                        anchors.fill: parent
                        anchors.margins: 17
                        spacing: 12
                        Repeater {
                            model: [
                                {heading:"Hệ thống", value:"CreOS Desktop"},
                                {heading:"Nền tảng", value:"Ubuntu · Qt Quick"},
                                {heading:"Phiên bản", value:releaseStore.latestVersion}
                            ]
                            delegate: Item {
                                required property var modelData
                                width: parent.width
                                height: 29
                                Text {
                                    text: modelData.heading
                                    color: System.Theme.secondary
                                    font.pixelSize: 12
                                    anchors.left: parent.left
                                }
                                Text {
                                    text: modelData.value
                                    color: System.Theme.ink
                                    font.pixelSize: 12
                                    font.weight: Font.DemiBold
                                    anchors.right: parent.right
                                }
                            }
                        }
                    }
                }

                SectionLabel { text: "ỨNG DỤNG CREOS" }
                SurfaceCard {
                    width: parent.width
                    height: System.Apps.applications.length * 62 + 12
                    Column {
                        anchors.fill: parent
                        anchors.margins: 7
                        Repeater {
                            model: System.Apps.applications
                            delegate: Item {
                                required property var modelData
                                width: parent.width
                                height: 62
                                Row {
                                    x: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 14
                                    AppIcon {
                                        size: 39
                                        appId: modelData.id
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Column {
                                        spacing: 5
                                        anchors.verticalCenter: parent.verticalCenter
                                        Text {
                                            text: modelData.name
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                            color: System.Theme.ink
                                        }
                                        Text {
                                            text: modelData.subtitle
                                            font.pixelSize: 11
                                            color: System.Theme.secondary
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                SystemButton {
                    text: "Mở GitHub CreOS"
                    primary: true
                    implicitWidth: 170
                    onClicked: Qt.openUrlExternally(releaseStore.repository)
                }
                Text {
                    text: "© 2026 CreOS"
                    color: System.Theme.muted
                    font.pixelSize: 11
                }
            }
        }
    }
}
