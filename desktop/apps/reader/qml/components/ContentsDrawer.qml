import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: root
    edge: Qt.LeftEdge
    width: Math.min(300, parent ? parent.width * 0.34 : 300)
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
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: "Contenido"
                color: "white"
                font.pixelSize: 18
                font.bold: true
            }
            ToolButton { text: "×"; onClicked: root.close() }
        }

        TextField {
            Layout.fillWidth: true
            placeholderText: "Buscar en el índice"
            color: "white"
            placeholderTextColor: "#7893a0"
            background: Rectangle {
                radius: 13
                color: "#162c39"
                border.color: "#345b6d"
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 5
            model: [
                "Introducción",
                "Capítulo I · El valor de la vida humana",
                "Capítulo II · La transmisión de la vida",
                "Capítulo III · Los desafíos actuales",
                "Capítulo IV · Orientaciones pastorales",
                "Conclusión",
                "Marcadores"
            ]
            delegate: Button {
                required property string modelData
                width: ListView.view.width
                height: 46
                text: modelData
                background: Rectangle {
                    radius: 12
                    color: parent.hovered ? "#1c4255" : "transparent"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#dce8ed"
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: root.close()
            }
        }
    }
}
