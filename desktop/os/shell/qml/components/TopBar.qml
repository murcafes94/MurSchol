import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    property date now: new Date()
    signal systemClicked()

    height: 36
    color: "#F2181A1F"
    border.width: 0

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#40352B24"
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Rectangle {
            width: 24
            height: 24
            radius: 12
            color: "#16191F"
            border.width: 1
            border.color: backend.accentColor
            Label {
                anchors.centerIn: parent
                text: "✝"
                color: backend.accentColor
                font.pixelSize: 13
                font.bold: true
            }
        }

        Label {
            text: "MurSchol OS"
            color: "#F5F1E8"
            font.pixelSize: 13
            font.bold: true
        }

        Rectangle {
            width: 1
            height: 16
            color: "#59483A2C"
        }

        Label {
            visible: root.width > 920
            text: "Ad maiorem Dei gloriam"
            color: "#D9C8AC"
            font.pixelSize: 11
            font.italic: true
            font.family: "Noto Serif"
        }

        Item { Layout.fillWidth: true }

        Label {
            text: Qt.formatDateTime(root.now, "ddd d 'de' MMMM   hh:mm")
            color: "#F3EFE7"
            font.pixelSize: 11
            font.weight: Font.Medium
            Layout.alignment: Qt.AlignHCenter
        }

        Item { Layout.fillWidth: true }

        Label {
            visible: root.width > 980
            text: "▣"
            color: "#ECE8DF"
            font.pixelSize: 12
        }
        Label {
            text: "⌁"
            color: "#ECE8DF"
            font.pixelSize: 16
        }
        Label {
            text: "◕"
            color: "#ECE8DF"
            font.pixelSize: 13
        }
        Label {
            visible: backend.batteryAvailable
            text: (backend.charging ? "⚡" : "▰") + " " + backend.batteryPercent + "%"
            color: backend.batteryPercent <= 20 ? "#E07A68" : "#ECE8DF"
            font.pixelSize: 10
        }
        Label {
            text: "●"
            color: "#ECE8DF"
            font.pixelSize: 8
        }

        Label {
            visible: root.width > 1120
            text: "Ora. Estudia. Sirve."
            color: "#D9C8AC"
            font.pixelSize: 10
            font.italic: true
            font.family: "Noto Serif"
        }

        Button {
            width: 28
            height: 28
            text: "⚙"
            onClicked: root.systemClicked()
            background: Rectangle {
                radius: 9
                color: parent.hovered ? "#332A211B" : "transparent"
                border.width: parent.hovered ? 1 : 0
                border.color: backend.accentColor
            }
            contentItem: Label {
                text: parent.text
                color: parent.hovered ? backend.accentColor : "#ECE8DF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
            }
        }
    }
}
