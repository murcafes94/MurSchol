import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var appModel
    property var searchModel
    property var backend
    signal closeRequested()

    width: Math.min(840, parent ? parent.width - 80 : 840)
    height: 570
    radius: 28
    color: "#f0142531"
    border.color: "#3a5e6e"

    onVisibleChanged: {
        if (visible) {
            search.text = ""
            search.forceActiveFocus()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Inicio"; color: "white"; font.pixelSize: 27; font.bold: true }
            Item { Layout.fillWidth: true }
            Label { text: "Un escritorio, tres ecosistemas"; color: "#7da2b1"; font.pixelSize: 12 }
            Button {
                text: "×"
                onClicked: root.closeRequested()
                flat: true
                contentItem: Label {
                    text: parent.text; color: "white"; font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        TextField {
            id: search
            Layout.fillWidth: true
            placeholderText: "Buscar aplicaciones, documentos o acciones…"
            color: "white"
            placeholderTextColor: "#78909b"
            leftPadding: 16
            rightPadding: 16
            background: Rectangle {
                radius: 15
                color: "#182d38"
                border.color: search.activeFocus ? "#2ad6d0" : "#355466"
            }
            onTextChanged: {
                root.appModel.filter = text
                root.searchModel.query = text
            }
            Keys.onReturnPressed: {
                if (text.trim().length >= 2 && root.searchModel.count > 0) {
                    root.searchModel.activate(0)
                    root.closeRequested()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: search.text.trim().length >= 2 ? "Búsqueda universal" : "Aplicaciones"
                color: "#aec3cc"
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Label {
                visible: search.text.trim().length >= 2
                text: "Apps · documentos · acciones"
                color: "#647f8c"
                font.pixelSize: 10
            }
        }

        GridView {
            id: grid
            visible: search.text.trim().length < 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 150
            cellHeight: 102
            clip: true
            model: root.appModel

            delegate: Button {
                width: 138
                height: 90
                icon.name: iconName
                icon.width: 28
                icon.height: 28
                text: appName
                onClicked: {
                    root.appModel.launch(index)
                    root.closeRequested()
                }
                background: Rectangle {
                    radius: 17
                    color: parent.hovered ? "#284c5d" : "#1b3440"
                    border.color: "#345768"
                }
                contentItem: Column {
                    anchors.centerIn: parent
                    spacing: 7
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: appName.substring(0, 1)
                        visible: iconName.length === 0
                        color: "#56e1da"
                        font.pixelSize: 22
                        font.bold: true
                    }
                    Label {
                        width: 116
                        text: appName
                        color: "white"
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 12
                    }
                    Label {
                        width: 116
                        text: appSource
                        color: "#7995a2"
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 10
                    }
                }
            }
        }

        Item {
            visible: search.text.trim().length >= 2
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: results
                anchors.fill: parent
                clip: true
                spacing: 8
                model: root.searchModel

                delegate: Button {
                    width: results.width
                    height: 70
                    onClicked: {
                        root.searchModel.activate(index)
                        root.closeRequested()
                    }
                    background: Rectangle {
                        radius: 15
                        color: parent.hovered ? "#254653" : "#192f3a"
                        border.color: parent.hovered ? "#3b7687" : "#294958"
                    }
                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 12
                            color: resultKind === "Aplicación" ? "#174957" : (resultKind === "Documento" ? "#263e5a" : "#254339")
                            Label {
                                anchors.centerIn: parent
                                text: resultKind === "Aplicación" ? "A" : (resultKind === "Documento" ? "D" : "→")
                                color: resultKind === "Aplicación" ? "#65e3dc" : (resultKind === "Documento" ? "#9fc8ff" : "#92e0af")
                                font.bold: true
                                font.pixelSize: 16
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label {
                                Layout.fillWidth: true
                                text: resultTitle
                                color: "white"
                                font.bold: true
                                font.pixelSize: 13
                                elide: Text.ElideRight
                            }
                            Label {
                                Layout.fillWidth: true
                                text: resultSubtitle
                                color: "#7f99a5"
                                font.pixelSize: 10
                                elide: Text.ElideMiddle
                            }
                        }

                        Rectangle {
                            width: kindLabel.implicitWidth + 16
                            height: 26
                            radius: 13
                            color: "#203843"
                            Label {
                                id: kindLabel
                                anchors.centerIn: parent
                                text: resultKind
                                color: "#9eb8c3"
                                font.pixelSize: 9
                            }
                        }
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                visible: root.searchModel.count === 0
                text: "No encontramos resultados locales."
                color: "#708a95"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: search.text.trim().length >= 2
                      ? root.searchModel.count + " resultados"
                      : root.appModel.count + " aplicaciones"
                color: "#78909c"
                font.pixelSize: 11
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Actualizar índice"
                visible: search.text.trim().length >= 2
                onClicked: root.searchModel.refreshIndexes()
            }
            Button {
                text: "Archivos"
                onClicked: {
                    backend.openFiles()
                    root.closeRequested()
                }
            }
            Button { text: "Apagar"; onClicked: backend.powerOff() }
        }
    }
}
