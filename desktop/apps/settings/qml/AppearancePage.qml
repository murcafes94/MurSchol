import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    property bool lightTheme: false
    property color accent: "#22d6cf"

    implicitHeight: content.implicitHeight + 36
    radius: 20
    color: lightTheme ? "#f9fbfc" : "#0d202a"
    border.color: lightTheme ? "#d5e0e4" : "#284653"

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        spacing: 14

        Label { text: "Tema"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 13 }
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
                        color: themeButton.checked ? (root.lightTheme ? "#d9eeee" : "#153c45") : (root.lightTheme ? "#edf2f4" : "#122832")
                        border.width: themeButton.checked ? 2 : 1
                        border.color: themeButton.checked ? root.accent : (root.lightTheme ? "#d2dde1" : "#294653")
                    }
                    contentItem: Label {
                        text: themeButton.text
                        color: root.lightTheme ? "#17303a" : "#eef6f8"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 10
                        font.bold: themeButton.checked
                    }
                }
            }
        }

        Label { text: "Color de énfasis"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 13 }
        RowLayout {
            spacing: 10
            Repeater {
                model: ["#22d6cf", "#38bdf8", "#6d8cff", "#9a71f5", "#55d58a", "#e6a85c"]
                delegate: Button {
                    id: accentButton
                    required property string modelData
                    width: 42
                    height: 42
                    onClicked: root.backend.setAccentColor(modelData)
                    background: Rectangle {
                        radius: 21
                        color: accentButton.modelData
                        border.width: root.backend.accentColor === accentButton.modelData ? 4 : 1
                        border.color: root.backend.accentColor === accentButton.modelData ? (root.lightTheme ? "#17303a" : "white") : "#60808d"
                    }
                    contentItem: Item {}
                }
            }
        }

        Label { text: "Animaciones"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 13 }
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
                        color: animationButton.checked ? (root.lightTheme ? "#d9eeee" : "#153c45") : (root.lightTheme ? "#edf2f4" : "#122832")
                        border.color: animationButton.checked ? root.accent : (root.lightTheme ? "#d2dde1" : "#294653")
                    }
                    contentItem: Label {
                        text: animationButton.text
                        color: root.lightTheme ? "#17303a" : "#eef6f8"
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
            color: lightTheme ? "#71838b" : "#668694"
            font.pixelSize: 9
            wrapMode: Text.WordWrap
        }
    }
}
