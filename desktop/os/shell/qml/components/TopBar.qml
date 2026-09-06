import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    property date now: new Date()
    signal systemClicked()

    height: 46
    color: "#e1091722"
    border.color: "#173544"

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 14
        spacing: 10

        Rectangle {
            width: 30
            height: 30
            radius: 9
            color: "#123544"
            border.color: "#29d9d1"
            Label { anchors.centerIn: parent; text: "MS"; color: "#c8fffb"; font.bold: true; font.pixelSize: 10 }
        }

        Label { text: "MurSchol OS"; color: "white"; font.pixelSize: 15; font.bold: true }
        Label {
            visible: root.width > 1120
            text: "Aprender hoy, un mundo mejor mañana"
            color: "#748f9c"
            font.pixelSize: 9
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            visible: root.width > 960
            height: 26
            width: workspaceLabel.implicitWidth + 20
            radius: 13
            color: "#143441"
            border.color: "#2f6877"
            Label {
                id: workspaceLabel
                anchors.centerIn: parent
                text: backend.workspace
                color: "#9fe7e2"
                font.pixelSize: 9
                font.bold: true
            }
        }

        Label {
            text: Qt.formatDateTime(root.now, "ddd, d MMM  hh:mm")
            color: "#d9e5e9"
            font.pixelSize: 11
        }

        Rectangle {
            visible: root.width > 1180
            width: 60
            height: 24
            radius: 12
            color: "#122a35"
            Label {
                anchors.centerIn: parent
                text: "CPU " + backend.cpuUsage + "%"
                color: "#81d9d4"
                font.pixelSize: 8
            }
        }

        Rectangle {
            visible: root.width > 1180
            width: 60
            height: 24
            radius: 12
            color: "#122a35"
            Label {
                anchors.centerIn: parent
                text: "RAM " + backend.memoryUsage + "%"
                color: "#a9d7a7"
                font.pixelSize: 8
            }
        }

        Label {
            visible: backend.batteryAvailable
            text: (backend.charging ? "⚡ " : "") + backend.batteryPercent + "%"
            color: backend.batteryPercent <= 20 ? "#efb36a" : "#d1e6d8"
            font.pixelSize: 10
            font.bold: backend.batteryPercent <= 20
        }

        Button {
            width: 34
            height: 32
            text: "⚙"
            onClicked: root.systemClicked()
            background: Rectangle { radius: 10; color: parent.hovered ? "#294758" : "transparent" }
            contentItem: Label {
                text: parent.text
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 15
            }
        }
    }
}
