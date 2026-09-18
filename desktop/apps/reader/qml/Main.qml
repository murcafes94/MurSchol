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
    property int zoomPercent: Math.round(pdfView.renderScale * 100)

    function displayName(sourceUrl) {
        var value = sourceUrl.toString()
        var slash = value.lastIndexOf("/")
        var name = slash >= 0 ? value.substring(slash + 1) : value
        return decodeURIComponent(name)
    }

    property url activeSource: ""
    property bool restoring: false
    property var savedMarks: []
    property var recentDocuments: readingStore.recentDocuments
    property string messageText: ""

    function savePosition() {
        if (!restoring && pdfDocument.status === PdfDocument.Ready && pdfView.currentPage >= 0)
            readingStore.remember(activeSource, pdfView.currentPage, pdfView.renderScale)
    }

    function openDocument(sourceUrl) {
        var local = readingStore.localDocument(sourceUrl)
        if (local.toString().length === 0) {
            messageText = "No se puede leer este archivo local. Puede haberse movido o eliminado."
            messageDialog.open()
            return
        }
        if (local.toString() === activeSource.toString()) {
            reading = true
            return
        }
        savePosition()
        restoreTimer.stop()
        passwordDialog.close()
        contentsDrawer.close()
        marksDrawer.close()
        restoring = true
        pdfDocument.source = ""
        pdfDocument.password = ""
        activeSource = local
        currentDocument = displayName(local)
        searchOpen = false
        searchField.text = ""
        savedMarks = readingStore.bookmarks(local)
        reading = true
        pdfDocument.source = local
    }

    function closeDocument() {
        savePosition()
        restoreTimer.stop()
        saveTimer.stop()
        passwordDialog.close()
        contentsDrawer.close()
        marksDrawer.close()
        searchOpen = false
        focusMode = false
        reading = false
        currentDocument = ""
        restoring = true
        pdfDocument.source = ""
        pdfDocument.password = ""
        activeSource = ""
        restoring = false
    }

    onClosing: savePosition()

    Connections {
        target: readingStore
        function onChanged() { window.savedMarks = readingStore.bookmarks(window.activeSource) }
        function onStorageError(message) {
            window.messageText = message
            messageDialog.open()
        }
    }

    Timer {
        id: saveTimer
        interval: 700
        onTriggered: window.savePosition()
    }

    Timer {
        id: restoreTimer
        interval: 100
        onTriggered: {
            if (pdfDocument.status !== PdfDocument.Ready) return
            var state = readingStore.state(window.activeSource)
            pdfView.renderScale = state.zoom === undefined ? 1 : Math.max(0.4, Math.min(3, state.zoom))
            pdfView.goToPage(Math.max(0, Math.min(pdfDocument.pageCount - 1, Number(state.page) || 0)))
            window.restoring = false
            saveTimer.restart()
        }
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
        onActivated: pdfView.renderScale = Math.min(3, pdfView.renderScale + 0.1)
    }

    Shortcut {
        sequence: "Ctrl+-"
        enabled: window.reading
        onActivated: pdfView.renderScale = Math.max(0.4, pdfView.renderScale - 0.1)
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

        onStatusChanged: function(status) {
            if (status === PdfDocument.Ready) {
                passwordDialog.close()
                restoreTimer.restart()
            }
        }

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
        recentDocuments: window.recentDocuments
        onDocumentRequested: function(url) { window.openDocument(url) }
        onForgetRequested: function(url) { readingStore.forget(url) }
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
            onMarksRequested: marksDrawer.open()
            onPageRequested: function(page) { pdfView.goToPage(page) }
            onSearchRequested: {
                window.searchOpen = !window.searchOpen
                if (window.searchOpen)
                    searchField.forceActiveFocus()
            }
            onZoomOutRequested: pdfView.renderScale = Math.max(0.4, pdfView.renderScale - 0.1)
            onZoomInRequested: pdfView.renderScale = Math.min(3, pdfView.renderScale + 0.1)
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
            clip: true
            onCurrentPageChanged: if (!window.restoring) saveTimer.restart()
            onRenderScaleChanged: if (!window.restoring) saveTimer.restart()
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

    MarksDrawer {
        id: marksDrawer
        parent: window.contentItem
        marks: window.savedMarks
        currentPage: pdfView.currentPage
        documentReady: pdfDocument.status === PdfDocument.Ready
        onToggleRequested: function(page) { readingStore.toggleBookmark(window.activeSource, page) }
        onPageRequested: function(page) { pdfView.goToPage(page) }
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
        width: Math.min(380, window.width - 40)
        modal: true
        anchors.centerIn: parent
        title: "PDF protegido"
        standardButtons: Dialog.Ok | Dialog.Cancel
        closePolicy: Popup.NoAutoClose
        onRejected: window.closeDocument()
        onOpened: passwordField.forceActiveFocus()
        onAccepted: {
            pdfDocument.password = passwordField.text
            passwordField.text = ""
        }

        contentItem: ColumnLayout {
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
                onAccepted: passwordDialog.accept()
            }
        }

        background: Rectangle {
            radius: 18
            color: "#171B21"
            border.color: "#51463B"
        }
    }

    Dialog {
        id: messageDialog
        width: Math.min(400, window.width - 40)
        modal: true
        anchors.centerIn: parent
        title: "MurSchol Reader"
        standardButtons: Dialog.Ok

        contentItem: Label {
            padding: 18
            text: window.messageText
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
