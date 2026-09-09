import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property bool lightTheme: false
    property color accent: "#2563EB"
    property string description: ""
    property string buttonText: "Abrir"
    property bool available: false
    signal openRequested()

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
        spacing: 12

        Label {
            Layout.fillWidth: true
            text: root.description
            color: root.lightTheme ? "#5B6573" : "#9AA4B2"
            font.pixelSize: 10
            wrapMode: Text.WordWrap
        }

        Button {
            id: openButton
            text: root.buttonText
            enabled: root.available
            onClicked: root.openRequested()
            background: Rectangle {
                radius: 13
                color: openButton.enabled && openButton.hovered
                       ? (root.lightTheme ? "#EAF1FF" : "#123A7A")
                       : (root.lightTheme ? "#F4F6F9" : "#171C24")
                border.width: 1
                border.color: openButton.enabled ? root.accent : (root.lightTheme ? "#D8DEE9" : "#252B35")
            }
            contentItem: Label {
                text: openButton.text
                color: openButton.enabled
                       ? (root.lightTheme ? "#0B0D12" : "#F8FAFC")
                       : (root.lightTheme ? "#8B95A3" : "#697280")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 10
                font.bold: openButton.enabled
            }
        }
    }
}
