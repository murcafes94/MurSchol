import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholCapture 1.0

ApplicationWindow {
    id: root
    width: 560
    height: 330
    minimumWidth: 520
    minimumHeight: 300
    visible: true
    title: "MurSchol Capture"
    color: "#0B0E12"

    palette.window: "#0B0E12"
    palette.windowText: "#F3EEE5"
    palette.base: "#171B21"
    palette.text: "#F3EEE5"
    palette.button: "#1E2025"
    palette.buttonText: "#F3EEE5"
    palette.highlight: "#D6A85F"
    palette.highlightedText: "#201B17"

    CaptureBackend { id: capture }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                width: 42
                height: 42
                radius: 13
                color: "#49352B"
                border.color: "#D6A85F"
                Label {
                    anchors.centerIn: parent
                    text: "▣"
                    color: "#D6A85F"
                    font.pixelSize: 15
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Label {
                    text: "MurSchol Capture"
                    color: "#F3EEE5"
                    font.pixelSize: 21
                    font.bold: true
                }
                Label {
                    text: "Captura rápido, edita solo cuando lo necesites"
                    color: "#A79E94"
                    font.pixelSize: 10
                }
            }

            ComboBox {
                id: delayBox
                model: ["Sin espera", "3 s", "5 s", "10 s"]
                Layout.preferredWidth: 125
                property var seconds: [0, 3, 5, 10]
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Button {
                id: regionButton
                Layout.fillWidth: true
                Layout.fillHeight: true
                enabled: !capture.busy
                text: "▱\nSeleccionar área\nSuper + Shift + S"
                font.pixelSize: 14
                onClicked: capture.captureRegion(delayBox.seconds[delayBox.currentIndex])
                background: Rectangle {
                    radius: 18
                    color: regionButton.down ? "#49352B" : (regionButton.hovered ? "#24211D" : "#171B21")
                    border.width: 1
                    border.color: regionButton.hovered ? "#D6A85F" : "#35312D"
                }
                contentItem: Label {
                    text: regionButton.text
                    color: "#F3EEE5"
                    font.pixelSize: regionButton.font.pixelSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: screenButton
                Layout.fillWidth: true
                Layout.fillHeight: true
                enabled: !capture.busy
                text: "▣\nPantalla completa\nPrint Screen"
                font.pixelSize: 14
                onClicked: capture.captureScreen(delayBox.seconds[delayBox.currentIndex])
                background: Rectangle {
                    radius: 18
                    color: screenButton.down ? "#49352B" : (screenButton.hovered ? "#24211D" : "#171B21")
                    border.width: 1
                    border.color: screenButton.hovered ? "#D6A85F" : "#35312D"
                }
                contentItem: Label {
                    text: screenButton.text
                    color: "#F3EEE5"
                    font.pixelSize: screenButton.font.pixelSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 58
            radius: 16
            color: "#15181D"
            border.color: "#35312D"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 10
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Label {
                        Layout.fillWidth: true
                        text: capture.message.length ? capture.message : "Las capturas se guardan en Imágenes/Capturas de pantalla"
                        color: capture.busy ? "#D6A85F" : "#C9C0B6"
                        font.pixelSize: 10
                        elide: Text.ElideMiddle
                    }
                    Label {
                        Layout.fillWidth: true
                        visible: capture.lastCapture.length > 0
                        text: capture.lastCapture
                        color: "#7F766D"
                        font.pixelSize: 8
                        elide: Text.ElideMiddle
                    }
                }

                Button {
                    text: "Editar"
                    enabled: capture.lastCapture.length > 0 && !capture.busy
                    onClicked: capture.editLast()
                }
                Button {
                    text: "Abrir carpeta"
                    enabled: !capture.busy
                    onClicked: capture.openCaptureFolder()
                }
            }
        }
    }
}
