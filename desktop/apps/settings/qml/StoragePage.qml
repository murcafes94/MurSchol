import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var backend
    property bool lightTheme: false
    property color accent: "#29d9d1"
    spacing: 14

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: systemColumn.implicitHeight + 34
        radius: 18
        color: lightTheme ? "#f8fbfc" : "#0d202b"
        border.color: lightTheme ? "#d7e2e6" : "#234454"

        ColumnLayout {
            id: systemColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 17
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Rectangle {
                    width: 48
                    height: 48
                    radius: 15
                    color: lightTheme ? "#dcefed" : "#123d49"
                    Label { anchors.centerIn: parent; text: "▤"; color: root.accent; font.pixelSize: 22; font.bold: true }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Label { text: "Almacenamiento del sistema"; color: lightTheme ? "#17303a" : "#f1f6f8"; font.pixelSize: 17; font.bold: true }
                    Label {
                        text: backend.rootUsedText + " usados de " + backend.rootTotalText + " · " + backend.rootFreeText + " libres"
                        color: lightTheme ? "#657983" : "#7f9aa6"
                        font.pixelSize: 9
                    }
                }
                Button { text: "Actualizar"; onClicked: backend.refresh() }
            }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: backend.rootUsedPercent
                background: Rectangle { implicitHeight: 8; radius: 4; color: lightTheme ? "#dfe8eb" : "#17313c" }
                contentItem: Item {
                    implicitHeight: 8
                    Rectangle {
                        width: parent.width * (backend.rootUsedPercent / 100)
                        height: parent.height
                        radius: 4
                        color: root.accent
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: cleanupColumn.implicitHeight + 34
        radius: 18
        color: lightTheme ? "#f8fbfc" : "#0d202b"
        border.color: lightTheme ? "#d7e2e6" : "#234454"

        ColumnLayout {
            id: cleanupColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 17
            spacing: 11

            Label { text: "Limpieza segura"; color: lightTheme ? "#19323c" : "#f0f6f8"; font.pixelSize: 13; font.bold: true }
            Label {
                text: "MurSchol solo limpia datos regenerables o elementos que tú ya enviaste a la papelera. No borra documentos personales ni cachés generales de otras aplicaciones."
                color: lightTheme ? "#657983" : "#7d98a4"
                font.pixelSize: 9
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 84
                    radius: 15
                    color: lightTheme ? "#f1f6f7" : "#102731"
                    border.color: lightTheme ? "#d9e3e6" : "#244351"
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Label { text: "Papelera"; color: lightTheme ? "#17303a" : "#eef5f7"; font.pixelSize: 11; font.bold: true }
                            Label { text: backend.trashSizeText; color: lightTheme ? "#647984" : "#87a0aa"; font.pixelSize: 9 }
                        }
                        Button { text: "Vaciar"; onClicked: backend.emptyTrash() }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 84
                    radius: 15
                    color: lightTheme ? "#f1f6f7" : "#102731"
                    border.color: lightTheme ? "#d9e3e6" : "#244351"
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Label { text: "Miniaturas temporales"; color: lightTheme ? "#17303a" : "#eef5f7"; font.pixelSize: 11; font.bold: true }
                            Label { text: backend.thumbnailsSizeText; color: lightTheme ? "#647984" : "#87a0aa"; font.pixelSize: 9 }
                        }
                        Button { text: "Limpiar"; onClicked: backend.clearThumbnails() }
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: devicesColumn.implicitHeight + 34
        radius: 18
        color: lightTheme ? "#f8fbfc" : "#0d202b"
        border.color: lightTheme ? "#d7e2e6" : "#234454"

        ColumnLayout {
            id: devicesColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 17
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Label { text: "Discos y dispositivos"; color: lightTheme ? "#19323c" : "#f0f6f8"; font.pixelSize: 13; font.bold: true }
                Item { Layout.fillWidth: true }
                Label {
                    text: backend.udisksAvailable ? "Montaje seguro disponible" : "Solo lectura de estado"
                    color: backend.udisksAvailable ? root.accent : (lightTheme ? "#8c7770" : "#c4a189")
                    font.pixelSize: 8
                }
            }

            Repeater {
                model: backend.volumes
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: volumeColumn.implicitHeight + 26
                    radius: 15
                    color: lightTheme ? "#f2f6f7" : "#102630"
                    border.color: modelData.external ? root.accent : (lightTheme ? "#d9e2e5" : "#274653")

                    ColumnLayout {
                        id: volumeColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 13
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Rectangle {
                                width: 38
                                height: 38
                                radius: 12
                                color: lightTheme ? "#e1ecee" : "#163441"
                                Label {
                                    anchors.centerIn: parent
                                    text: modelData.external ? "USB" : (modelData.system ? "OS" : "◆")
                                    color: root.accent
                                    font.pixelSize: modelData.external ? 8 : 13
                                    font.bold: true
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Label { text: modelData.name; color: lightTheme ? "#17303a" : "#eef5f7"; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                                Label {
                                    text: modelData.kind + " · " + modelData.fileSystem + " · " + modelData.totalText
                                    color: lightTheme ? "#657983" : "#7e98a4"
                                    font.pixelSize: 8
                                }
                                Label {
                                    visible: modelData.mounted
                                    text: modelData.mountPoint
                                    color: lightTheme ? "#788b93" : "#678591"
                                    font.pixelSize: 8
                                    elide: Text.ElideMiddle
                                    Layout.fillWidth: true
                                }
                            }

                            Button {
                                visible: modelData.canOpen
                                text: "Abrir"
                                onClicked: backend.openPath(modelData.mountPoint)
                            }
                            Button {
                                visible: modelData.canMount
                                text: "Montar"
                                onClicked: backend.mountDevice(modelData.device)
                            }
                            Button {
                                visible: modelData.canUnmount
                                text: "Expulsar"
                                onClicked: backend.unmountDevice(modelData.device)
                            }
                        }

                        ProgressBar {
                            visible: modelData.mounted
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: modelData.usedPercent
                            background: Rectangle { implicitHeight: 6; radius: 3; color: lightTheme ? "#dde6e8" : "#18313b" }
                            contentItem: Item {
                                implicitHeight: 6
                                Rectangle {
                                    width: parent.width * (modelData.usedPercent / 100)
                                    height: parent.height
                                    radius: 3
                                    color: root.accent
                                }
                            }
                        }

                        Label {
                            visible: modelData.mounted
                            text: modelData.usedText + " usados · " + modelData.freeText + " libres"
                            color: lightTheme ? "#6d818a" : "#77929d"
                            font.pixelSize: 8
                        }
                    }
                }
            }

            Label {
                visible: backend.volumes.length === 0
                text: "No se detectaron volúmenes de bloque."
                color: lightTheme ? "#72858d" : "#708d99"
                font.pixelSize: 9
            }
        }
    }
}
