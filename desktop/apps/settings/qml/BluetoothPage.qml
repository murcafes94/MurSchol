import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    property var settingsBackend
    property bool lightTheme: false
    property color accent: "#22d6cf"

    Layout.fillWidth: true
    height: contentColumn.implicitHeight + 36
    radius: 20
    color: lightTheme ? "#f9fbfc" : "#0d202a"
    border.color: lightTheme ? "#d5e0e4" : "#284653"

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Bluetooth"
                    color: root.lightTheme ? "#1b323c" : "white"
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    text: root.backend.available ? root.backend.adapterName : "BlueZ no disponible"
                    color: root.lightTheme ? "#71838b" : "#77939f"
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
                    color: scanButton.enabled
                           ? (scanButton.hovered ? root.accent : (root.lightTheme ? "#dcebed" : "#153744"))
                           : (root.lightTheme ? "#e0e5e7" : "#263942")
                    border.color: scanButton.enabled ? root.accent : "transparent"
                }
                contentItem: Label {
                    text: scanButton.text
                    color: scanButton.enabled
                           ? (scanButton.hovered ? "#07131d" : (root.lightTheme ? "#29434d" : "#d9eef0"))
                           : (root.lightTheme ? "#8b989d" : "#71858d")
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
                    color: refreshButton.hovered ? (root.lightTheme ? "#e4edef" : "#15313c") : "transparent"
                    border.color: root.lightTheme ? "#cdd9dd" : "#294653"
                }
                contentItem: Label {
                    text: refreshButton.text
                    color: root.lightTheme ? "#425a64" : "#c7d8de"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 8
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.lightTheme ? "#dce5e8" : "#23414e" }

        Label {
            visible: root.backend.devices.length > 0
            text: "Dispositivos"
            color: root.lightTheme ? "#1b323c" : "white"
            font.pixelSize: 11
            font.bold: true
        }

        Repeater {
            model: root.backend.devices
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 70
                radius: 14
                color: modelData.connected
                       ? (root.lightTheme ? "#e2f0ef" : "#12343e")
                       : (root.lightTheme ? "#edf2f4" : "#112630")
                border.width: modelData.connected ? 1 : 0
                border.color: root.accent

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 13
                    anchors.rightMargin: 13
                    spacing: 10

                    Rectangle {
                        width: 34
                        height: 34
                        radius: 11
                        color: modelData.connected
                               ? root.accent
                               : (root.lightTheme ? "#dce5e8" : "#17313c")
                        Label {
                            anchors.centerIn: parent
                            text: "ᛒ"
                            color: modelData.connected ? "#07131d" : root.accent
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
                            color: root.lightTheme ? "#18313b" : "#edf5f7"
                            font.pixelSize: 10
                            font.bold: modelData.connected
                            elide: Text.ElideRight
                        }
                        Label {
                            Layout.fillWidth: true
                            text: modelData.address
                                  + (modelData.paired ? " · Emparejado" : " · No emparejado")
                                  + (modelData.trusted ? " · Confiable" : "")
                            color: root.lightTheme ? "#6b7f88" : "#75929e"
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
                            color: deviceActionButton.hovered ? root.accent : (root.lightTheme ? "#dbe9eb" : "#153744")
                            border.color: root.accent
                        }
                        contentItem: Label {
                            text: deviceActionButton.text
                            color: deviceActionButton.hovered ? "#07131d" : (root.lightTheme ? "#29434d" : "#d9eef0")
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
            color: root.lightTheme ? "#6a7d86" : "#77939f"
            font.pixelSize: 9
            wrapMode: Text.WordWrap
        }

        Label {
            visible: root.backend.available && !root.backend.powered
            Layout.fillWidth: true
            text: "Activa Bluetooth para ver dispositivos y buscar equipos cercanos."
            color: root.lightTheme ? "#6a7d86" : "#77939f"
            font.pixelSize: 9
            wrapMode: Text.WordWrap
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.lightTheme ? "#dce5e8" : "#23414e" }

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Emparejamiento avanzado"
                    color: root.lightTheme ? "#1b323c" : "white"
                    font.pixelSize: 11
                    font.bold: true
                }
                Label {
                    Layout.fillWidth: true
                    text: "Los dispositivos nuevos que requieran PIN, confirmación o perfiles especiales se emparejan todavía con el agente de Blueman."
                    color: root.lightTheme ? "#71838b" : "#77939f"
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
                    color: advancedButton.enabled
                           ? (advancedButton.hovered ? root.accent : (root.lightTheme ? "#dcebed" : "#153744"))
                           : (root.lightTheme ? "#e0e5e7" : "#263942")
                    border.color: advancedButton.enabled ? root.accent : "transparent"
                }
                contentItem: Label {
                    text: advancedButton.text
                    color: advancedButton.enabled
                           ? (advancedButton.hovered ? "#07131d" : (root.lightTheme ? "#29434d" : "#d9eef0"))
                           : (root.lightTheme ? "#8b989d" : "#71858d")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 8
                    font.bold: true
                }
            }
        }
    }
}
