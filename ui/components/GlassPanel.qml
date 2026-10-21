import QtQuick
import "../system" as System

Rectangle {
    radius: System.Theme.radiusLarge
    color: System.Theme.glass
    border.width: 1
    border.color: System.Theme.line
    antialiasing: true

    Rectangle {
        x: 15
        y: 1
        width: Math.max(0, parent.width - 30)
        height: 1
        radius: 1
        color: "#B8FFFFFF"
    }
}
