import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholShell 1.0

Rectangle {
    id: root
    property var backend
    property string pendingPowerAction: ""
    width: 470
    height: Math.min(680, parent ? Math.max(500, parent.height - 105) : 680)
    radius: 26
    color: "#F016191E"
    border.width: 1
    border.color: "#5E50443A"

    QuickControlsBackend { id: quickControls }

    function requestPowerAction(action) {
        pendingPowerAction = action
        powerConfirm.open()
    }

    Popup {
        id: powerConfirm
        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height - height) / 2)
        width: Math.min(340, root.width - 36)
        height: 182
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0

        background: Rectangle {
            radius: 20
            color: "#F51A1D22"
            border.width: 1
            border.color: root.pendingPowerAction === "poweroff" ? "#A55D5047" : root.backend.accentColor
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10
            Label {
                Layout.fillWidth: true
                text: root.pendingPowerAction === "poweroff" ? "Apagar MurSchol OS" : "Reiniciar MurSchol OS"
                color: "#F3EEE5"
                font.pixelSize: 17
                font.bold: true
            }
            Label {
                Layout.fillWidth: true
                text: root.pendingPowerAction === "poweroff"
                      ? "Guarda tus documentos antes de apagar el equipo."
                      : "Guarda tus documentos antes de reiniciar el equipo."
                color: "#A79E94"
                font.pixelSize: 10
                wrapMode: Text.WordWrap
            }
            Item { Layout.fillHeight: true }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Item { Layout.fillWidth: true }
                Button {
                    text: "Cancelar"
                    onClicked: powerConfirm.close()
                    background: Rectangle {
                        radius: 11
                        color: parent.hovered ? "#302C28" : "#24211D"
                        border.width: 1
                        border.color: "#51463B"
                    }
                    contentItem: Label {
                        text: parent.text
                        color: "#D7CFC5"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                    }
                }
                Button {
                    text: root.pendingPowerAction === "poweroff" ? "Apagar" : "Reiniciar"
                    onClicked: {
                        var action = root.pendingPowerAction
                        powerConfirm.close()
                        if (action === "poweroff")
                            root.backend.powerOff()
                        else if (action === "reboot")
                            root.backend.reboot()
                    }
                    background: Rectangle {
                        radius: 11
                        color: parent.hovered ? "#E3BB78" : root.backend.accentColor
                    }
                    contentItem: Label {
                        text: parent.text
                        color: "#15120F"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                    }
                }
            }
        }
        onClosed: root.pendingPowerAction = ""
    }

    ScrollView {
        id: scroll
        anchors.fill: parent
        anchors.margins: 14
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: scroll.availableWidth
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    spacing: 0
                    Label { text: "Centro del sistema"; color: "#F3EEE5"; font.pixelSize: 21; font.bold: true }
                    Label { text: "Controles, rendimiento y estado"; color: "#968C82"; font.pixelSize: 10 }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 86
                    height: 28
                    radius: 14
                    color: "#302820"
                    border.width: 1
                    border.color: root.backend.accentColor
                    Label { anchors.centerIn: parent; text: root.backend.profile; color: "#F1DEC1"; font.pixelSize: 9; font.bold: true }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: [
                        {n:"CPU", v:backend.cpuUsage, c:root.backend.accentColor},
                        {n:"RAM", v:backend.memoryUsage, c:"#78B58B"},
                        {n:"Disco", v:backend.diskUsage, c:"#C58A6A"}
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        height: 70
                        radius: 16
                        color: "#1A1D22"
                        border.width: 1
                        border.color: modelData.c
                        Column {
                            anchors.centerIn: parent
                            spacing: 2
                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.v + "%"; color: "#F3EEE5"; font.pixelSize: 18; font.bold: true }
                            Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.n; color: "#A79E94"; font.pixelSize: 9 }
                        }
                    }
                }
            }

            Label { text: "Controles rápidos"; color: "#D7CFC5"; font.bold: true; font.pixelSize: 11 }
            RowLayout {
                Layout.fillWidth: true
                spacing: 7

                Button {
                    Layout.preferredWidth: 106
                    Layout.preferredHeight: 64
                    enabled: quickControls.networkAvailable
                    onClicked: quickControls.setWifiEnabled(!quickControls.wifiEnabled)
                    background: Rectangle {
                        radius: 15
                        color: parent.hovered ? "#302920" : "#1A1D22"
                        border.width: 1
                        border.color: quickControls.wifiEnabled ? root.backend.accentColor : "#51463B"
                    }
                    contentItem: ColumnLayout {
                        spacing: 1
                        Label { Layout.alignment: Qt.AlignHCenter; text: "Wi-Fi"; color: "#F3EEE5"; font.bold: true; font.pixelSize: 10 }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: quickControls.wifiStatus
                            color: quickControls.wifiEnabled ? "#E3BB78" : "#91877D"
                            font.pixelSize: 8
                        }
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: enabled ? "Activar o desactivar Wi-Fi" : "Wi-Fi no disponible"
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 15
                    color: "#1A1D22"
                    border.width: 1
                    border.color: quickControls.muted ? "#76544A" : "#51463B"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 7
                        anchors.rightMargin: 7
                        spacing: 4
                        Button {
                            enabled: quickControls.audioAvailable
                            text: "−"
                            onClicked: quickControls.setVolume(quickControls.volume - 5)
                            background: Rectangle { radius: 9; color: parent.hovered ? "#342D27" : "transparent" }
                            contentItem: Label { text: parent.text; color: "#D7CFC5"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Label { Layout.alignment: Qt.AlignHCenter; text: quickControls.muted ? "Silencio" : "Volumen"; color: "#F3EEE5"; font.bold: true; font.pixelSize: 9 }
                            Label { Layout.alignment: Qt.AlignHCenter; text: quickControls.audioAvailable ? quickControls.volume + "%" : "N/D"; color: "#A79E94"; font.pixelSize: 8 }
                        }
                        Button {
                            enabled: quickControls.audioAvailable
                            text: "+"
                            onClicked: quickControls.setVolume(quickControls.volume + 5)
                            background: Rectangle { radius: 9; color: parent.hovered ? "#342D27" : "transparent" }
                            contentItem: Label { text: parent.text; color: "#D7CFC5"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                        Button {
                            enabled: quickControls.audioAvailable
                            text: quickControls.muted ? "×" : "♪"
                            onClicked: quickControls.toggleMute()
                            background: Rectangle { radius: 9; color: parent.hovered ? "#342D27" : "transparent" }
                            contentItem: Label { text: parent.text; color: quickControls.muted ? "#E8A18E" : "#E3BB78"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: quickControls.openAudioSettings()
                    }
                }

                Button {
                    Layout.preferredWidth: 106
                    Layout.preferredHeight: 64
                    enabled: quickControls.bluetoothAvailable
                    onClicked: quickControls.setBluetoothEnabled(!quickControls.bluetoothEnabled)
                    background: Rectangle {
                        radius: 15
                        color: parent.hovered ? "#302920" : "#1A1D22"
                        border.width: 1
                        border.color: quickControls.bluetoothEnabled ? root.backend.accentColor : "#51463B"
                    }
                    contentItem: ColumnLayout {
                        spacing: 1
                        Label { Layout.alignment: Qt.AlignHCenter; text: "Bluetooth"; color: "#F3EEE5"; font.bold: true; font.pixelSize: 9 }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: quickControls.bluetoothAvailable ? (quickControls.bluetoothEnabled ? "Activado" : "Desactivado") : "No disponible"
                            color: quickControls.bluetoothEnabled ? "#E3BB78" : "#91877D"
                            font.pixelSize: 8
                        }
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: enabled ? "Activar o desactivar Bluetooth" : "Bluetooth no disponible"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Button {
                    Layout.fillWidth: true
                    text: "Redes…"
                    enabled: quickControls.networkAvailable
                    onClicked: quickControls.openNetworkSettings()
                    background: Rectangle { radius: 10; color: parent.hovered ? "#2B2723" : "#17191D"; border.width: 1; border.color: "#443C35" }
                    contentItem: Label { text: parent.text; color: "#BDB4AA"; font.pixelSize: 8; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Button {
                    Layout.fillWidth: true
                    text: "Sonido…"
                    enabled: quickControls.audioAvailable
                    onClicked: quickControls.openAudioSettings()
                    background: Rectangle { radius: 10; color: parent.hovered ? "#2B2723" : "#17191D"; border.width: 1; border.color: "#443C35" }
                    contentItem: Label { text: parent.text; color: "#BDB4AA"; font.pixelSize: 8; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Button {
                    Layout.fillWidth: true
                    text: "Bluetooth…"
                    enabled: quickControls.bluetoothAvailable
                    onClicked: quickControls.openBluetoothSettings()
                    background: Rectangle { radius: 10; color: parent.hovered ? "#2B2723" : "#17191D"; border.width: 1; border.color: "#443C35" }
                    contentItem: Label { text: parent.text; color: "#BDB4AA"; font.pixelSize: 8; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }

            Label { text: "Equipo"; color: "#D7CFC5"; font.bold: true; font.pixelSize: 11 }
            Rectangle {
                Layout.fillWidth: true
                height: root.backend.batteryAvailable ? 94 : 78
                radius: 15
                color: "#1A1D22"
                border.width: 1
                border.color: "#4A423A34"
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 11
                    spacing: 2
                    Label { text: root.backend.distroName; color: "#F3EEE5"; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true; font.pixelSize: 11 }
                    Label { text: root.backend.cpuModel + " · " + root.backend.cpuThreads + " hilos"; color: "#AAA097"; font.pixelSize: 9; elide: Text.ElideRight; Layout.fillWidth: true }
                    Label { text: "Kernel " + root.backend.kernelVersion + " · RAM " + root.backend.totalMemoryGb.toFixed(1) + " GB"; color: "#8E857D"; font.pixelSize: 9 }
                    Label {
                        visible: root.backend.batteryAvailable
                        text: "Batería " + root.backend.batteryPercent + "% · " + (root.backend.charging ? "cargando" : "en uso")
                        color: root.backend.batteryPercent <= 20 ? "#E19A73" : "#78B58B"
                        font.pixelSize: 9
                    }
                }
            }

            Label { text: "Compatibilidad"; color: "#D7CFC5"; font.bold: true; font.pixelSize: 11 }
            RowLayout {
                Layout.fillWidth: true
                spacing: 7
                Repeater {
                    model: [
                        {name:"Linux", symbol:"L", detail:"Nativo", ready:true},
                        {name:"Android", symbol:"A", detail:"Waydroid", ready:backend.waydroidAvailable},
                        {name:"Windows", symbol:"W", detail:"Wine/Bottles", ready:backend.wineAvailable || backend.bottlesAvailable}
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        height: 66
                        radius: 15
                        color: "#1A1D22"
                        border.width: 1
                        border.color: modelData.ready ? "#537A60" : "#675943"
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 1
                            Label { Layout.alignment: Qt.AlignHCenter; text: modelData.symbol; color: modelData.ready ? "#8FC7A0" : "#E3BB78"; font.bold: true; font.pixelSize: 15 }
                            Label { Layout.alignment: Qt.AlignHCenter; text: modelData.name; color: "#F3EEE5"; font.bold: true; font.pixelSize: 9 }
                            Label { Layout.alignment: Qt.AlignHCenter; text: modelData.ready ? modelData.detail : "No instalado"; color: modelData.ready ? "#82B892" : "#C9A86F"; font.pixelSize: 7 }
                        }
                    }
                }
            }

            Label { text: "Modo de rendimiento"; color: "#D7CFC5"; font.bold: true; font.pixelSize: 11 }
            Rectangle {
                Layout.fillWidth: true
                height: 116
                radius: 17
                color: "#15181D"
                border.width: 1
                border.color: "#4A423A34"
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 7
                    Repeater {
                        model: [
                            {name:"Ligero", symbol:"◆", desc:"Ahorro"},
                            {name:"Normal", symbol:"▣", desc:"Equilibrio"},
                            {name:"Rendimiento", symbol:"▲", desc:"Potencia"}
                        ]
                        delegate: Button {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            onClicked: root.backend.setProfile(modelData.name)
                            background: Rectangle {
                                radius: 14
                                color: root.backend.profile === modelData.name ? "#3C2D242A" : (parent.hovered ? "#29251F24" : "#111419")
                                border.width: root.backend.profile === modelData.name ? 2 : 1
                                border.color: root.backend.profile === modelData.name ? root.backend.accentColor : "#443C352F"
                            }
                            contentItem: ColumnLayout {
                                spacing: 2
                                Item { Layout.fillHeight: true }
                                Label { Layout.alignment: Qt.AlignHCenter; text: modelData.symbol; color: root.backend.profile === modelData.name ? root.backend.accentColor : "#B8AEA4"; font.pixelSize: 16; font.bold: true }
                                Label { Layout.alignment: Qt.AlignHCenter; text: modelData.name; color: "#F3EEE5"; font.pixelSize: 9; font.bold: true }
                                Label { Layout.alignment: Qt.AlignHCenter; text: modelData.desc; color: "#91877D"; font.pixelSize: 7 }
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    visible: modelData.name === root.backend.recommendedProfile
                                    width: rec.implicitWidth + 10
                                    height: 18
                                    radius: 9
                                    color: "#273E30"
                                    border.width: 1
                                    border.color: "#537A60"
                                    Label { id: rec; anchors.centerIn: parent; text: "Recomendado"; color: "#A5D1AF"; font.pixelSize: 7; font.bold: true }
                                }
                                Item { Layout.fillHeight: true }
                            }
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#3A342F" }
            RowLayout {
                Layout.fillWidth: true
                spacing: 7
                Label {
                    text: quickControls.statusText.length > 0 ? quickControls.statusText : root.backend.statusText
                    color: "#857C73"
                    font.pixelSize: 8
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Button {
                    visible: root.backend.profile !== root.backend.recommendedProfile
                    text: "Recomendado"
                    onClicked: root.backend.applyRecommendedProfile()
                    background: Rectangle { radius: 11; color: parent.hovered ? "#3B332C" : "#25211D"; border.width: 1; border.color: "#675A4B" }
                    contentItem: Label { text: parent.text; color: "#D7CFC5"; font.pixelSize: 8; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Button {
                    text: "Configuración"
                    onClicked: root.backend.openSettings("appearance")
                    background: Rectangle { radius: 11; color: parent.hovered ? "#3B332C" : "#25211D"; border.width: 1; border.color: "#675A4B" }
                    contentItem: Label { text: parent.text; color: "#D7CFC5"; font.pixelSize: 8; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Button {
                    text: "↻"
                    ToolTip.visible: hovered
                    ToolTip.text: "Reiniciar"
                    onClicked: root.requestPowerAction("reboot")
                    background: Rectangle { radius: 11; color: parent.hovered ? "#3B332C" : "#25211D"; border.width: 1; border.color: "#675A4B" }
                    contentItem: Label { text: parent.text; color: "#E3BB78"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Button {
                    text: "⏻"
                    ToolTip.visible: hovered
                    ToolTip.text: "Apagar"
                    onClicked: root.requestPowerAction("poweroff")
                    background: Rectangle { radius: 11; color: parent.hovered ? "#50352F" : "#2A211F"; border.width: 1; border.color: "#76544A" }
                    contentItem: Label { text: parent.text; color: "#E8A18E"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
        }
    }
}
