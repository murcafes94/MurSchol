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
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Perfil activo"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 13; Layout.fillWidth: true }
            Rectangle {
                width: recommendation.implicitWidth + 22
                height: 28
                radius: 14
                color: lightTheme ? "#dcefee" : "#153943"
                Label {
                    id: recommendation
                    anchors.centerIn: parent
                    text: "Recomendado: " + root.backend.recommendedProfile
                    color: root.accent
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: [
                    { name: "Ligero", detail: "Menos efectos y actividad secundaria", symbol: "◆" },
                    { name: "Normal", detail: "Equilibrio para el uso diario", symbol: "▣" },
                    { name: "Rendimiento", detail: "Más respuesta y precarga cuando sea útil", symbol: "▲" }
                ]
                delegate: Button {
                    id: profileButton
                    required property var modelData
                    Layout.fillWidth: true
                    height: 118
                    checkable: true
                    checked: root.backend.profile === modelData.name
                    onClicked: root.backend.setProfile(modelData.name)
                    background: Rectangle {
                        radius: 16
                        color: profileButton.checked ? (root.lightTheme ? "#dcefee" : "#143943") : (root.lightTheme ? "#edf2f4" : "#112630")
                        border.width: profileButton.checked ? 2 : 1
                        border.color: profileButton.checked ? root.accent : (root.lightTheme ? "#d1dde1" : "#294754")
                    }
                    contentItem: ColumnLayout {
                        spacing: 4
                        Label { Layout.alignment: Qt.AlignHCenter; text: profileButton.modelData.symbol; color: root.accent; font.pixelSize: 19; font.bold: true }
                        Label { Layout.alignment: Qt.AlignHCenter; text: profileButton.modelData.name; color: root.lightTheme ? "#18313b" : "white"; font.pixelSize: 11; font.bold: true }
                        Label {
                            Layout.fillWidth: true
                            text: profileButton.modelData.detail
                            color: root.lightTheme ? "#6c7f87" : "#7895a1"
                            font.pixelSize: 8
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: "El perfil ya controla sondeo y parte de las animaciones. CPU, compositor, cachés y precarga se conectarán únicamente cuando la política esté probada en hardware real."
            color: lightTheme ? "#71838b" : "#668694"
            font.pixelSize: 9
            wrapMode: Text.WordWrap
        }
    }
}
