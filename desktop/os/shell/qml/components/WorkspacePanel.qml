import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    width: 560
    height: 146
    radius: 22
    color: "#E816191E"
    border.width: 1
    border.color: "#5E50443A"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "Espacios de trabajo"
                color: "#F3EEE5"
                font.bold: true
                font.pixelSize: 15
            }
            Item { Layout.fillWidth: true }
            Label {
                text: "Super + 1 / 2 / 3 / 4"
                color: "#8D8379"
                font.pixelSize: 8
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    {n:"Estudio", s:"Clases y apuntes", k:"1"},
                    {n:"Biblioteca", s:"Lectura e investigación", k:"2"},
                    {n:"Ministerium", s:"Pastoral y liturgia", k:"3"},
                    {n:"Personal", s:"Tu espacio", k:"4"}
                ]

                delegate: Button {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 78
                    onClicked: root.backend.setWorkspace(modelData.n)
                    background: Rectangle {
                        radius: 15
                        color: root.backend.workspace === modelData.n
                               ? "#3C2D242A"
                               : (parent.hovered ? "#28241F24" : "#1A1D22")
                        border.width: 1
                        border.color: root.backend.workspace === modelData.n
                                      ? root.backend.accentColor
                                      : "#4A423A34"
                    }
                    contentItem: Column {
                        anchors.centerIn: parent
                        spacing: 3
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.n
                            color: "#F1EBE2"
                            font.bold: true
                            font.pixelSize: 10
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.s
                            color: "#91877D"
                            font.pixelSize: 8
                        }
                        Label {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Super + " + modelData.k
                            color: root.backend.workspace === modelData.n ? root.backend.accentColor : "#746C65"
                            font.pixelSize: 7
                        }
                    }
                }
            }
        }
    }
}
