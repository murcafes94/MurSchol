import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    signal systemClicked()
    height: 58
    color: "#d80b1722"
    border.color: "#183848"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 22
        anchors.rightMargin: 16
        spacing: 14

        Rectangle {
            width: 36; height: 36; radius: 11
            color: "#123544"; border.color: "#29d9d1"
            Label { anchors.centerIn: parent; text: "MS"; color: "#c8fffb"; font.bold: true }
        }
        Label { text: "MurSchol OS"; color: "white"; font.pixelSize: 18; font.bold: true }
        Label { text: "Ligero • Versátil • Preparado para el futuro"; color: "#7f99a7"; font.pixelSize: 12 }
        Item { Layout.fillWidth: true }
        Label { text: Qt.formatDateTime(new Date(), "ddd, d MMM  hh:mm"); color: "#d2e0e5" }
        Label { text: "CPU " + backend.cpuUsage + "%"; color: "#8edbd5"; font.pixelSize: 12 }
        Label { text: "RAM " + backend.memoryUsage + "%"; color: "#a9d7a7"; font.pixelSize: 12 }
        Button {
            text: "⚙"
            onClicked: root.systemClicked()
            background: Rectangle { radius: 10; color: parent.hovered ? "#294758" : "#172934" }
            contentItem: Label { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 18 }
        }
    }
}
