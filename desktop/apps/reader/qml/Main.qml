import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Pdf
import "components"

ApplicationWindow {
    id: window

    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 620
    visible: true
    title: currentDocument.length > 0 ? currentDocument + " — MurSchol Reader" : "MurSchol Reader"
    color: "#0B0E12"

    property bool reading: false
    property bool focusMode: false
    property bool searchOpen: false
    property string currentDocument: ""
    property int zoomPercent: 100

    function displayName(sourceUrl) {
        var value = sourceUrl.toString()
        var slash = value.lastIndexOf("/")
        var name = slash >= 0 ? value.substring(slash + 1) : value
        return decodeURIComponent(name)
    }

    function openDocument(sourceUrl) {
        var value = sourceUrl.toString()
        if (!value.toLowerCase().endsWith(".pdf")) {
            unsupportedDialog.open()
            return
        }

        currentDocument = displayName(sourceUrl)
        zoomPercent = 100
        searchOpen = false
        searchField.text = ""
        pdfDocument.source = sourceUrl
        reading = true
    }

    function closeDocument() {
        contentsDrawer.close()
        searchOpen = false
        focusMode = false
        reading = false
        currentDocument = ""
        pdfDocument.source = ""
    }

    Shortcut {
        sequence: "Ctrl+O"
        onActivated: openDialog.open()
    }

    Shortcut {
        sequence: "Ctrl+F"
        enabled: window.reading
        onActivated: {
            window.searchOpen = true
            searchField.forceActiveFocus()
        }
    }

    Shortcut {
        sequence: "Ctrl++"
        enabled: window.reading
        onActivated: window.zoomPercent = Math.min(300, window.zoomPercent + 10)
    }

    Shortcut {
        sequence: "Ctrl+-"
        enabled: window.reading
        onActivated: window.zoomPercent = Math.max(40, window.zoomPercent - 10)
    }

    Shortcut {
        sequence: "F11"
        enabled: window.reading
        onActivated: window.focusMode = !window.focusMode
    }

    Shortcut {
        sequence: "Esc"
        enabled: window.reading && (window.focusMode || window.searchOpen)
        onActivated: {
            if (window.searchOpen)
                window.searchOpen = false
            else
                window.focusMode = false
        }
    }

    PdfDocument {
        id: pdfDocument

        onPasswordRequired: {
            passwordField.text = ""
            passwordDialog.open()
        }
    }

    PdfBookmarkModel {
        id: bookmarkModel
        document: pdfDocument
    }

    FileDialog {
        id: openDialog
        title: "Abrir PDF"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Documentos PDF (*.pdf)"]
        onAccepted: window.openDocument(selectedFile)
    }

    LibraryHome {
        anchors.fill: parent
        visible: !window.reading
        onBrowseRequested: openDialog.open()
    }

    Item {
        id: readingView
        anchors.fill: parent
        visible: window.reading

        Rectangle {
            anchors.fill: parent
            color: "#0B0E12"
        }

        ReaderTopBar {
            id: topBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            z: 20
            documentTitle: window.currentDocument
            currentPage: pdfView.currentPage >= 0 ? pdfView.currentPage + 1 : 0
            pageCount: pdfDocument.pageCount
            zoomPercent: window.zoomPercent
            focusMode: window.focusMode

            onBackRequested: window.closeDocument()
            onOpenRequested: openDialog.open()
            onContentsRequested: contentsDrawer.open()
            onSearchRequested: {
                window.searchOpen = !window.searchOpen
                if (window.searchOpen)
                    searchField.forceActiveFocus()
            }
            onZoomOutRequested: window.zoomPercent = Math.max(40, window.zoomPercent - 10)
            onZoomInRequested: window.zoomPercent = Math.min(300, window.zoomPercent + 10)
            onFocusModeRequested: window.focusMode = !window.focusMode
        }

        PdfMultiPageView {
            id: pdfView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: topBar.bottom
            anchors.bottom: parent.bottom
            document: pdfDocument
            searchString: searchField.text
            renderScale: window.zoomPercent / 100.0
        }

        Rectangle {
            id: searchPanel
            z: 30
            visible: window.searchOpen && !window.focusMode
            width: Math.min(520, parent.width - 40)
            height: 50
            radius: 15
            anchors.top: topBar.bottom
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.rightMargin: 18
            color: "#F2171B21"
            border.color: "#51463B"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 7
                spacing: 6

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "Buscar en el PDF"
                    color: "#F3EEE5"
                    placeholderTextColor: "#7F766D"
                    selectByMouse: true
                    background: Rectangle {
                        radius: 10
                        color: "#11151C"
                        border.color: parent.activeFocus ? "#D6A85F" : "#35312D"
                    }
                    onAccepted: {
                        if (text.length > 0)
                            pdfView.searchForward()
                    }
                }

                ToolButton {
                    text: "↑"
                    enabled: searchField.text.length > 0
                    ToolTip.visible: hovered
                    ToolTip.text: "Coincidencia anterior"
                    onClicked: pdfView.searchBack()
                }

                ToolButton {
                    text: "↓"
                    enabled: searchField.text.length > 0
                    ToolTip.visible: hovered
                    ToolTip.text: "Siguiente coincidencia"
                    onClicked: pdfView.searchForward()
                }

                ToolButton {
                    text: "×"
                    ToolTip.visible: hovered
                    ToolTip.text: "Cerrar búsqueda"
                    onClicked: window.searchOpen = false
                }
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: pdfDocument.status === PdfDocument.Loading
            visible: running
            z: 40
        }

        Rectangle {
            z: 40
            visible: pdfDocument.status === PdfDocument.Error
            width: Math.min(520, parent.width - 60)
            height: errorColumn.implicitHeight + 42
            radius: 20
            anchors.centerIn: parent
            color: "#171B21"
            border.color: "#E28A78"

            ColumnLayout {
                id: errorColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20
                spacing: 8

                Label {
                    Layout.fillWidth: true
                    text: "No se pudo abrir este PDF"
                    color: "#F3EEE5"
                    font.pixelSize: 17
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    Layout.fillWidth: true
                    text: pdfDocument.error
                    color: "#C9C0B6"
                    font.pixelSize: 10
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Elegir otro archivo"
                    onClicked: openDialog.open()
                }
            }
        }

        Rectangle {
            visible: window.focusMode
            z: 50
            width: 108
            height: 32
            radius: 16
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 8
            color: focusHover.hovered ? "#51463B" : "#D924211D"

            HoverHandler { id: focusHover }

            Label {
                anchors.centerIn: parent
                text: "F11 · salir"
                color: "#C9C0B6"
                font.pixelSize: 9
            }

            MouseArea {
                anchors.fill: parent
                onClicked: window.focusMode = false
            }
        }

        ContentsDrawer {
            id: contentsDrawer
            parent: readingView
            bookmarkModel: bookmarkModel
            onPageRequested: function(page) {
                pdfView.goToPage(page)
            }
        }
    }

    DropArea {
        anchors.fill: parent
        z: 100

        onDropped: function(drop) {
            if (drop.hasUrls && drop.urls.length > 0) {
                window.openDocument(drop.urls[0])
                drop.acceptProposedAction()
            }
        }
    }

    Dialog {
        id: passwordDialog
        modal: true
        anchors.centerIn: parent
        title: "PDF protegido"
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: pdfDocument.password = passwordField.text

        contentItem: ColumnLayout {
            width: 340
            spacing: 10

            Label {
                Layout.fillWidth: true
                text: "Este documento requiere una contraseña."
                color: "#F3EEE5"
                wrapMode: Text.Wrap
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Contraseña"
            }
        }

        background: Rectangle {
            radius: 18
            color: "#171B21"
            border.color: "#51463B"
        }
    }

    Dialog {
        id: unsupportedDialog
        modal: true
        anchors.centerIn: parent
        title: "Formato no disponible"
        standardButtons: Dialog.Ok

        contentItem: Label {
            width: 360
            padding: 18
            text: "Esta versión de MurSchol Reader abre PDF reales. EPUB, MOBI y otros formatos se activarán únicamente cuando tengan un motor de lectura estable."
            color: "#C9C0B6"
            wrapMode: Text.Wrap
        }

        background: Rectangle {
            radius: 18
            color: "#171B21"
            border.color: "#51463B"
        }
    }

    Component.onCompleted: {
        if (murscholStartupDocument && murscholStartupDocument.toString().length > 0)
            window.openDocument(murscholStartupDocument)
    }
}
