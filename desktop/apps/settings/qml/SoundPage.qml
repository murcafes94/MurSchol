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
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Salida de audio"
                    color: root.textPrimary
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    text: root.backend.available ? root.backend.outputName : "WirePlumber no disponible"
                    color: root.textSecondary
                    font.pixelSize: 9
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            Button {
                id: outputMuteButton
                text: root.backend.outputMuted ? "Activar" : "Silenciar"
                enabled: root.backend.available
                onClicked: root.backend.setOutputMuted(!root.backend.outputMuted)
                background: Rectangle {
                    radius: 12
                    color: outputMuteButton.hovered
                           ? (root.backend.outputMuted ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.danger)
                           : root.raised
                    border.width: 1
                    border.color: outputMuteButton.hovered
                                  ? (root.backend.outputMuted ? root.accent : root.danger)
                                  : root.borderTone
                }
                contentItem: Label {
                    text: outputMuteButton.text
                    color: outputMuteButton.hovered && !root.backend.outputMuted ? "#FFFFFF" : root.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: root.backend.outputMuted ? "◌" : "◕"
                color: root.backend.outputMuted ? root.textSecondary : root.accent
                font.pixelSize: 18
                Layout.preferredWidth: 28
                horizontalAlignment: Text.AlignHCenter
            }
            Slider {
                Layout.fillWidth: true
                from: 0
                to: 100
                stepSize: 1
                value: root.backend.outputVolume
                enabled: root.backend.available
                onMoved: root.backend.setOutputVolume(Math.round(value))
            }
            Rectangle {
                width: 50
                height: 30
                radius: 10
                color: root.raised
                border.width: 1
                border.color: root.borderTone
                Label {
                    anchors.centerIn: parent
                    text: root.backend.outputVolume + "%"
                    color: root.textPrimary
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.borderTone }

        Label {
            text: "Dispositivo de salida"
            color: root.textPrimary
            font.pixelSize: 11
            font.bold: true
        }

        Repeater {
            model: root.backend.outputs
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 56
                radius: 13
                color: modelData.active ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                border.width: modelData.active ? 2 : 1
                border.color: modelData.active ? root.accent : root.borderTone

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 9
                    Label {
                        text: modelData.active ? "●" : "○"
                        color: modelData.active ? root.accent : root.textSecondary
                        font.pixelSize: 11
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData.name
                        color: root.textPrimary
                        font.pixelSize: 10
                        font.bold: modelData.active
                        elide: Text.ElideRight
                    }
                    Button {
                        id: outputUseButton
                        visible: !modelData.active
                        text: "Usar"
                        onClicked: root.backend.setDefaultOutput(modelData.id)
                        background: Rectangle {
                            radius: 10
                            color: outputUseButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                            border.width: 1
                            border.color: root.accent
                        }
                        contentItem: Label {
                            text: outputUseButton.text
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

        Rectangle { Layout.fillWidth: true; height: 1; color: root.borderTone }

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Micrófono"
                    color: root.textPrimary
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    text: root.backend.available ? root.backend.inputName : "Entrada no disponible"
                    color: root.textSecondary
                    font.pixelSize: 9
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            Button {
                id: inputMuteButton
                text: root.backend.inputMuted ? "Activar" : "Silenciar"
                enabled: root.backend.available
                onClicked: root.backend.setInputMuted(!root.backend.inputMuted)
                background: Rectangle {
                    radius: 12
                    color: inputMuteButton.hovered
                           ? (root.backend.inputMuted ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.danger)
                           : root.raised
                    border.width: 1
                    border.color: inputMuteButton.hovered
                                  ? (root.backend.inputMuted ? root.accent : root.danger)
                                  : root.borderTone
                }
                contentItem: Label {
                    text: inputMuteButton.text
                    color: inputMuteButton.hovered && !root.backend.inputMuted ? "#FFFFFF" : root.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: root.backend.inputMuted ? "◌" : "●"
                color: root.backend.inputMuted ? root.textSecondary : root.accent
                font.pixelSize: 14
                Layout.preferredWidth: 28
                horizontalAlignment: Text.AlignHCenter
            }
            Slider {
                Layout.fillWidth: true
                from: 0
                to: 100
                stepSize: 1
                value: root.backend.inputVolume
                enabled: root.backend.available
                onMoved: root.backend.setInputVolume(Math.round(value))
            }
            Rectangle {
                width: 50
                height: 30
                radius: 10
                color: root.raised
                border.width: 1
                border.color: root.borderTone
                Label {
                    anchors.centerIn: parent
                    text: root.backend.inputVolume + "%"
                    color: root.textPrimary
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        Label {
            visible: root.backend.inputs.length > 0
            text: "Dispositivo de entrada"
            color: root.textPrimary
            font.pixelSize: 11
            font.bold: true
        }

        Repeater {
            model: root.backend.inputs
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 56
                radius: 13
                color: modelData.active ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                border.width: modelData.active ? 2 : 1
                border.color: modelData.active ? root.accent : root.borderTone

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 9
                    Label {
                        text: modelData.active ? "●" : "○"
                        color: modelData.active ? root.accent : root.textSecondary
                        font.pixelSize: 11
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData.name
                        color: root.textPrimary
                        font.pixelSize: 10
                        font.bold: modelData.active
                        elide: Text.ElideRight
                    }
                    Button {
                        id: inputUseButton
                        visible: !modelData.active
                        text: "Usar"
                        onClicked: root.backend.setDefaultInput(modelData.id)
                        background: Rectangle {
                            radius: 10
                            color: inputUseButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                            border.width: 1
                            border.color: root.accent
                        }
                        contentItem: Label {
                            text: inputUseButton.text
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

        Label {
            visible: root.backend.available && root.backend.outputs.length === 0 && root.backend.inputs.length === 0
            Layout.fillWidth: true
            text: "PipeWire está disponible, pero todavía no se detectan dispositivos de audio."
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
                    text: "Controles avanzados"
                    color: root.textPrimary
                    font.pixelSize: 11
                    font.bold: true
                }
                Label {
                    Layout.fillWidth: true
                    text: "pavucontrol queda disponible para perfiles, puertos y mezcla por aplicación mientras completamos la interfaz MurSchol."
                    color: root.textSecondary
                    font.pixelSize: 8
                    wrapMode: Text.WordWrap
                }
            }
            Button {
                id: advancedButton
                text: "Abrir avanzado"
                enabled: root.settingsBackend.audioSettingsAvailable
                onClicked: root.settingsBackend.openAudioSettings()
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
