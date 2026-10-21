import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../system" as System

Item {
    id: notesApp
    property string currentId: ""
    property bool loadingNote: false
    readonly property color ink: System.Theme.ink
    readonly property color muted: System.Theme.secondary
    clip: true

    function flush() {
        if (currentId !== "" && !loadingNote)
            creosData.saveNote(currentId, titleEdit.text, bodyEdit.text)
    }
    function selectNote(id) {
        saveDelay.stop()
        flush()
        loadingNote = true
        var note = creosData.getNote(id)
        currentId = note.id || ""
        titleEdit.text = note.title || ""
        bodyEdit.text = note.body || ""
        loadingNote = false
    }
    function newNote() {
        saveDelay.stop()
        flush()
        var identity = creosData.createNote()
        selectNote(identity)
        titleEdit.forceActiveFocus()
        titleEdit.selectAll()
    }
    Timer {
        id: saveDelay
        interval: 550
        repeat: false
        onTriggered: notesApp.flush()
    }
    Component.onCompleted: {
        var all = creosData.notes
        if (all.length > 0)
            selectNote(all[0].id)
    }
    Component.onDestruction: {
        saveDelay.stop()
        flush()
    }

    Rectangle { anchors.fill: parent; color: "#EAF8FBFF" }
    RowLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            Layout.preferredWidth: 245
            Layout.fillHeight: true
            color: "#9CEAF2FF"
            Rectangle {
                anchors.right: parent.right; width: 1; height: parent.height
                color: "#81FFFFFF"
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: "Ghi chú"
                        color: notesApp.ink
                        font.pixelSize: 21
                        font.weight: Font.DemiBold
                    }
                    Button {
                        id: newButton
                        width: 35; height: 35
                        hoverEnabled: true
                        onClicked: notesApp.newNote()
                        background: Rectangle {
                            radius: 12
                            color: newButton.hovered ? "#D6E3FF" : "#E9FFFFFF"
                            border.color: "#FFFFFF"
                        }
                        contentItem: Text {
                            text: "+"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: System.Theme.accent
                            font.pixelSize: 21
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "Tạo ghi chú"
                    }
                }
                Text {
                    text: creosData.notes.length + " ghi chú của bạn"
                    color: notesApp.muted
                    font.pixelSize: 11
                }
                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 9
                    model: creosData.notes
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    delegate: Rectangle {
                        required property var modelData
                        width: list.width - 6
                        height: 81
                        radius: 16
                        color: notesApp.currentId === modelData.id ? "#D9E5FB" :
                              (itemHit.containsMouse ? "#D6FFFFFF" : "#A8FFFFFF")
                        border.width: 1
                        border.color: notesApp.currentId === modelData.id ? "#AFCAF3" : "#F1FFFFFF"
                        Behavior on color { ColorAnimation { duration: 180 } }
                        Column {
                            x: 13; y: 12; width: parent.width - 25; spacing: 5
                            Text {
                                width: parent.width
                                elide: Text.ElideRight
                                text: modelData.title.trim() || "Không tiêu đề"
                                color: notesApp.ink
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }
                            Text {
                                width: parent.width
                                elide: Text.ElideRight
                                text: modelData.body.replace(/\s+/g, " ").trim() || "Chưa có nội dung"
                                color: notesApp.muted
                                font.pixelSize: 10
                            }
                            Text {
                                text: modelData.updated
                                color: "#9BA9BF"
                                font.pixelSize: 9
                            }
                        }
                        MouseArea {
                            id: itemHit
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notesApp.selectNote(modelData.id)
                        }
                    }
                }
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 23
                spacing: 13
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: notesApp.currentId ? "TRÌNH SOẠN THẢO" : "GHI CHÚ CỦA BẠN"
                        color: "#9AA7BC"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1.2
                    }
                    Text {
                        visible: notesApp.currentId !== ""
                        text: "●  Lưu tự động"
                        color: "#4B9B83"
                        font.pixelSize: 10
                    }
                    Button {
                        id: deleteButton
                        visible: notesApp.currentId !== ""
                        text: "Xóa"
                        hoverEnabled: true
                        onClicked: deleteDialog.open()
                        background: Rectangle {
                            radius: 10
                            color: deleteButton.hovered ? "#FCE5E8" : "#F0FFFFFF"
                            border.color: "#FFFFFFFF"
                        }
                        contentItem: Text {
                            text: deleteButton.text
                            color: "#B75B6C"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 12; rightPadding: 12
                        }
                    }
                }
                TextField {
                    id: titleEdit
                    visible: notesApp.currentId !== ""
                    Layout.fillWidth: true
                    text: ""
                    placeholderText: "Tiêu đề ghi chú"
                    font.family: System.Theme.fontFamily
                    font.pixelSize: 25
                    font.weight: Font.DemiBold
                    color: notesApp.ink
                    selectByMouse: true
                    background: Rectangle { color: "transparent" }
                    onTextChanged: if (!notesApp.loadingNote) saveDelay.restart()
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    visible: notesApp.currentId !== ""
                    color: "#D3DFED"
                }
                ScrollView {
                    visible: notesApp.currentId !== ""
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    TextArea {
                        id: bodyEdit
                        width: parent.width
                        wrapMode: TextEdit.Wrap
                        placeholderText: "Hôm nay bạn đang nghĩ gì?"
                        font.family: System.Theme.fontFamily
                        font.pixelSize: 13
                        color: notesApp.ink
                        selectByMouse: true
                        topPadding: 9
                        leftPadding: 2
                        background: Rectangle { color: "transparent" }
                        onTextChanged: if (!notesApp.loadingNote) saveDelay.restart()
                    }
                }
                Item {
                    visible: notesApp.currentId === ""
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Column {
                        anchors.centerIn: parent
                        spacing: 14
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "✎"
                            font.pixelSize: 64
                            color: "#9AACE7"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Ý tưởng đầu tiên bắt đầu ở đây."
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: notesApp.ink
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Tạo một ghi chú rồi viết bất cứ điều gì."
                            font.pixelSize: 11
                            color: notesApp.muted
                        }
                        SystemButton {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Ghi chú mới"
                            symbol: "+"
                            primary: true
                            onClicked: notesApp.newNote()
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: deleteDialog
        title: "Xóa ghi chú?"
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: {
            saveDelay.stop()
            creosData.deleteNote(notesApp.currentId)
            var next = creosData.notes
            notesApp.loadingNote = true
            notesApp.currentId = ""
            titleEdit.text = ""
            bodyEdit.text = ""
            notesApp.loadingNote = false
            if (next.length > 0) notesApp.selectNote(next[0].id)
        }
    }
}
