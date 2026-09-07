import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    property var powerBackend
    property bool lightTheme: false
    property color accent: "#22d6cf"

    Layout.fillWidth: true
    height: contentColumn.implicitHeight + 36
    radius: 20
    color: lightTheme ? "#f9fbfc" : "#0d202a"
    border.color: lightTheme ? "#d5e0e4" : "#284653"

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
        anchors.margins: 18
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "Pantallas conectadas"
                color: root.lightTheme ? "#1b323c" : "white"
                font.pixelSize: 13
                font.bold: true
                Layout.fillWidth: true
            }
            Label {
                text: root.backend.screens.length + (root.backend.screens.length === 1 ? " pantalla" : " pantallas")
                color: root.accent
                font.pixelSize: 9
                font.bold: true
            }
        }

        Repeater {
            model: root.backend.screens
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 78
                radius: 14
                color: root.lightTheme ? "#edf2f4" : "#112630"
                border.width: modelData.primary ? 1 : 0
                border.color: root.accent

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 12

                    Rectangle {
                        width: 58
                        height: 38
                        radius: 6
                        color: root.lightTheme ? "#dbe6e9" : "#173441"
                        border.color: modelData.primary ? root.accent : (root.lightTheme ? "#aebdc2" : "#42606c")
                        Label {
                            anchors.centerIn: parent
                            text: "▣"
                            color: modelData.primary ? root.accent : (root.lightTheme ? "#526a73" : "#7895a1")
                            font.pixelSize: 18
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Label {
                            text: modelData.name + (modelData.primary ? " · Principal" : "")
                            color: root.lightTheme ? "#18313b" : "#edf5f7"
                            font.pixelSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        Label {
                            text: modelData.width + " × " + modelData.height
                                  + " · " + modelData.refreshRate + " Hz"
                                  + " · escala " + Number(modelData.scale).toFixed(2) + "×"
                            color: root.lightTheme ? "#6b7f88" : "#75929e"
                            font.pixelSize: 8
                        }
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: "Resolución, escala, orientación y disposición ya se detectan desde Qt/Wayland. Los cambios persistentes se habilitarán solo con confirmación y reversión automática para evitar dejar una pantalla inutilizable."
            color: root.lightTheme ? "#71838b" : "#668694"
            font.pixelSize: 8
            wrapMode: Text.WordWrap
        }

        ColumnLayout {
            visible: root.powerBackend.brightnessAvailable
            Layout.fillWidth: true
            spacing: 10

            Rectangle { Layout.fillWidth: true; height: 1; color: root.lightTheme ? "#dce5e8" : "#23414e" }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Brillo"
                    color: root.lightTheme ? "#1b323c" : "white"
                    font.pixelSize: 13
                    font.bold: true
                    Layout.fillWidth: true
                }
                Label {
                    text: root.powerBackend.brightnessPercent + "%"
                    color: root.lightTheme ? "#334b55" : "#c8d9df"
                    font.pixelSize: 9
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

        Rectangle { Layout.fillWidth: true; height: 1; color: root.lightTheme ? "#dce5e8" : "#23414e" }

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Luz nocturna"
                    color: root.lightTheme ? "#1b323c" : "white"
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    Layout.fillWidth: true
                    text: root.backend.nightLightAvailable
                          ? "Reduce la luz azul usando una temperatura de color más cálida."
                          : "No disponible: Gammastep/Wayland no está instalado o no es compatible con esta sesión."
                    color: root.lightTheme ? "#71838b" : "#77939f"
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
                    color: root.lightTheme ? "#7a8b92" : "#678490"
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
                Label {
                    text: Math.round(temperatureSlider.value) + " K"
                    color: root.lightTheme ? "#334b55" : "#c8d9df"
                    font.pixelSize: 8
                    Layout.preferredWidth: 55
                    horizontalAlignment: Text.AlignRight
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Button {
                    text: "Suave"
                    Layout.fillWidth: true
                    onClicked: root.backend.applyNightLightPreset("Suave")
                    background: Rectangle {
                        radius: 12
                        color: parent.hovered ? root.accent : (root.lightTheme ? "#e5edef" : "#15313c")
                        border.color: root.accent
                    }
                    contentItem: Label {
                        text: parent.text
                        color: parent.parent.hovered ? "#07131d" : (root.lightTheme ? "#29434d" : "#d9eef0")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
                Button {
                    text: "Nocturno"
                    Layout.fillWidth: true
                    onClicked: root.backend.applyNightLightPreset("Nocturno")
                    background: Rectangle {
                        radius: 12
                        color: parent.hovered ? root.accent : (root.lightTheme ? "#e5edef" : "#15313c")
                        border.color: root.accent
                    }
                    contentItem: Label {
                        text: parent.text
                        color: parent.parent.hovered ? "#07131d" : (root.lightTheme ? "#29434d" : "#d9eef0")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                text: "La programación por horario se añadirá mediante un servicio de usuario pequeño. El filtro manual y sus presets ya usan Gammastep directamente; si el compositor no acepta control gamma, Settings lo informará en lugar de simularlo."
                color: root.lightTheme ? "#71838b" : "#668694"
                font.pixelSize: 8
                wrapMode: Text.WordWrap
            }
        }
    }
}
