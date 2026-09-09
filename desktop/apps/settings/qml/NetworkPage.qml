import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    required property var settingsBackend
    property bool lightTheme: false
    property color accent: "#2563EB"

    implicitHeight: content.implicitHeight + 40
    radius: 18
    color: lightTheme ? "#FFFFFF" : "#11151C"
    border.color: lightTheme ? "#D8DEE9" : "#252B35"

    readonly property color raised: lightTheme ? "#F4F6F9" : "#171C24"
    readonly property color borderTone: lightTheme ? "#D8DEE9" : "#252B35"
    readonly property color textPrimary: lightTheme ? "#0B0D12" : "#F8FAFC"
    readonly property color textSecondary: lightTheme ? "#5B6573" : "#9AA4B2"
    readonly property color danger: "#E63946"

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Wi-Fi"
                    color: root.textPrimary
                    font.pixelSize: 14
                    font.bold: true
                }
                Label {
                    text: !root.backend.managerAvailable
                          ? "NetworkManager no está disponible"
                          : (!root.backend.wifiHardwareAvailable
                             ? "No se detectó un adaptador Wi-Fi"
                             : root.backend.connectivityText)
                    color: root.textSecondary
                    font.pixelSize: 9
                }
            }
            Button {
                id: scanButton
                visible: root.backend.wifiHardwareAvailable && root.backend.wifiEnabled
                text: root.backend.scanning ? "Buscando…" : "Buscar redes"
                enabled: !root.backend.scanning
                onClicked: root.backend.requestScan()
                background: Rectangle {
                    radius: 12
                    color: scanButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                    border.width: 1
                    border.color: scanButton.hovered ? root.accent : root.borderTone
                }
                contentItem: Label {
                    text: scanButton.text
                    color: root.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                    font.bold: true
                }
            }
            Switch {
                visible: root.backend.wifiHardwareAvailable
                checked: root.backend.wifiEnabled
                enabled: root.backend.managerAvailable
                onToggled: root.backend.setWifiEnabled(checked)
            }
        }

        Rectangle {
            visible: root.backend.activeSsid.length > 0
            Layout.fillWidth: true
            height: 80
            radius: 15
            color: root.lightTheme ? "#EAF1FF" : "#123A7A"
            border.width: 1
            border.color: root.accent

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                Rectangle {
                    width: 42
                    height: 42
                    radius: 13
                    color: root.accent
                    Label {
                        anchors.centerIn: parent
                        text: "◎"
                        color: "#FFFFFF"
                        font.pixelSize: 19
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        text: root.backend.activeSsid
                        color: root.textPrimary
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Label {
                        text: "Conectada"
                              + (root.backend.activeInterface.length > 0 ? " · " + root.backend.activeInterface : "")
                              + (root.backend.ipv4Address.length > 0 ? " · " + root.backend.ipv4Address : "")
                        color: root.lightTheme ? "#3C4A5E" : "#DCE8FF"
                        font.pixelSize: 9
                    }
                }

                Button {
                    id: disconnectButton
                    text: "Desconectar"
                    onClicked: root.backend.disconnectWifi()
                    background: Rectangle {
                        radius: 12
                        color: disconnectButton.hovered ? root.danger : "transparent"
                        border.width: 1
                        border.color: disconnectButton.hovered ? root.danger : root.accent
                    }
                    contentItem: Label {
                        text: disconnectButton.text
                        color: disconnectButton.hovered ? "#FFFFFF" : root.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }
        }

        Label {
            visible: root.backend.wifiHardwareAvailable && root.backend.wifiEnabled
            text: "Redes disponibles"
            color: root.textPrimary
            font.pixelSize: 12
            font.bold: true
        }

        ColumnLayout {
            visible: root.backend.wifiHardwareAvailable && root.backend.wifiEnabled
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.backend.accessPoints
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 66
                    radius: 14
                    color: modelData.active
                           ? (root.lightTheme ? "#EAF1FF" : "#123A7A")
                           : root.raised
                    border.width: modelData.active ? 2 : 1
                    border.color: modelData.active ? root.accent : root.borderTone

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 13
                        anchors.rightMargin: 13
                        spacing: 10

                        Label {
                            text: modelData.strength >= 75 ? "▰" : (modelData.strength >= 45 ? "▱" : "·")
                            color: modelData.active ? root.accent : root.textSecondary
                            font.pixelSize: 16
                            Layout.preferredWidth: 25
                            horizontalAlignment: Text.AlignHCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Label {
                                text: modelData.ssid
                                color: root.textPrimary
                                font.pixelSize: 11
                                font.bold: modelData.active
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Label {
                                text: modelData.security
                                      + (modelData.saved ? " · Guardada" : "")
                                      + (modelData.band.length > 0 ? " · " + modelData.band : "")
                                      + " · " + modelData.strength + "%"
                                color: root.textSecondary
                                font.pixelSize: 8
                            }
                        }

                        Label {
                            visible: modelData.active
                            text: "Activa"
                            color: root.accent
                            font.pixelSize: 9
                            font.bold: true
                        }

                        Button {
                            id: connectButton
                            visible: !modelData.active && modelData.saved
                            text: "Conectar"
                            onClicked: root.backend.connectSavedNetwork(modelData.ssid)
                            background: Rectangle {
                                radius: 11
                                color: connectButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                                border.width: 1
                                border.color: root.accent
                            }
                            contentItem: Label {
                                text: connectButton.text
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

        Label {
            visible: root.backend.wifiHardwareAvailable && root.backend.wifiEnabled && root.backend.accessPoints.length === 0
            Layout.fillWidth: true
            text: root.backend.scanning ? "Buscando redes cercanas…" : "No hay redes visibles. Pulsa Buscar redes para actualizar."
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
                    text: "Configuración avanzada"
                    color: root.textPrimary
                    font.pixelSize: 11
                    font.bold: true
                }
                Label {
                    text: "Para redes nuevas con contraseña, VPN, DNS manual y perfiles avanzados seguimos usando el editor de NetworkManager durante esta fase."
                    color: root.textSecondary
                    font.pixelSize: 8
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
            Button {
                id: advancedButton
                text: "Abrir avanzado"
                enabled: root.settingsBackend.networkSettingsAvailable
                onClicked: root.settingsBackend.openNetworkSettings()
                background: Rectangle {
                    radius: 12
                    color: advancedButton.enabled ? (advancedButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised) : root.raised
                    border.width: 1
                    border.color: advancedButton.enabled ? root.accent : root.borderTone
                }
                contentItem: Label {
                    text: advancedButton.text
                    color: advancedButton.enabled ? root.textPrimary : root.textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: root.backend.statusText
            color: root.textSecondary
            font.pixelSize: 8
            wrapMode: Text.WordWrap
        }
    }
}
