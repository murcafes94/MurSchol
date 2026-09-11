import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    property bool lightTheme: false
    property color accent: "#D6A85F"

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
                        color: themeButton.checked ? (root.lightTheme ? "#F8EEDC" : "#3C2D24") : (root.lightTheme ? "#EEF1F5" : "#171C24")
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
            text: "El dorado cálido es la identidad predeterminada de MurSchol. Puedes elegir tonos azul, burdeos o neutros si prefieres otro énfasis."
            color: lightTheme ? "#5B6573" : "#9AA4B2"
            font.pixelSize: 9
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        RowLayout {
            spacing: 10
            Repeater {
                model: ["#D6A85F", "#B98B4E", "#2E5878", "#74504A", "#9A9188"]
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
                        color: animationButton.checked ? (root.lightTheme ? "#F8EEDC" : "#3C2D24") : (root.lightTheme ? "#EEF1F5" : "#171C24")
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

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: resetColumn.implicitHeight + 28
            radius: 16
            color: root.lightTheme ? "#F7F8FA" : "#171C24"
            border.color: root.lightTheme ? "#D8DEE9" : "#252B35"

            RowLayout {
                id: resetColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    Label {
                        text: "Restablecer apariencia"
                        color: root.lightTheme ? "#0B0D12" : "#F8FAFC"
                        font.bold: true
                        font.pixelSize: 11
                    }
                    Label {
                        Layout.fillWidth: true
                        text: "Restaura el tema oscuro MurSchol, el acento dorado, animaciones y dock visible. No modifica archivos, red ni aplicaciones."
                        color: root.lightTheme ? "#5B6573" : "#9AA4B2"
                        font.pixelSize: 8
                        wrapMode: Text.WordWrap
                    }
                }

                Button {
                    text: "Restablecer"
                    onClicked: resetDialog.open()
                    background: Rectangle {
                        radius: 12
                        color: parent.hovered ? "#5A3A32" : "#74504A"
                    }
                    contentItem: Label {
                        text: parent.text
                        color: "#FFFFFF"
                        font.bold: true
                        font.pixelSize: 9
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
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

    Dialog {
        id: resetDialog
        anchors.centerIn: parent
        modal: true
        title: "Restablecer apariencia"
        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted: {
            root.backend.setTheme("Oscuro")
            root.backend.setAccentColor("#D6A85F")
            root.backend.setAnimationMode("Normal")
            root.backend.setDockAutoHide(false)
            root.backend.setDockSize(64)
            root.backend.setDockMagnify(true)
        }

        contentItem: Label {
            width: 360
            text: "MurSchol volverá a la apariencia oficial oscura con acento dorado y dock visible. Tus archivos, aplicaciones y conexiones permanecerán intactos."
            color: root.lightTheme ? "#0B0D12" : "#F8FAFC"
            wrapMode: Text.WordWrap
            font.pixelSize: 10
        }
    }
}
