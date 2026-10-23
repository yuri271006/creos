import QtQuick
import "../system" as System

// Use one real rounded surface. A transparent GPU blur behind a rounded panel
// creates the square corners previously seen around the Dock and Launchpad.
Rectangle {
    radius: System.Theme.radiusLarge
    color: System.Theme.glassStrong
    border.width: 1
    border.color: System.Theme.line
    antialiasing: true
}
