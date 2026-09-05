import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    width: 430; height: 650; radius: 24
    color: "#f0142531"; border.color: "#3a5e6e"

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 12

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
                    Layout.fillWidth: true; height: 82; radius: 18
                    color: "#192f3a"; border.color: modelData.c
                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.v + "%"; color: "white"; font.pixelSize: 21; font.bold: true }
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.n; color: "#9bb0ba"; font.pixelSize: 10 }
                    }
                }
            }
        }

        Label { text: "Equipo"; color: "#bdd0d8"; font.bold: true }
        Rectangle {
            Layout.fillWidth: true; height: root.backend.batteryAvailable ? 112 : 92; radius: 15
            color: "#192e39"; border.color: "#294a59"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 12; spacing: 3
                Label { text: root.backend.distroName; color: "white"; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                Label { text: root.backend.cpuModel + " · " + root.backend.cpuThreads + " hilos"; color: "#88a0ab"; font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true }
                Label { text: "Kernel " + root.backend.kernelVersion + " · RAM " + root.backend.totalMemoryGb.toFixed(1) + " GB"; color: "#7895a1"; font.pixelSize: 10 }
                Label {
                    visible: root.backend.batteryAvailable
                    text: "Batería " + root.backend.batteryPercent + "% · " + (root.backend.charging ? "cargando" : "en uso")
                    color: root.backend.batteryPercent <= 20 ? "#efb36a" : "#72d9c7"; font.pixelSize: 10
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
                Layout.fillWidth: true; height: 56; radius: 15; color: "#192e39"; border.color: "#294a59"
                RowLayout {
                    anchors.fill: parent; anchors.margins: 10
                    Rectangle {
                        width: 32; height: 32; radius: 10; color: "#234552"
                        Label { anchors.centerIn: parent; text: modelData.name.substring(0,1); color: "#5ee6df"; font.bold: true }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 0
                        Label { text: modelData.name; color: "white"; font.bold: true }
                        Label { text: modelData.detail; color: "#7895a1"; font.pixelSize: 9 }
                    }
                    Label { text: modelData.ready ? "Disponible" : "Pendiente"; color: modelData.ready ? "#72e2ad" : "#e7b86e"; font.pixelSize: 9 }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true; height: 58; radius: 14
            color: root.backend.profile === root.backend.recommendedProfile ? "#173a38" : "#3b3121"
            border.color: root.backend.profile === root.backend.recommendedProfile ? "#2b8c7d" : "#96723e"
            RowLayout {
                anchors.fill: parent; anchors.margins: 11
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 1
                    Label { text: "Perfil actual: " + root.backend.profile; color: "white"; font.bold: true }
                    Label { text: "Recomendado: " + root.backend.recommendedProfile; color: "#94aaaF"; font.pixelSize: 9 }
                }
                Button {
                    visible: root.backend.profile !== root.backend.recommendedProfile
                    text: "Aplicar"
                    onClicked: root.backend.applyRecommendedProfile()
                    background: Rectangle { radius: 9; color: "#275e62" }
                    contentItem: Label { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
        }

        Item { Layout.fillHeight: true }
        Label { text: root.backend.statusText; color: "#6f929f"; font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true }
    }
}
