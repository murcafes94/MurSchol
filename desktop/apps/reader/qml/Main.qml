import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

ApplicationWindow {
    id: window

    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 620
    visible: true
    title: "MurSchol Reader"
    color: "#07131d"

    property bool reading: false
    property bool focusMode: false
    property string currentDocument: "Donum Vitae.pdf"
    property int zoomPercent: 100

    Shortcut {
        sequence: "F11"
        onActivated: window.focusMode = !window.focusMode
    }

    Shortcut {
        sequence: "Esc"
        enabled: window.reading && window.focusMode
        onActivated: window.focusMode = false
    }

    LibraryHome {
        anchors.fill: parent
        visible: !window.reading
        onOpenDocumentRequested: function(title) {
            window.currentDocument = title
            window.reading = true
            window.focusMode = false
        }
    }

    Item {
        id: readingView
        anchors.fill: parent
        visible: window.reading

        Rectangle {
            anchors.fill: parent
            color: "#08141e"
        }

        ReaderTopBar {
            id: topBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            documentTitle: window.currentDocument
            zoomPercent: window.zoomPercent
            focusMode: window.focusMode
            onBackRequested: {
                contentsDrawer.close()
                marksDrawer.close()
                window.focusMode = false
                window.reading = false
            }
            onContentsRequested: contentsDrawer.open()
            onMarksRequested: marksDrawer.open()
            onZoomOutRequested: window.zoomPercent = Math.max(25, window.zoomPercent - 10)
            onZoomInRequested: window.zoomPercent = Math.min(400, window.zoomPercent + 10)
            onFocusModeRequested: window.focusMode = !window.focusMode
            onPrintRequested: printNotice.open()
            onSearchRequested: searchNotice.open()
        }

        Flickable {
            id: documentViewport
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: topBar.bottom
            anchors.bottom: parent.bottom
            contentWidth: width
            contentHeight: Math.max(height, documentPage.height + 80)
            clip: true

            Rectangle {
                id: documentPage
                width: Math.min(documentViewport.width * 0.72, 760) * (window.zoomPercent / 100.0)
                height: width * 1.414
                anchors.horizontalCenter: parent.horizontalCenter
                y: 38
                color: "#fbfaf5"
                radius: 3
                border.color: "#d7d3ca"

                Column {
                    anchors.fill: parent
                    anchors.margins: Math.max(36, parent.width * 0.08)
                    spacing: Math.max(14, parent.width * 0.025)

                    Label {
                        width: parent.width
                        text: window.currentDocument.toLowerCase().endsWith(".pdf") ? "DONUM VITAE" : "LECTURA"
                        color: "#202020"
                        font.pixelSize: Math.max(18, documentPage.width * 0.038)
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        width: parent.width
                        text: window.currentDocument.toLowerCase().endsWith(".pdf")
                              ? "Instrucción sobre el respeto a la vida humana naciente"
                              : "Vista de libro electrónico"
                        color: "#3b3b3b"
                        font.pixelSize: Math.max(11, documentPage.width * 0.019)
                        font.italic: true
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Item { width: 1; height: 12 }

                    Label {
                        width: parent.width
                        text: "Introducción"
                        color: "#202020"
                        font.pixelSize: Math.max(15, documentPage.width * 0.027)
                        font.bold: true
                    }

                    Label {
                        width: parent.width
                        text: "Esta es la primera interfaz funcional de MurSchol Reader. El documento se muestra como marcador de posición mientras conectamos los motores reales de PDF y eBook. La prioridad del lector será abrir rápido, renderizar únicamente lo necesario y mantener las herramientas fuera de la vista hasta que el usuario las solicite."
                        color: "#242424"
                        font.pixelSize: Math.max(11, documentPage.width * 0.020)
                        lineHeight: 1.35
                        wrapMode: Text.Wrap
                    }

                    Rectangle {
                        width: parent.width
                        height: highlightText.implicitHeight + 20
                        radius: 4
                        color: "#fff1a6"
                        Label {
                            id: highlightText
                            anchors.fill: parent
                            anchors.margins: 10
                            text: "Los paneles de Contenido y Mis marcas permanecen ocultos durante la lectura y aparecen solo cuando se solicitan."
                            color: "#28251c"
                            font.pixelSize: Math.max(11, documentPage.width * 0.020)
                            lineHeight: 1.3
                            wrapMode: Text.Wrap
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: window.focusMode
            width: 98
            height: 30
            radius: 15
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 8
            color: focusHover.hovered ? "#d9254050" : "#75162b38"
            opacity: 0.92
            HoverHandler { id: focusHover }
            Label {
                anchors.centerIn: parent
                text: "F11 · salir"
                color: "#dbe9ee"
                font.pixelSize: 9
            }
            MouseArea {
                anchors.fill: parent
                onClicked: window.focusMode = false
            }
        }

        ContentsDrawer { id: contentsDrawer; parent: readingView }
        MarksDrawer { id: marksDrawer; parent: readingView }
    }

    Dialog {
        id: printNotice
        modal: true
        anchors.centerIn: parent
        title: "Impresión PDF avanzada"
        standardButtons: Dialog.Ok
        contentItem: Label {
            width: 360
            padding: 18
            text: "El centro de impresión tipo Adobe está reservado para la siguiente fase: vista previa, rangos, escalado, páginas por hoja, folleto y dúplex mediante CUPS/Qt PrintSupport."
            color: "#dbe8ed"
            wrapMode: Text.Wrap
        }
        background: Rectangle { radius: 18; color: "#102634"; border.color: "#376174" }
    }

    Dialog {
        id: searchNotice
        modal: true
        anchors.centerIn: parent
        title: "Buscar en el documento"
        standardButtons: Dialog.Ok
        contentItem: Label {
            width: 330
            padding: 18
            text: "La búsqueda real se conectará al motor PDF/eBook. La interfaz queda preparada sin mantener un panel permanente visible."
            color: "#dbe8ed"
            wrapMode: Text.Wrap
        }
        background: Rectangle { radius: 18; color: "#102634"; border.color: "#376174" }
    }
}
