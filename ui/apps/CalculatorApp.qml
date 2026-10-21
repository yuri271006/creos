import QtQuick
import QtQuick.Controls
import "../system" as System

Item {
    id: calculator
    clip: true
    focus: true
    property string display: "0"
    property real stored: 0
    property string operation: ""
    property bool awaiting: false
    property bool invalid: false

    function formatNumber(value) {
        if (!isFinite(value)) return "Lỗi tính toán"
        if (Math.abs(value) < 0.00000000001) return "0"
        return String(Number(value.toPrecision(12)))
    }
    function compute() {
        var a = stored
        var b = Number(display)
        var result = b
        if (operation === "+") result = a + b
        else if (operation === "−") result = a - b
        else if (operation === "×") result = a * b
        else if (operation === "÷") {
            if (b === 0) {
                display = "Không thể chia cho 0"
                operation = ""
                awaiting = true
                invalid = true
                return false
            }
            result = a / b
        }
        display = formatNumber(result)
        invalid = display === "Lỗi tính toán"
        return !invalid
    }
    function press(key) {
        if (key === "AC") {
            display = "0"; stored = 0; operation = ""; awaiting = false; invalid = false
            return
        }
        if (invalid && key !== "AC") {
            display = "0"; invalid = false; stored = 0; operation = ""; awaiting = false
        }
        if ("0123456789".indexOf(key) !== -1 && key.length === 1) {
            if (awaiting) { display = key; awaiting = false }
            else if (display === "0") display = key
            else if (display.replace(/[.−-]/g, "").length < 15) display += key
        } else if (key === ".") {
            if (awaiting) { display = "0."; awaiting = false }
            else if (display.indexOf(".") === -1) display += "."
        } else if (key === "±") {
            if (Number(display) !== 0) display = display[0] === "-" ? display.slice(1) : "-" + display
        } else if (key === "%") {
            display = formatNumber(Number(display) / 100)
        } else if (key === "⌫") {
            if (awaiting) { display = "0"; awaiting = false }
            else display = display.length > 1 ? display.slice(0, -1) : "0"
            if (display === "-") display = "0"
        } else if (key === "=") {
            if (operation !== "" && !awaiting) compute()
            operation = ""
            awaiting = true
        } else if (key === "+" || key === "−" || key === "×" || key === "÷") {
            if (operation !== "" && !awaiting && !compute()) return
            stored = Number(display)
            operation = key
            awaiting = true
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#EDF5FF" }
            GradientStop { position: 1; color: "#E5E9F8" }
        }
    }

    Column {
        id: pad
        width: Math.min(parent.width - 54, 456)
        anchors.centerIn: parent
        spacing: 14

        Row {
            width: parent.width
            spacing: 10
            Text {
                text: "Máy tính"
                color: "#394A68"
                font.pixelSize: 22
                font.weight: Font.DemiBold
            }
            Text {
                y: 9
                text: "STANDARD"
                color: "#9AA8BD"
                font.pixelSize: 9
                font.letterSpacing: 1.1
            }
        }

        Rectangle {
            width: parent.width
            height: 93
            radius: 19
            color: "#B8FFFFFF"
            border.width: 1
            border.color: "#EFFFFFFF"
            Text {
                x: 19; y: 12
                text: calculator.operation === "" ? "CREOS CALCULATOR" : formatNumber(calculator.stored) + "  " + calculator.operation
                font.pixelSize: 10
                color: "#9BAAC0"
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                width: parent.width - 35
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideLeft
                text: calculator.display
                color: calculator.invalid ? "#BD5A69" : "#2D3D58"
                font.pixelSize: calculator.display.length > 14 ? 23 : 36
                font.weight: Font.Medium
            }
        }

        Grid {
            id: keyGrid
            width: parent.width
            columns: 4
            spacing: 10
            Repeater {
                model: [
                    { k:"AC",kind:"tool" },{ k:"±",kind:"tool" },{ k:"%",kind:"tool" },{ k:"÷",kind:"op" },
                    { k:"7",kind:"num" },{ k:"8",kind:"num" },{ k:"9",kind:"num" },{ k:"×",kind:"op" },
                    { k:"4",kind:"num" },{ k:"5",kind:"num" },{ k:"6",kind:"num" },{ k:"−",kind:"op" },
                    { k:"1",kind:"num" },{ k:"2",kind:"num" },{ k:"3",kind:"num" },{ k:"+",kind:"op" },
                    { k:"⌫",kind:"tool" },{ k:"0",kind:"num" },{ k:".",kind:"num" },{ k:"=",kind:"equal" }
                ]
                delegate: Button {
                    id: keyButton
                    required property var modelData
                    width: (keyGrid.width - keyGrid.spacing * 3) / 4
                    height: 55
                    hoverEnabled: true
                    focusPolicy: Qt.StrongFocus
                    onClicked: calculator.press(modelData.k)
                    background: Rectangle {
                        radius: 17
                        color: keyButton.modelData.kind === "equal" ? (keyButton.down ? "#3856B5" : "#5873DE") :
                               keyButton.modelData.kind === "op" ? (keyButton.hovered ? "#CED9FA" : "#D9E3FA") :
                               keyButton.hovered ? "#FFFFFF" : "#CCFFFFFF"
                        border.width: 1
                        border.color: keyButton.modelData.kind === "equal" ? "#6E8CEA" : "#F0FFFFFF"
                        Behavior on color { ColorAnimation { duration: 140 } }
                    }
                    contentItem: Text {
                        text: keyButton.modelData.k
                        color: keyButton.modelData.kind === "equal" ? "#FFFFFF" : "#3E506F"
                        font.pixelSize: keyButton.modelData.kind === "num" ? 20 : 18
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        Text {
            width: parent.width
            text: "Các phép tính cơ bản  ·  Không cần kết nối Internet"
            horizontalAlignment: Text.AlignHCenter
            color: "#94A3B8"
            font.pixelSize: 10
        }
    }

    Keys.onPressed: function(event) {
        var key = event.text
        if (/^[0-9.]$/.test(key)) calculator.press(key)
        else if (key === "+" || key === "-") calculator.press(key === "-" ? "−" : key)
        else if (key === "*" || key === "/") calculator.press(key === "*" ? "×" : "÷")
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) calculator.press("=")
        else if (event.key === Qt.Key_Backspace) calculator.press("⌫")
        else if (event.key === Qt.Key_Escape) calculator.press("AC")
        else return
        event.accepted = true
    }
}
