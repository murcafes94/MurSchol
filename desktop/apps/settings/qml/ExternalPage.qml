import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property bool lightTheme: false
    property color accent: "#22d6cf"
    property string description: ""
    property string buttonText: "Abrir"
    property bool available: false
    signal openRequested()

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

        Label {
            Layout.fillWidth: true
            text: root.description
            color: root.lightTheme ? "#4f6670" : "#8ca6b0"
            font.pixelSize: 10
            wrapMode: Text.WordWrap
        }

        Button {
            text: root.buttonText
            enabled: root.available
            onClicked: root.openRequested()
            background: Rectangle {
                radius: 13
                color: parent.enabled ? root.accent : (root.lightTheme ? "#dbe2e5" : "#263942")
            }
            contentItem: Label {
                text: parent.text
                color: parent.enabled ? "#07131d" : (root.lightTheme ? "#89969b" : "#71858d")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 10
                font.bold: parent.enabled
            }
        }
    }
}
