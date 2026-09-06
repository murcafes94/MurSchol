import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: root
    edge: Qt.RightEdge
    width: Math.min(330, parent ? parent.width * 0.36 : 330)
    modal: true
    dim: true
    interactive: true

    background: Rectangle {
        color: "#f50b1926"
        border.color: "#2e5669"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: "Mis marcas"
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }
            ToolButton { text: "×"; onClicked: root.close() }
        }

        TabBar {
            id: tabs
            Layout.fillWidth: true
            TabButton { text: "Subrayados" }
            TabButton { text: "Notas" }
            TabButton { text: "Marcadores" }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabs.currentIndex

            ListView {
                clip: true
                spacing: 8
                model: [
                    "El ser humano, desde la concepción… · p. 12",
                    "La vida es un don que precede… · p. 28",
                    "Toda persona es un fin… · p. 67"
                ]
                delegate: Rectangle {
                    required property string modelData
                    width: ListView.view.width
                    height: 54
                    radius: 12
                    color: "#142c39"
                    border.color: "#315467"
                    Label {
                        anchors.fill: parent
                        anchors.margins: 12
                        text: modelData
                        color: "#dfeaed"
                        font.pixelSize: 10
                        wrapMode: Text.Wrap
                    }
                }
            }

            ListView {
                clip: true
                spacing: 8
                model: [
                    "Reflexión personal · p. 12",
                    "Relacionar con Evangelium Vitae · p. 45"
                ]
                delegate: Rectangle {
                    required property string modelData
                    width: ListView.view.width
                    height: 54
                    radius: 12
                    color: "#142c39"
                    border.color: "#315467"
                    Label {
                        anchors.fill: parent
                        anchors.margins: 12
                        text: modelData
                        color: "#dfeaed"
                        font.pixelSize: 10
                        wrapMode: Text.Wrap
                    }
                }
            }

            ListView {
                clip: true
                spacing: 8
                model: ["Importante · p. 12"]
                delegate: Rectangle {
                    required property string modelData
                    width: ListView.view.width
                    height: 54
                    radius: 12
                    color: "#142c39"
                    border.color: "#315467"
                    Label {
                        anchors.fill: parent
                        anchors.margins: 12
                        text: modelData
                        color: "#dfeaed"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
