import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    width: 330; height: 212; radius: 22
    color: "#bd102430"; border.color: "#315666"

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 7
        Label { text: "Perfil adaptativo"; color: "white"; font.bold: true; font.pixelSize: 16 }
        Label {
            text: "Recomendado para este equipo: " + root.backend.recommendedProfile
            color: "#78d8d1"; font.pixelSize: 10
        }

        Repeater {
            model: ["Ligero", "Normal", "Rendimiento"]
            delegate: RadioButton {
                required property string modelData
                Layout.fillWidth: true
                text: modelData
                checked: root.backend.profile === modelData
                onClicked: root.backend.setProfile(modelData)
                contentItem: Label {
                    text: parent.text
                    color: parent.checked ? "#70e6df" : "#c3d0d6"
                    leftPadding: parent.indicator.width + 8
                    verticalAlignment: Text.AlignVCenter
                    font.bold: parent.checked
                }
            }
        }

        Button {
            Layout.fillWidth: true
            visible: root.backend.profile !== root.backend.recommendedProfile
            text: "Aplicar recomendado"
            onClicked: root.backend.applyRecommendedProfile()
            background: Rectangle { radius: 11; color: parent.hovered ? "#267a80" : "#205f67" }
            contentItem: Label {
                text: parent.text; color: "white"; font.bold: true
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
