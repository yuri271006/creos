pragma Singleton
import QtQuick

// One registration powers Dock, Launchpad and the system app list.
QtObject {
    readonly property var applications: [
        {
            "id": "about-creos", "name": "CreOS",
            "subtitle": "Thông tin hệ thống",
            "component": "CreosApp.qml", "appearance": "system"
        },
        {
            "id": "notes", "name": "Ghi chú",
            "subtitle": "Ghi chú cá nhân",
            "component": "NotesApp.qml", "appearance": "system"
        },
        {
            "id": "calculator", "name": "Máy tính",
            "subtitle": "Các phép tính",
            "component": "CalculatorApp.qml", "appearance": "system"
        },
        {
            "id": "clock", "name": "Đồng hồ",
            "subtitle": "Giờ và bấm giờ",
            "component": "ClockApp.qml", "appearance": "system"
        },
        {
            "id": "browser", "name": "Trình duyệt",
            "subtitle": "Duyệt web",
            "component": "BrowserApp.qml", "appearance": "system"
        },
        {
            "id": "files", "name": "Tệp",
            "subtitle": "Quản lý sys và data",
            "component": "FilesApp.qml", "appearance": "system"
        },
        {
            "id": "settings", "name": "Cài đặt",
            "subtitle": "Hình nền và giao diện",
            "component": "SettingsApp.qml", "appearance": "system"
        }
    ]
    function findIndex(appId) {
        for (var i = 0; i < applications.length; ++i) {
            if (applications[i].id === appId) return i
        }
        return -1
    }
}
