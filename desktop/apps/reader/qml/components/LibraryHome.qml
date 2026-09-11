import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    signal browseRequested()

    Rectangle {
        anchors.fill: parent
        color: "#0B0E12"
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 72, 760)
        spacing: 18

        Label {
            Layout.fillWidth: true
            text: "MurSchol Reader"
            color: "#F3EEE5"
            font.pixelSize: 30
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            Layout.fillWidth: true
            text: "Lectura PDF integrada para estudio"
            color: "#A79E94"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            radius: 26
            color: "#171B21"
            border.color: "#51463B"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32
                spacing: 14

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 74
                    height: 74
                    radius: 22
                    color: "#49352B"

                    Label {
                        anchors.centerIn: parent
                        text: "PDF"
                        color: "#E3BB78"
                        font.pixelSize: 19
                        font.bold: true
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: "Abre un documento PDF"
                    color: "#F3EEE5"
                    font.pixelSize: 20
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    Layout.fillWidth: true
                    text: "Puedes elegir un archivo o arrastrarlo directamente a esta ventana. Reader usa el motor PDF de Qt para renderizar páginas reales, buscar texto y navegar por el índice del documento."
                    color: "#C9C0B6"
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 190
                    Layout.preferredHeight: 44
                    text: "Abrir PDF"
                    onClicked: root.browseRequested()
                    background: Rectangle {
                        radius: 13
                        color: parent.hovered ? "#E3BB78" : "#D6A85F"
                    }
                    contentItem: Label {
                        text: parent.text
                        color: "#15120F"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: [
                    { title: "Multipágina", text: "Desplázate por todo el documento sin cargar una interfaz falsa." },
                    { title: "Búsqueda real", text: "Busca texto dentro del PDF y salta entre coincidencias." },
                    { title: "Modo estudio", text: "Zoom, índice y concentración sin paneles permanentes." }
                ]

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 112
                    radius: 18
                    color: "#11151C"
                    border.color: "#35312D"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 6

                        Label {
                            Layout.fillWidth: true
                            text: modelData.title
                            color: "#E3BB78"
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Label {
                            Layout.fillWidth: true
                            text: modelData.text
                            color: "#A79E94"
                            font.pixelSize: 9
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: "EPUB, MOBI y otros formatos se añadirán cuando tengan un motor real; no se muestran como disponibles antes de tiempo."
            color: "#7F766D"
            font.pixelSize: 9
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
