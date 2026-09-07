import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholMusic 1.0

ApplicationWindow {
    id: root
    width: 1240
    height: 760
    minimumWidth: 860
    minimumHeight: 560
    visible: true
    title: "MurSchol Music"
    color: "#07131d"

    property int activeSource: 0
    property string activeSection: "Inicio"

    MusicLibraryModel {
        id: library
    }

    ListModel {
        id: sourceModel
        ListElement { title: "Este dispositivo"; subtitle: "Música local"; stateText: "Disponible"; enabledNow: true }
        ListElement { title: "Mi servidor"; subtitle: "OpenSubsonic / Navidrome"; stateText: "Por configurar"; enabledNow: false }
        ListElement { title: "Radio"; subtitle: "Emisoras por Internet"; stateText: "Próxima fase"; enabledNow: false }
        ListElement { title: "Servicios"; subtitle: "Proveedores y plugins"; stateText: "Próxima fase"; enabledNow: false }
    }

    Rectangle {
        anchors.fill: parent
        color: "#07131d"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 238
            Layout.fillHeight: true
            color: "#0a1a25"
            border.width: 1
            border.color: "#15303e"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 12
                        color: "#12384a"
                        Label {
                            anchors.centerIn: parent
                            text: "♫"
                            color: "#69e6de"
                            font.pixelSize: 18
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label {
                            text: "MurSchol Music"
                            color: "#f3f8fa"
                            font.pixelSize: 15
                            font.bold: true
                        }
                        Label {
                            text: "Biblioteca musical universal"
                            color: "#6e8d9b"
                            font.pixelSize: 9
                        }
                    }
                }

                Item { Layout.preferredHeight: 6 }

                Repeater {
                    model: ["Inicio", "Buscar", "Canciones", "Álbumes", "Artistas", "Listas", "Favoritos"]
                    delegate: Button {
                        required property string modelData
                        Layout.fillWidth: true
                        text: modelData
                        checkable: true
                        checked: root.activeSection === modelData
                        onClicked: root.activeSection = modelData
                    }
                }

                Item { Layout.preferredHeight: 10 }

                Label {
                    text: "FUENTES"
                    color: "#557582"
                    font.pixelSize: 9
                    font.bold: true
                }

                ListView {
                    id: sources
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, 248)
                    model: sourceModel
                    spacing: 6
                    interactive: contentHeight > height

                    delegate: Rectangle {
                        required property int index
                        required property string title
                        required property string subtitle
                        required property string stateText
                        required property bool enabledNow

                        width: sources.width
                        height: 58
                        radius: 12
                        color: root.activeSource === index ? "#123447" : "#0d2230"
                        border.width: root.activeSource === index ? 1 : 0
                        border.color: "#2a6276"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.activeSource = index
                        }

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 24
                            spacing: 2
                            Label {
                                width: parent.width
                                text: title
                                color: "#eef5f7"
                                font.pixelSize: 11
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Label {
                                width: parent.width
                                text: subtitle + " · " + stateText
                                color: enabledNow ? "#67cfc8" : "#657f8b"
                                font.pixelSize: 8
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Label {
                    Layout.fillWidth: true
                    text: "El audio se reproduce con MurSchol Media/libmpv."
                    wrapMode: Text.WordWrap
                    color: "#557582"
                    font.pixelSize: 9
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 72
                color: "#091923"
                border.width: 1
                border.color: "#15303e"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 22
                    anchors.rightMargin: 22
                    spacing: 14

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Label {
                            text: root.activeSection
                            color: "#f4f8fa"
                            font.pixelSize: 22
                            font.bold: true
                        }
                        Label {
                            text: root.activeSource === 0 ? (library.scanning ? "Explorando tu carpeta Música…" : library.count + " canciones locales") : sourceModel.get(root.activeSource).subtitle
                            color: "#6f8c99"
                            font.pixelSize: 10
                        }
                    }

                    TextField {
                        id: searchField
                        Layout.preferredWidth: 320
                        visible: root.activeSource === 0
                        placeholderText: "Buscar canciones, artistas o álbumes"
                        text: library.query
                        onTextChanged: library.query = text
                    }

                    Button {
                        text: "Actualizar"
                        visible: root.activeSource === 0
                        enabled: !library.scanning
                        onClicked: library.refresh()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#07131d"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 16

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 118
                        radius: 20
                        visible: root.activeSource === 0
                        color: "#0d2634"
                        border.width: 1
                        border.color: "#1d4658"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 16

                            Rectangle {
                                width: 74
                                height: 74
                                radius: 18
                                color: "#12394c"
                                Label {
                                    anchors.centerIn: parent
                                    text: "♫"
                                    color: "#67e4dc"
                                    font.pixelSize: 30
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Label {
                                    text: "Tu música, sin depender de Internet"
                                    color: "#f1f7f9"
                                    font.pixelSize: 17
                                    font.bold: true
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: "MurSchol Music indexa la carpeta Música en segundo plano y conserva los archivos donde están."
                                    wrapMode: Text.WordWrap
                                    color: "#7f9eaa"
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }

                    ListView {
                        id: trackList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.activeSource === 0
                        clip: true
                        model: library
                        spacing: 6

                        delegate: Rectangle {
                            required property int index
                            required property string title
                            required property string artist
                            required property string album
                            required property string format
                            required property string path

                            width: trackList.width
                            height: 62
                            radius: 12
                            color: hoverArea.containsMouse ? "#102b39" : "#0a202c"

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onDoubleClicked: library.play(index)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                Button {
                                    text: "▶"
                                    width: 38
                                    onClicked: library.play(index)
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Label {
                                        Layout.fillWidth: true
                                        text: title
                                        color: "#f0f6f8"
                                        font.pixelSize: 12
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }
                                    Label {
                                        Layout.fillWidth: true
                                        text: artist + (album.length > 0 ? " · " + album : "")
                                        color: "#718e9b"
                                        font.pixelSize: 9
                                        elide: Text.ElideRight
                                    }
                                }

                                Label {
                                    text: format
                                    color: "#5fc8c1"
                                    font.pixelSize: 9
                                }
                            }
                        }

                        footer: Item {
                            width: trackList.width
                            height: library.count === 0 ? 120 : 16
                            Label {
                                anchors.centerIn: parent
                                visible: library.count === 0 && !library.scanning
                                text: searchField.text.length > 0 ? "No hay coincidencias" : "Aún no hay música en tu carpeta Música"
                                color: "#6f8c99"
                                font.pixelSize: 11
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.activeSource !== 0
                        radius: 20
                        color: "#0b2330"
                        border.width: 1
                        border.color: "#1a4051"

                        ColumnLayout {
                            anchors.centerIn: parent
                            width: Math.min(520, parent.width - 60)
                            spacing: 12

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: sourceModel.get(root.activeSource).title
                                color: "#f3f8fa"
                                font.pixelSize: 26
                                font.bold: true
                            }
                            Label {
                                Layout.fillWidth: true
                                text: sourceModel.get(root.activeSource).subtitle
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                color: "#87a3af"
                                font.pixelSize: 12
                            }
                            Label {
                                Layout.fillWidth: true
                                text: root.activeSource === 1
                                      ? "La integración prevista usará OpenSubsonic para conectarse a servidores personales como Navidrome."
                                      : root.activeSource === 2
                                        ? "La radio se añadirá como proveedor independiente para no afectar a la biblioteca local."
                                        : "Los servicios externos se implementarán como proveedores/plugins aislados del núcleo de MurSchol Music."
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                                color: "#607f8d"
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }
    }
}
