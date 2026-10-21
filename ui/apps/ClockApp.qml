import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../system" as System

Item {
    id: clockApp
    property int activeTab: 0
    property string timeText: Qt.formatDateTime(new Date(), "HH:mm:ss")
    property string dateText: Qt.formatDateTime(new Date(), "dddd · dd/MM/yyyy")
    property double elapsed: 0
    property double startedAt: 0
    property bool running: false
    property string stopwatchText: "00:00.00"
    property var laps: []

    function formatted(ms) {
        var centiseconds = Math.floor(ms / 10)
        var minutes = Math.floor(centiseconds / 6000)
        var seconds = Math.floor(centiseconds / 100) % 60
        var fraction = centiseconds % 100
        return String(minutes).padStart(2, "0") + ":" +
               String(seconds).padStart(2, "0") + "." +
               String(fraction).padStart(2, "0")
    }
    function currentMs() {
        return elapsed + (running ? Math.max(0, Date.now() - startedAt) : 0)
    }
    function toggleStopwatch() {
        if (running) {
            elapsed = currentMs()
            running = false
            stopwatchText = formatted(elapsed)
        } else {
            startedAt = Date.now()
            running = true
        }
    }
    function resetStopwatch() {
        running = false
        elapsed = 0
        stopwatchText = "00:00.00"
        laps = []
    }
    function addLap() {
        if (!running || laps.length >= 50) return
        var next = laps.slice()
        next.unshift({number: laps.length + 1, time: formatted(currentMs())})
        laps = next
    }
    Timer {
        interval: 50; running: true; repeat: true
        onTriggered: {
            var now = new Date()
            clockApp.timeText = Qt.formatDateTime(now, "HH:mm:ss")
            clockApp.dateText = Qt.formatDateTime(now, "dddd · dd/MM/yyyy")
            if (clockApp.running)
                clockApp.stopwatchText = clockApp.formatted(clockApp.currentMs())
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#ECF8FF" }
            GradientStop { position: 1; color: "#E6E7F7" }
        }
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 26
        spacing: 18

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: "Đồng hồ"
                font.pixelSize: 22
                font.weight: Font.DemiBold
                color: "#30415F"
            }
            Rectangle {
                Layout.preferredWidth: 194
                Layout.preferredHeight: 39
                radius: 14
                color: "#A8FFFFFF"
                border.color: "#FFFFFF"
                Row {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 3
                    Repeater {
                        model: ["Giờ hiện tại", "Bấm giờ"]
                        delegate: Button {
                            id: tabButton
                            required property string modelData
                            required property int index
                            width: 91; height: 31
                            hoverEnabled: true
                            onClicked: clockApp.activeTab = index
                            background: Rectangle {
                                radius: 10
                                color: clockApp.activeTab === index ? "#F8FFFFFF" :
                                       (tabButton.hovered ? "#77FFFFFF" : "transparent")
                                border.color: clockApp.activeTab === index ? "#FFFFFF" : "transparent"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: tabButton.modelData
                                color: clockApp.activeTab === tabButton.index ? "#3D567B" : "#7D8BA3"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: clockApp.activeTab

            Item {
                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 30, 560)
                    height: Math.min(parent.height - 12, 352)
                    radius: 27
                    color: "#B2FFFFFF"
                    border.color: "#EFFFFFFF"
                    Column {
                        anchors.centerIn: parent
                        spacing: 18
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "THỜI GIAN HIỆN TẠI"
                            color: "#869AB6"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.letterSpacing: 2
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: clockApp.timeText
                            font.pixelSize: 62
                            font.weight: Font.Light
                            color: "#344764"
                            font.family: System.Theme.fontFamily
                            font.letterSpacing: 1
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: clockApp.dateText
                            color: "#8C9DB6"
                            font.pixelSize: 14
                        }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 170; height: 30; radius: 15
                            color: "#E4F1F8"
                            Text {
                                anchors.centerIn: parent
                                text: "●  LOCAL TIME"
                                color: "#5E8A9F"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }

            Item {
                Column {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 30, 520)
                    spacing: 15
                    Rectangle {
                        width: parent.width
                        height: 173
                        radius: 23
                        color: "#B8FFFFFF"
                        border.color: "#FFFFFF"
                        Column {
                            anchors.centerIn: parent
                            spacing: 15
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "BẤM GIỜ"
                                color: "#92A0B8"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 1.8
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: clockApp.stopwatchText
                                color: "#334563"
                                font.pixelSize: 55
                                font.family: System.Theme.fontFamily
                                font.weight: Font.Light
                            }
                        }
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 13
                        SystemButton {
                            text: clockApp.running ? "Tạm dừng" : "Bắt đầu"
                            primary: true
                            symbol: clockApp.running ? "Ⅱ" : "▶"
                            onClicked: clockApp.toggleStopwatch()
                        }
                        SystemButton {
                            text: "Vòng"
                            symbol: "+"
                            enabled: clockApp.running
                            opacity: enabled ? 1 : 0.5
                            onClicked: clockApp.addLap()
                        }
                        SystemButton {
                            text: "Đặt lại"
                            symbol: "↺"
                            onClicked: clockApp.resetStopwatch()
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: 112
                        radius: 17
                        color: "#9BFFFFFF"
                        border.color: "#FFFFFFFF"
                        ListView {
                            id: lapsList
                            anchors.fill: parent
                            anchors.margins: 14
                            clip: true
                            spacing: 7
                            model: clockApp.laps
                            delegate: Row {
                                required property var modelData
                                width: lapsList.width
                                Text {
                                    text: "Vòng " + modelData.number
                                    width: parent.width / 2
                                    color: "#7487A2"
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: modelData.time
                                    width: parent.width / 2
                                    horizontalAlignment: Text.AlignRight
                                    color: "#465D82"
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                }
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: clockApp.laps.length === 0
                                text: "Các vòng sẽ xuất hiện ở đây"
                                color: "#A0B0C5"
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
        }
        Text {
            Layout.fillWidth: true
            text: "CreOS Clock  ·  Dùng giờ địa phương của máy Ubuntu"
            font.pixelSize: 10
            color: "#97A7BA"
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
