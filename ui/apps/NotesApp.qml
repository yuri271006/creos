import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../system" as System

Item {
    id: app
    clip: true
    property string currentId: ""
    property bool loading: false

    function flush() {
        if (currentId !== "" && !loading)
            creosData.saveNote(currentId, noteTitle.text, noteBody.text)
    }
    function selectNote(identity) {
        saveDelay.stop()
        flush()
        loading = true
        var record = creosData.getNote(identity)
        currentId = record.id || ""
        noteTitle.text = record.title || ""
        noteBody.text = record.body || ""
        loading = false
    }
    function createNote() {
        saveDelay.stop()
        flush()
        var identity = creosData.createNote()
        selectNote(identity)
        noteTitle.forceActiveFocus()
        noteTitle.selectAll()
    }
    function deleteCurrent() {
        saveDelay.stop()
        var toDelete = currentId
        loading = true
        currentId = ""
        noteTitle.text = ""
        noteBody.text = ""
        creosData.deleteNote(toDelete)
        loading = false
        var remaining = creosData.notes
        if (remaining.length) selectNote(remaining[0].id)
    }

    Timer {
        id: saveDelay
        interval: 450
        repeat: false
        onTriggered: app.flush()
    }
    Component.onCompleted: {
        var items = creosData.notes
        if (items.length > 0) selectNote(items[0].id)
    }
    Component.onDestruction: { saveDelay.stop(); flush() }

    Rectangle { anchors.fill: parent; color: System.Theme.canvas }
    RowLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            Layout.preferredWidth: Math.min(274, Math.max(212, app.width * 0.31))
            Layout.fillHeight: true
            color: System.Theme.sidebar
            Rectangle {
                anchors.right: parent.right
                width: 1; height: parent.height
                color: System.Theme.line
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 13

                RowLayout {
                    Layout.fillWidth: true
                    PaneHeader {
                        Layout.fillWidth: true
                        heading: "Ghi chú"
                        detail: creosData.notes.length + " ghi chú"
                    }
                    SystemButton {
                        text: "+"
                        implicitWidth: 44
                        primary: true
                        onClicked: app.createNote()
                        ToolTip.visible: hovered
                        ToolTip.text: "Ghi chú mới"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: System.Theme.line
                }
                ListView {
                    id: noteList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 7
                    model: creosData.notes
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    delegate: Rectangle {
                        id: noteCard
                        required property var modelData
                        width: noteList.width - 5
                        height: 91
                        radius: 14
                        color: app.currentId === modelData.id ? "#FFFFFF" :
                               noteTap.containsMouse ? "#F8FAFD" : "transparent"
                        border.width: app.currentId === modelData.id ? 1 : 0
                        border.color: System.Theme.line
                        Behavior on color { ColorAnimation { duration: System.Theme.durationQuick } }
                        Column {
                            x: 13; y: 13; width: parent.width - 26
                            spacing: 6
                            Text {
                                width: parent.width
                                text: noteCard.modelData.title.trim() || "Không tiêu đề"
                                elide: Text.ElideRight
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: System.Theme.ink
                            }
                            Text {
                                width: parent.width
                                text: noteCard.modelData.body.split("\n").join(" ").trim() || "Chưa có nội dung"
                                elide: Text.ElideRight
                                font.pixelSize: 11
                                color: System.Theme.secondary
                            }
                            Text {
                                text: noteCard.modelData.updated
                                font.pixelSize: 10
                                color: System.Theme.muted
                            }
                        }
                        MouseArea {
                            id: noteTap
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: app.selectNote(noteCard.modelData.id)
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
                anchors.margins: 22
                spacing: 11
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    Text {
                        Layout.fillWidth: true
                        text: app.currentId ? "Trình soạn thảo" : "Ghi chú"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: System.Theme.secondary
                    }
                    Text {
                        visible: app.currentId !== ""
                        text: "●  Tự động lưu"
                        font.pixelSize: 11
                        color: System.Theme.positive
                    }
                    SystemButton {
                        visible: app.currentId !== ""
                        text: "Xóa"
                        destructive: true
                        implicitWidth: 70
                        onClicked: deleteDialog.open()
                    }
                }
                SurfaceCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: app.currentId !== ""
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12
                        TextField {
                            id: noteTitle
                            Layout.fillWidth: true
                            font.pixelSize: 26
                            font.weight: Font.DemiBold
                            color: System.Theme.ink
                            placeholderText: "Tiêu đề"
                            selectByMouse: true
                            background: Item {}
                            onTextChanged: if (!app.loading) saveDelay.restart()
                        }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: System.Theme.subtleLine }
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            TextArea {
                                id: noteBody
                                width: parent.width
                                wrapMode: TextEdit.Wrap
                                selectByMouse: true
                                font.pixelSize: 13
                                color: System.Theme.ink
                                placeholderText: "Nhập nội dung ghi chú..."
                                background: Item {}
                                onTextChanged: if (!app.loading) saveDelay.restart()
                            }
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: app.currentId === ""
                    Column {
                        anchors.centerIn: parent
                        spacing: 15
                        AppIcon {
                            appId: "notes"
                            size: 79
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: "Chưa có ghi chú"
                            font.pixelSize: 17
                            font.weight: Font.DemiBold
                            color: System.Theme.ink
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: "Chọn Tạo ghi chú để bắt đầu."
                            font.pixelSize: 12
                            color: System.Theme.secondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        SystemButton {
                            text: "Tạo ghi chú"
                            primary: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            onClicked: app.createNote()
                        }
                    }
                }
            }
        }
    }
    Dialog {
        id: deleteDialog
        title: "Xóa ghi chú này?"
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: app.deleteCurrent()
    }
}
