import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: root

    property var bookmarkModel: null
    signal pageRequested(int page)

    edge: Qt.LeftEdge
    width: Math.min(340, parent ? parent.width * 0.36 : 340)
    modal: true
    dim: true
    interactive: true

    background: Rectangle {
        color: "#FA11151C"
        border.color: "#51463B"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: "Índice del PDF"
                color: "#F3EEE5"
                font.pixelSize: 18
                font.bold: true
            }

            ToolButton {
                text: "×"
                onClicked: root.close()
            }
        }

        Label {
            Layout.fillWidth: true
            text: "Los títulos provienen del índice incluido en el propio archivo."
            color: "#A79E94"
            font.pixelSize: 9
            wrapMode: Text.Wrap
        }

        ListView {
            id: tocList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: root.bookmarkModel

            delegate: Button {
                width: ListView.view.width
                height: 44
                leftPadding: 12 + Math.max(0, Number(model.level)) * 12
                rightPadding: 10
                text: model.title

                background: Rectangle {
                    radius: 11
                    color: parent.hovered ? "#35312D" : "transparent"
                }

                contentItem: Label {
                    text: parent.text
                    color: "#C9C0B6"
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    root.pageRequested(Number(model.page))
                    root.close()
                }
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.fillHeight: tocList.count === 0
            visible: tocList.count === 0
            text: "Este PDF no contiene un índice interno. Puedes navegar desplazándote por las páginas o usar la búsqueda."
            color: "#7F766D"
            font.pixelSize: 10
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
