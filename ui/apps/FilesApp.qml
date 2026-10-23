import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../system" as System

// CreOS Files: system source tree is read-only; user files live under XDG data.
Item {
    id: app
    clip: true
    property string selectedName: ""
    property bool selectedFolder: false
    property bool dirty: false
    property bool updatingEditor: false
    property string actionMode: "folder"
    property string notice: ""

    function choose(item) {
        if (dirty) {
            notice = "Hãy lưu hoặc bỏ thay đổi trước khi chuyển tệp."
            return
        }
        selectedName = item.name
        selectedFolder = item.directory
        updatingEditor = true
        editor.text = item.directory ? "" : fileStore.readText(item.name)
        updatingEditor = false
        dirty = false
        notice = item.directory ? "Nhấp đúp vào thư mục để mở." : ""
    }
    function openFolder(item) {
        if (!item.directory) return
        if (dirty) { notice = "Hãy lưu hoặc bỏ thay đổi trước khi mở thư mục."; return }
        fileStore.enter(item.name)
        selectedName = ""
        selectedFolder = false
        updatingEditor = true; editor.text = ""; updatingEditor = false
        dirty = false
        notice = ""
    }
    function switchArea(area) {
        if (dirty) { notice = "Hãy lưu hoặc bỏ thay đổi trước khi chuyển khu vực."; return }
        fileStore.selectArea(area)
        selectedName = ""
        selectedFolder = false
        updatingEditor = true; editor.text = ""; updatingEditor = false
        notice = ""
    }
    function goBack() {
        if (dirty) { notice = "Hãy lưu hoặc bỏ thay đổi trước khi quay lại."; return }
        fileStore.goUp()
        selectedName = ""
        selectedFolder = false
        updatingEditor = true; editor.text = ""; updatingEditor = false
    }
    function saveCurrent() {
        if (!selectedName || fileStore.readOnly) return
        if (fileStore.saveText(selectedName, editor.text)) {
            dirty = false
            notice = "Đã lưu tệp."
        } else notice = fileStore.message
    }
    function discard() {
        if (!selectedName) return
        updatingEditor = true
        editor.text = fileStore.readText(selectedName)
        updatingEditor = false
        dirty = false
        notice = ""
    }
    function showAction(mode) {
        actionMode = mode
        nameField.text = mode === "rename" ? selectedName : ""
        nameDialog.open()
        nameField.forceActiveFocus()
        nameField.selectAll()
    }

    Rectangle { anchors.fill: parent; color: System.Theme.canvas }
    RowLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            Layout.preferredWidth: 196
            Layout.fillHeight: true
            color: System.Theme.sidebar
            Rectangle {
                width: 1; height: parent.height
                anchors.right: parent.right
                color: System.Theme.line
            }
            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                Text {
                    text: "Tệp"
                    color: System.Theme.ink
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                }
                SectionLabel { text: "VỊ TRÍ" }
                SidebarItem {
                    width: parent.width
                    glyph: "▣"
                    text: "data"
                    selected: fileStore.area === "data"
                    onClicked: app.switchArea("data")
                }
                SidebarItem {
                    width: parent.width
                    glyph: "⌘"
                    text: "sys"
                    selected: fileStore.area === "sys"
                    onClicked: app.switchArea("sys")
                }
                Rectangle { width: parent.width; height: 1; color: System.Theme.line }
                Text {
                    width: parent.width
                    wrapMode: Text.Wrap
                    font.pixelSize: 11
                    color: System.Theme.secondary
                    lineHeight: 1.4
                    text: fileStore.readOnly
                        ? "Các tệp vận hành CreOS. Chỉ có thể xem, không được sửa hay xóa."
                        : "Không gian dữ liệu của bạn. Tạo thư mục và quản lý tệp văn bản."
                }
                SurfaceCard {
                    width: parent.width
                    height: 57
                    Text {
                        anchors.fill: parent
                        anchors.margins: 11
                        wrapMode: Text.Wrap
                        font.pixelSize: 11
                        color: fileStore.readOnly ? System.Theme.secondary : System.Theme.positive
                        text: fileStore.readOnly ? "●  Chỉ đọc · Hệ thống" : "●  Có thể chỉnh sửa"
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 17
                spacing: 10
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 9
                    Text {
                        text: "Tệp"
                        font.pixelSize: 21
                        font.weight: Font.DemiBold
                        color: System.Theme.ink
                        Layout.fillWidth: true
                    }
                    SystemButton {
                        text: "+ Thư mục"
                        implicitWidth: 98
                        enabled: !fileStore.readOnly
                        onClicked: app.showAction("folder")
                    }
                    SystemButton {
                        text: "+ Tệp"
                        implicitWidth: 72
                        primary: true
                        enabled: !fileStore.readOnly
                        onClicked: app.showAction("file")
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 9
                    SystemButton {
                        text: "‹"
                        implicitWidth: 43
                        quiet: true
                        onClicked: app.goBack()
                    }
                    SurfaceCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 43
                        Text {
                            text: "CreOS / " + fileStore.currentPath
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 10
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideLeft
                            font.pixelSize: 12
                            color: System.Theme.secondary
                        }
                    }
                    SystemButton {
                        text: "↻"
                        implicitWidth: 43
                        quiet: true
                        onClicked: fileStore.refresh()
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 11
                    SurfaceCard {
                        Layout.preferredWidth: Math.max(205, parent.width * 0.46)
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 11
                            spacing: 5
                            RowLayout {
                                Layout.fillWidth: true
                                SectionLabel {
                                    text: fileStore.entries.length + " MỤC"
                                    Layout.fillWidth: true
                                }
                                SectionLabel { text: "TÊN / KÍCH THƯỚC" }
                            }
                            ListView {
                                id: fileList
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                spacing: 4
                                model: fileStore.entries
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                delegate: Rectangle {
                                    id: fileRow
                                    required property var modelData
                                    width: fileList.width
                                    height: 62
                                    radius: 13
                                    color: app.selectedName === modelData.name ?
                                           System.Theme.accentSoft :
                                           rowMouse.containsMouse ? System.Theme.inset : "transparent"
                                    Behavior on color { ColorAnimation { duration: System.Theme.durationQuick } }
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 9
                                        Rectangle {
                                            width: 35; height: 35; radius: 11
                                            color: fileRow.modelData.directory ? "#E4EDFF" : "#E9F3F4"
                                            Text {
                                                anchors.centerIn: parent
                                                text: fileRow.modelData.directory ? "▰" : "▤"
                                                color: fileRow.modelData.directory ? System.Theme.accent : System.Theme.positive
                                                font.pixelSize: 18
                                            }
                                        }
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4
                                            Text {
                                                Layout.fillWidth: true
                                                text: fileRow.modelData.name
                                                elide: Text.ElideMiddle
                                                font.pixelSize: 12
                                                font.weight: Font.DemiBold
                                                color: System.Theme.ink
                                            }
                                            Text {
                                                text: fileRow.modelData.size
                                                font.pixelSize: 10
                                                color: System.Theme.muted
                                            }
                                        }
                                        Text {
                                            text: fileRow.modelData.directory ? "›" : ""
                                            font.pixelSize: 20
                                            color: System.Theme.muted
                                        }
                                    }
                                    MouseArea {
                                        id: rowMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: app.choose(fileRow.modelData)
                                    onDoubleClicked: app.openFolder(fileRow.modelData)
                                    }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    visible: fileList.count === 0
                                    text: "Thư mục trống"
                                    font.pixelSize: 12
                                    color: System.Theme.muted
                                }
                            }
                        }
                    }
                    SurfaceCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 9
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: app.selectedName || "Xem tệp"
                                    elide: Text.ElideMiddle
                                    font.pixelSize: 15
                                    font.weight: Font.DemiBold
                                    color: System.Theme.ink
                                }
                                Text {
                                    visible: app.dirty
                                    text: "Chưa lưu"
                                    font.pixelSize: 10
                                    color: System.Theme.danger
                                }
                            }
                            Text {
                                text: fileStore.readOnly ? "SYS · CHỈ ĐỌC" : "DATA · TỆP VĂN BẢN"
                                font.pixelSize: 10
                                color: System.Theme.muted
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: System.Theme.subtleLine
                            }
                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                TextArea {
                                    id: editor
                                    visible: app.selectedName.length > 0 && !app.selectedFolder
                                    wrapMode: TextEdit.Wrap
                                    selectByMouse: true
                                    readOnly: fileStore.readOnly || app.selectedFolder
                                    font.family: "monospace"
                                    font.pixelSize: 12
                                    color: System.Theme.ink
                                    placeholderText: "Chọn tệp để xem nội dung"
                                    background: Item {}
                                    onTextChanged: {
                                        if (!app.updatingEditor && app.selectedName.length && !fileStore.readOnly)
                                            app.dirty = true
                                    }
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                SystemButton {
                                    text: "Lưu"
                                    primary: true
                                    implicitWidth: 68
                                    enabled: app.selectedName !== "" && !app.selectedFolder && !fileStore.readOnly && app.dirty
                                    onClicked: app.saveCurrent()
                                }
                                SystemButton {
                                    text: "Bỏ sửa"
                                    quiet: true
                                    implicitWidth: 77
                                    enabled: app.dirty
                                    onClicked: app.discard()
                                }
                                Item { Layout.fillWidth: true }
                                SystemButton {
                                    text: "Đổi tên"
                                    implicitWidth: 80
                                    enabled: app.selectedName !== "" && !fileStore.readOnly && !app.dirty
                                    onClicked: app.showAction("rename")
                                }
                                SystemButton {
                                    text: "Xóa"
                                    destructive: true
                                    implicitWidth: 64
                                    enabled: app.selectedName !== "" && !fileStore.readOnly && !app.dirty
                                    onClicked: deleteDialog.open()
                                }
                            }
                        }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    elide: Text.ElideRight
                    text: app.notice || fileStore.message ||
                          (fileStore.readOnly ? "Tệp sys được bảo vệ." : "Tệp nằm trong thư mục dữ liệu riêng của CreOS.")
                    font.pixelSize: 11
                    color: app.notice || fileStore.message ? System.Theme.danger : System.Theme.muted
                }
            }
        }
    }

    Dialog {
        id: nameDialog
        anchors.centerIn: parent
        modal: true
        title: app.actionMode === "folder" ? "Thư mục mới" :
               app.actionMode === "rename" ? "Đổi tên" : "Tệp văn bản mới"
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            var value = nameField.text.trim()
            var success = false
            if (app.actionMode === "folder")
                success = fileStore.createFolder(value)
            else if (app.actionMode === "file")
                success = fileStore.createTextFile(value)
            else
                success = fileStore.renameEntry(app.selectedName, value)
            app.notice = success ? "Đã cập nhật dữ liệu." : fileStore.message
            if (success && app.actionMode === "rename") app.selectedName = value
        }
        contentItem: TextField {
            id: nameField
            width: 300
            selectByMouse: true
            placeholderText: app.actionMode === "file" ? "ví dụ: ghichu.txt" : "Tên"
            onAccepted: nameDialog.accept()
        }
    }
    Dialog {
        id: deleteDialog
        title: "Xóa tệp/thư mục này?"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: {
            var ok = fileStore.deleteEntry(app.selectedName)
            app.notice = ok ? "Đã xóa." : fileStore.message
            if (ok) {
                app.selectedName = ""
                app.updatingEditor = true; editor.text = ""; app.updatingEditor = false
                app.dirty = false
            }
        }
    }
}
