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
            Label { text: "Modo estudio"; color: "white"; font.bold: true; font.pixelSize: 16 }
            Item { Layout.fillWidth: true }
            Label { text: "Preparado para composición de ventanas"; color: "#6f8f9c"; font.pixelSize: 8 }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Repeater {
                model: [
                    {n:"PDF + NotCan", s:"Leer y tomar apuntes"},
                    {n:"Moodle + Apuntes", s:"Clase y notas"},
                    {n:"Lectura", s:"Sin distracciones"}
                ]
                delegate: Button {
                    required property var modelData
                    Layout.fillWidth: true; height: 82
                    onClicked: {
                        root.backend.setWorkspace("Estudio")
                        root.backend.setStudyLayout(modelData.n)
                    }
                    background: Rectangle {
                        radius: 15
                        color: root.backend.studyLayout === modelData.n ? "#203f61" : (parent.hovered ? "#243f50" : "#1a3440")
                        border.color: root.backend.studyLayout === modelData.n ? "#5d8cff" : "#355666"
                    }
                    contentItem: Column {
                        anchors.centerIn: parent; spacing: 4
                        Label {
                            width: parent.parent.width - 16
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.n
                            color: "white"; font.bold: true; font.pixelSize: 10
                            horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                        }
                        Label {
                            width: parent.parent.width - 16
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.s
                            color: "#8aa4af"; font.pixelSize: 8
                            horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
