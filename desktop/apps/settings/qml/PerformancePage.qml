import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    property bool lightTheme: false
    property color accent: "#2563EB"

    implicitHeight: content.implicitHeight + 40
    radius: 18
    color: lightTheme ? "#FFFFFF" : "#11151C"
    border.color: lightTheme ? "#D8DEE9" : "#252B35"

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Label { text: "Perfil del sistema"; color: lightTheme ? "#0B0D12" : "#F8FAFC"; font.bold: true; font.pixelSize: 13 }
                Label { text: "Controla la frecuencia de sondeo y el nivel de movimiento visual ya conectado."; color: lightTheme ? "#5B6573" : "#9AA4B2"; font.pixelSize: 9 }
            }
            Rectangle {
                width: recommendation.implicitWidth + 24
                height: 30
                radius: 15
                color: lightTheme ? "#EAF1FF" : "#123A7A"
                border.width: 1
                border.color: root.accent
                Label {
                    id: recommendation
                    anchors.centerIn: parent
                    text: "Recomendado: " + root.backend.recommendedProfile
                    color: root.lightTheme ? "#123A7A" : "#DCE8FF"
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Repeater {
                model: [
                    { name: "Ligero", detail: "Menos efectos y menos sondeo", symbol: "◆" },
                    { name: "Normal", detail: "Equilibrio para uso diario", symbol: "▣" },
                    { name: "Rendimiento", detail: "Respuesta visual más frecuente", symbol: "▲" }
                ]
                delegate: Button {
                    id: profileButton
                    required property var modelData
                    Layout.fillWidth: true
                    height: 122
                    checkable: true
                    checked: root.backend.profile === modelData.name
                    onClicked: root.backend.setProfile(modelData.name)
                    background: Rectangle {
                        radius: 16
                        color: profileButton.checked
                               ? (root.lightTheme ? "#EAF1FF" : "#123A7A")
                               : (root.lightTheme ? "#F4F6F9" : "#171C24")
                        border.width: profileButton.checked ? 2 : 1
                        border.color: profileButton.checked ? root.accent : (root.lightTheme ? "#D8DEE9" : "#252B35")
                    }
                    contentItem: ColumnLayout {
                        spacing: 5
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: profileButton.modelData.symbol
                            color: profileButton.checked ? root.accent : (root.lightTheme ? "#5B6573" : "#9AA4B2")
                            font.pixelSize: 20
                            font.bold: true
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: profileButton.modelData.name
                            color: root.lightTheme ? "#0B0D12" : "#F8FAFC"
                            font.pixelSize: 11
                            font.bold: true
                        }
                        Label {
                            Layout.fillWidth: true
                            text: profileButton.modelData.detail
                            color: root.lightTheme ? "#5B6573" : "#9AA4B2"
                            font.pixelSize: 8
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: note.implicitHeight + 26
            radius: 14
            color: lightTheme ? "#F4F6F9" : "#0B0D12"
            border.width: 1
            border.color: lightTheme ? "#D8DEE9" : "#252B35"
            Label {
                id: note
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 13
                text: "MurSchol no cambia todavía governors de CPU, GPU ni políticas del compositor. Esas optimizaciones se activarán únicamente después de validarlas en hardware real."
                color: root.lightTheme ? "#5B6573" : "#9AA4B2"
                font.pixelSize: 9
                wrapMode: Text.WordWrap
            }
        }
    }
}
