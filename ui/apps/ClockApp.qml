import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../system" as System

Item {
    id: clock
    clip: true
    property int activeTab: 0
    property string timeText: Qt.formatDateTime(new Date(), "HH:mm:ss")
    property string dateText: Qt.formatDateTime(new Date(), "dddd · dd/MM/yyyy")
    property double elapsed: 0
    property double startedAt: 0
    property bool running: false
    property string stopwatchText: "00:00.00"
    property var laps: []

    function formatted(ms) {
        var cs = Math.floor(ms / 10)
        return String(Math.floor(cs / 6000)).padStart(2, "0") + ":" +
               String(Math.floor(cs / 100) % 60).padStart(2, "0") + "." +
               String(cs % 100).padStart(2, "0")
    }
    function currentMs() { return elapsed + (running ? Math.max(0, Date.now() - startedAt) : 0) }
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
    // Clock updates once per second. High-frequency updates ONLY run
    // while the stopwatch is active, reducing idle CPU wakeups.
    Timer {
        interval: 1000
        repeat: true
        running: clock.visible
        onTriggered: {
            var current = new Date()
            clock.timeText = Qt.formatDateTime(current, "HH:mm:ss")
            clock.dateText = Qt.formatDateTime(current, "dddd · dd/MM/yyyy")
        }
    }
    Timer {
        interval: 50
        repeat: true
        running: clock.running && clock.activeTab === 1 && clock.visible
        onTriggered: clock.stopwatchText = clock.formatted(clock.currentMs())
    }

    AppPage {
        heading: "Đồng hồ"
        caption: "Giờ hiện tại và bấm giờ"
        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            SegmentedTabs {
                Layout.preferredWidth: 256
                Layout.preferredHeight: 42
                Layout.alignment: Qt.AlignHCenter
                options: ["Giờ hiện tại", "Bấm giờ"]
                selectedIndex: clock.activeTab
                onActivated: function(i) { clock.activeTab = i }
            }
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: clock.activeTab
                Item {
                    SurfaceCard {
                        width: Math.min(parent.width, 565)
                        height: Math.min(parent.height - 4, 295)
                        anchors.centerIn: parent
                        Column {
                            anchors.centerIn: parent
                            spacing: 16
                            SectionLabel {
                                text: "GIỜ ĐỊA PHƯƠNG"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: clock.timeText
                                font.pixelSize: 56
                                font.weight: Font.Light
                                font.family: System.Theme.fontFamily
                                color: System.Theme.ink
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: clock.dateText
                                font.pixelSize: 14
                                color: System.Theme.secondary
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 144; height: 29; radius: 14
                                color: System.Theme.accentSoft
                                Text {
                                    anchors.centerIn: parent
                                    text: "Giờ hệ thống"
                                    color: System.Theme.accent
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 11
                        SurfaceCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 143
                            Column {
                                anchors.centerIn: parent
                                spacing: 12
                                SectionLabel {
                                    text: "BẤM GIỜ"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Text {
                                    text: clock.stopwatchText
                                    font.pixelSize: 44
                                    font.weight: Font.Light
                                    font.family: System.Theme.fontFamily
                                    color: System.Theme.ink
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 9
                            SystemButton {
                                Layout.fillWidth: true
                                text: clock.running ? "Tạm dừng" : "Bắt đầu"
                                primary: true
                                onClicked: clock.toggleStopwatch()
                            }
                            SystemButton {
                                Layout.fillWidth: true
                                text: "Ghi vòng"
                                enabled: clock.running
                                onClicked: clock.addLap()
                            }
                            SystemButton {
                                Layout.fillWidth: true
                                text: "Đặt lại"
                                quiet: true
                                onClicked: clock.resetStopwatch()
                            }
                        }
                        SurfaceCard {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            ListView {
                                id: lapList
                                anchors.fill: parent
                                anchors.margins: 14
                                clip: true
                                spacing: 5
                                model: clock.laps
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                delegate: Rectangle {
                                    required property var modelData
                                    width: lapList.width
                                    height: 32
                                    color: "transparent"
                                    Row {
                                        anchors.fill: parent
                                        Text {
                                            width: parent.width / 2
                                            text: "Vòng " + modelData.number
                                            font.pixelSize: 12
                                            color: System.Theme.secondary
                                        }
                                        Text {
                                            width: parent.width / 2
                                            text: modelData.time
                                            horizontalAlignment: Text.AlignRight
                                            font.pixelSize: 12
                                            font.weight: Font.DemiBold
                                            color: System.Theme.ink
                                        }
                                    }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    visible: clock.laps.length === 0
                                    text: "Chưa ghi vòng nào"
                                    font.pixelSize: 12
                                    color: System.Theme.muted
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
