import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var backend
    property bool lightTheme: false
    property color accent: "#2563EB"
    spacing: 14

    readonly property color surface: lightTheme ? "#FFFFFF" : "#11151C"
    readonly property color raised: lightTheme ? "#F4F6F9" : "#171C24"
    readonly property color border: lightTheme ? "#D8DEE9" : "#252B35"
    readonly property color textPrimary: lightTheme ? "#0B0D12" : "#F8FAFC"
    readonly property color textSecondary: lightTheme ? "#5B6573" : "#9AA4B2"

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 102
        radius: 18
        color: root.surface
        border.color: root.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Rectangle {
                width: 48
                height: 48
                radius: 15
                color: root.lightTheme ? "#EAF1FF" : "#123A7A"
                Label { anchors.centerIn: parent; text: "⇄"; color: root.accent; font.pixelSize: 22; font.bold: true }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label { text: "Una experiencia, varios formatos"; color: root.textPrimary; font.pixelSize: 16; font.bold: true }
                Label {
                    text: "MurSchol muestra el estado real de cada capa sin exponer complejidad técnica en el flujo normal de uso."
                    color: root.textSecondary
                    font.pixelSize: 9
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }

    Repeater {
        model: [
            {
                title: "Linux nativo",
                subtitle: "Aplicaciones Debian, Qt, GTK, AppImage y herramientas del sistema.",
                state: "Disponible",
                available: true,
                symbol: "L"
            },
            {
                title: "Flatpak",
                subtitle: "Aplicaciones aisladas y actualizables desde repositorios Flatpak.",
                state: backend.flatpakAvailable ? "Disponible" : "No instalado",
                available: backend.flatpakAvailable,
                symbol: "F"
            },
            {
                title: "Android",
                subtitle: "APK mediante Waydroid cuando el hardware y el kernel lo permiten.",
                state: backend.waydroidAvailable ? "Waydroid disponible" : "Waydroid no instalado",
                available: backend.waydroidAvailable,
                symbol: "A"
            },
            {
                title: "Windows",
                subtitle: "EXE/MSI mediante Wine; Bottles funciona como capa gráfica opcional.",
                state: backend.wineAvailable ? (backend.bottlesAvailable ? "Wine + Bottles" : "Wine disponible") : (backend.bottlesAvailable ? "Bottles disponible" : "No instalado"),
                available: backend.wineAvailable || backend.bottlesAvailable,
                symbol: "W"
            }
        ]

        delegate: Rectangle {
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: 92
            radius: 17
            color: root.surface
            border.width: 1
            border.color: root.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Rectangle {
                    width: 44
                    height: 44
                    radius: 14
                    color: modelData.available
                           ? (root.lightTheme ? "#EAF1FF" : "#123A7A")
                           : root.raised
                    Label {
                        anchors.centerIn: parent
                        text: modelData.symbol
                        color: modelData.available ? root.accent : root.textSecondary
                        font.pixelSize: 16
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label { text: modelData.title; color: root.textPrimary; font.pixelSize: 13; font.bold: true }
                    Label {
                        text: modelData.subtitle
                        color: root.textSecondary
                        font.pixelSize: 9
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    width: stateLabel.implicitWidth + 22
                    height: 30
                    radius: 15
                    color: modelData.available
                           ? (root.lightTheme ? "#EAF1FF" : "#123A7A")
                           : root.raised
                    border.width: 1
                    border.color: modelData.available ? root.accent : root.border
                    Label {
                        id: stateLabel
                        anchors.centerIn: parent
                        text: modelData.state
                        color: modelData.available ? (root.lightTheme ? "#123A7A" : "#DCE8FF") : root.textSecondary
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: criterionColumn.implicitHeight + 30
        radius: 17
        color: root.raised
        border.width: 1
        border.color: root.border

        ColumnLayout {
            id: criterionColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 15
            spacing: 5
            Label { text: "Criterio de compatibilidad"; color: root.textPrimary; font.pixelSize: 12; font.bold: true }
            Label {
                Layout.fillWidth: true
                text: "La tienda y el gestor de aplicaciones usarán Nativa, Excelente, Compatible, Experimental o No compatible. Tener Wine o Waydroid instalado no garantiza que cualquier aplicación vaya a funcionar correctamente."
                color: root.textSecondary
                font.pixelSize: 9
                wrapMode: Text.WordWrap
            }
        }
    }
}
