import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    signal openDocumentRequested(string title)

    Rectangle {
        anchors.fill: parent
        color: "#081521"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 16

        Rectangle {
            Layout.preferredWidth: 180
            Layout.fillHeight: true
            radius: 22
            color: "#0e2230"
            border.color: "#23485b"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Label {
                    text: "MurSchol Reader"
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.leftMargin: 8
                    Layout.topMargin: 6
                }
                Label {
                    text: "Biblioteca personal de estudio"
                    color: "#6f909e"
                    font.pixelSize: 9
                    Layout.leftMargin: 8
                    Layout.bottomMargin: 12
                }

                Repeater {
                    model: ["Inicio", "Recientes", "Favoritos", "Colecciones", "Autores", "Etiquetas"]
                    delegate: Button {
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        text: modelData
                        background: Rectangle {
                            radius: 12
                            color: modelData === "Inicio" ? "#17465f" : (parent.hovered ? "#173443" : "transparent")
                        }
                        contentItem: Label {
                            text: parent.text
                            color: modelData === "Inicio" ? "#dffcff" : "#b9cbd2"
                            font.pixelSize: 11
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 8
                        }
                    }
                }

                Item { Layout.fillHeight: true }
                Label {
                    Layout.fillWidth: true
                    text: "PDF · EPUB · MOBI · AZW3 · FB2 · CBZ"
                    color: "#5f7c88"
                    font.pixelSize: 8
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Biblioteca"
                    color: "white"
                    font.pixelSize: 26
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                TextField {
                    Layout.preferredWidth: Math.min(420, parent.width * 0.45)
                    placeholderText: "Buscar libros, autores o colecciones"
                    color: "white"
                    placeholderTextColor: "#6f8e9b"
                    background: Rectangle {
                        radius: 16
                        color: "#102735"
                        border.color: "#31586b"
                    }
                }
            }

            Label {
                text: "Continuar leyendo"
                color: "#d7e8ee"
                font.pixelSize: 14
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 122
                radius: 20
                color: "#102a39"
                border.color: "#285367"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 14

                    Rectangle {
                        width: 70
                        height: 92
                        radius: 8
                        color: "#ede7d6"
                        Column {
                            anchors.centerIn: parent
                            spacing: 8
                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "DONUM"; color: "#34322c"; font.bold: true; font.pixelSize: 10 }
                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "VITAE"; color: "#34322c"; font.bold: true; font.pixelSize: 10 }
                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "✦"; color: "#62865d"; font.pixelSize: 18 }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        Label { text: "Donum Vitae"; color: "white"; font.pixelSize: 16; font.bold: true }
                        Label { text: "Congregación para la Doctrina de la Fe · PDF"; color: "#86a0ab"; font.pixelSize: 9 }
                        ProgressBar { Layout.fillWidth: true; value: 0.67 }
                        Label { text: "67 % leído"; color: "#7ddfd8"; font.pixelSize: 9 }
                    }

                    Button {
                        text: "Continuar leyendo"
                        onClicked: root.openDocumentRequested("Donum Vitae.pdf")
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label { text: "Mi biblioteca"; color: "#d7e8ee"; font.pixelSize: 14; font.bold: true }
                Item { Layout.fillWidth: true }
                ComboBox { model: ["Todos los libros", "PDF", "eBooks", "Favoritos"] }
            }

            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: 145
                cellHeight: 205
                model: [
                    {title:"Evangelium Vitae", author:"San Juan Pablo II", kind:"PDF"},
                    {title:"Patrología", author:"Varios autores", kind:"PDF"},
                    {title:"Cristología", author:"Varios autores", kind:"EPUB"},
                    {title:"Mundo y Persona", author:"Karol Wojtyła", kind:"PDF"},
                    {title:"Código de Derecho Canónico", author:"Iglesia Católica", kind:"PDF"},
                    {title:"Confesiones", author:"San Agustín", kind:"EPUB"}
                ]

                delegate: Button {
                    required property var modelData
                    width: 132
                    height: 190
                    onClicked: root.openDocumentRequested(modelData.title + "." + modelData.kind.toLowerCase())
                    background: Rectangle {
                        radius: 16
                        color: parent.hovered ? "#17394a" : "#0d2230"
                        border.color: parent.hovered ? "#3d7185" : "#254758"
                    }
                    contentItem: ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 84
                            Layout.preferredHeight: 118
                            radius: 8
                            color: "#1b4052"
                            border.color: "#3b7084"
                            Label {
                                anchors.centerIn: parent
                                width: parent.width - 14
                                text: modelData.title
                                color: "#edf8fa"
                                font.bold: true
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.Wrap
                            }
                        }
                        Label { Layout.fillWidth: true; text: modelData.author; color: "#829da8"; font.pixelSize: 8; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter }
                        Label { Layout.fillWidth: true; text: modelData.kind; color: "#55d7cf"; font.pixelSize: 8; horizontalAlignment: Text.AlignHCenter }
                    }
                }
            }
        }
    }
}
