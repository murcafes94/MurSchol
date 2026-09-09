import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    property bool lightTheme: false
    property color accent: "#2563EB"

    implicitHeight: content.implicitHeight + 36
    radius: 20
    color: lightTheme ? "#FFFFFF" : "#11151C"
    border.color: lightTheme ? "#D8DEE9" : "#252B35"

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        spacing: 14

        Label { text: "Tema"; color: lightTheme ? "#0B0D12" : "#F8FAFC"; font.bold: true; font.pixelSize: 13 }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: ["Automático", "Claro", "Oscuro"]
                delegate: Button {
                    id: themeButton
                    required property string modelData
                    Layout.fillWidth: true
                    height: 48
                    checkable: true
                    checked: root.backend.theme === modelData
                    text: modelData
                    onClicked: root.backend.setTheme(modelData)
                    background: Rectangle {
                        radius: 14
                        color: themeButton.checked ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : (root.lightTheme ? "#EEF1F5" : "#171C24")
                        border.width: themeButton.checked ? 2 : 1
                        border.color: themeButton.checked ? root.accent : (root.lightTheme ? "#D8DEE9" : "#252B35")
                    }
                    contentItem: Label {
                        text: themeButton.text
                        color: root.lightTheme ? "#0B0D12" : "#F8FAFC"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 10
                        font.bold: themeButton.checked
                    }
                }
            }
        }

        Label { text: "Color de énfasis"; color: lightTheme ? "#0B0D12" : "#F8FAFC"; font.bold: true; font.pixelSize: 13 }
        Label {
            text: "Azul para interacción e identidad; rojo para un énfasis más fuerte. Blanco y negro estructuran el tema."
            color: lightTheme ? "#5B6573" : "#9AA4B2"
            font.pixelSize: 9
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        RowLayout {
            spacing: 10
            Repeater {
                model: ["#2563EB", "#3B82F6", "#123A7A", "#E63946"]
                delegate: Button {
                    id: accentButton
                    required property string modelData
                    width: 42
                    height: 42
                    onClicked: root.backend.setAccentColor(modelData)
                    background: Rectangle {
                        radius: 21
                        color: accentButton.modelData
                        border.width: root.backend.accentColor.toUpperCase() === accentButton.modelData.toUpperCase() ? 4 : 1
                        border.color: root.backend.accentColor.toUpperCase() === accentButton.modelData.toUpperCase() ? (root.lightTheme ? "#0B0D12" : "#F8FAFC") : "#9AA4B2"
                    }
                    contentItem: Item {}
                }
            }
        }

        Label { text: "Animaciones"; color: lightTheme ? "#0B0D12" : "#F8FAFC"; font.bold: true; font.pixelSize: 13 }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: ["Normal", "Reducidas", "Desactivadas"]
                delegate: Button {
                    id: animationButton
                    required property string modelData
                    Layout.fillWidth: true
                    height: 44
                    checkable: true
                    checked: root.backend.animationMode === modelData
                    text: modelData
                    onClicked: root.backend.setAnimationMode(modelData)
                    background: Rectangle {
                        radius: 13
                        color: animationButton.checked ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : (root.lightTheme ? "#EEF1F5" : "#171C24")
                        border.color: animationButton.checked ? root.accent : (root.lightTheme ? "#D8DEE9" : "#252B35")
                    }
                    contentItem: Label {
                        text: animationButton.text
                        color: root.lightTheme ? "#0B0D12" : "#F8FAFC"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 9
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: "Los cambios se guardan en la configuración común y el shell los detecta sin requerir una cuenta ni conexión a Internet."
            color: lightTheme ? "#5B6573" : "#9AA4B2"
            font.pixelSize: 9
            wrapMode: Text.WordWrap
        }
    }
}
