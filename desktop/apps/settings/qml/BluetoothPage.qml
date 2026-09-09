import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    property var settingsBackend
    property bool lightTheme: false
    property color accent: "#2563EB"

    Layout.fillWidth: true
    height: contentColumn.implicitHeight + 40
    radius: 18
    color: lightTheme ? "#FFFFFF" : "#11151C"
    border.color: lightTheme ? "#D8DEE9" : "#252B35"

    readonly property color raised: lightTheme ? "#F4F6F9" : "#171C24"
    readonly property color borderTone: lightTheme ? "#D8DEE9" : "#252B35"
    readonly property color textPrimary: lightTheme ? "#0B0D12" : "#F8FAFC"
    readonly property color textSecondary: lightTheme ? "#5B6573" : "#9AA4B2"
    readonly property color danger: "#E63946"

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Bluetooth"
                    color: root.textPrimary
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    text: root.backend.available ? root.backend.adapterName : "BlueZ no disponible"
                    color: root.textSecondary
                    font.pixelSize: 9
                }
            }
            Switch {
                checked: root.backend.powered
                enabled: root.backend.available
                onToggled: root.backend.setPowered(checked)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Button {
                id: scanButton
                text: root.backend.discovering ? "Detener búsqueda" : "Buscar dispositivos"
                enabled: root.backend.available && root.backend.powered
                onClicked: {
                    if (root.backend.discovering)
                        root.backend.stopDiscovery()
                    else
                        root.backend.startDiscovery()
                }
                background: Rectangle {
                    radius: 12
                    color: scanButton.enabled && scanButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                    border.width: 1
                    border.color: scanButton.enabled ? root.accent : root.borderTone
                }
                contentItem: Label {
                    text: scanButton.text
                    color: scanButton.enabled ? root.textPrimary : root.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                    font.bold: true
                }
            }

            Label {
                visible: root.backend.discovering
                text: "Buscando…"
                color: root.accent
                font.pixelSize: 9
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Button {
                id: refreshButton
                text: "Actualizar"
                enabled: root.backend.available
                onClicked: root.backend.refresh()
                background: Rectangle {
                    radius: 11
                    color: refreshButton.hovered ? root.raised : "transparent"
                    border.width: 1
                    border.color: root.borderTone
                }
                contentItem: Label {
                    text: refreshButton.text
                    color: root.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 8
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.borderTone }

        Label {
            visible: root.backend.devices.length > 0
            text: "Dispositivos"
            color: root.textPrimary
            font.pixelSize: 11
            font.bold: true
        }

        Repeater {
            model: root.backend.devices
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 72
                radius: 14
                color: modelData.connected ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                border.width: modelData.connected ? 2 : 1
                border.color: modelData.connected ? root.accent : root.borderTone

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 13
                    anchors.rightMargin: 13
                    spacing: 10

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 11
                        color: modelData.connected ? root.accent : (root.lightTheme ? "#FFFFFF" : "#0B0D12")
                        border.width: 1
                        border.color: modelData.connected ? root.accent : root.borderTone
                        Label {
                            anchors.centerIn: parent
                            text: "ᛒ"
                            color: modelData.connected ? "#FFFFFF" : root.accent
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Label {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: root.textPrimary
                            font.pixelSize: 10
                            font.bold: modelData.connected
                            elide: Text.ElideRight
                        }
                        Label {
                            Layout.fillWidth: true
                            text: modelData.address
                                  + (modelData.paired ? " · Emparejado" : " · No emparejado")
                                  + (modelData.trusted ? " · Confiable" : "")
                            color: root.textSecondary
                            font.pixelSize: 8
                            elide: Text.ElideRight
                        }
                    }

                    Label {
                        visible: modelData.connected
                        text: "Conectado"
                        color: root.accent
                        font.pixelSize: 8
                        font.bold: true
                    }

                    Button {
                        id: deviceActionButton
                        text: modelData.connected ? "Desconectar" : (modelData.paired ? "Conectar" : "Emparejar")
                        onClicked: {
                            if (modelData.connected)
                                root.backend.disconnectDevice(modelData.path)
                            else if (modelData.paired)
                                root.backend.connectDevice(modelData.path)
                            else
                                root.settingsBackend.openBluetoothSettings()
                        }
                        background: Rectangle {
                            radius: 10
                            color: deviceActionButton.hovered
                                   ? (modelData.connected ? root.danger : (root.lightTheme ? "#EAF1FF" : "#123A7A"))
                                   : root.raised
                            border.width: 1
                            border.color: modelData.connected && deviceActionButton.hovered ? root.danger : root.accent
                        }
                        contentItem: Label {
                            text: deviceActionButton.text
                            color: modelData.connected && deviceActionButton.hovered ? "#FFFFFF" : root.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 8
                            font.bold: true
                        }
                    }
                }
            }
        }

        Label {
            visible: root.backend.available && root.backend.powered && root.backend.devices.length === 0
            Layout.fillWidth: true
            text: root.backend.discovering
                  ? "Buscando dispositivos cercanos…"
                  : "No hay dispositivos conocidos. Pulsa Buscar dispositivos para actualizar."
            color: root.textSecondary
            font.pixelSize: 9
            wrapMode: Text.WordWrap
        }

        Label {
            visible: root.backend.available && !root.backend.powered
            Layout.fillWidth: true
            text: "Activa Bluetooth para ver dispositivos y buscar equipos cercanos."
            color: root.textSecondary
            font.pixelSize: 9
            wrapMode: Text.WordWrap
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.borderTone }

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Emparejamiento avanzado"
                    color: root.textPrimary
                    font.pixelSize: 11
                    font.bold: true
                }
                Label {
                    Layout.fillWidth: true
                    text: "Los dispositivos nuevos que requieran PIN, confirmación o perfiles especiales se emparejan todavía con el agente de Blueman."
                    color: root.textSecondary
                    font.pixelSize: 8
                    wrapMode: Text.WordWrap
                }
            }
            Button {
                id: advancedButton
                text: "Abrir avanzado"
                enabled: root.settingsBackend.bluetoothSettingsAvailable
                onClicked: root.settingsBackend.openBluetoothSettings()
                background: Rectangle {
                    radius: 11
                    color: advancedButton.enabled && advancedButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                    border.width: 1
                    border.color: advancedButton.enabled ? root.accent : root.borderTone
                }
                contentItem: Label {
                    text: advancedButton.text
                    color: advancedButton.enabled ? root.textPrimary : root.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 8
                    font.bold: true
                }
            }
        }
    }
}
