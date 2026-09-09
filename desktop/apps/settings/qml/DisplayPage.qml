import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    property var powerBackend
    property bool lightTheme: false
    property color accent: "#2563EB"

    Layout.fillWidth: true
    height: contentColumn.implicitHeight + 40
    radius: 18
    color: lightTheme ? "#FFFFFF" : "#11151C"
    border.color: lightTheme ? "#D8DEE9" : "#252B35"

    readonly property color raised: lightTheme ? "#F4F6F9" : "#171C24"
    readonly property color textPrimary: lightTheme ? "#0B0D12" : "#F8FAFC"
    readonly property color textSecondary: lightTheme ? "#5B6573" : "#9AA4B2"
    readonly property color borderTone: lightTheme ? "#D8DEE9" : "#252B35"

    Timer {
        id: nightApplyTimer
        interval: 250
        repeat: false
        onTriggered: root.backend.setNightLightTemperature(Math.round(temperatureSlider.value))
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "Pantallas conectadas"
                color: root.textPrimary
                font.pixelSize: 13
                font.bold: true
                Layout.fillWidth: true
            }
            Rectangle {
                width: displayCount.implicitWidth + 22
                height: 28
                radius: 14
                color: root.lightTheme ? "#EAF1FF" : "#123A7A"
                border.width: 1
                border.color: root.accent
                Label {
                    id: displayCount
                    anchors.centerIn: parent
                    text: root.backend.screens.length + (root.backend.screens.length === 1 ? " pantalla" : " pantallas")
                    color: root.lightTheme ? "#123A7A" : "#DCE8FF"
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        Repeater {
            model: root.backend.screens
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 82
                radius: 15
                color: root.raised
                border.width: modelData.primary ? 2 : 1
                border.color: modelData.primary ? root.accent : root.borderTone

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 13

                    Rectangle {
                        width: 60
                        height: 40
                        radius: 8
                        color: root.lightTheme ? "#FFFFFF" : "#0B0D12"
                        border.width: 2
                        border.color: modelData.primary ? root.accent : root.borderTone
                        Label {
                            anchors.centerIn: parent
                            text: "▣"
                            color: modelData.primary ? root.accent : root.textSecondary
                            font.pixelSize: 18
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label {
                            text: modelData.name + (modelData.primary ? " · Principal" : "")
                            color: root.textPrimary
                            font.pixelSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Label {
                            text: modelData.width + " × " + modelData.height
                                  + " · " + modelData.refreshRate + " Hz"
                                  + " · escala " + Number(modelData.scale).toFixed(2) + "×"
                            color: root.textSecondary
                            font.pixelSize: 8
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: displayNote.implicitHeight + 26
            radius: 14
            color: root.lightTheme ? "#F4F6F9" : "#0B0D12"
            border.width: 1
            border.color: root.borderTone
            Label {
                id: displayNote
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 13
                text: "Resolución, escala, orientación y disposición se detectan desde Qt/Wayland. Los cambios persistentes se habilitarán únicamente con confirmación y reversión automática."
                color: root.textSecondary
                font.pixelSize: 8
                wrapMode: Text.WordWrap
            }
        }

        ColumnLayout {
            visible: root.powerBackend.brightnessAvailable
            Layout.fillWidth: true
            spacing: 10

            Rectangle { Layout.fillWidth: true; height: 1; color: root.borderTone }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Brillo"
                    color: root.textPrimary
                    font.pixelSize: 13
                    font.bold: true
                    Layout.fillWidth: true
                }
                Label {
                    text: root.powerBackend.brightnessPercent + "%"
                    color: root.textSecondary
                    font.pixelSize: 9
                    font.bold: true
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "☀"; color: root.accent; font.pixelSize: 16; Layout.preferredWidth: 26 }
                Slider {
                    Layout.fillWidth: true
                    from: 1
                    to: 100
                    stepSize: 1
                    value: root.powerBackend.brightnessPercent
                    onMoved: root.powerBackend.setBrightness(Math.round(value))
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
                    text: "Luz nocturna"
                    color: root.textPrimary
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    Layout.fillWidth: true
                    text: root.backend.nightLightAvailable
                          ? "Reduce la luz azul usando una temperatura de color más cálida."
                          : "No disponible: Gammastep/Wayland no está instalado o no es compatible con esta sesión."
                    color: root.textSecondary
                    font.pixelSize: 8
                    wrapMode: Text.WordWrap
                }
            }
            Switch {
                enabled: root.backend.nightLightAvailable
                checked: root.backend.nightLightEnabled
                onToggled: {
                    if (checked !== root.backend.nightLightEnabled)
                        root.backend.setNightLightEnabled(checked)
                }
            }
        }

        ColumnLayout {
            visible: root.backend.nightLightAvailable
            Layout.fillWidth: true
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Más cálido"
                    color: root.textSecondary
                    font.pixelSize: 8
                }
                Slider {
                    id: temperatureSlider
                    Layout.fillWidth: true
                    from: 3000
                    to: 6500
                    stepSize: 100
                    value: root.backend.nightLightTemperature
                    onMoved: nightApplyTimer.restart()
                }
                Rectangle {
                    width: 64
                    height: 28
                    radius: 9
                    color: root.raised
                    border.width: 1
                    border.color: root.borderTone
                    Label {
                        anchors.centerIn: parent
                        text: Math.round(temperatureSlider.value) + " K"
                        color: root.textPrimary
                        font.pixelSize: 8
                        font.bold: true
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Button {
                    id: softButton
                    text: "Suave"
                    Layout.fillWidth: true
                    onClicked: root.backend.applyNightLightPreset("Suave")
                    background: Rectangle {
                        radius: 12
                        color: softButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                        border.color: softButton.hovered ? root.accent : root.borderTone
                    }
                    contentItem: Label {
                        text: softButton.text
                        color: root.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
                Button {
                    id: nightButton
                    text: "Nocturno"
                    Layout.fillWidth: true
                    onClicked: root.backend.applyNightLightPreset("Nocturno")
                    background: Rectangle {
                        radius: 12
                        color: nightButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                        border.color: nightButton.hovered ? root.accent : root.borderTone
                    }
                    contentItem: Label {
                        text: nightButton.text
                        color: root.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: "La programación por horario se añadirá mediante un servicio de usuario pequeño. El filtro manual ya usa Gammastep directamente; si el compositor no acepta control gamma, Settings lo informará."
                color: root.textSecondary
                font.pixelSize: 8
                wrapMode: Text.WordWrap
            }
        }
    }
}
