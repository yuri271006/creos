pragma Singleton
import QtQuick

// Register new applications here. All apps run in the CreOS window shell.
// "system" inherits the shared tokens; "custom" may style its content.
QtObject {
    readonly property var applications: [
        {
            "id": "about-creos",
            "name": "CreOS",
            "subtitle": "Phiên bản & bản phát hành",
            "component": "CreosApp.qml",
            "appearance": "system"
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
