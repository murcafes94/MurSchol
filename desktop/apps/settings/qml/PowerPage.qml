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

        Label {
            text: "Batería"
            color: root.lightTheme ? "#1b323c" : "white"
            font.pixelSize: 13
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: root.backend.batteryAvailable ? 94 : 66
            radius: 15
            color: root.lightTheme ? "#edf2f4" : "#112630"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                Rectangle {
                    width: 62
                    height: 34
                    radius: 8
                    color: "transparent"
                    border.width: 2
                    border.color: root.backend.batteryAvailable ? root.accent : (root.lightTheme ? "#8a9aa0" : "#607985")
                    Rectangle {
                        visible: root.backend.batteryAvailable
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 5
                        width: Math.max(4, (parent.width - 10) * root.backend.batteryPercent / 100)
                        radius: 4
                        color: root.accent
                    }
                    Rectangle {
                        width: 4
                        height: 14
                        radius: 2
                        anchors.left: parent.right
                        anchors.leftMargin: 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.backend.batteryAvailable ? root.accent : (root.lightTheme ? "#8a9aa0" : "#607985")
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        text: root.backend.batteryAvailable ? root.backend.batteryPercent + "%" : "Sin batería detectada"
                        color: root.lightTheme ? "#18313b" : "#edf5f7"
                        font.pixelSize: root.backend.batteryAvailable ? 22 : 12
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: root.backend.batteryAvailable
                              ? root.backend.batteryState + (root.backend.batteryTimeText.length > 0 ? " · " + root.backend.batteryTimeText : "")
                              : "Es normal en una máquina virtual o un PC de escritorio sin batería."
                        color: root.lightTheme ? "#6b7f88" : "#75929e"
                        font.pixelSize: 9
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.lightTheme ? "#dce5e8" : "#23414e" }

        Label {
            text: "Modo de rendimiento"
            color: root.lightTheme ? "#1b323c" : "white"
            font.pixelSize: 13
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: ["Ligero", "Normal", "Rendimiento"]
                delegate: Button {
                    required property string modelData
                    Layout.fillWidth: true
                    height: 46
                    checkable: true
                    checked: root.settingsBackend.profile === modelData
                    text: modelData
                    onClicked: root.settingsBackend.setProfile(modelData)
                    background: Rectangle {
                        radius: 13
                        color: parent.checked ? (root.lightTheme ? "#dcefee" : "#143943")
                                              : (root.lightTheme ? "#edf2f4" : "#112630")
                        border.width: parent.checked ? 2 : 1
                        border.color: parent.checked ? root.accent : (root.lightTheme ? "#d1dde1" : "#294754")
                    }
                    contentItem: Label {
                        text: parent.text
                        color: root.lightTheme ? "#18313b" : "#edf5f7"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                        font.bold: parent.checked
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: "Estos perfiles coordinan la experiencia MurSchol; todavía no fuerzan frecuencias de CPU o GPU."
            color: root.lightTheme ? "#71838b" : "#668694"
            font.pixelSize: 8
            wrapMode: Text.WordWrap
        }

        ColumnLayout {
            visible: root.backend.brightnessAvailable
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
                    text: root.backend.brightnessPercent + "%"
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
                    value: root.backend.brightnessPercent
                    onMoved: root.backend.setBrightness(Math.round(value))
                }
            }

            Label {
                text: root.backend.brightnessDevice.length > 0 ? "Control: " + root.backend.brightnessDevice : ""
                visible: text.length > 0
                color: root.lightTheme ? "#7a8b92" : "#678490"
                font.pixelSize: 8
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.lightTheme ? "#dce5e8" : "#23414e" }

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Suspensión"
                    color: root.lightTheme ? "#1b323c" : "white"
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    Layout.fillWidth: true
                    text: "Suspende el equipo mediante systemd-logind y respeta los permisos e inhibidores del sistema."
                    color: root.lightTheme ? "#71838b" : "#77939f"
                    font.pixelSize: 8
                    wrapMode: Text.WordWrap
                }
            }
            Button {
                text: "Suspender ahora"
                onClicked: root.backend.suspendNow()
                background: Rectangle {
                    radius: 12
                    color: parent.hovered ? root.accent : (root.lightTheme ? "#dcebed" : "#153744")
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
            text: "Los temporizadores automáticos de apagar pantalla, suspensión y cierre de tapa se añadirán cuando estén conectados a un servicio de sesión persistente; no se muestran controles que todavía no tengan efecto real."
            color: root.lightTheme ? "#71838b" : "#668694"
            font.pixelSize: 8
            wrapMode: Text.WordWrap
        }
    }
}
