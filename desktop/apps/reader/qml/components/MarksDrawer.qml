import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: root
    property var marks: []
    property int currentPage: -1
    property bool documentReady: false
    signal pageRequested(int page)
    signal toggleRequested(int page)
    edge: Qt.RightEdge
    width: Math.min(360, parent ? parent.width - 40 : 360)
    height: parent ? parent.height : 600
    modal: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        Label { text: "Mis marcadores"; font.pixelSize: 20 }
        Button {
            Layout.fillWidth: true
            text: root.marks.indexOf(root.currentPage) >= 0 ? "Quitar marcador de esta página" : "Marcar esta página"
            enabled: root.documentReady && root.currentPage >= 0
            onClicked: root.toggleRequested(root.currentPage)
        }
        Label {
            Layout.fillWidth: true
            visible: root.marks.length === 0
            text: "Todavía no hay marcadores en este documento."
            wrapMode: Text.Wrap
        }
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.marks
            delegate: RowLayout {
                required property int modelData
                width: ListView.view.width
                Button {
                    Layout.fillWidth: true
                    text: "Página " + (modelData + 1)
                    onClicked: { root.pageRequested(modelData); root.close() }
                }
                ToolButton {
                    text: "×"
                    Accessible.name: "Eliminar marcador"
                    onClicked: root.toggleRequested(modelData)
                }
            }
        }
        Button { text: "Cerrar"; onClicked: root.close() }
    }
}
