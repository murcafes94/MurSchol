import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    width: 470
    height: 680
    radius: 26
    color: "#f0142531"
    border.color: "#3a5e6e"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 0
                Label { text: "Centro del sistema"; color: "white"; font.pixelSize: 21; font.bold: true }
                Label { text: "Rendimiento, compatibilidad y estado"; color: "#7899a6"; font.pixelSize: 10 }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 82
                height: 26
                radius: 13
                color: "#153845"
                Label { anchors.centerIn: parent; text: root.backend.profile; color: "#8fe1dc"; font.pixelSize: 9; font.bold: true }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: [
                    {n:"CPU", v:backend.cpuUsage, c:"#38bdf8"},
                    {n:"RAM", v:backend.memoryUsage, c:"#55d58a"},
                    {n:"Disco", v:backend.diskUsage, c:"#a36bf4"}
                ]
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 76
                    radius: 17
                    color: "#192f3a"
                    border.color: modelData.c
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.v + "%"; color: "white"; font.pixelSize: 19; font.bold: true }
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.n; color: "#9bb0ba"; font.pixelSize: 9 }
                    }
                }
            }
        }

        Label { text: "Equipo"; color: "#bdd0d8"; font.bold: true; font.pixelSize: 11 }
        Rectangle {
            Layout.fillWidth: true
            height: root.backend.batteryAvailable ? 100 : 82
            radius: 15
            color: "#192e39"
            border.color: "#294a59"
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 11
                spacing: 2
                Label { text: root.backend.distroName; color: "white"; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true; font.pixelSize: 11 }
                Label { text: root.backend.cpuModel + " · " + root.backend.cpuThreads + " hilos"; color: "#88a0ab"; font.pixelSize: 9; elide: Text.ElideRight; Layout.fillWidth: true }
                Label { text: "Kernel " + root.backend.kernelVersion + " · RAM " + root.backend.totalMemoryGb.toFixed(1) + " GB"; color: "#7895a1"; font.pixelSize: 9 }
                Label {
                    visible: root.backend.batteryAvailable
                    text: "Batería " + root.backend.batteryPercent + "% · " + (root.backend.charging ? "cargando" : "en uso")
                    color: root.backend.batteryPercent <= 20 ? "#efb36a" : "#72d9c7"
                    font.pixelSize: 9
                }
            }
        }

        Label { text: "Compatibilidad"; color: "#bdd0d8"; font.bold: true; font.pixelSize: 11 }

        RowLayout {
            Layout.fillWidth: true
            spacing: 7
            Repeater {
                model: [
                    {name:"Linux", symbol:"L", detail:"Nativo", ready:true},
                    {name:"Android", symbol:"A", detail:"Waydroid", ready:backend.waydroidAvailable},
                    {name:"Windows", symbol:"W", detail:"Wine/Bottles", ready:backend.wineAvailable || backend.bottlesAvailable}
                ]
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    height: 70
                    radius: 15
                    color: "#192e39"
                    border.color: modelData.ready ? "#2c6b60" : "#4d4a3a"
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1
                        Label { Layout.alignment: Qt.AlignHCenter; text: modelData.symbol; color: modelData.ready ? "#6ce1ba" : "#d0ad72"; font.bold: true; font.pixelSize: 16 }
                        Label { Layout.alignment: Qt.AlignHCenter; text: modelData.name; color: "white"; font.bold: true; font.pixelSize: 9 }
                        Label { Layout.alignment: Qt.AlignHCenter; text: modelData.ready ? modelData.detail : "Pendiente"; color: modelData.ready ? "#72e2ad" : "#e7b86e"; font.pixelSize: 7 }
                    }
                }
            }
        }

        Label { text: "Modo de rendimiento"; color: "#bdd0d8"; font.bold: true; font.pixelSize: 11 }
        Rectangle {
            Layout.fillWidth: true
            height: 126
            radius: 17
            color: "#152b36"
            border.color: "#2b4c5b"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 9
                spacing: 7

                Repeater {
                    model: [
                        {name:"Ligero", symbol:"◆", desc:"Ahorro"},
                        {name:"Normal", symbol:"▣", desc:"Equilibrio"},
                        {name:"Rendimiento", symbol:"▲", desc:"Potencia"}
                    ]
                    delegate: Button {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        onClicked: root.backend.setProfile(modelData.name)
                        background: Rectangle {
                            radius: 14
                            color: root.backend.profile === modelData.name ? "#174a5e" : (parent.hovered ? "#183a47" : "#112732")
                            border.width: root.backend.profile === modelData.name ? 2 : 1
                            border.color: root.backend.profile === modelData.name ? "#2bd6e1" : "#2c4b59"
                        }
                        contentItem: ColumnLayout {
                            spacing: 2
                            Item { Layout.fillHeight: true }
                            Label { Layout.alignment: Qt.AlignHCenter; text: modelData.symbol; color: "#70e5df"; font.pixelSize: 17; font.bold: true }
                            Label { Layout.alignment: Qt.AlignHCenter; text: modelData.name; color: "white"; font.pixelSize: 9; font.bold: true }
                            Label { Layout.alignment: Qt.AlignHCenter; text: modelData.desc; color: "#8fa8b2"; font.pixelSize: 7 }
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                visible: modelData.name === root.backend.recommendedProfile
                                width: rec.implicitWidth + 10
                                height: 18
                                radius: 9
                                color: "#196a59"
                                Label { id: rec; anchors.centerIn: parent; text: "Recomendado"; color: "#baffdf"; font.pixelSize: 7; font.bold: true }
                            }
                            Item { Layout.fillHeight: true }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
        RowLayout {
            Layout.fillWidth: true
            Label { text: root.backend.statusText; color: "#6f929f"; font.pixelSize: 9; elide: Text.ElideRight; Layout.fillWidth: true }
            Button {
                visible: root.backend.profile !== root.backend.recommendedProfile
                text: "Usar recomendado"
                onClicked: root.backend.applyRecommendedProfile()
            }
        }
    }
}
