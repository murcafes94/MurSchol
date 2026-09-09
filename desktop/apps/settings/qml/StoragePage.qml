import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var backend
    property bool lightTheme: false
    property color accent: "#2563EB"
    spacing: 14

    readonly property color surface: lightTheme ? "#FFFFFF" : "#11151C"
    readonly property color raised: lightTheme ? "#F4F6F9" : "#171C24"
    readonly property color border: lightTheme ? "#D8DEE9" : "#252B35"
    readonly property color textPrimary: lightTheme ? "#0B0D12" : "#F8FAFC"
    readonly property color textSecondary: lightTheme ? "#5B6573" : "#9AA4B2"
    readonly property color danger: "#E63946"

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: systemColumn.implicitHeight + 36
        radius: 18
        color: root.surface
        border.color: root.border

        ColumnLayout {
            id: systemColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 18
            spacing: 11

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Rectangle {
                    width: 48
                    height: 48
                    radius: 15
                    color: root.lightTheme ? "#EAF1FF" : "#123A7A"
                    Label { anchors.centerIn: parent; text: "▤"; color: root.accent; font.pixelSize: 22; font.bold: true }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Label { text: "Almacenamiento del sistema"; color: root.textPrimary; font.pixelSize: 17; font.bold: true }
                    Label {
                        text: backend.rootUsedText + " usados de " + backend.rootTotalText + " · " + backend.rootFreeText + " libres"
                        color: root.textSecondary
                        font.pixelSize: 9
                    }
                }
                Button {
                    id: refreshButton
                    text: "Actualizar"
                    onClicked: backend.refresh()
                    background: Rectangle {
                        radius: 12
                        color: refreshButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                        border.width: 1
                        border.color: refreshButton.hovered ? root.accent : root.border
                    }
                    contentItem: Label {
                        text: refreshButton.text
                        color: root.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: backend.rootUsedPercent
                background: Rectangle { implicitHeight: 8; radius: 4; color: root.raised }
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
        implicitHeight: cleanupColumn.implicitHeight + 36
        radius: 18
        color: root.surface
        border.color: root.border

        ColumnLayout {
            id: cleanupColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 18
            spacing: 11

            Label { text: "Limpieza segura"; color: root.textPrimary; font.pixelSize: 13; font.bold: true }
            Label {
                text: "MurSchol solo limpia datos regenerables o elementos que tú ya enviaste a la papelera. No borra documentos personales ni cachés generales de otras aplicaciones."
                color: root.textSecondary
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
                    implicitHeight: 86
                    radius: 15
                    color: root.raised
                    border.color: root.border
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Label { text: "Papelera"; color: root.textPrimary; font.pixelSize: 11; font.bold: true }
                            Label { text: backend.trashSizeText; color: root.textSecondary; font.pixelSize: 9 }
                        }
                        Button {
                            id: emptyTrashButton
                            text: "Vaciar"
                            onClicked: backend.emptyTrash()
                            background: Rectangle {
                                radius: 10
                                color: emptyTrashButton.hovered ? root.danger : "transparent"
                                border.width: 1
                                border.color: emptyTrashButton.hovered ? root.danger : root.border
                            }
                            contentItem: Label {
                                text: emptyTrashButton.text
                                color: emptyTrashButton.hovered ? "#FFFFFF" : root.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 86
                    radius: 15
                    color: root.raised
                    border.color: root.border
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Label { text: "Miniaturas temporales"; color: root.textPrimary; font.pixelSize: 11; font.bold: true }
                            Label { text: backend.thumbnailsSizeText; color: root.textSecondary; font.pixelSize: 9 }
                        }
                        Button {
                            id: clearThumbsButton
                            text: "Limpiar"
                            onClicked: backend.clearThumbnails()
                            background: Rectangle {
                                radius: 10
                                color: clearThumbsButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : "transparent"
                                border.width: 1
                                border.color: clearThumbsButton.hovered ? root.accent : root.border
                            }
                            contentItem: Label {
                                text: clearThumbsButton.text
                                color: root.textPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: devicesColumn.implicitHeight + 36
        radius: 18
        color: root.surface
        border.color: root.border

        ColumnLayout {
            id: devicesColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 18
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Label { text: "Discos y dispositivos"; color: root.textPrimary; font.pixelSize: 13; font.bold: true }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: udisksLabel.implicitWidth + 20
                    height: 28
                    radius: 14
                    color: backend.udisksAvailable ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                    border.width: 1
                    border.color: backend.udisksAvailable ? root.accent : root.border
                    Label {
                        id: udisksLabel
                        anchors.centerIn: parent
                        text: backend.udisksAvailable ? "Montaje seguro disponible" : "Solo lectura de estado"
                        color: backend.udisksAvailable ? (root.lightTheme ? "#123A7A" : "#DCE8FF") : root.textSecondary
                        font.pixelSize: 8
                        font.bold: true
                    }
                }
            }

            Repeater {
                model: backend.volumes
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: volumeColumn.implicitHeight + 28
                    radius: 15
                    color: root.raised
                    border.width: modelData.external ? 2 : 1
                    border.color: modelData.external ? root.accent : root.border

                    ColumnLayout {
                        id: volumeColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 14
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Rectangle {
                                width: 38
                                height: 38
                                radius: 12
                                color: modelData.external ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : (root.lightTheme ? "#FFFFFF" : "#0B0D12")
                                border.width: 1
                                border.color: modelData.external ? root.accent : root.border
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
                                Label { text: modelData.name; color: root.textPrimary; font.pixelSize: 11; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                                Label {
                                    text: modelData.kind + " · " + modelData.fileSystem + " · " + modelData.totalText
                                    color: root.textSecondary
                                    font.pixelSize: 8
                                }
                                Label {
                                    visible: modelData.mounted
                                    text: modelData.mountPoint
                                    color: root.textSecondary
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
                            background: Rectangle { implicitHeight: 6; radius: 3; color: root.lightTheme ? "#FFFFFF" : "#0B0D12" }
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
                            color: root.textSecondary
                            font.pixelSize: 8
                        }
                    }
                }
            }

            Label {
                visible: backend.volumes.length === 0
                text: "No se detectaron volúmenes de bloque."
                color: root.textSecondary
                font.pixelSize: 9
            }
        }
    }
}
