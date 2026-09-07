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
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Salida de audio"
                    color: root.lightTheme ? "#1b323c" : "white"
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    text: root.backend.available ? root.backend.outputName : "WirePlumber no disponible"
                    color: root.lightTheme ? "#71838b" : "#77939f"
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
                    color: outputMuteButton.hovered ? root.accent : (root.lightTheme ? "#e5edef" : "#15313c")
                    border.color: root.accent
                }
                contentItem: Label {
                    text: outputMuteButton.text
                    color: outputMuteButton.hovered ? "#07131d" : (root.lightTheme ? "#29434d" : "#d9eef0")
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
                color: root.backend.outputMuted ? (root.lightTheme ? "#82939a" : "#627985") : root.accent
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
            Label {
                text: root.backend.outputVolume + "%"
                color: root.lightTheme ? "#334b55" : "#c8d9df"
                font.pixelSize: 9
                Layout.preferredWidth: 42
                horizontalAlignment: Text.AlignRight
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.lightTheme ? "#dce5e8" : "#23414e" }

        Label {
            text: "Dispositivo de salida"
            color: root.lightTheme ? "#1b323c" : "white"
            font.pixelSize: 11
            font.bold: true
        }

        Repeater {
            model: root.backend.outputs
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 54
                radius: 13
                color: modelData.active
                       ? (root.lightTheme ? "#e2f0ef" : "#12343e")
                       : (root.lightTheme ? "#edf2f4" : "#112630")
                border.width: modelData.active ? 1 : 0
                border.color: root.accent

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 9
                    Label {
                        text: modelData.active ? "●" : "○"
                        color: modelData.active ? root.accent : (root.lightTheme ? "#7b8d95" : "#6e8792")
                        font.pixelSize: 11
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData.name
                        color: root.lightTheme ? "#18313b" : "#edf5f7"
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
                            color: outputUseButton.hovered ? root.accent : (root.lightTheme ? "#dbe9eb" : "#153744")
                            border.color: root.accent
                        }
                        contentItem: Label {
                            text: outputUseButton.text
                            color: outputUseButton.hovered ? "#07131d" : (root.lightTheme ? "#29434d" : "#d9eef0")
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 8
                            font.bold: true
                        }
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.lightTheme ? "#dce5e8" : "#23414e" }

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Micrófono"
                    color: root.lightTheme ? "#1b323c" : "white"
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    text: root.backend.available ? root.backend.inputName : "Entrada no disponible"
                    color: root.lightTheme ? "#71838b" : "#77939f"
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
                    color: inputMuteButton.hovered ? root.accent : (root.lightTheme ? "#e5edef" : "#15313c")
                    border.color: root.accent
                }
                contentItem: Label {
                    text: inputMuteButton.text
                    color: inputMuteButton.hovered ? "#07131d" : (root.lightTheme ? "#29434d" : "#d9eef0")
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
                color: root.backend.inputMuted ? (root.lightTheme ? "#82939a" : "#627985") : root.accent
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
            Label {
                text: root.backend.inputVolume + "%"
                color: root.lightTheme ? "#334b55" : "#c8d9df"
                font.pixelSize: 9
                Layout.preferredWidth: 42
                horizontalAlignment: Text.AlignRight
            }
        }

        Label {
            visible: root.backend.inputs.length > 0
            text: "Dispositivo de entrada"
            color: root.lightTheme ? "#1b323c" : "white"
            font.pixelSize: 11
            font.bold: true
        }

        Repeater {
            model: root.backend.inputs
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 54
                radius: 13
                color: modelData.active
                       ? (root.lightTheme ? "#e2f0ef" : "#12343e")
                       : (root.lightTheme ? "#edf2f4" : "#112630")
                border.width: modelData.active ? 1 : 0
                border.color: root.accent

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 9
                    Label {
                        text: modelData.active ? "●" : "○"
                        color: modelData.active ? root.accent : (root.lightTheme ? "#7b8d95" : "#6e8792")
                        font.pixelSize: 11
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData.name
                        color: root.lightTheme ? "#18313b" : "#edf5f7"
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
                            color: inputUseButton.hovered ? root.accent : (root.lightTheme ? "#dbe9eb" : "#153744")
                            border.color: root.accent
                        }
                        contentItem: Label {
                            text: inputUseButton.text
                            color: inputUseButton.hovered ? "#07131d" : (root.lightTheme ? "#29434d" : "#d9eef0")
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
                    text: "Controles avanzados"
                    color: root.lightTheme ? "#1b323c" : "white"
                    font.pixelSize: 11
                    font.bold: true
                }
                Label {
                    Layout.fillWidth: true
                    text: "pavucontrol queda disponible para perfiles, puertos y mezcla por aplicación mientras completamos la interfaz MurSchol."
                    color: root.lightTheme ? "#71838b" : "#77939f"
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
                    color: advancedButton.enabled ? (advancedButton.hovered ? root.accent : (root.lightTheme ? "#dcebed" : "#153744"))
                                                  : (root.lightTheme ? "#e0e5e7" : "#263942")
                    border.color: advancedButton.enabled ? root.accent : "transparent"
                }
                contentItem: Label {
                    text: advancedButton.text
                    color: advancedButton.enabled ? (advancedButton.hovered ? "#07131d" : (root.lightTheme ? "#29434d" : "#d9eef0"))
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
