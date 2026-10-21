import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: root
    visible: true
    width: 1180; height: 780
    minimumWidth: 950; minimumHeight: 640
    title: "CreOS · Release Center"
    color: "#0C1326"

    property int currentPage: 0
    property int releaseFilter: 0
    property int selectedReleaseIndex: 0
    readonly property var selectedRelease: releaseStore.releases[selectedReleaseIndex]
    readonly property color primaryText: "#F3F7FF"
    readonly property color mutedText: "#A9BDD9"

    function navigate(index) {
        if (currentPage === index) return
        currentPage = index
        pageEnter.restart()
    }
    NumberAnimation {
        id: pageEnter; target: pages; property: "opacity"
        from: 0.1; to: 1; duration: 380; easing.type: Easing.OutCubic
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#111A33" }
            GradientStop { position: 0.56; color: "#0C142A" }
            GradientStop { position: 1; color: "#11152B" }
        }
    }
    Item {
        anchors.fill: parent; clip: true
        Rectangle {
            width: 570; height: 570; radius: 285
            x: root.width * 0.14; y: -255; opacity: 0.31
            gradient: Gradient {
                GradientStop { position: 0; color: "#536DD1" }
                GradientStop { position: 1; color: "#17265B" }
            }
            SequentialAnimation on x {
                loops: Animation.Infinite
                NumberAnimation { to: root.width * 0.24; duration: 10500; easing.type: Easing.InOutSine }
                NumberAnimation { to: root.width * 0.14; duration: 10500; easing.type: Easing.InOutSine }
            }
        }
        Rectangle {
            width: 490; height: 490; radius: 245
            x: root.width - 270; y: root.height - 290; opacity: 0.27
            gradient: Gradient {
                GradientStop { position: 0; color: "#9666C8" }
                GradientStop { position: 1; color: "#29265F" }
            }
            SequentialAnimation on y {
                loops: Animation.Infinite
                NumberAnimation { to: root.height - 405; duration: 13500; easing.type: Easing.InOutSine }
                NumberAnimation { to: root.height - 290; duration: 13500; easing.type: Easing.InOutSine }
            }
        }
    }

    RowLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 21
        Rectangle {
            Layout.preferredWidth: 235; Layout.fillHeight: true
            radius: 28; color: "#65172442"
            border.width: 1; border.color: "#45D8E9FF"
            Column {
                anchors.fill: parent; anchors.margins: 20
                Row {
                    height: 67; spacing: 12
                    CreosMark { size: 45; anchors.verticalCenter: parent.verticalCenter }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 2
                        Text { text: "creos"; font.pixelSize: 25; font.weight: Font.Bold; color: root.primaryText }
                        Text { text: "THE INNER UNIVERSE"; font.pixelSize: 8; font.letterSpacing: 1.7; color: "#90A9D2" }
                    }
                }
                Rectangle { width: parent.width; height: 1; color: "#2DFFFFFF" }
                Item { width: 1; height: 34 }
                Text { text: "KHÔNG GIAN"; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 2; color: "#8DA4C7"; leftPadding: 14 }
                Item { width: 1; height: 15 }
                NavButton { width: parent.width; selected: root.currentPage === 0; symbol: "◈"; caption: "Tổng quan"; onClicked: root.navigate(0) }
                Item { width: 1; height: 6 }
                NavButton { width: parent.width; selected: root.currentPage === 1; symbol: "▤"; caption: "Bản phát hành"; onClicked: root.navigate(1) }
                Item { width: 1; height: 6 }
                NavButton { width: parent.width; selected: root.currentPage === 2; symbol: "◎"; caption: "Về CreOS"; onClicked: root.navigate(2) }
                Item { width: 1; height: 31 }
                Text { text: "TRẠNG THÁI"; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 2; color: "#8DA4C7"; leftPadding: 14 }
                Item { width: 1; height: 15 }
                Rectangle {
                    width: parent.width; height: 81; radius: 19
                    color: "#27FFFFFF"; border.color: "#24FFFFFF"
                    Row {
                        x: 15; anchors.verticalCenter: parent.verticalCenter; spacing: 11
                        Rectangle {
                            width: 9; height: 9; radius: 5; color: "#79E7CD"
                            anchors.verticalCenter: parent.verticalCenter
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.42; duration: 1300 }
                                NumberAnimation { to: 1; duration: 1300 }
                            }
                        }
                        Column {
                            spacing: 5
                            Text { text: "Đang phát triển"; font.pixelSize: 12; font.weight: Font.DemiBold; color: "#F1F6FF" }
                            Text { text: "Build " + releaseStore.latestVersion; font.pixelSize: 11; color: "#9CB2D2" }
                        }
                    }
                }
            }
            Column {
                anchors.left: parent.left; anchors.right: parent.right
                anchors.bottom: parent.bottom; anchors.margins: 22; spacing: 7
                Rectangle { width: parent.width; height: 1; color: "#29FFFFFF" }
                Text { text: "CREOS / DEVELOPER PREVIEW"; font.pixelSize: 9; font.letterSpacing: 1; color: "#91A9CD" }
                Text { text: "Made to become more."; font.pixelSize: 10; color: "#6F88B0" }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 19
            RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 49; spacing: 12
                Column {
                    Layout.fillWidth: true; spacing: 4
                    Text {
                        text: "CREOS  /  " + (root.currentPage === 0 ? "TỔNG QUAN" : root.currentPage === 1 ? "PHÁT HÀNH" : "GIỚI THIỆU")
                        font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1.5; color: "#95AED4"
                    }
                    Text {
                        text: root.currentPage === 0 ? "Chào mừng đến CreOS" : root.currentPage === 1 ? "Bản phát hành" : "Về CreOS"
                        font.pixelSize: 20; font.weight: Font.DemiBold; color: "#F4F7FF"
                    }
                }
                Rectangle {
                    Layout.preferredWidth: 133; Layout.preferredHeight: 34
                    radius: 14; color: "#2BFFFFFF"; border.color: "#38FFFFFF"
                    Text { anchors.centerIn: parent; text: "●  PREVIEW BUILD"; font.pixelSize: 10; font.weight: Font.DemiBold; color: "#CFDFFF" }
                }
                SoftButton { text: "GitHub"; symbol: "↗"; implicitWidth: 111; onClicked: Qt.openUrlExternally(releaseStore.repository) }
            }

            StackLayout {
                id: pages
                Layout.fillWidth: true; Layout.fillHeight: true
                currentIndex: root.currentPage

                // OVERVIEW
                Item {
                    clip: true
                    Flickable {
                        anchors.fill: parent; contentWidth: width; contentHeight: overviewBody.height + 12
                        boundsBehavior: Flickable.StopAtBounds; clip: true
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                        Column {
                            id: overviewBody; width: parent.width; spacing: 17
                            Rectangle {
                                id: hero; width: parent.width; height: 280; radius: 29; clip: true
                                gradient: Gradient {
                                    GradientStop { position: 0; color: "#7D456CA0" }
                                    GradientStop { position: 0.52; color: "#823B5D91" }
                                    GradientStop { position: 1; color: "#A130345D" }
                                }
                                border.width: 1; border.color: "#83D2E5FF"
                                Rectangle { width: 337; height: 337; radius: 169; x: hero.width - 225; y: -105; color: "#2CC5F3FF"; border.color: "#6FEFFFFF" }
                                Rectangle { width: 244; height: 244; radius: 122; x: hero.width - 180; y: 14; color: "#43BAA1FF"; border.color: "#8ED7DDFF" }
                                Rectangle { width: 152; height: 152; radius: 76; x: hero.width - 132; y: 62; color: "#599FE8FF"; border.color: "#7DFFFFFF" }
                                CreosMark { size: 89; x: hero.width - 147; y: 91 }
                                Column {
                                    x: 32; y: 26; spacing: 18
                                    Rectangle {
                                        width: 178; height: 28; radius: 14; color: "#2FFFFFFF"; border.color: "#5FFFFFFF"
                                        Text { anchors.centerIn: parent; text: "✦  THE INNER UNIVERSE"; font.pixelSize: 10; font.weight: Font.DemiBold; color: "#E4F2FF" }
                                    }
                                    Text { text: "Một không gian.\nVô hạn khả năng."; font.pixelSize: 30; lineHeight: 1.13; font.weight: Font.DemiBold; color: "#FFFFFF" }
                                    Text { text: "Nền tảng ứng dụng thu nhỏ ngay bên trong Ubuntu.\nKhởi đầu từ một ý tưởng, lớn lên theo từng bản dựng."; font.pixelSize: 12; lineHeight: 1.4; color: "#DBE6FD" }
                                }
                                Rectangle {
                                    x: 32; y: hero.height - 51; height: 26; width: 137; radius: 13
                                    color: "#36FFFFFF"; border.color: "#48FFFFFF"
                                    Text { anchors.centerIn: parent; text: "v" + releaseStore.latestVersion + "  ·  DEV"; font.pixelSize: 11; font.weight: Font.Bold; color: "#FFFFFF" }
                                }
                            }
                            Row {
                                width: parent.width; spacing: 14
                                Repeater {
                                    model: [
                                        {label: "PHIÊN BẢN HIỆN TẠI", value: releaseStore.latestVersion, foot: "Developer Preview", icon: "◇"},
                                        {label: "NỀN TẢNG", value: "Ubuntu", foot: "Cửa sổ độc lập", icon: "▧"},
                                        {label: "TRẠNG THÁI", value: "Đang xây dựng", foot: "Giai đoạn giao diện", icon: "✧"}
                                    ]
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: (overviewBody.width - 28) / 3; height: 137; radius: 22
                                        color: "#5B21314F"; border.color: "#48FFFFFF"
                                        Text { x: 19; y: 16; text: modelData.icon; font.pixelSize: 22; color: "#C2DCFF" }
                                        Text { x: 19; y: 52; text: modelData.label; font.pixelSize: 9; font.weight: Font.Bold; font.letterSpacing: 1; color: "#91AED4" }
                                        Text { x: 19; y: 72; text: modelData.value; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#F5F8FF" }
                                        Text { x: 19; y: 108; text: modelData.foot; font.pixelSize: 10; color: "#9DAFCE" }
                                    }
                                }
                            }
                            Rectangle {
                                width: parent.width; height: 175; radius: 24
                                color: "#56203450"; border.width: 1; border.color: "#44FFFFFF"
                                Text { x: 22; y: 19; text: "Dòng thời gian CreOS"; font.pixelSize: 18; font.weight: Font.DemiBold; color: root.primaryText }
                                Text { x: 22; y: 55; width: parent.width - 44; wrapMode: Text.Wrap; text: "Từ trung tâm phiên bản đến một desktop thu nhỏ và hệ sinh thái ứng dụng."; font.pixelSize: 12; color: root.mutedText }
                                Text { x: 22; y: 83; text: "●   0.1.0-dev  /  Khởi đầu       →       0.2.0  /  Desktop"; font.pixelSize: 12; color: "#CBE1FF" }
                                SoftButton { x: 22; y: parent.height - 52; implicitWidth: 184; implicitHeight: 37; text: "Xem các bản dựng"; symbol: "→"; onClicked: root.navigate(1) }
                            }
                            Item { width: 1; height: 12 }
                        }
                    }
                }

                // RELEASE CENTER
                Item {
                    Column {
                        anchors.fill: parent; spacing: 18
                        Rectangle {
                            width: parent.width; height: 134; radius: 25
                            color: "#662D3F63"; border.color: "#52C1D5F2"
                            Text { x: 23; y: 23; text: "Nhật ký phát triển"; font.pixelSize: 26; font.weight: Font.DemiBold; color: "#F5F8FF" }
                            Text { x: 23; y: 66; width: parent.width - 46; wrapMode: Text.Wrap; text: "Theo dõi từng bản dựng, thay đổi và những chặng đường tiếp theo."; font.pixelSize: 12; color: "#BED0EA" }
                            Text { x: parent.width - 128; y: 92; text: "01 / 03"; font.pixelSize: 22; font.weight: Font.Light; color: "#89A6D6" }
                        }
                        Row {
                            height: 36; spacing: 10
                            Repeater {
                                model: ["Tất cả", "Hiện tại", "Kế hoạch"]
                                delegate: Button {
                                    required property string modelData
                                    required property int index
                                    width: index === 1 ? 108 : 100; height: 35; hoverEnabled: true
                                    onClicked: { root.releaseFilter = index; if (index === 1) root.selectedReleaseIndex = 0; if (index === 2 && root.selectedReleaseIndex === 0) root.selectedReleaseIndex = 1 }
                                    background: Rectangle {
                                        radius: 13
                                        color: root.releaseFilter === index ? "#50C9DFFF" : (parent.hovered ? "#30FFFFFF" : "#1BFFFFFF")
                                        border.color: root.releaseFilter === index ? "#89DBE8FF" : "#30FFFFFF"
                                        border.width: 1
                                        Behavior on color { ColorAnimation { duration: 180 } }
                                    }
                                    contentItem: Text { text: modelData; font.pixelSize: 11; font.weight: Font.DemiBold; color: "#E9F2FF"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                }
                            }
                        }
                        Row {
                            width: parent.width; height: parent.height - 207; spacing: 16
                            Flickable {
                                id: releaseFlick
                                width: Math.max(252, parent.width * 0.41); height: parent.height
                                contentHeight: releaseList.height; clip: true
                                boundsBehavior: Flickable.StopAtBounds
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                Column {
                                    id: releaseList; width: releaseFlick.width - 4; spacing: 11
                                    Repeater {
                                        model: releaseStore.releases
                                        delegate: Rectangle {
                                            required property var modelData
                                            required property int index
                                            visible: root.releaseFilter === 0 || (root.releaseFilter === 1 && modelData.type === "current") || (root.releaseFilter === 2 && modelData.type === "planned")
                                            width: releaseList.width; height: visible ? 116 : 0; radius: 20
                                            color: root.selectedReleaseIndex === index ? "#7D354F7C" : (entryMouse.containsMouse ? "#5D2A395E" : "#49202E4C")
                                            border.width: 1; border.color: root.selectedReleaseIndex === index ? "#A8D1F4FF" : "#3BFFFFFF"
                                            Behavior on color { ColorAnimation { duration: 190 } }
                                            MouseArea {
                                                id: entryMouse; anchors.fill: parent; hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.selectedReleaseIndex = index
                                            }
                                            Text { x: 18; y: 14; text: "v" + modelData.version; font.pixelSize: 17; font.weight: Font.DemiBold; color: "#F5F8FF" }
                                            Rectangle {
                                                x: 18; y: 47; width: modelData.type === "current" ? 86 : 69; height: 21; radius: 10
                                                color: modelData.type === "current" ? "#3060D7BE" : "#2BFFFFFF"
                                                Text { anchors.centerIn: parent; text: modelData.type === "current" ? "HIỆN TẠI" : "DỰ KIẾN"; font.pixelSize: 9; font.weight: Font.Bold; color: "#D6F6F1" }
                                            }
                                            Text { x: 18; y: 77; text: modelData.name + "  ·  " + modelData.date; font.pixelSize: 11; color: "#ABC2E3" }
                                            Text { anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: "›"; font.pixelSize: 24; color: "#AFC9E5" }
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                width: parent.width - releaseFlick.width - parent.spacing; height: parent.height
                                radius: 25; color: "#60243551"; border.width: 1; border.color: "#50FFFFFF"
                                Flickable {
                                    anchors.fill: parent; anchors.margins: 23; clip: true
                                    contentWidth: width; contentHeight: detailBody.height + 10
                                    boundsBehavior: Flickable.StopAtBounds
                                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                                    Column {
                                        id: detailBody; width: parent.width; spacing: 13
                                        Rectangle {
                                            width: 84; height: 26; radius: 13
                                            color: root.selectedRelease.type === "current" ? "#3677B7AA" : "#34FFFFFF"
                                            Text { anchors.centerIn: parent; text: root.selectedRelease.type === "current" ? "BUILD" : "ROADMAP"; font.pixelSize: 10; font.weight: Font.Bold; color: "#EDFBFF" }
                                        }
                                        Text { text: "v" + root.selectedRelease.version; color: "#F6FAFF"; font.pixelSize: 30; font.weight: Font.DemiBold }
                                        Text { text: root.selectedRelease.name; color: "#B5CBEE"; font.pixelSize: 16; font.weight: Font.Medium }
                                        Rectangle { width: parent.width; height: 1; color: "#30FFFFFF" }
                                        Text { text: root.selectedRelease.description; width: parent.width; wrapMode: Text.Wrap; color: "#C2D3EC"; font.pixelSize: 12; lineHeight: 1.5 }
                                        Item { width: 1; height: 3 }
                                        Text { text: "THAY ĐỔI / DỰ ĐỊNH"; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1.1; color: "#8DAED9" }
                                        Repeater {
                                            model: root.selectedRelease.highlights
                                            delegate: Row {
                                                required property string modelData
                                                width: detailBody.width; spacing: 10
                                                Rectangle { width: 6; height: 6; radius: 3; color: "#8BD5E7"; y: 7 }
                                                Text { text: modelData; width: detailBody.width - 19; wrapMode: Text.Wrap; color: "#E0E9F9"; font.pixelSize: 12; lineHeight: 1.35 }
                                            }
                                        }
                                        Item { width: 1; height: 8 }
                                        Text { text: "Trạng thái: " + root.selectedRelease.status + "   ·   " + root.selectedRelease.date; width: parent.width; wrapMode: Text.Wrap; font.pixelSize: 10; color: "#93AACD" }
                                    }
                                }
                            }
                        }
                    }
                }

                // ABOUT
                Item {
                    Flickable {
                        anchors.fill: parent; contentHeight: aboutBody.height + 12; contentWidth: width
                        boundsBehavior: Flickable.StopAtBounds; clip: true
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                        Column {
                            id: aboutBody; width: parent.width; spacing: 18
                            Rectangle {
                                width: parent.width; height: 314; radius: 29
                                gradient: Gradient {
                                    GradientStop { position: 0; color: "#75395189" }
                                    GradientStop { position: 1; color: "#A124395B" }
                                }
                                border.color: "#77D5E7FF"
                                CreosMark { size: 84; anchors.horizontalCenter: parent.horizontalCenter; y: 30 }
                                Text { text: "CreOS"; anchors.horizontalCenter: parent.horizontalCenter; y: 125; font.pixelSize: 40; font.weight: Font.DemiBold; color: "#FFFFFF" }
                                Text { text: "THE INNER UNIVERSE"; anchors.horizontalCenter: parent.horizontalCenter; y: 178; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 3; color: "#C3D8FB" }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter; y: 218
                                    width: Math.min(parent.width - 65, 510)
                                    text: "Một hệ điều hành trong hệ điều hành — không gian sáng tạo chứa những ứng dụng nhỏ, chạy bên trong một cửa sổ Ubuntu."
                                    wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter
                                    font.pixelSize: 13; lineHeight: 1.5; color: "#DFE9FA"
                                }
                            }
                            Row {
                                width: parent.width; spacing: 16
                                Repeater {
                                    model: [
                                        { icon: "◇", title: "Không gian riêng", body: "Một cửa sổ Ubuntu, một thế giới bên trong." },
                                        { icon: "◎", title: "Linh hoạt", body: "Thiết kế cho những ứng dụng độc lập." },
                                        { icon: "✧", title: "Không ngừng lớn", body: "Xây dựng và cải tiến qua từng bản dựng." }
                                    ]
                                    delegate: Rectangle {
                                        required property var modelData
                                        width: (aboutBody.width - 32) / 3; height: 144; radius: 22
                                        color: "#61223854"; border.color: "#43FFFFFF"
                                        Text { x: 19; y: 16; text: modelData.icon; font.pixelSize: 22; color: "#B5D9FF" }
                                        Text { x: 19; y: 55; text: modelData.title; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#F1F7FF" }
                                        Text { x: 19; y: 83; width: parent.width - 32; text: modelData.body; font.pixelSize: 11; lineHeight: 1.2; wrapMode: Text.Wrap; color: "#A9BFD9" }
                                    }
                                }
                            }
                            Rectangle {
                                width: parent.width; height: 114; radius: 23
                                color: "#61213854"; border.color: "#43FFFFFF"
                                Text { x: 21; y: 18; text: "THÔNG TIN PHIÊN BẢN"; font.pixelSize: 10; font.weight: Font.Bold; font.letterSpacing: 1.4; color: "#9CB8DB" }
                                Text { x: 21; y: 50; text: "CreOS " + releaseStore.latestVersion + "   ·   " + releaseStore.channel; font.pixelSize: 16; color: "#F4F8FF"; font.weight: Font.DemiBold }
                                Text { x: 21; y: 82; text: "Đây là bản thử nghiệm giao diện, chưa phải hệ điều hành đầy đủ."; color: "#ACBDD7"; font.pixelSize: 11 }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 24
                Text { text: "CREOS  ·  AN OPENING CHAPTER"; font.pixelSize: 9; font.letterSpacing: 1.3; color: "#7690B8"; Layout.fillWidth: true }
                Text { text: "© 2026  ·  Developer Preview"; font.pixelSize: 10; color: "#7A94B9" }
            }
        }
    }
}
