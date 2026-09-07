import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    required property var settingsBackend
    property bool lightTheme: false
    property color accent: "#22d6cf"

    implicitHeight: content.implicitHeight + 36
    radius: 20
    color: lightTheme ? "#f9fbfc" : "#0d202a"
    border.color: lightTheme ? "#d5e0e4" : "#284653"

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Wi-Fi"
                    color: root.lightTheme ? "#18313b" : "white"
                    font.pixelSize: 14
                    font.bold: true
                }
                Label {
                    text: !root.backend.managerAvailable
                          ? "NetworkManager no está disponible"
                          : (!root.backend.wifiHardwareAvailable
                             ? "No se detectó un adaptador Wi-Fi"
                             : root.backend.connectivityText)
                    color: root.lightTheme ? "#6d8189" : "#7795a1"
                    font.pixelSize: 9
                }
            }
            Button {
                visible: root.backend.wifiHardwareAvailable && root.backend.wifiEnabled
                text: root.backend.scanning ? "Buscando…" : "Buscar redes"
                enabled: !root.backend.scanning
                onClicked: root.backend.requestScan()
                background: Rectangle {
                    radius: 12
                    color: parent.hovered ? (root.lightTheme ? "#deebed" : "#163442") : (root.lightTheme ? "#edf3f4" : "#112a35")
                    border.color: root.lightTheme ? "#cad8dd" : "#31515f"
                }
                contentItem: Label {
                    text: parent.text
                    color: root.lightTheme ? "#29434d" : "#dbe9ed"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
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
            height: 78
            radius: 15
            color: root.lightTheme ? "#e5f2f1" : "#12343e"
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
                        color: "#07131d"
                        font.pixelSize: 19
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        text: root.backend.activeSsid
                        color: root.lightTheme ? "#15303a" : "white"
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Label {
                        text: "Conectada"
                              + (root.backend.activeInterface.length > 0 ? " · " + root.backend.activeInterface : "")
                              + (root.backend.ipv4Address.length > 0 ? " · " + root.backend.ipv4Address : "")
                        color: root.lightTheme ? "#58717a" : "#8eb0ba"
                        font.pixelSize: 9
                    }
                }

                Button {
                    text: "Desconectar"
                    onClicked: root.backend.disconnectWifi()
                    background: Rectangle {
                        radius: 12
                        color: parent.hovered ? (root.lightTheme ? "#d6e6e8" : "#244552") : "transparent"
                        border.color: root.lightTheme ? "#bfcfd4" : "#486773"
                    }
                    contentItem: Label {
                        text: parent.text
                        color: root.lightTheme ? "#344c56" : "#d6e5e9"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                    }
                }
            }
        }

        Label {
            visible: root.backend.wifiHardwareAvailable && root.backend.wifiEnabled
            text: "Redes disponibles"
            color: root.lightTheme ? "#1b323c" : "white"
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
                    height: 64
                    radius: 14
                    color: modelData.active
                           ? (root.lightTheme ? "#e5f2f1" : "#12343e")
                           : (root.lightTheme ? "#edf2f4" : "#112630")
                    border.width: modelData.active ? 1 : 0
                    border.color: root.accent

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 13
                        anchors.rightMargin: 13
                        spacing: 10

                        Label {
                            text: modelData.strength >= 75 ? "▰" : (modelData.strength >= 45 ? "▱" : "·")
                            color: root.accent
                            font.pixelSize: 16
                            Layout.preferredWidth: 25
                            horizontalAlignment: Text.AlignHCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Label {
                                text: modelData.ssid
                                color: root.lightTheme ? "#18313b" : "#edf5f7"
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
                                color: root.lightTheme ? "#6b7f88" : "#75929e"
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
                                color: connectButton.hovered ? root.accent : (root.lightTheme ? "#dcebec" : "#153744")
                                border.color: root.accent
                            }
                            contentItem: Label {
                                text: connectButton.text
                                color: connectButton.hovered ? "#07131d" : (root.lightTheme ? "#24434c" : "#d7eeee")
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
                    text: "Configuración avanzada"
                    color: root.lightTheme ? "#1b323c" : "white"
                    font.pixelSize: 11
                    font.bold: true
                }
                Label {
                    text: "Para redes nuevas con contraseña, VPN, DNS manual y perfiles avanzados seguimos usando el editor de NetworkManager durante esta fase."
                    color: root.lightTheme ? "#6f828a" : "#718e9a"
                    font.pixelSize: 8
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
            Button {
                text: "Abrir avanzado"
                enabled: root.settingsBackend.networkSettingsAvailable
                onClicked: root.settingsBackend.openNetworkSettings()
                background: Rectangle {
                    radius: 12
                    color: parent.enabled ? (root.lightTheme ? "#e2ecee" : "#173440") : (root.lightTheme ? "#dde4e6" : "#263942")
                    border.color: root.lightTheme ? "#c8d5d9" : "#3d5d69"
                }
                contentItem: Label {
                    text: parent.text
                    color: parent.enabled ? (root.lightTheme ? "#29434d" : "#dcebed") : (root.lightTheme ? "#89969b" : "#71858d")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: root.backend.statusText
            color: root.lightTheme ? "#6b8088" : "#6f909c"
            font.pixelSize: 8
            wrapMode: Text.WordWrap
        }
    }
}
