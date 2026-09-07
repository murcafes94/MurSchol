import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var backend
    property bool lightTheme: false
    property color accent: "#29d9d1"
    spacing: 14

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 100
        radius: 18
        color: lightTheme ? "#f8fbfc" : "#0d202b"
        border.color: lightTheme ? "#d7e2e6" : "#234454"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Rectangle {
                width: 48
                height: 48
                radius: 15
                color: lightTheme ? "#dcefed" : "#123d49"
                Label { anchors.centerIn: parent; text: "⇄"; color: root.accent; font.pixelSize: 22; font.bold: true }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label { text: "Una sola experiencia, varios tipos de aplicaciones"; color: lightTheme ? "#17303a" : "#f1f6f8"; font.pixelSize: 16; font.bold: true }
                Label {
                    text: "MurSchol no oculta el estado real: cada capa aparece como disponible, no instalada o pendiente de configuración."
                    color: lightTheme ? "#657983" : "#7f9aa6"
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
                subtitle: "EXE/MSI mediante Wine; Bottles se usa como capa gráfica opcional.",
                state: backend.wineAvailable ? (backend.bottlesAvailable ? "Wine + Bottles" : "Wine disponible") : (backend.bottlesAvailable ? "Bottles disponible" : "No instalado"),
                available: backend.wineAvailable || backend.bottlesAvailable,
                symbol: "W"
            }
        ]

        delegate: Rectangle {
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: 90
            radius: 17
            color: lightTheme ? "#f8fbfc" : "#0d202b"
            border.color: lightTheme ? "#d7e2e6" : "#234454"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Rectangle {
                    width: 44
                    height: 44
                    radius: 14
                    color: modelData.available
                           ? (lightTheme ? "#dcefed" : "#123d49")
                           : (lightTheme ? "#eceff0" : "#202d34")
                    Label {
                        anchors.centerIn: parent
                        text: modelData.symbol
                        color: modelData.available ? root.accent : (lightTheme ? "#8b999f" : "#657983")
                        font.pixelSize: 16
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label { text: modelData.title; color: lightTheme ? "#17303a" : "#f1f6f8"; font.pixelSize: 13; font.bold: true }
                    Label {
                        text: modelData.subtitle
                        color: lightTheme ? "#657983" : "#7f9aa6"
                        font.pixelSize: 9
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    width: stateLabel.implicitWidth + 20
                    height: 30
                    radius: 15
                    color: modelData.available
                           ? (lightTheme ? "#dcefe7" : "#14392f")
                           : (lightTheme ? "#eceff0" : "#202d34")
                    Label {
                        id: stateLabel
                        anchors.centerIn: parent
                        text: modelData.state
                        color: modelData.available
                               ? (lightTheme ? "#2d6752" : "#8cddb9")
                               : (lightTheme ? "#6f7f86" : "#82949c")
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 86
        radius: 17
        color: lightTheme ? "#f4f7f8" : "#0b1b25"
        border.color: lightTheme ? "#d8e1e4" : "#203c49"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 4
            Label { text: "Criterio de compatibilidad"; color: lightTheme ? "#203942" : "#e8f1f4"; font.pixelSize: 12; font.bold: true }
            Label {
                Layout.fillWidth: true
                text: "La tienda y el gestor de aplicaciones usarán etiquetas Nativa, Excelente, Compatible, Experimental o No compatible. La presencia de Wine o Waydroid no significa que cualquier aplicación vaya a funcionar perfectamente."
                color: lightTheme ? "#697d86" : "#7d96a1"
                font.pixelSize: 9
                wrapMode: Text.WordWrap
            }
        }
    }
}
