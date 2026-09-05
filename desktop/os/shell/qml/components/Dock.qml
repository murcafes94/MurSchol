import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    signal startClicked()
    signal filesClicked()
    signal terminalClicked()
    signal systemClicked()
    width: 520; height: 68; radius: 23
    color: "#ea111f2b"; border.color: "#315464"

    RowLayout {
        anchors.centerIn: parent
        spacing: 10
        Repeater {
            model: [
                {t:"MS", tip:"Inicio"}, {t:"⌕", tip:"Buscar"}, {t:"▣", tip:"Archivos"},
                {t:">_", tip:"Terminal"}, {t:"A", tip:"Android"}, {t:"W", tip:"Windows"}, {t:"⚙", tip:"Sistema"}
            ]
            delegate: Button {
                required property var modelData
                width: 48; height: 48
                text: modelData.t
                ToolTip.visible: hovered; ToolTip.text: modelData.tip; ToolTip.delay: 450
                background: Rectangle { radius: 15; color: parent.hovered ? "#2c5264" : "#1a3542"; border.color: "#365969" }
                contentItem: Label { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    if (index === 0 || index === 1) root.startClicked()
                    else if (index === 2) root.filesClicked()
                    else if (index === 3) root.terminalClicked()
                    else if (index === 6) root.systemClicked()
                }
            }
        }
    }
}
