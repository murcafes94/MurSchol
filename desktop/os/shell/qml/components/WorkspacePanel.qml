import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    width: 430; height: 150; radius: 22
    color: "#bd102430"; border.color: "#315666"

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 9
        RowLayout {
            Layout.fillWidth: true
            Label { text: "Espacios de trabajo"; color: "white"; font.bold: true; font.pixelSize: 16 }
            Item { Layout.fillWidth: true }
            Label { text: "Super + 1 / 2 / 3"; color: "#6f8f9c"; font.pixelSize: 9 }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Repeater {
                model: [
                    {n:"Estudio", s:"Clases y apuntes", k:"1"},
                    {n:"Trabajos", s:"Proyectos", k:"2"},
                    {n:"Personal", s:"Tu espacio", k:"3"}
                ]
                delegate: Button {
                    required property var modelData
                    Layout.fillWidth: true; height: 82
                    onClicked: root.backend.setWorkspace(modelData.n)
                    background: Rectangle {
                        radius: 15
                        color: root.backend.workspace === modelData.n ? "#1b5260" : (parent.hovered ? "#234552" : "#1a3440")
                        border.color: root.backend.workspace === modelData.n ? "#2de0d7" : "#355666"
                    }
                    contentItem: Column {
                        anchors.centerIn: parent; spacing: 3
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.n; color: "white"; font.bold: true }
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.s; color: "#8aa4af"; font.pixelSize: 9 }
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Super + " + modelData.k; color: "#5f8492"; font.pixelSize: 8 }
                    }
                }
            }
        }
    }
}
