import QtQuick

// One reusable hit-zone for each edge and corner of a CreOS window.
// horizontal: -1 left, 0 none, +1 right
// vertical:   -1 top,  0 none, +1 bottom
Item {
    id: handle
    property Item windowItem
    property int horizontal: 0
    property int vertical: 0
    property real originalX: 0
    property real originalY: 0
    property real originalWidth: 0
    property real originalHeight: 0
    signal pressed()

    visible: windowItem !== null && !windowItem.maximized
    z: 100

    DragHandler {
        id: resizing
        target: null
        acceptedButtons: Qt.LeftButton
        cursorShape: (handle.horizontal !== 0 && handle.vertical !== 0)
            ? (handle.horizontal === handle.vertical ? Qt.SizeFDiagCursor : Qt.SizeBDiagCursor)
            : (handle.horizontal !== 0 ? Qt.SizeHorCursor : Qt.SizeVerCursor)
        onActiveChanged: {
            if (active && handle.windowItem) {
                handle.originalX = handle.windowItem.x
                handle.originalY = handle.windowItem.y
                handle.originalWidth = handle.windowItem.width
                handle.originalHeight = handle.windowItem.height
                handle.pressed()
            }
        }
        onTranslationChanged: {
            if (!active || !handle.windowItem || !handle.windowItem.parent)
                return

            var win = handle.windowItem
            var outer = win.parent
            var left = handle.originalX
            var top = handle.originalY
            var right = left + handle.originalWidth
            var bottom = top + handle.originalHeight
            var dx = translation.x
            var dy = translation.y

            if (handle.horizontal < 0)
                left = Math.max(6, Math.min(right - win.minimumPanelWidth, left + dx))
            else if (handle.horizontal > 0)
                right = Math.max(left + win.minimumPanelWidth,
                                 Math.min(outer.width - 6, right + dx))

            if (handle.vertical < 0)
                top = Math.max(6, Math.min(bottom - win.minimumPanelHeight, top + dy))
            else if (handle.vertical > 0)
                bottom = Math.max(top + win.minimumPanelHeight,
                                  Math.min(outer.height - 6, bottom + dy))

            win.x = left
            win.y = top
            win.width = right - left
            win.height = bottom - top
        }
    }
}
