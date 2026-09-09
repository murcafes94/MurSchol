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

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 16

        Label {
            text: "Batería"
            color: root.textPrimary
            font.pixelSize: 13
            font.bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: root.backend.batteryAvailable ? 96 : 68
            radius: 15
            color: root.raised
            border.width: 1
            border.color: root.borderTone

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
                    border.color: root.backend.batteryAvailable ? root.accent : root.textSecondary
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
                        color: root.backend.batteryAvailable ? root.accent : root.textSecondary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        text: root.backend.batteryAvailable ? root.backend.batteryPercent + "%" : "Sin batería detectada"
                        color: root.textPrimary
                        font.pixelSize: root.backend.batteryAvailable ? 22 : 12
                        font.bold: true
                    }
                    Label {
                        Layout.fillWidth: true
                        text: root.backend.batteryAvailable
                              ? root.backend.batteryState + (root.backend.batteryTimeText.length > 0 ? " · " + root.backend.batteryTimeText : "")
                              : "Es normal en una máquina virtual o un PC de escritorio sin batería."
                        color: root.textSecondary
                        font.pixelSize: 9
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.borderTone }

        Label {
            text: "Modo de rendimiento"
            color: root.textPrimary
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
                        color: parent.checked
                               ? (root.lightTheme ? "#EAF1FF" : "#123A7A")
                               : root.raised
                        border.width: parent.checked ? 2 : 1
                        border.color: parent.checked ? root.accent : root.borderTone
                    }
                    contentItem: Label {
                        text: parent.text
                        color: root.textPrimary
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
            color: root.textSecondary
            font.pixelSize: 8
            wrapMode: Text.WordWrap
        }

        ColumnLayout {
            visible: root.backend.brightnessAvailable
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
                Rectangle {
                    width: 52
                    height: 30
                    radius: 10
                    color: root.raised
                    border.width: 1
                    border.color: root.borderTone
                    Label {
                        anchors.centerIn: parent
                        text: root.backend.brightnessPercent + "%"
                        color: root.textPrimary
                        font.pixelSize: 9
                        font.bold: true
                    }
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
                color: root.textSecondary
                font.pixelSize: 8
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: root.borderTone }

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label {
                    text: "Suspensión"
                    color: root.textPrimary
                    font.pixelSize: 13
                    font.bold: true
                }
                Label {
                    Layout.fillWidth: true
                    text: "Suspende el equipo mediante systemd-logind y respeta permisos e inhibidores del sistema."
                    color: root.textSecondary
                    font.pixelSize: 8
                    wrapMode: Text.WordWrap
                }
            }
            Button {
                id: suspendButton
                text: "Suspender ahora"
                onClicked: root.backend.suspendNow()
                background: Rectangle {
                    radius: 12
                    color: suspendButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                    border.width: 1
                    border.color: root.accent
                }
                contentItem: Label {
                    text: suspendButton.text
                    color: root.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: pendingNote.implicitHeight + 26
            radius: 14
            color: root.lightTheme ? "#F4F6F9" : "#0B0D12"
            border.width: 1
            border.color: root.borderTone
            Label {
                id: pendingNote
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 13
                text: "Los temporizadores automáticos de apagar pantalla, suspensión y cierre de tapa se añadirán cuando estén conectados a un servicio de sesión persistente; no mostramos controles que todavía no tengan efecto real."
                color: root.textSecondary
                font.pixelSize: 8
                wrapMode: Text.WordWrap
            }
        }
    }
}
