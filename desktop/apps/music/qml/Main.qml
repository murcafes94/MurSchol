import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholMusic 1.0

ApplicationWindow {
    id: root
    width: 1240
    height: 780
    minimumWidth: 900
    minimumHeight: 600
    visible: true
    title: "MurSchol Music"
    color: "#0B0D12"

    property string activeSection: "Inicio"
    property color accent: "#2563EB"
    property color danger: "#E63946"
    property color surface: "#11151C"
    property color surfaceRaised: "#171C24"
    property color borderColor: "#252B35"
    property color textPrimary: "#F8FAFC"
    property color textSecondary: "#9AA4B2"

    onActiveSectionChanged: {
        library.favoritesOnly = activeSection === "Favoritos"
        if (activeSection === "Letras" && library.currentPath.length > 0)
            library.requestCurrentLyrics()
    }

    MusicLibraryModel {
        id: library
        onErrorOccurred: message => statusLabel.showMessage(message, true)
        onStatusChanged: message => statusLabel.showMessage(message, false)
    }

    Component {
        id: trackDelegate

        Rectangle {
            id: trackCard
            required property int index
            required property string title
            required property string artist
            required property string album
            required property string format
            required property string path
            required property string genre
            required property int year
            required property string durationText
            required property string coverUrl
            required property bool favorite
            required property bool hasLocalLyrics

            width: trackList.width
            height: 72
            radius: 16
            color: hoverArea.containsMouse ? "#1A2230" : root.surface
            border.width: library.currentPath === path ? 1 : 0
            border.color: root.accent

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: library.selectTrack(index)
                onDoubleClicked: library.play(index)
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    radius: 12
                    color: "#0F172A"
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: trackCard.coverUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: trackCard.coverUrl.length > 0
                        asynchronous: true
                        cache: true
                    }
                    Label {
                        anchors.centerIn: parent
                        visible: trackCard.coverUrl.length === 0
                        text: "♫"
                        color: root.accent
                        font.pixelSize: 22
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        Layout.fillWidth: true
                        text: trackCard.title
                        color: root.textPrimary
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Label {
                        Layout.fillWidth: true
                        text: trackCard.artist + (trackCard.album.length > 0 ? " · " + trackCard.album : "")
                        color: root.textSecondary
                        font.pixelSize: 9
                        elide: Text.ElideRight
                    }
                    Label {
                        Layout.fillWidth: true
                        text: [trackCard.genre, trackCard.year > 0 ? trackCard.year : "", trackCard.format].filter(v => v !== "").join(" · ")
                        color: "#687386"
                        font.pixelSize: 8
                        elide: Text.ElideRight
                    }
                }

                Label {
                    visible: trackCard.hasLocalLyrics
                    text: "LRC"
                    color: "#93C5FD"
                    font.pixelSize: 8
                    font.bold: true
                }

                Label {
                    text: trackCard.durationText
                    color: root.textSecondary
                    font.pixelSize: 9
                    Layout.preferredWidth: 42
                    horizontalAlignment: Text.AlignRight
                }

                Button {
                    text: "▶"
                    ToolTip.visible: hovered
                    ToolTip.text: "Reproducir"
                    onClicked: library.play(trackCard.index)
                }
                Button {
                    text: trackCard.favorite ? "♥" : "♡"
                    ToolTip.visible: hovered
                    ToolTip.text: trackCard.favorite ? "Quitar de favoritos" : "Añadir a favoritos"
                    onClicked: library.toggleFavorite(trackCard.index)
                    contentItem: Label {
                        text: parent.text
                        color: trackCard.favorite ? root.danger : root.textPrimary
                        font.pixelSize: 17
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Button {
                    text: "+ Cola"
                    onClicked: library.addToQueue(trackCard.index)
                }
                Button {
                    text: "+ Lista"
                    enabled: library.selectedPlaylist.length > 0
                    ToolTip.visible: hovered && !enabled
                    ToolTip.text: "Crea o selecciona una lista primero"
                    onClicked: library.addToSelectedPlaylist(trackCard.index)
                }
                Button {
                    text: "Letras"
                    onClicked: {
                        library.requestLyrics(trackCard.index)
                        root.activeSection = "Letras"
                    }
                }
            }
        }
    }

    Dialog {
        id: createPlaylistDialog
        anchors.centerIn: parent
        modal: true
        title: "Nueva lista"
        standardButtons: Dialog.Ok | Dialog.Cancel
        onOpened: playlistNameField.forceActiveFocus()
        onAccepted: {
            if (!library.createPlaylist(playlistNameField.text)) {
                statusLabel.showMessage("Usa un nombre distinto para la lista", true)
            }
            playlistNameField.clear()
        }

        contentItem: ColumnLayout {
            width: 380
            spacing: 10
            Label {
                text: "Nombre de la lista"
                color: root.textPrimary
                font.bold: true
            }
            TextField {
                id: playlistNameField
                Layout.fillWidth: true
                placeholderText: "Ej. Estudio, Favoritas, Clásica"
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 230
                Layout.fillHeight: true
                color: "#0D1016"
                border.width: 1
                border.color: root.borderColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 12
                            color: root.accent
                            Label {
                                anchors.centerIn: parent
                                text: "♫"
                                color: "#FFFFFF"
                                font.pixelSize: 19
                                font.bold: true
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Label {
                                text: "MurSchol Music"
                                color: root.textPrimary
                                font.pixelSize: 15
                                font.bold: true
                            }
                            Label {
                                text: "Local primero"
                                color: root.textSecondary
                                font.pixelSize: 9
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 6 }

                    Repeater {
                        model: ["Inicio", "Canciones", "Favoritos", "Listas", "Cola", "Letras"]
                        delegate: Button {
                            id: navButton
                            required property string modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            text: modelData
                            checkable: true
                            checked: root.activeSection === modelData
                            onClicked: root.activeSection = modelData
                            background: Rectangle {
                                radius: 12
                                color: navButton.checked ? "#173B82" : (navButton.hovered ? "#171C24" : "transparent")
                                border.width: navButton.checked ? 1 : 0
                                border.color: root.accent
                            }
                            contentItem: Label {
                                text: navButton.text
                                color: navButton.checked ? "#FFFFFF" : root.textSecondary
                                font.bold: navButton.checked
                                font.pixelSize: 10
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 10
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 8 }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: sourceColumn.implicitHeight + 24
                        radius: 14
                        color: root.surface
                        border.color: root.borderColor
                        ColumnLayout {
                            id: sourceColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 12
                            spacing: 4
                            Label {
                                text: "ESTE DISPOSITIVO"
                                color: "#93C5FD"
                                font.pixelSize: 8
                                font.bold: true
                            }
                            Label {
                                text: library.scanning ? "Explorando Música…" : library.count + " visibles · " + library.favoritesCount + " favoritas"
                                color: root.textSecondary
                                font.pixelSize: 9
                            }
                            Label {
                                text: "MP3 · FLAC · OGG · OPUS · AAC · M4A · WAV"
                                color: "#687386"
                                font.pixelSize: 7
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Label {
                        Layout.fillWidth: true
                        text: "Metadatos con TagLib · Letras locales/LRCLIB · reproducción mediante MurSchol Media"
                        wrapMode: Text.WordWrap
                        color: "#687386"
                        font.pixelSize: 8
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 76
                    color: "#0B0D12"
                    border.width: 1
                    border.color: root.borderColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 22
                        anchors.rightMargin: 22
                        spacing: 14

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Label {
                                text: root.activeSection
                                color: root.textPrimary
                                font.pixelSize: 22
                                font.bold: true
                            }
                            Label {
                                text: root.activeSection === "Favoritos"
                                      ? library.count + " canciones favoritas"
                                      : root.activeSection === "Cola"
                                        ? library.queueCount + " elementos en espera"
                                        : root.activeSection === "Listas"
                                          ? library.playlists.length + " listas"
                                          : root.activeSection === "Letras"
                                            ? (library.currentTitle.length > 0 ? library.currentTitle : "Selecciona una canción")
                                            : (library.scanning ? "Explorando tu carpeta Música…" : library.count + " canciones")
                                color: root.textSecondary
                                font.pixelSize: 10
                            }
                        }

                        TextField {
                            id: searchField
                            Layout.preferredWidth: 330
                            visible: root.activeSection === "Inicio" || root.activeSection === "Canciones" || root.activeSection === "Favoritos"
                            placeholderText: "Buscar título, artista, álbum o género"
                            text: library.query
                            onTextChanged: library.query = text
                        }

                        Button {
                            text: "Actualizar"
                            visible: searchField.visible
                            enabled: !library.scanning
                            onClicked: library.refresh()
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#0B0D12"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 14

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: root.activeSection === "Inicio" ? 112 : 0
                            visible: root.activeSection === "Inicio"
                            radius: 20
                            color: "#111827"
                            border.color: "#1E40AF"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 16
                                Rectangle {
                                    width: 72
                                    height: 72
                                    radius: 18
                                    color: root.accent
                                    Label {
                                        anchors.centerIn: parent
                                        text: "♫"
                                        color: "#FFFFFF"
                                        font.pixelSize: 30
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Label {
                                        text: "Tu biblioteca, primero local"
                                        color: root.textPrimary
                                        font.pixelSize: 17
                                        font.bold: true
                                    }
                                    Label {
                                        Layout.fillWidth: true
                                        text: "MurSchol Music conserva tus archivos donde están, lee sus metadatos, guarda favoritos/listas localmente y solo usa Internet cuando pides letras a LRCLIB."
                                        wrapMode: Text.WordWrap
                                        color: root.textSecondary
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }

                        ListView {
                            id: trackList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: root.activeSection === "Inicio" || root.activeSection === "Canciones" || root.activeSection === "Favoritos"
                            clip: true
                            model: library
                            spacing: 7
                            delegate: trackDelegate

                            footer: Item {
                                width: trackList.width
                                height: library.count === 0 ? 130 : 16
                                Label {
                                    anchors.centerIn: parent
                                    visible: library.count === 0 && !library.scanning
                                    text: root.activeSection === "Favoritos"
                                          ? "Todavía no has marcado canciones como favoritas"
                                          : searchField.text.length > 0
                                            ? "No hay coincidencias"
                                            : "Aún no hay música en tu carpeta Música"
                                    color: root.textSecondary
                                    font.pixelSize: 11
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: root.activeSection === "Listas"
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                ComboBox {
                                    id: playlistCombo
                                    Layout.preferredWidth: 280
                                    model: library.playlists
                                    currentIndex: library.selectedPlaylist.length === 0 ? -1 : library.playlists.indexOf(library.selectedPlaylist)
                                    onActivated: library.selectedPlaylist = currentText
                                }
                                Button {
                                    text: "Nueva lista"
                                    onClicked: createPlaylistDialog.open()
                                }
                                Button {
                                    text: "Eliminar lista"
                                    enabled: library.selectedPlaylist.length > 0
                                    onClicked: library.deletePlaylist(library.selectedPlaylist)
                                }
                                Item { Layout.fillWidth: true }
                                Label {
                                    text: library.selectedPlaylistItems.length + " canciones"
                                    color: root.textSecondary
                                    font.pixelSize: 10
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 18
                                color: root.surface
                                border.color: root.borderColor

                                ListView {
                                    id: playlistList
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    model: library.selectedPlaylistItems
                                    spacing: 6
                                    clip: true
                                    delegate: Rectangle {
                                        required property int index
                                        required property var modelData
                                        width: playlistList.width
                                        height: 62
                                        radius: 13
                                        color: "#171C24"
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10
                                            Button {
                                                text: "▶"
                                                onClicked: library.playPath(modelData.path)
                                            }
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2
                                                Label { Layout.fillWidth: true; text: modelData.title; color: root.textPrimary; font.bold: true; elide: Text.ElideRight }
                                                Label { Layout.fillWidth: true; text: modelData.artist + (modelData.album ? " · " + modelData.album : ""); color: root.textSecondary; font.pixelSize: 9; elide: Text.ElideRight }
                                            }
                                            Label { text: modelData.durationText; color: root.textSecondary; font.pixelSize: 9 }
                                            Button {
                                                text: "Quitar"
                                                onClicked: library.removeSelectedPlaylistItem(index)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: root.activeSection === "Cola"
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                Label {
                                    text: "La cola queda guardada entre sesiones. La reproducción automática enlazada con Media llegará mediante MPRIS."
                                    color: root.textSecondary
                                    font.pixelSize: 9
                                    Layout.fillWidth: true
                                    wrapMode: Text.WordWrap
                                }
                                Button {
                                    text: "Vaciar cola"
                                    enabled: library.queueCount > 0
                                    onClicked: library.clearQueue()
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 18
                                color: root.surface
                                border.color: root.borderColor
                                ListView {
                                    id: queueList
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    model: library.queueItems
                                    spacing: 6
                                    clip: true
                                    delegate: Rectangle {
                                        required property int index
                                        required property var modelData
                                        width: queueList.width
                                        height: 62
                                        radius: 13
                                        color: "#171C24"
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10
                                            Label {
                                                text: index + 1
                                                color: "#93C5FD"
                                                font.bold: true
                                                Layout.preferredWidth: 24
                                            }
                                            Button {
                                                text: "▶"
                                                onClicked: library.playQueueItem(index)
                                            }
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2
                                                Label { Layout.fillWidth: true; text: modelData.title; color: root.textPrimary; font.bold: true; elide: Text.ElideRight }
                                                Label { Layout.fillWidth: true; text: modelData.artist; color: root.textSecondary; font.pixelSize: 9; elide: Text.ElideRight }
                                            }
                                            Label { text: modelData.durationText; color: root.textSecondary; font.pixelSize: 9 }
                                            Button { text: "Quitar"; onClicked: library.removeQueueItem(index) }
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: root.activeSection === "Letras"
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Label {
                                        text: library.currentTitle.length > 0 ? library.currentTitle : "Sin canción seleccionada"
                                        color: root.textPrimary
                                        font.pixelSize: 18
                                        font.bold: true
                                    }
                                    Label {
                                        text: library.currentArtist + (library.currentAlbum.length > 0 ? " · " + library.currentAlbum : "")
                                        color: root.textSecondary
                                        font.pixelSize: 10
                                    }
                                    Label {
                                        text: library.lyricsSource + (library.lyricsSynchronized ? " · contiene tiempos" : "")
                                        color: library.lyricsSynchronized ? "#93C5FD" : "#687386"
                                        font.pixelSize: 9
                                    }
                                }
                                BusyIndicator {
                                    running: library.lyricsLoading
                                    visible: running
                                }
                                Button {
                                    text: "Buscar letras"
                                    enabled: library.currentPath.length > 0 && !library.lyricsLoading
                                    onClicked: library.requestCurrentLyrics()
                                }
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                TextArea {
                                    text: library.lyricsText
                                    readOnly: true
                                    wrapMode: TextEdit.Wrap
                                    color: root.textPrimary
                                    selectionColor: root.accent
                                    selectedTextColor: "#FFFFFF"
                                    font.pixelSize: 13
                                    lineHeight: 1.35
                                    padding: 18
                                    background: Rectangle {
                                        radius: 18
                                        color: root.surface
                                        border.color: root.borderColor
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: library.currentPath.length > 0 ? 86 : 0
            visible: library.currentPath.length > 0
            color: "#0D1016"
            border.width: 1
            border.color: root.borderColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 12

                Rectangle {
                    width: 56
                    height: 56
                    radius: 13
                    color: "#0F172A"
                    clip: true
                    Image {
                        anchors.fill: parent
                        source: library.currentCoverUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: library.currentCoverUrl.length > 0
                    }
                    Label {
                        anchors.centerIn: parent
                        visible: library.currentCoverUrl.length === 0
                        text: "♫"
                        color: root.accent
                        font.pixelSize: 23
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label { Layout.fillWidth: true; text: library.currentTitle; color: root.textPrimary; font.bold: true; font.pixelSize: 12; elide: Text.ElideRight }
                    Label { Layout.fillWidth: true; text: library.currentArtist; color: root.textSecondary; font.pixelSize: 9; elide: Text.ElideRight }
                }

                Label {
                    id: statusLabel
                    property bool errorState: false
                    Layout.preferredWidth: 260
                    text: ""
                    color: errorState ? root.danger : "#93C5FD"
                    font.pixelSize: 9
                    elide: Text.ElideRight

                    function showMessage(message, isError) {
                        text = message
                        errorState = isError
                        statusTimer.restart()
                    }

                    Timer {
                        id: statusTimer
                        interval: 4500
                        onTriggered: statusLabel.text = ""
                    }
                }

                Button {
                    text: "▶ Abrir en Media"
                    onClicked: library.playPath(library.currentPath)
                }
                Button {
                    text: "Letras"
                    onClicked: {
                        root.activeSection = "Letras"
                        library.requestCurrentLyrics()
                    }
                }
            }
        }
    }
}
