import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    property date now: new Date()
    signal systemClicked()
    height: 58
    color: "#d80b1722"
    border.color: "#183848"

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

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
        Label {
            visible: root.width > 980
            text: "Ligero • Versátil • Preparado para el futuro"
            color: "#7f99a7"; font.pixelSize: 12
        }

        Rectangle {
            visible: root.width > 1120
            height: 30
            width: workspaceLabel.implicitWidth + 24
            radius: 15
            color: "#173947"
            border.color: "#2f6877"
            Label {
                id: workspaceLabel
                anchors.centerIn: parent
                text: "Espacio: " + backend.workspace
                color: "#9fe7e2"
                font.pixelSize: 11
                font.bold: true
            }
        }

        Item { Layout.fillWidth: true }

        Label { text: Qt.formatDateTime(root.now, "ddd, d MMM  hh:mm"); color: "#d2e0e5" }
        Label { visible: root.width > 1050; text: "CPU " + backend.cpuUsage + "%"; color: "#8edbd5"; font.pixelSize: 12 }
        Label { visible: root.width > 1050; text: "RAM " + backend.memoryUsage + "%"; color: "#a9d7a7"; font.pixelSize: 12 }
        Label {
            visible: backend.batteryAvailable
            text: (backend.charging ? "⚡ " : "") + backend.batteryPercent + "%"
            color: backend.batteryPercent <= 20 ? "#efb36a" : "#d1e6d8"
            font.pixelSize: 12
            font.bold: backend.batteryPercent <= 20
        }

        Button {
            text: "⚙"
            onClicked: root.systemClicked()
            background: Rectangle { radius: 10; color: parent.hovered ? "#294758" : "#172934" }
            contentItem: Label {
                text: parent.text; color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 18
            }
        }
    }
}
