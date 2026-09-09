import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property bool lightTheme: false

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
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Rectangle {
                width: 32
                height: 32
                radius: 10
                color: root.lightTheme ? "#EAF1FF" : "#123A7A"
                Label {
                    anchors.centerIn: parent
                    text: "…"
                    color: "#2563EB"
                    font.bold: true
                }
            }
            Label {
                Layout.fillWidth: true
                text: "Preparado, todavía sin controles ficticios"
                color: root.lightTheme ? "#0B0D12" : "#F8FAFC"
                font.bold: true
                font.pixelSize: 13
            }
        }
        Label {
            Layout.fillWidth: true
            text: "Esta sección forma parte de la navegación definitiva. Sus controles aparecerán únicamente cuando estén conectados al backend real del sistema."
            color: root.lightTheme ? "#5B6573" : "#9AA4B2"
            font.pixelSize: 10
            wrapMode: Text.WordWrap
        }
    }
}
