import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    width: 300; height: 168; radius: 22
    color: "#bd102430"; border.color: "#315666"

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 8
        Label { text: "Perfil adaptativo"; color: "white"; font.bold: true; font.pixelSize: 16 }
        Label { text: "Se adapta al hardware del equipo"; color: "#7895a1"; font.pixelSize: 10 }
        Repeater {
            model: ["Ligero", "Normal", "Rendimiento"]
            delegate: RadioButton {
                required property string modelData
                Layout.fillWidth: true
                text: modelData
                checked: root.backend.profile === modelData
                onClicked: root.backend.setProfile(modelData)
                contentItem: Label { text: parent.text; color: parent.checked ? "#70e6df" : "#c3d0d6"; leftPadding: parent.indicator.width + 8; verticalAlignment: Text.AlignVCenter; font.bold: parent.checked }
            }
        }
    }
}
