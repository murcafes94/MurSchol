import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    property date now: new Date()
    signal systemClicked()

    height: 46
    color: "#F20B0D12"
    border.color: "#252B35"

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
            color: backend.accentColor
            border.color: "#5B8CFF"
            Label {
                anchors.centerIn: parent
                text: "MS"
                color: "#FFFFFF"
                font.bold: true
                font.pixelSize: 10
            }
        }

        Label { text: "MurSchol OS"; color: "#F8FAFC"; font.pixelSize: 15; font.bold: true }
        Label {
            visible: root.width > 1120
            text: "Aprender hoy, un mundo mejor mañana"
            color: "#8B95A5"
            font.pixelSize: 9
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            visible: root.width > 960
            height: 26
            width: workspaceLabel.implicitWidth + 20
            radius: 13
            color: "#151A23"
            border.color: backend.accentColor
            Label {
                id: workspaceLabel
                anchors.centerIn: parent
                text: backend.workspace
                color: "#F8FAFC"
                font.pixelSize: 9
                font.bold: true
            }
        }

        Label {
            text: Qt.formatDateTime(root.now, "ddd, d MMM  hh:mm")
            color: "#E5E7EB"
            font.pixelSize: 11
        }

        Rectangle {
            visible: root.width > 1180
            width: 60
            height: 24
            radius: 12
            color: "#171C24"
            border.color: "#252B35"
            Label {
                anchors.centerIn: parent
                text: "CPU " + backend.cpuUsage + "%"
                color: backend.accentColor
                font.pixelSize: 8
                font.bold: true
            }
        }

        Rectangle {
            visible: root.width > 1180
            width: 60
            height: 24
            radius: 12
            color: "#171C24"
            border.color: "#252B35"
            Label {
                anchors.centerIn: parent
                text: "RAM " + backend.memoryUsage + "%"
                color: "#F8FAFC"
                font.pixelSize: 8
            }
        }

        Label {
            visible: backend.batteryAvailable
            text: (backend.charging ? "⚡ " : "") + backend.batteryPercent + "%"
            color: backend.batteryPercent <= 20 ? "#E63946" : "#F8FAFC"
            font.pixelSize: 10
            font.bold: backend.batteryPercent <= 20
        }

        Button {
            width: 34
            height: 32
            text: "⚙"
            onClicked: root.systemClicked()
            background: Rectangle {
                radius: 10
                color: parent.hovered ? "#1E3A8A" : "transparent"
                border.color: parent.hovered ? backend.accentColor : "transparent"
            }
            contentItem: Label {
                text: parent.text
                color: "#F8FAFC"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 15
            }
        }
    }
}
