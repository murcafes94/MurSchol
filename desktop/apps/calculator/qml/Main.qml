import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 980
    height: 680
    minimumWidth: 760
    minimumHeight: 560
    visible: true
    title: "MurSchol Calculator"
    color: "#08141d"

    property string mode: "standard"
    property bool historyOpen: true
    property var unitSets: ({
        "Longitud": ["mm", "cm", "m", "km", "in", "ft", "yd", "mi"],
        "Masa": ["mg", "g", "kg", "oz", "lb"],
        "Temperatura": ["degC", "degF", "K"],
        "Velocidad": ["m/s", "km/h", "mph"],
        "Área": ["cm^2", "m^2", "km^2", "ft^2"],
        "Tiempo": ["s", "min", "h", "day"],
        "Almacenamiento": ["B", "kB", "MB", "GB", "TB", "KiB", "MiB", "GiB"]
    })

    function appendToken(token) {
        expression.forceActiveFocus()
        const start = expression.selectionStart
        const end = expression.selectionEnd
        const before = expression.text.slice(0, start)
        const after = expression.text.slice(end)
        expression.text = before + token + after
        expression.cursorPosition = start + token.length
    }

    function backspaceToken() {
        if (expression.selectionStart !== expression.selectionEnd) {
            const start = expression.selectionStart
            const end = expression.selectionEnd
            expression.text = expression.text.slice(0, start) + expression.text.slice(end)
            expression.cursorPosition = start
        } else if (expression.cursorPosition > 0) {
            const pos = expression.cursorPosition
            expression.text = expression.text.slice(0, pos - 1) + expression.text.slice(pos)
            expression.cursorPosition = pos - 1
        }
        expression.forceActiveFocus()
    }

    function calculateCurrent() {
        calculatorBackend.evaluate(expression.text)
    }

    Shortcut { sequence: "Ctrl+L"; onActivated: expression.selectAll() }
    Shortcut { sequence: "Ctrl+H"; onActivated: root.historyOpen = !root.historyOpen }
    Shortcut { sequence: "Escape"; onActivated: expression.clear() }

    header: Rectangle {
        height: 58
        color: "#0d202c"
        border.color: "#1c3a4a"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 8

            Label {
                text: "MurSchol Calculator"
                color: "#f2f7f8"
                font.bold: true
                font.pixelSize: 16
                Layout.fillWidth: true
            }

            ToolButton {
                text: "Historial"
                checkable: true
                checked: root.historyOpen
                onClicked: root.historyOpen = !root.historyOpen
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#08141d"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: [
                            {label: "Estándar", value: "standard"},
                            {label: "Científica", value: "scientific"},
                            {label: "Convertir", value: "convert"},
                            {label: "Programador", value: "programmer"}
                        ]
                        delegate: Button {
                            required property var modelData
                            text: modelData.label
                            checkable: true
                            checked: root.mode === modelData.value
                            onClicked: root.mode = modelData.value
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.mode === "convert" ? 150 : 134
                    radius: 18
                    color: "#0d202c"
                    border.color: "#244655"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8

                        TextField {
                            id: expression
                            Layout.fillWidth: true
                            visible: root.mode !== "convert"
                            placeholderText: root.mode === "programmer" ? "Ej. 255, 0xFF, 0b1010, 5 << 2" : "Escribe una expresión…"
                            color: "#eaf4f6"
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignRight
                            selectByMouse: true
                            onAccepted: root.calculateCurrent()
                            background: Rectangle { color: "transparent" }
                        }

                        Label {
                            visible: root.mode !== "convert"
                            Layout.fillWidth: true
                            text: calculatorBackend.result.length ? calculatorBackend.result : "0"
                            color: "#ffffff"
                            font.pixelSize: 30
                            font.bold: true
                            horizontalAlignment: Text.AlignRight
                            elide: Text.ElideLeft
                        }

                        RowLayout {
                            visible: root.mode !== "convert"
                            Layout.fillWidth: true
                            Label {
                                text: calculatorBackend.errorText
                                color: "#ff9d9d"
                                font.pixelSize: 10
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Button {
                                text: "Copiar"
                                enabled: calculatorBackend.result.length > 0
                                onClicked: calculatorBackend.copyResult()
                            }
                        }

                        ColumnLayout {
                            visible: root.mode === "convert"
                            Layout.fillWidth: true
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                ComboBox {
                                    id: categoryBox
                                    Layout.preferredWidth: 150
                                    model: ["Longitud", "Masa", "Temperatura", "Velocidad", "Área", "Tiempo", "Almacenamiento"]
                                }
                                TextField {
                                    id: conversionValue
                                    Layout.fillWidth: true
                                    placeholderText: "Valor"
                                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                ComboBox {
                                    id: fromUnit
                                    Layout.fillWidth: true
                                    model: root.unitSets[categoryBox.currentText] || []
                                }
                                Label { text: "→"; color: "#73e0da"; font.pixelSize: 20 }
                                ComboBox {
                                    id: toUnit
                                    Layout.fillWidth: true
                                    model: root.unitSets[categoryBox.currentText] || []
                                    Component.onCompleted: currentIndex = Math.min(1, count - 1)
                                }
                                Button {
                                    text: "Convertir"
                                    onClicked: calculatorBackend.convert(conversionValue.text, fromUnit.currentText, toUnit.currentText)
                                }
                            }

                            Label {
                                Layout.fillWidth: true
                                text: calculatorBackend.result.length ? calculatorBackend.result : "Resultado"
                                color: "#ffffff"
                                font.pixelSize: 24
                                font.bold: true
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }

                RowLayout {
                    visible: root.mode === "scientific"
                    Layout.fillWidth: true
                    spacing: 6
                    Label { text: "Ángulo"; color: "#7f9aa5" }
                    Button {
                        text: "DEG"
                        checkable: true
                        checked: calculatorBackend.degreeMode
                        onClicked: calculatorBackend.degreeMode = true
                    }
                    Button {
                        text: "RAD"
                        checkable: true
                        checked: !calculatorBackend.degreeMode
                        onClicked: calculatorBackend.degreeMode = false
                    }
                    Item { Layout.fillWidth: true }
                    Label { text: "π y e están disponibles como constantes"; color: "#607f8c"; font.pixelSize: 10 }
                }

                GridLayout {
                    visible: root.mode === "scientific"
                    Layout.fillWidth: true
                    columns: 7
                    rowSpacing: 6
                    columnSpacing: 6

                    Repeater {
                        model: ["sin(", "cos(", "tan(", "asin(", "acos(", "atan(", "sqrt(", "log(", "ln(", "^2", "^", "!", "pi", "e"]
                        delegate: Button {
                            required property string modelData
                            Layout.fillWidth: true
                            text: modelData
                            onClicked: root.appendToken(modelData)
                        }
                    }
                }

                RowLayout {
                    visible: root.mode === "programmer"
                    Layout.fillWidth: true
                    spacing: 6
                    Label { text: "Salida"; color: "#7f9aa5" }
                    Repeater {
                        model: ["BIN", "OCT", "DEC", "HEX"]
                        delegate: Button {
                            required property string modelData
                            text: modelData
                            onClicked: calculatorBackend.formatBase(expression.text, modelData)
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        text: "Usa 0x para hexadecimal y 0b para binario en la entrada"
                        color: "#607f8c"
                        font.pixelSize: 10
                    }
                }

                GridLayout {
                    visible: root.mode !== "convert"
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 4
                    rowSpacing: 8
                    columnSpacing: 8

                    Repeater {
                        model: [
                            {label: "C", token: "clear"}, {label: "(", token: "("}, {label: ")", token: ")"}, {label: "⌫", token: "back"},
                            {label: "7", token: "7"}, {label: "8", token: "8"}, {label: "9", token: "9"}, {label: "÷", token: "/"},
                            {label: "4", token: "4"}, {label: "5", token: "5"}, {label: "6", token: "6"}, {label: "×", token: "*"},
                            {label: "1", token: "1"}, {label: "2", token: "2"}, {label: "3", token: "3"}, {label: "−", token: "-"},
                            {label: "0", token: "0"}, {label: ".", token: "."}, {label: "%", token: "%"}, {label: "+", token: "+"},
                            {label: "ANS", token: "ans"}, {label: "=", token: "equals"}
                        ]
                        delegate: Button {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.columnSpan: modelData.token === "equals" ? 3 : 1
                            text: modelData.label
                            font.pixelSize: 17
                            onClicked: {
                                if (modelData.token === "clear")
                                    expression.clear()
                                else if (modelData.token === "back")
                                    root.backspaceToken()
                                else if (modelData.token === "equals")
                                    root.calculateCurrent()
                                else if (modelData.token === "ans")
                                    root.appendToken(calculatorBackend.result)
                                else
                                    root.appendToken(modelData.token)
                            }
                        }
                    }
                }

                Label {
                    visible: root.mode === "standard"
                    Layout.fillWidth: true
                    text: "También puedes escribir directamente expresiones y conversiones, por ejemplo: 2 kg * 9.81 m/s^2"
                    color: "#567682"
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
            }
        }

        Rectangle {
            visible: root.historyOpen
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: "#0b1b25"
            border.color: "#1e3d4b"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: "Historial"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                        Layout.fillWidth: true
                    }
                    ToolButton {
                        text: "Borrar"
                        enabled: calculatorBackend.history.length > 0
                        onClicked: calculatorBackend.clearHistory()
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    model: calculatorBackend.history
                    delegate: Rectangle {
                        required property string modelData
                        width: ListView.view.width
                        height: historyText.implicitHeight + 20
                        radius: 10
                        color: "#102633"
                        border.color: "#203f4d"

                        Label {
                            id: historyText
                            anchors.fill: parent
                            anchors.margins: 10
                            text: modelData
                            color: "#cfe0e5"
                            wrapMode: Text.WrapAnywhere
                            font.pixelSize: 11
                        }
                    }

                    Label {
                        anchors.centerIn: parent
                        visible: calculatorBackend.history.length === 0
                        text: "Tus cálculos aparecerán aquí"
                        color: "#5e7b87"
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
