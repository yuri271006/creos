import QtQuick

// CreOS icon language: original vector assets instead of font glyphs.
// SVGs are shared by Desktop, Dock, Launchpad and app listing.
Item {
    id: icon
    property real size: 46
    property string appId: "about-creos"
    width: size
    height: size

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../assets/icons/" + icon.appId + ".svg")
        sourceSize.width: 192
        sourceSize.height: 192
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        cache: true
        onStatusChanged: {
            if (status === Image.Error)
                console.warn("CreOS icon load failed:", source)
        }
    }
}
