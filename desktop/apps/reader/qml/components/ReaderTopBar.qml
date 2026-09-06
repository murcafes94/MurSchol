import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string documentTitle: "Donum Vitae.pdf"
    property int currentPage: 12
    property int pageCount: 153
    property int zoomPercent: 100
    property bool focusMode: false

    signal backRequested()
    signal contentsRequested()
    signal marksRequested()
    signal searchRequested()
    signal printRequested()
    signal zoomOutRequested()
    signal zoomInRequested()
    signal focusModeRequested()

    height: root.focusMode ? 0 : 52
    color: "#f20b1926"
    border.color: "#244a5e"
    clip: true

    Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 6

        ToolButton {
            text: "←"
            ToolTip.visible: hovered
            ToolTip.text: "Volver a la biblioteca"
            onClicked: root.backRequested()
        }

        ToolButton {
            text: "☰"
            ToolTip.visible: hovered
            ToolTip.text: "Contenido"
            onClicked: root.contentsRequested()
        }

        Label {
            Layout.fillWidth: true
            text: root.documentTitle
            color: "#f2f7f9"
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideMiddle
        }

        Label {
            text: root.currentPage + " / " + root.pageCount
            color: "#a8bcc5"
            font.pixelSize: 11
        }

        ToolButton {
            text: "⌕"
            ToolTip.visible: hovered
            ToolTip.text: "Buscar"
            onClicked: root.searchRequested()
        }

        ToolButton {
            text: "🖨"
            ToolTip.visible: hovered
            ToolTip.text: "Imprimir"
            onClicked: root.printRequested()
        }

        ToolButton {
            text: "−"
            ToolTip.visible: hovered
            ToolTip.text: "Alejar"
            onClicked: root.zoomOutRequested()
        }

        Label {
            text: root.zoomPercent + "%"
            color: "#d3e2e8"
            font.pixelSize: 10
            Layout.preferredWidth: 42
            horizontalAlignment: Text.AlignHCenter
        }

        ToolButton {
            text: "+"
            ToolTip.visible: hovered
            ToolTip.text: "Acercar"
            onClicked: root.zoomInRequested()
        }

        ToolButton {
            text: "✎"
            ToolTip.visible: hovered
            ToolTip.text: "Mis marcas"
            onClicked: root.marksRequested()
        }

        ToolButton {
            text: "⛶"
            ToolTip.visible: hovered
            ToolTip.text: "Modo concentración (F11)"
            onClicked: root.focusModeRequested()
        }
    }
}
