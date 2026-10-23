import QtQuick
import "../system" as System

// Cards are solid, softly rounded and GPU-cheap. No live blurs or layer masks.
Rectangle {
    radius: System.Theme.radiusLarge
    color: System.Theme.surface
    border.width: 1
    border.color: System.Theme.subtleLine
    antialiasing: true
}
