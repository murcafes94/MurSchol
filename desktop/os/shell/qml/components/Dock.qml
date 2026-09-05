import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    signal startClicked()
    signal filesClicked()
    signal terminalClicked()
    signal androidClicked()
    signal windowsClicked()
    signal appManagerClicked()
    signal systemClicked()

    width: 590
    height: 68
    radius: 23
    color: "#ea111f2b"
    border.color: "#315464"

    RowLayout {
        anchors.centerIn: parent
        spacing: 9

        Repeater {
            model: [
                {t:"MS", tip:"Inicio", action:"start"},
                {t:"⌕", tip:"Buscar", action:"start"},
                {t:"▣", tip:"Archivos", action:"files"},
                {t:">_", tip:"Terminal", action:"terminal"},
                {t:"A", tip:"Android", action:"android"},
                {t:"W", tip:"Windows", action:"windows"},
                {t:"+", tip:"Instalar aplicación", action:"install"},
                {t:"⚙", tip:"Sistema", action:"system"}
            ]

            delegate: Button {
                required property var modelData
                width: 48
                height: 48
                text: modelData.t
                ToolTip.visible: hovered
                ToolTip.text: modelData.tip
                ToolTip.delay: 450
                background: Rectangle {
                    radius: 15
                    color: parent.hovered ? "#2c5264" : "#1a3542"
                    border.color: modelData.action === "install" ? "#2e7c7b" : "#365969"
                }
                contentItem: Label {
                    text: parent.text
                    color: modelData.action === "install" ? "#72e4dc" : "white"
                    font.bold: true
                    font.pixelSize: modelData.action === "install" ? 21 : 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    switch (modelData.action) {
                    case "start": root.startClicked(); break
                    case "files": root.filesClicked(); break
                    case "terminal": root.terminalClicked(); break
                    case "android": root.androidClicked(); break
                    case "windows": root.windowsClicked(); break
                    case "install": root.appManagerClicked(); break
                    case "system": root.systemClicked(); break
                    }
                }
            }
        }
    }
}
