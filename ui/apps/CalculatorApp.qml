import QtQuick
import QtQuick.Controls
import "../components"
import "../system" as System

Item {
    id: calc
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
        var b = Number(display)
        var answer = b
        if (operation === "+") answer = stored + b
        else if (operation === "−") answer = stored - b
        else if (operation === "×") answer = stored * b
        else if (operation === "÷") {
            if (b === 0) {
                display = "Không thể chia cho 0"; operation = ""; awaiting = true
                invalid = true
                return false
            }
            answer = stored / b
        }
        display = formatNumber(answer)
        invalid = display === "Lỗi tính toán"
        return !invalid
    }
    function press(key) {
        if (key === "AC") {
            display = "0"; stored = 0; operation = ""; awaiting = false; invalid = false
            return
        }
        if (invalid) {
            display = "0"; stored = 0; operation = ""; awaiting = false; invalid = false
        }
        if ("0123456789".indexOf(key) >= 0 && key.length === 1) {
            if (awaiting) { display = key; awaiting = false }
            else if (display === "0") display = key
            else if (display.replace(/[.\-]/g, "").length < 15) display += key
        } else if (key === ".") {
            if (awaiting) { display = "0."; awaiting = false }
            else if (display.indexOf(".") < 0) display += "."
        } else if (key === "±") {
            if (Number(display) !== 0)
                display = display[0] === "-" ? display.slice(1) : "-" + display
        } else if (key === "%") display = formatNumber(Number(display) / 100)
        else if (key === "⌫") {
            if (awaiting) { display = "0"; awaiting = false }
            else display = display.length > 1 ? display.slice(0, -1) : "0"
            if (display === "-") display = "0"
        } else if (key === "=") {
            if (operation !== "" && !awaiting) compute()
            operation = ""; awaiting = true
        } else if (key === "+" || key === "−" || key === "×" || key === "÷") {
            if (operation !== "" && !awaiting && !compute()) return
            stored = Number(display); operation = key; awaiting = true
        }
    }

    AppPage {
        heading: "Máy tính"
        caption: "Tính toán nhanh, tập trung vào điều quan trọng."
        Flickable {
            anchors.fill: parent
            clip: true
            contentWidth: width
            contentHeight: pad.height + 22
            boundsBehavior: Flickable.StopAtBounds
            Column {
                id: pad
                x: Math.max(0, (parent.width - width) / 2)
                width: Math.min(parent.width, 440)
                spacing: 13
                SurfaceCard {
                    width: parent.width
                    height: 111
                    Column {
                        anchors.fill: parent
                        anchors.margins: 17
                        spacing: 12
                        Text {
                            text: calc.operation ? calc.formatNumber(calc.stored) + "  " + calc.operation : "KẾT QUẢ"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1
                            color: System.Theme.muted
                        }
                        Text {
                            width: parent.width
                            text: calc.display
                            font.pixelSize: calc.display.length > 14 ? 23 : 36
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideLeft
                            color: calc.invalid ? System.Theme.danger : System.Theme.ink
                        }
                    }
                }
                Grid {
                    id: keys
                    width: parent.width
                    columns: 4
                    spacing: 9
                    Repeater {
                        model: [
                            {k:"AC", kind:"tool"}, {k:"±", kind:"tool"}, {k:"%", kind:"tool"}, {k:"÷", kind:"op"},
                            {k:"7", kind:"num"}, {k:"8", kind:"num"}, {k:"9", kind:"num"}, {k:"×", kind:"op"},
                            {k:"4", kind:"num"}, {k:"5", kind:"num"}, {k:"6", kind:"num"}, {k:"−", kind:"op"},
                            {k:"1", kind:"num"}, {k:"2", kind:"num"}, {k:"3", kind:"num"}, {k:"+", kind:"op"},
                            {k:"⌫", kind:"tool"}, {k:"0", kind:"num"}, {k:".", kind:"num"}, {k:"=", kind:"equal"}
                        ]
                        delegate: Button {
                            id: keyButton
                            required property var modelData
                            width: (keys.width - keys.spacing * 3) / 4
                            height: 51
                            hoverEnabled: true
                            focusPolicy: Qt.StrongFocus
                            onClicked: calc.press(modelData.k)
                            background: Rectangle {
                                radius: 15
                                color: keyButton.modelData.kind === "equal" ? System.Theme.accent :
                                       keyButton.modelData.kind === "op" ? System.Theme.accentSoft :
                                       keyButton.modelData.kind === "tool" ? "#E1E7F1" : "#FFFFFF"
                                border.width: 1
                                border.color: keyButton.modelData.kind === "equal" ? System.Theme.accent :
                                              System.Theme.subtleLine
                                opacity: keyButton.down ? 0.72 : 1
                                Behavior on opacity { NumberAnimation { duration: System.Theme.durationQuick } }
                            }
                            contentItem: Text {
                                text: keyButton.modelData.k
                                color: keyButton.modelData.kind === "equal" ? "#FFFFFF" :
                                       keyButton.modelData.kind === "op" ? System.Theme.accent : System.Theme.ink
                                font.pixelSize: keyButton.modelData.kind === "num" ? 20 : 16
                                font.weight: Font.Medium
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }
    Keys.onPressed: function(event) {
        var value = event.text
        if (value.length === 1 && "0123456789.".indexOf(value) >= 0) calc.press(value)
        else if (value === "+" || value === "-") calc.press(value === "-" ? "−" : value)
        else if (value === "*" || value === "/") calc.press(value === "*" ? "×" : "÷")
        else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) calc.press("=")
        else if (event.key === Qt.Key_Backspace) calc.press("⌫")
        else if (event.key === Qt.Key_Escape) calc.press("AC")
        else return
        event.accepted = true
    }
}
