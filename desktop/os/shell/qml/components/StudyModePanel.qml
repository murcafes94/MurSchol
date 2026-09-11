import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    width: 430
    height: 150
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
            Label { text: "Modo estudio"; color: "#F3EEE5"; font.bold: true; font.pixelSize: 16 }
            Item { Layout.fillWidth: true }
            Label { text: "Composición rápida"; color: "#8D8379"; font.pixelSize: 8 }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    {n:"PDF + NotCan", s:"Leer y tomar apuntes"},
                    {n:"Moodle + Apuntes", s:"Clase y notas"},
                    {n:"Lectura", s:"Sin distracciones"}
                ]

                delegate: Button {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 82
                    onClicked: {
                        root.backend.setWorkspace("Estudio")
                        root.backend.setStudyLayout(modelData.n)
                    }
                    background: Rectangle {
                        radius: 15
                        color: root.backend.studyLayout === modelData.n
                               ? "#3C2D242A"
                               : (parent.hovered ? "#29251F24" : "#1A1D22")
                        border.width: 1
                        border.color: root.backend.studyLayout === modelData.n
                                      ? root.backend.accentColor
                                      : "#4A423A34"
                    }
                    contentItem: Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Label {
                            width: parent.parent.width - 16
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.n
                            color: root.backend.studyLayout === modelData.n ? "#F1DEC1" : "#F3EEE5"
                            font.bold: true
                            font.pixelSize: 10
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                        Label {
                            width: parent.parent.width - 16
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.s
                            color: "#91877D"
                            font.pixelSize: 8
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
