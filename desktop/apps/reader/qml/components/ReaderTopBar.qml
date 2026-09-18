import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string documentTitle: ""
    property int currentPage: 0
    property int pageCount: 0
    property int zoomPercent: 100
    property bool focusMode: false

    signal pageRequested(int page)
    signal marksRequested()
    signal backRequested()
    signal openRequested()
    signal contentsRequested()
    signal searchRequested()
    signal zoomOutRequested()
    signal zoomInRequested()
    signal focusModeRequested()

    height: root.focusMode ? 0 : 54
    color: "#F211151C"
    border.color: "#35312D"
    clip: true

    Behavior on height {
        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 6

        ToolButton {
            text: "←"
            ToolTip.visible: hovered
            ToolTip.text: "Volver"
            onClicked: root.backRequested()
        }

        ToolButton {
            text: "Abrir"
            ToolTip.visible: hovered
            ToolTip.text: "Abrir otro PDF"
            onClicked: root.openRequested()
        }

        ToolButton {
            text: "Índice"
            ToolTip.visible: hovered
            ToolTip.text: "Índice del documento"
            onClicked: root.contentsRequested()
        }

        Label {
            Layout.fillWidth: true
            text: root.documentTitle
            color: "#F3EEE5"
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideMiddle
        }

        ToolButton {
            text: "‹"
            enabled: root.currentPage > 1
            onClicked: root.pageRequested(root.currentPage - 2)
            ToolTip.visible: hovered
            ToolTip.text: "Página anterior"
        }

        SpinBox {
            from: 1
            to: Math.max(1, root.pageCount)
            value: Math.max(1, root.currentPage)
            editable: true
            enabled: root.pageCount > 0
            onValueModified: root.pageRequested(value - 1)
            Accessible.name: "Página"
        }

        Label { text: "/ " + root.pageCount; color: "#A79E94" }

        ToolButton {
            text: "›"
            enabled: root.currentPage < root.pageCount
            onClicked: root.pageRequested(root.currentPage)
            ToolTip.visible: hovered
            ToolTip.text: "Página siguiente"
        }

        ToolButton {
            text: "Marcas"
            enabled: root.pageCount > 0
            onClicked: root.marksRequested()
            ToolTip.visible: hovered
            ToolTip.text: "Marcadores personales"
        }

        ToolButton {
            text: "Buscar"
            ToolTip.visible: hovered
            ToolTip.text: "Buscar en el PDF"
            onClicked: root.searchRequested()
        }

        ToolButton {
            text: "−"
            ToolTip.visible: hovered
            ToolTip.text: "Alejar"
            onClicked: root.zoomOutRequested()
        }

        Label {
            text: root.zoomPercent + "%"
            color: "#C9C0B6"
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
            text: "F11"
            ToolTip.visible: hovered
            ToolTip.text: "Modo concentración (F11)"
            onClicked: root.focusModeRequested()
        }
    }
}
