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
    color: "#08141d"

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
                color: "#123347"
                border.color: "#285d73"
                Label {
                    anchors.centerIn: parent
                    text: "MS"
                    color: "#73eae3"
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Label {
                    text: "MurSchol Capture"
                    color: "#f4f8fa"
                    font.pixelSize: 21
                    font.bold: true
                }
                Label {
                    text: "Captura rápido, edita solo cuando lo necesites"
                    color: "#7897a6"
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
                Layout.fillWidth: true
                Layout.fillHeight: true
                enabled: !capture.busy
                text: "▱\nSeleccionar área\nSuper + Shift + S"
                font.pixelSize: 14
                onClicked: capture.captureRegion(delayBox.seconds[delayBox.currentIndex])
            }

            Button {
                Layout.fillWidth: true
                Layout.fillHeight: true
                enabled: !capture.busy
                text: "▣\nPantalla completa\nPrint Screen"
                font.pixelSize: 14
                onClicked: capture.captureScreen(delayBox.seconds[delayBox.currentIndex])
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 58
            radius: 16
            color: "#0e2431"
            border.color: "#234657"

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
                        color: capture.busy ? "#72e5df" : "#c8d8de"
                        font.pixelSize: 10
                        elide: Text.ElideMiddle
                    }
                    Label {
                        Layout.fillWidth: true
                        visible: capture.lastCapture.length > 0
                        text: capture.lastCapture
                        color: "#637f8c"
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
