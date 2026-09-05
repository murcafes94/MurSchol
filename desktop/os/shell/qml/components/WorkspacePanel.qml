import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 430; height: 142; radius: 22
    color: "#bd102430"; border.color: "#315666"

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 10
        Label { text: "Espacios de trabajo"; color: "white"; font.bold: true; font.pixelSize: 16 }
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Repeater {
                model: [
                    {n:"Estudio", s:"Clases y apuntes"},
                    {n:"Trabajos", s:"Proyectos"},
                    {n:"Personal", s:"Tu espacio"}
                ]
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true; height: 78; radius: 15
                    color: index === 0 ? "#1b5260" : "#1a3440"; border.color: index === 0 ? "#2de0d7" : "#355666"
                    Column { anchors.centerIn: parent; spacing: 4
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.n; color: "white"; font.bold: true }
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.s; color: "#8aa4af"; font.pixelSize: 9 }
                    }
                }
            }
        }
    }
}
