import QtQuick
import QtQuick.Controls
import "../system" as System

// A compact system-status island that floats over the desktop.
// It owns no app content and never reserves a full-width title bar.
Item {
    id: island
    property bool expanded: false
    property int openWindows: 0
    property string clockText: "00:00"
    property string message: ""
    signal action(string key)

    width: expanded ? 392 : 247
    height: expanded ? 203 : 42
    transformOrigin: Item.Top
    Behavior on width { NumberAnimation { duration: System.Theme.durationSlow; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: System.Theme.durationSlow; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        radius: island.expanded ? 25 : 22
        color: "#E91A2236"
        antialiasing: true
        border.width: 1
        border.color: "#3EFFFFFF"
        Behavior on radius { NumberAnimation { duration: System.Theme.durationNormal } }
    }

    Rectangle {
        x: 14; y: 16; width: 8; height: 8; radius: 4
        color: "#69D9BC"
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: .48; duration: 1100; easing.type: Easing.InOutSine }
            NumberAnimation { from: .48; to: 1; duration: 1100; easing.type: Easing.InOutSine }
        }
    }
    Text {
        x: 30; y: 12
        text: island.message ? island.message : "CreOS"
        width: island.width - 130
        elide: Text.ElideRight
        color: "#FFFFFF"
        font.pixelSize: 12
        font.weight: Font.DemiBold
    }
    Text {
        anchors.right: parent.right
        anchors.rightMargin: 37
        y: 13
        text: island.clockText
        color: "#B7C9E4"
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }
    Text {
        anchors.right: parent.right
        anchors.rightMargin: 15
        y: 12
        text: island.expanded ? "⌃" : "⌄"
        color: "#C2D3EA"
        font.pixelSize: 12
    }
    MouseArea {
        x: 0; y: 0; width: parent.width; height: 42
        cursorShape: Qt.PointingHandCursor
        onClicked: island.expanded = !island.expanded
    }

    Item {
        y: 49; x: 13
        width: island.width - 26
        height: island.height - 58
        opacity: island.expanded ? 1 : 0
        visible: island.expanded || opacity > .01
        Behavior on opacity { NumberAnimation { duration: System.Theme.durationNormal } }

        Text {
            x: 9; y: 6
            text: island.openWindows + " cửa sổ đang mở"
            font.pixelSize: 12
            color: "#BED0E7"
        }
        Rectangle {
            x: 9; y: 30; height: 1; width: parent.width - 18
            color: "#35FFFFFF"
        }
        Grid {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 41
            columns: 2
            rowSpacing: 9
            columnSpacing: 10
            Repeater {
                model: [
                    {label:"Tệp · Files", cmd:"files"},
                    {label:"Cài đặt", cmd:"settings"},
                    {label:"Thông tin", cmd:"about"},
                    {label:"Toàn màn hình · F11", cmd:"fullscreen"}
                ]
                delegate: Button {
                    id: actionButton
                    required property var modelData
                    width: 171
                    height: 41
                    hoverEnabled: true
                    onClicked: {
                        island.expanded = false
                        island.action(modelData.cmd)
                    }
                    background: Rectangle {
                        radius: 13
                        color: actionButton.hovered ? "#365C7397" : "#2BFFFFFF"
                        Behavior on color { ColorAnimation { duration: System.Theme.durationQuick } }
                    }
                    contentItem: Text {
                        text: actionButton.modelData.label
                        color: "#F1F6FF"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
