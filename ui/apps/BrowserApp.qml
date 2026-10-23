import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import "../components"
import "../system" as System

Item {
    id: browser
    clip: true
    property bool showingHome: true
    property bool engineStarted: false
    property string pendingUrl: "about:blank"
    property string errorMessage: ""
    property real loadProgress: 0

    function navigate(text) {
        var raw = String(text).trim()
        if (!raw) return
        var lower = raw.toLowerCase()
        var target = ""
        if (lower.indexOf("https://") === 0 || lower.indexOf("http://") === 0)
            target = raw
        else if (raw.indexOf(".") >= 0 && raw.indexOf(" ") === -1)
            target = "https://" + raw
        else
            target = "https://www.google.com/search?q=" + encodeURIComponent(raw)
        if (target.length > 4096) return
        pendingUrl = target
        errorMessage = ""
        showingHome = false
        address.text = target
        if (!engineStarted) engineStarted = true
        else if (webLoader.item) webLoader.item.url = target
    }
    function goHome() {
        showingHome = true
        if (webLoader.item) webLoader.item.stop()
        address.text = ""
        errorMessage = ""
    }
    function goBack() {
        if (webLoader.item && webLoader.item.canGoBack)
            webLoader.item.goBack()
    }
    function goForward() {
        if (webLoader.item && webLoader.item.canGoForward)
            webLoader.item.goForward()
    }
    function reload() {
        if (webLoader.item && !showingHome) webLoader.item.reload()
    }

    Rectangle { anchors.fill: parent; color: System.Theme.canvas }
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 63
            color: System.Theme.surface
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 13
                anchors.rightMargin: 13
                spacing: 8
                Repeater {
                    model: [
                        {label:"‹", what:"back", hint:"Quay lại"},
                        {label:"›", what:"forward", hint:"Tiến tới"},
                        {label:"⌂", what:"home", hint:"Trang chủ"},
                        {label:"↻", what:"reload", hint:"Tải lại"}
                    ]
                    delegate: SystemButton {
                        required property var modelData
                        implicitWidth: 42
                        text: modelData.label
                        quiet: true
                        enabled: modelData.what === "home" || modelData.what === "reload" ||
                                (modelData.what === "back" && webLoader.item && webLoader.item.canGoBack) ||
                                (modelData.what === "forward" && webLoader.item && webLoader.item.canGoForward)
                        onClicked: {
                            if (modelData.what === "home") browser.goHome()
                            else if (modelData.what === "back") browser.goBack()
                            else if (modelData.what === "forward") browser.goForward()
                            else browser.reload()
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: modelData.hint
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 14
                    color: System.Theme.inset
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 13
                        anchors.rightMargin: 8
                        spacing: 6
                        Text {
                            text: "⌕"
                            font.pixelSize: 20
                            color: System.Theme.muted
                        }
                        TextField {
                            id: address
                            Layout.fillWidth: true
                            selectByMouse: true
                            text: ""
                            placeholderText: "Tìm kiếm hoặc nhập tên website"
                            font.pixelSize: 12
                            color: System.Theme.ink
                            background: Item {}
                            onAccepted: browser.navigate(text)
                        }
                    }
                }
                SystemButton {
                    implicitWidth: 47
                    text: "Đi"
                    primary: true
                    onClicked: browser.navigate(address.text)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: (!browser.showingHome && browser.loadProgress < 100) ? 3 : 0
            color: System.Theme.accentSoft
            Rectangle {
                width: parent.width * browser.loadProgress / 100
                height: parent.height
                color: System.Theme.accent
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            // Chromium is created lazily, only after navigation.
            Loader {
                id: webLoader
                anchors.fill: parent
                active: browser.engineStarted
                visible: !browser.showingHome
                asynchronous: true
                sourceComponent: Component {
                    WebEngineView {
                        backgroundColor: "#FFFFFF"
                        url: "about:blank"
                        onUrlChanged: {
                            if (!browser.showingHome) address.text = String(url)
                        }
                        onLoadProgressChanged: browser.loadProgress = loadProgress
                        onLoadingChanged: function(request) {
                            if (request.status === WebEngineView.LoadFailedStatus && !browser.showingHome)
                                browser.errorMessage = request.errorString
                            else if (request.status === WebEngineView.LoadSucceededStatus)
                                browser.errorMessage = ""
                        }
                    }
                }
                onLoaded: {
                    if (item) item.url = browser.pendingUrl
                }
            }

            Rectangle {
                anchors.fill: parent
                visible: browser.showingHome
                color: System.Theme.canvas
                Column {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 46, 510)
                    spacing: 18
                    AppIcon {
                        appId: "browser"
                        size: 70
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "Khám phá cùng CreOS"
                        color: System.Theme.ink
                        font.pixelSize: 23
                        font.weight: Font.DemiBold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "Một cửa sổ nhỏ dẫn đến cả thế giới."
                        color: System.Theme.secondary
                        font.pixelSize: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    SurfaceCard {
                        width: parent.width
                        height: 58
                        TextField {
                            anchors.fill: parent
                            anchors.margins: 14
                            placeholderText: "Bạn muốn tìm điều gì?"
                            font.pixelSize: 14
                            color: System.Theme.ink
                            selectByMouse: true
                            background: Item {}
                            onAccepted: browser.navigate(text)
                        }
                    }
                    SectionLabel { text: "TRUY CẬP NHANH" }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 9
                        Repeater {
                            model: [
                                {name:"Wikipedia", url:"https://www.wikipedia.org/"},
                                {name:"GitHub", url:"https://github.com/"},
                                {name:"Qt", url:"https://www.qt.io/"}
                            ]
                            delegate: SystemButton {
                                required property var modelData
                                text: modelData.name
                                implicitWidth: 126
                                onClicked: browser.navigate(modelData.url)
                            }
                        }
                    }
                }
            }
            SurfaceCard {
                visible: !browser.showingHome && browser.errorMessage !== ""
                width: Math.min(parent.width - 30, 480)
                height: 75
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                Text {
                    anchors.fill: parent
                    anchors.margins: 12
                    text: "Không thể tải trang. " + browser.errorMessage
                    wrapMode: Text.Wrap
                    font.pixelSize: 12
                    color: System.Theme.danger
                }
            }
        }
    }
}
