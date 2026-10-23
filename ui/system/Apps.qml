pragma Singleton
import QtQuick

// Registry for built-in CreOS applications. The system owns all window chrome.
QtObject {
    readonly property var applications: [
        {
            "id": "about-creos", "name": "CreOS",
            "subtitle": "Hệ thống & phiên bản",
            "component": "CreosApp.qml", "appearance": "system",
            "glyph": "C", "tint": "#778EDB"
        },
        {
            "id": "notes", "name": "Ghi chú",
            "subtitle": "Lưu ý tưởng của bạn",
            "component": "NotesApp.qml", "appearance": "system",
            "glyph": "✎", "tint": "#EEB35D"
        },
        {
            "id": "calculator", "name": "Máy tính",
            "subtitle": "Tính toán cơ bản",
            "component": "CalculatorApp.qml", "appearance": "system",
            "glyph": "＋", "tint": "#7B8BDC"
        },
        {
            "id": "clock", "name": "Đồng hồ",
            "subtitle": "Giờ địa phương & bấm giờ",
            "component": "ClockApp.qml", "appearance": "system",
            "glyph": "◷", "tint": "#6BA6C6"
        },
        {
            "id": "browser", "name": "Trình duyệt",
            "subtitle": "Duyệt web trong CreOS",
            "component": "BrowserApp.qml", "appearance": "system",
            "glyph": "◎", "tint": "#4E9BC6"
        },
        {
            "id": "settings", "name": "Cài đặt",
            "subtitle": "Cá nhân hóa CreOS",
            "component": "SettingsApp.qml", "appearance": "system",
            "glyph": "⚙", "tint": "#8995B6"
        }
    ]

    function findIndex(appId) {
        for (var i = 0; i < applications.length; ++i) {
            if (applications[i].id === appId)
                return i
        }
        return -1
    }
}
