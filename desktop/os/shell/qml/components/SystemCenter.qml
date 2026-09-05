import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    width: 390; height: 520; radius: 24
    color: "#f0142531"; border.color: "#3a5e6e"

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        Label { text: "MurSchol System Center"; color: "white"; font.pixelSize: 22; font.bold: true }
        Label { text: "Control, rendimiento y compatibilidad"; color: "#7899a6" }

        RowLayout {
            Layout.fillWidth: true; spacing: 10
            Repeater {
                model: [
                    {n:"CPU", v:backend.cpuUsage, c:"#38bdf8"},
                    {n:"RAM", v:backend.memoryUsage, c:"#55d58a"},
                    {n:"Disco", v:backend.diskUsage, c:"#a36bf4"}
                ]
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true; height: 92; radius: 18
                    color: "#192f3a"; border.color: modelData.c
                    Column { anchors.centerIn: parent; spacing: 5
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.v + "%"; color: "white"; font.pixelSize: 22; font.bold: true }
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.n; color: "#9bb0ba"; font.pixelSize: 11 }
                    }
                }
            }
        }

        Label { text: "Ecosistemas"; color: "#bdd0d8"; font.bold: true }

        Repeater {
            model: [
                {name:"Linux", detail:"Sistema principal", ready:true},
                {name:"Android", detail:"Waydroid bajo demanda", ready:backend.waydroidAvailable},
                {name:"Windows", detail:"Wine/Bottles bajo demanda", ready:backend.wineAvailable || backend.bottlesAvailable}
            ]
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true; height: 62; radius: 15; color: "#192e39"; border.color: "#294a59"
                RowLayout { anchors.fill: parent; anchors.margins: 12
                    Rectangle { width: 34; height: 34; radius: 10; color: "#234552"; Label { anchors.centerIn: parent; text: modelData.name.substring(0,1); color: "#5ee6df"; font.bold: true } }
                    ColumnLayout { Layout.fillWidth: true; spacing: 1
                        Label { text: modelData.name; color: "white"; font.bold: true }
                        Label { text: modelData.detail; color: "#7895a1"; font.pixelSize: 10 }
                    }
                    Label { text: modelData.ready ? "Disponible" : "Pendiente"; color: modelData.ready ? "#72e2ad" : "#e7b86e"; font.pixelSize: 10 }
                }
            }
        }

        Item { Layout.fillHeight: true }
        Label { text: "Perfil actual: " + backend.profile; color: "#8fc9c4" }
    }
}
