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
    property string errorMessage: ""
    readonly property string homepage: "https://www.wikipedia.org/"

    function navigate(input) {
        var raw = String(input).trim()
        if (!raw) return
        var destination = ""
        var lower = raw.toLowerCase()
        if (lower.indexOf("https://") === 0 || lower.indexOf("http://") === 0)
            destination = raw
        else if ((raw.indexOf(".") >= 0 || lower.indexOf("localhost") === 0)
                 && raw.indexOf(" ") < 0)
            destination = "https://" + raw
        else
            destination = "https://www.google.com/search?q=" + encodeURIComponent(raw)
        if (destination.length > 4096) return
        browser.showingHome = false
        browser.errorMessage = ""
        web.url = destination
        addressField.focus = false
    }
    function goHome() {
        web.stop()
        showingHome = true
        addressField.text = ""
        errorMessage = ""
    }

    Rectangle {
        anchors.fill: parent
        color: "#F5F8FF"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 55
            color: "#E9F3FB"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 13
                anchors.rightMargin: 13
                spacing: 9

                Repeater {
                    model: [
                        {symbol:"‹", hint:"Quay lại", action:"back"},
                        {symbol:"›", hint:"Tiến tới", action:"forward"},
                        {symbol:"↻", hint:"Tải lại", action:"reload"},
                        {symbol:"⌂", hint:"Trang chủ", action:"home"}
                    ]
                    delegate: Button {
                        id: navButton
                        required property var modelData
                        width: 34; height: 34
                        hoverEnabled: true
                        enabled: modelData.action === "home" || modelData.action === "reload"
                                 || (modelData.action === "back" && web.canGoBack)
                                 || (modelData.action === "forward" && web.canGoForward)
                        opacity: enabled ? 1 : 0.43
                        onClicked: {
                            if (modelData.action === "home") browser.goHome()
                            else if (modelData.action === "back") { browser.showingHome = false; web.goBack() }
                            else if (modelData.action === "forward") { browser.showingHome = false; web.goForward() }
                            else if (modelData.action === "reload") {
                                if (!browser.showingHome) {
                                    if (web.loading) web.stop()
                                    else web.reload()
                                }
                            }
                        }
                        background: Rectangle {
                            radius: 10
                            color: navButton.hovered ? "#D7E4FB" : "transparent"
                        }
                        contentItem: Text {
                            text: navButton.modelData.symbol
                            color: "#465B7D"
                            font.pixelSize: 21
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: modelData.hint
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 37
                    radius: 12
                    color: "#F8FFFFFF"
                    border.width: 1
                    border.color: "#D3E2F1"

                    TextField {
                        id: addressField
                        anchors.fill: parent
                        anchors.leftMargin: 11
                        anchors.rightMargin: 8
                        placeholderText: "Nhập địa chỉ web hoặc tìm kiếm..."
                        color: System.Theme.ink
                        font.pixelSize: 12
                        selectByMouse: true
                        verticalAlignment: TextInput.AlignVCenter
                        background: Item {}
                        onAccepted: browser.navigate(text)
                    }
                }
                Button {
                    id: visitButton
                    text: "Đi"
                    width: 38; height: 34
                    onClicked: browser.navigate(addressField.text)
                    background: Rectangle {
                        radius: 10
                        color: visitButton.hovered ? "#D8E3FA" : "#EEF4FE"
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: web.loading && !browser.showingHome ? 3 : 0
            color: "transparent"
            Rectangle {
                height: parent.height
                width: parent.width * web.loadProgress / 100
                color: "#637EE2"
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            WebEngineView {
                id: web
                anchors.fill: parent
                visible: !browser.showingHome
                url: "about:blank"
                backgroundColor: "#FFFFFF"
                onUrlChanged: {
                    if (!browser.showingHome)
                        addressField.text = String(url)
                }
                onLoadingChanged: function(request) {
                    if (request.status === WebEngineView.LoadFailedStatus
                        && !browser.showingHome)
                        browser.errorMessage = request.errorString
                    else if (request.status === WebEngineView.LoadSucceededStatus)
                        browser.errorMessage = ""
                }
            }
            Rectangle {
                anchors.fill: parent
                visible: browser.showingHome
                gradient: Gradient {
                    GradientStop { position: 0; color: "#F6FBFF" }
                    GradientStop { position: 1; color: "#E9EEFB" }
                }
                Column {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 42, 540)
                    spacing: 18
                    AppIcon {
                        size: 75
                        appId: "browser"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "CreOS Browser"
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#324764"
                        font.pixelSize: 29
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: "Mở cả thế giới web ngay bên trong CreOS."
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#8396AE"
                        font.pixelSize: 12
                    }
                    Rectangle {
                        width: parent.width
                        height: 49
                        radius: 16
                        color: "#DFFFFFFF"
                        border.color: "#FFFFFF"
                        TextField {
                            anchors.fill: parent
                            anchors.margins: 10
                            placeholderText: "Tìm kiếm hoặc nhập URL"
                            color: System.Theme.ink
                            selectByMouse: true
                            font.pixelSize: 14
                            background: Item {}
                            onAccepted: browser.navigate(text)
                        }
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12
                        Repeater {
                            model: [
                                {label:"Wikipedia", href:"https://www.wikipedia.org/"},
                                {label:"Qt", href:"https://www.qt.io/"},
                                {label:"GitHub", href:"https://github.com/"}
                            ]
                            delegate: SystemButton {
                                required property var modelData
                                width: 110
                                text: modelData.label
                                symbol: "↗"
                                onClicked: browser.navigate(modelData.href)
                            }
                        }
                    }
                }
            }
            Rectangle {
                visible: !browser.showingHome && browser.errorMessage !== ""
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 17
                width: Math.min(parent.width - 35, 500)
                height: 64
                radius: 15
                color: "#F9E5E9"
                border.color: "#E5C0CB"
                Text {
                    anchors.fill: parent
                    anchors.margins: 13
                    wrapMode: Text.Wrap
                    text: "Không tải được trang: " + browser.errorMessage
                    color: "#9C4158"
                    font.pixelSize: 11
                }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 23
            color: "#E8F1FA"
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: browser.showingHome ? "Trang chủ · CreOS Browser" :
                      (web.loading ? "Đang tải trang..." : web.title || "Trang web")
                elide: Text.ElideRight
                width: parent.width - 34
                font.pixelSize: 10
                color: "#8190A6"
            }
        }
    }
}
