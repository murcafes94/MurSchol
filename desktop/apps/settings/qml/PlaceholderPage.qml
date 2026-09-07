import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property bool lightTheme: false

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
        spacing: 7

        Label {
            text: "Preparado, todavía sin controles ficticios"
            color: root.lightTheme ? "#1b323c" : "white"
            font.bold: true
            font.pixelSize: 13
        }
        Label {
            Layout.fillWidth: true
            text: "Esta sección forma parte de la navegación definitiva. Sus controles aparecerán únicamente cuando estén conectados al backend real del sistema."
            color: root.lightTheme ? "#667a83" : "#77939f"
            font.pixelSize: 10
            wrapMode: Text.WordWrap
        }
    }
}
