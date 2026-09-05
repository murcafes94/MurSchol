import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var appModel
    property var backend
    signal closeRequested()
    width: Math.min(820, parent ? parent.width - 80 : 820)
    height: 560
    radius: 28
    color: "#f0142531"
    border.color: "#3a5e6e"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            Label { text: "Inicio"; color: "white"; font.pixelSize: 27; font.bold: true }
            Item { Layout.fillWidth: true }
            Label { text: "Un escritorio, tres ecosistemas"; color: "#7da2b1"; font.pixelSize: 12 }
            Button { text: "×"; onClicked: root.closeRequested(); flat: true; contentItem: Label { text: parent.text; color: "white"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter } }
        }

        TextField {
            id: search
            Layout.fillWidth: true
            placeholderText: "Buscar aplicaciones, archivos o acciones…"
            color: "white"; placeholderTextColor: "#78909b"
            leftPadding: 16; rightPadding: 16
            background: Rectangle { radius: 15; color: "#182d38"; border.color: search.activeFocus ? "#2ad6d0" : "#355466" }
            onTextChanged: root.appModel.filter = text
        }

        Label { text: search.text.length ? "Resultados" : "Aplicaciones"; color: "#aec3cc"; font.bold: true }

        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 150
            cellHeight: 102
            clip: true
            model: root.appModel
            delegate: Button {
                width: 138; height: 90
                icon.name: iconName
                icon.width: 28; icon.height: 28
                text: appName
                onClicked: { root.appModel.launch(index); root.closeRequested() }
                background: Rectangle { radius: 17; color: parent.hovered ? "#284c5d" : "#1b3440"; border.color: "#345768" }
                contentItem: Column {
                    anchors.centerIn: parent; spacing: 7
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: appName.substring(0, 1); visible: iconName.length === 0; color: "#56e1da"; font.pixelSize: 22; font.bold: true }
                    Label { width: 116; text: appName; color: "white"; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 12 }
                    Label { width: 116; text: appSource; color: "#7995a2"; horizontalAlignment: Text.AlignHCenter; font.pixelSize: 10 }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: root.appModel.count + " aplicaciones"; color: "#78909c"; font.pixelSize: 11 }
            Item { Layout.fillWidth: true }
            Button { text: "Archivos"; onClicked: { backend.openFiles(); root.closeRequested() } }
            Button { text: "Apagar"; onClicked: backend.powerOff() }
        }
    }
}
