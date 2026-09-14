import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholFiles 1.0

ApplicationWindow {
    id: root
    width: 1160
    height: 740
    minimumWidth: 860
    minimumHeight: 540
    visible: true
    title: "MurSchol Files"
    color: "#0B0E12"

    property bool gridMode: false
    property string errorText: ""
    property int selectedIndex: -1
    property string selectedName: ""

    function clearSelection() {
        selectedIndex = -1
        selectedName = ""
    }

    function selectEntry(index, name) {
        selectedIndex = index
        selectedName = name
    }

    function beginRename() {
        if (selectedIndex < 0)
            return
        renameField.text = selectedName
        renameDialog.open()
    }

    function beginTrash() {
        if (selectedIndex < 0)
            return
        trashDialog.open()
    }

    FileListModel {
        id: files
        onCurrentPathChanged: {
            addressField.text = currentPath
            searchField.text = ""
            root.clearSelection()
        }
        onCountChanged: {
            if (root.selectedIndex >= count)
                root.clearSelection()
        }
        onErrorOccurred: function(message) {
            root.errorText = message
            errorTimer.restart()
        }
    }

    Timer {
        id: errorTimer
        interval: 5000
        repeat: false
        onTriggered: root.errorText = ""
    }

    Shortcut {
        sequence: StandardKey.Find
        onActivated: {
            searchField.forceActiveFocus()
            searchField.selectAll()
        }
    }
    Shortcut {
        sequence: "Ctrl+L"
        onActivated: {
            addressField.forceActiveFocus()
            addressField.selectAll()
        }
    }
    Shortcut { sequence: "Ctrl+N"; onActivated: newFolderDialog.open() }
    Shortcut {
        sequence: "Ctrl+R"
        onActivated: {
            files.refresh()
            files.refreshVolumes()
            root.clearSelection()
        }
    }
    Shortcut {
        sequence: "F2"
        enabled: root.selectedIndex >= 0
        onActivated: root.beginRename()
    }
    Shortcut {
        sequence: "Delete"
        enabled: root.selectedIndex >= 0 && !addressField.activeFocus && !searchField.activeFocus
        onActivated: root.beginTrash()
    }
    Shortcut {
        sequence: "Backspace"
        enabled: files.canGoUp && !addressField.activeFocus && !searchField.activeFocus
        onActivated: files.goUp()
    }
    Shortcut {
        sequence: StandardKey.Copy
        enabled: root.selectedIndex >= 0 && !addressField.activeFocus && !searchField.activeFocus
        onActivated: files.copyEntry(root.selectedIndex)
    }
    Shortcut {
        sequence: StandardKey.Cut
        enabled: root.selectedIndex >= 0 && !addressField.activeFocus && !searchField.activeFocus
        onActivated: files.cutEntry(root.selectedIndex)
    }
    Shortcut {
        sequence: StandardKey.Paste
        enabled: files.canPaste && !files.fileOperationBusy
                 && !addressField.activeFocus && !searchField.activeFocus
        onActivated: files.pasteClipboard()
    }

    Dialog {
        id: newFolderDialog
        modal: true
        title: "Nueva carpeta"
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: Overlay.overlay
        onOpened: {
            folderNameField.text = "Nueva carpeta"
            folderNameField.forceActiveFocus()
            folderNameField.selectAll()
        }
        onAccepted: {
            if (files.createFolderNamed(folderNameField.text))
                root.clearSelection()
        }
        contentItem: ColumnLayout {
            spacing: 10
            Label { text: "Nombre de la carpeta"; color: "#F3EEE5" }
            TextField {
                id: folderNameField
                Layout.preferredWidth: 360
                selectByMouse: true
                onAccepted: newFolderDialog.accept()
            }
        }
        background: Rectangle {
            radius: 18
            color: "#171B21"
            border.color: "#51463B"
        }
    }

    Dialog {
        id: renameDialog
        modal: true
        title: "Renombrar"
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: Overlay.overlay
        onOpened: {
            renameField.forceActiveFocus()
            renameField.selectAll()
        }
        onAccepted: {
            if (files.renameEntry(root.selectedIndex, renameField.text))
                root.clearSelection()
        }
        contentItem: ColumnLayout {
            spacing: 10
            Label { text: "Nuevo nombre"; color: "#F3EEE5" }
            TextField {
                id: renameField
                Layout.preferredWidth: 360
                selectByMouse: true
                onAccepted: renameDialog.accept()
            }
        }
        background: Rectangle {
            radius: 18
            color: "#171B21"
            border.color: "#51463B"
        }
    }

    Dialog {
        id: trashDialog
        modal: true
        title: "Mover a la papelera"
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: Overlay.overlay
        onAccepted: {
            if (files.moveToTrash(root.selectedIndex))
                root.clearSelection()
        }
        contentItem: Label {
            width: 380
            padding: 12
            wrapMode: Text.WordWrap
            color: "#F3EEE5"
            text: root.selectedName.length > 0
                  ? "¿Mover “" + root.selectedName + "” a la papelera? Podrás recuperarlo después."
                  : "¿Mover el elemento seleccionado a la papelera?"
        }
        background: Rectangle {
            radius: 18
            color: "#171B21"
            border.color: "#76544A"
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#0B0E12" }
            GradientStop { position: 1; color: "#171B21" }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 230
            Layout.fillHeight: true
            color: "#E612151A"
            border.color: "#35312D"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    spacing: 10
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 11
                        color: "#49352B"
                        border.color: "#D6A85F"
                        Label {
                            anchors.centerIn: parent
                            text: "MS"
                            color: "#F3EEE5"
                            font.bold: true
                            font.pixelSize: 10
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label { text: "MurSchol Files"; color: "#F3EEE5"; font.bold: true; font.pixelSize: 13 }
                        Label { text: "Archivos y unidades"; color: "#A79E94"; font.pixelSize: 8 }
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        width: parent.width
                        spacing: 4

                        Label {
                            text: "Ubicaciones"
                            color: "#A79E94"
                            font.bold: true
                            font.pixelSize: 9
                            Layout.leftMargin: 8
                            Layout.topMargin: 4
                            Layout.bottomMargin: 3
                        }

                        Repeater {
                            model: [
                                {label:"Inicio", icon:"user-home", action:"home"},
                                {label:"Documentos", icon:"folder-documents", action:"documents"},
                                {label:"Descargas", icon:"folder-download", action:"downloads"},
                                {label:"Imágenes", icon:"folder-pictures", action:"pictures"},
                                {label:"Música", icon:"folder-music", action:"music"},
                                {label:"Videos", icon:"folder-videos", action:"videos"}
                            ]

                            delegate: Button {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 39
                                onClicked: {
                                    switch (modelData.action) {
                                    case "home": files.goHome(); break
                                    case "documents": files.goDocuments(); break
                                    case "downloads": files.goDownloads(); break
                                    case "pictures": files.goPictures(); break
                                    case "music": files.goMusic(); break
                                    case "videos": files.goVideos(); break
                                    }
                                }
                                background: Rectangle {
                                    radius: 11
                                    color: parent.hovered ? "#24211D" : "transparent"
                                }
                                contentItem: RowLayout {
                                    spacing: 9
                                    Image {
                                        source: "image://theme/" + modelData.icon
                                        width: 21
                                        height: 21
                                        sourceSize.width: 24
                                        sourceSize.height: 24
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    Label {
                                        text: modelData.label
                                        color: "#D7CFC5"
                                        font.pixelSize: 10
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 7
                            Layout.bottomMargin: 5
                            height: 1
                            color: "#35312D"
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Label {
                                text: "Unidades"
                                color: "#A79E94"
                                font.bold: true
                                font.pixelSize: 9
                                Layout.leftMargin: 8
                            }
                            Item { Layout.fillWidth: true }
                            ToolButton {
                                text: "↻"
                                ToolTip.visible: hovered
                                ToolTip.text: "Actualizar unidades"
                                onClicked: files.refreshVolumes()
                                contentItem: Label {
                                    text: parent.text
                                    color: "#A79E94"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        Label {
                            visible: files.volumes.length === 0
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            Layout.rightMargin: 8
                            text: "Conecta una memoria USB o monta una unidad para verla aquí."
                            color: "#7F766D"
                            font.pixelSize: 8
                            wrapMode: Text.WordWrap
                        }

                        Repeater {
                            model: files.volumes

                            delegate: Rectangle {
                                required property int index
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 54
                                radius: 12
                                color: volumeMouse.containsMouse ? "#24211D" : "#111419"
                                border.width: 1
                                border.color: volumeMouse.containsMouse ? "#675A4B" : "#35312D"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 9
                                    anchors.rightMargin: 7
                                    spacing: 7

                                    Image {
                                        source: "image://theme/drive-removable-media"
                                        width: 22
                                        height: 22
                                        sourceSize.width: 24
                                        sourceSize.height: 24
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        Label {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: "#E8E1D8"
                                            font.pixelSize: 9
                                            font.bold: true
                                            elide: Text.ElideRight
                                        }
                                        Label {
                                            Layout.fillWidth: true
                                            text: modelData.sizeText
                                            color: "#8F877F"
                                            font.pixelSize: 7
                                            elide: Text.ElideRight
                                        }
                                    }
                                    ToolButton {
                                        visible: modelData.canUnmount
                                        text: "⏏"
                                        ToolTip.visible: hovered
                                        ToolTip.text: "Desmontar de forma segura"
                                        onClicked: files.unmountVolume(index)
                                        contentItem: Label {
                                            text: parent.text
                                            color: "#D6A85F"
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }

                                MouseArea {
                                    id: volumeMouse
                                    anchors.fill: parent
                                    anchors.rightMargin: modelData.canUnmount ? 38 : 0
                                    hoverEnabled: true
                                    onClicked: files.openVolume(index)
                                }
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 46
                            Layout.topMargin: 7
                            onClicked: files.goComputer()
                            ToolTip.visible: hovered
                            ToolTip.text: "Abrir la raíz del sistema"
                            background: Rectangle {
                                radius: 12
                                color: parent.hovered ? "#24211D" : "#111419"
                                border.width: 1
                                border.color: "#35312D"
                            }
                            contentItem: RowLayout {
                                spacing: 8
                                Image {
                                    source: "image://theme/drive-harddisk"
                                    width: 20
                                    height: 20
                                    sourceSize.width: 22
                                    sourceSize.height: 22
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Label { text: "Sistema de archivos"; color: "#D7CFC5"; font.pixelSize: 9; font.bold: true }
                                    Label { text: "Raíz /"; color: "#7F766D"; font.pixelSize: 7 }
                                }
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#E60F1318"
                border.color: "#35312D"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 8

                    Button {
                        width: 38
                        height: 38
                        enabled: files.canGoUp
                        text: "↑"
                        onClicked: files.goUp()
                        ToolTip.visible: hovered
                        ToolTip.text: "Subir una carpeta"
                        background: Rectangle {
                            radius: 11
                            color: parent.hovered ? "#302C28" : "#171B21"
                            border.width: 1
                            border.color: "#51463B"
                        }
                        contentItem: Label {
                            text: parent.text
                            color: parent.parent.enabled ? "#D7CFC5" : "#5F5953"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 17
                        }
                    }

                    TextField {
                        id: addressField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 39
                        text: files.currentPath
                        color: "#F3EEE5"
                        selectByMouse: true
                        font.pixelSize: 10
                        leftPadding: 13
                        rightPadding: 13
                        background: Rectangle {
                            radius: 12
                            color: "#171B21"
                            border.width: addressField.activeFocus ? 2 : 1
                            border.color: addressField.activeFocus ? "#D6A85F" : "#51463B"
                        }
                        onAccepted: {
                            files.setPath(text)
                            root.clearSelection()
                        }
                    }

                    TextField {
                        id: searchField
                        Layout.preferredWidth: 230
                        Layout.preferredHeight: 39
                        placeholderText: "Buscar en esta carpeta"
                        color: "#F3EEE5"
                        placeholderTextColor: "#7F766D"
                        font.pixelSize: 10
                        leftPadding: 12
                        rightPadding: 12
                        background: Rectangle {
                            radius: 12
                            color: "#171B21"
                            border.width: searchField.activeFocus ? 2 : 1
                            border.color: searchField.activeFocus ? "#D6A85F" : "#51463B"
                        }
                        onTextChanged: {
                            files.filter = text
                            root.clearSelection()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: "#D912151A"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 6

                    Button {
                        text: "+ Nueva carpeta"
                        onClicked: newFolderDialog.open()
                        background: Rectangle { radius: 11; color: parent.hovered ? "#5A4133" : "#49352B"; border.width: 1; border.color: "#D6A85F" }
                        contentItem: Label {
                            text: parent.text
                            color: "#F3EEE5"
                            font.pixelSize: 9
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "Copiar"
                        enabled: root.selectedIndex >= 0
                        onClicked: files.copyEntry(root.selectedIndex)
                        ToolTip.visible: hovered
                        ToolTip.text: "Copiar (Ctrl+C)"
                        background: Rectangle { radius: 10; color: parent.enabled && parent.hovered ? "#302C28" : "transparent" }
                        contentItem: Label { text: parent.text; color: parent.parent.enabled ? "#D7CFC5" : "#5F5953"; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }

                    Button {
                        text: "Cortar"
                        enabled: root.selectedIndex >= 0
                        onClicked: files.cutEntry(root.selectedIndex)
                        ToolTip.visible: hovered
                        ToolTip.text: "Cortar (Ctrl+X)"
                        background: Rectangle { radius: 10; color: parent.enabled && parent.hovered ? "#302C28" : "transparent" }
                        contentItem: Label { text: parent.text; color: parent.parent.enabled ? "#D7CFC5" : "#5F5953"; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }

                    Button {
                        text: files.fileOperationBusy ? "Trabajando…" : "Pegar"
                        enabled: files.canPaste && !files.fileOperationBusy
                        onClicked: files.pasteClipboard()
                        ToolTip.visible: hovered
                        ToolTip.text: "Pegar (Ctrl+V)"
                        background: Rectangle { radius: 10; color: parent.enabled && parent.hovered ? "#302C28" : "transparent" }
                        contentItem: RowLayout {
                            spacing: 5
                            BusyIndicator { visible: files.fileOperationBusy; running: visible; width: 18; height: 18 }
                            Label { text: parent.parent.text; color: parent.parent.enabled ? "#D6A85F" : "#5F5953"; font.pixelSize: 9 }
                        }
                    }

                    Button {
                        id: renameButton
                        text: "Renombrar"
                        enabled: root.selectedIndex >= 0
                        onClicked: root.beginRename()
                        ToolTip.visible: hovered
                        ToolTip.text: "Renombrar (F2)"
                        background: Rectangle { radius: 10; color: parent.enabled && parent.hovered ? "#302C28" : "transparent" }
                        contentItem: Label { text: parent.text; color: parent.parent.enabled ? "#D7CFC5" : "#5F5953"; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }

                    Button {
                        id: trashButton
                        text: "Papelera"
                        enabled: root.selectedIndex >= 0
                        onClicked: root.beginTrash()
                        ToolTip.visible: hovered
                        ToolTip.text: "Mover a la papelera (Supr)"
                        background: Rectangle { radius: 10; color: parent.enabled && parent.hovered ? "#4B2C2A" : "transparent" }
                        contentItem: Label { text: parent.text; color: parent.parent.enabled ? "#E8A18E" : "#5F5953"; font.pixelSize: 9; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }

                    Button {
                        text: "↻"
                        onClicked: {
                            files.refresh()
                            files.refreshVolumes()
                            root.clearSelection()
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "Actualizar (Ctrl+R)"
                        background: Rectangle { radius: 10; color: parent.hovered ? "#302C28" : "transparent" }
                        contentItem: Label { text: parent.text; color: "#C9C0B6"; font.pixelSize: 16; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        visible: root.selectedIndex >= 0
                        text: root.selectedName
                        color: "#A79E94"
                        font.pixelSize: 8
                        elide: Text.ElideMiddle
                        Layout.maximumWidth: 150
                    }
                    Label {
                        text: files.count + (files.count === 1 ? " elemento" : " elementos")
                        color: "#7F766D"
                        font.pixelSize: 9
                    }

                    Button {
                        text: root.gridMode ? "☷" : "▦"
                        onClicked: {
                            root.gridMode = !root.gridMode
                            root.clearSelection()
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: root.gridMode ? "Vista de lista" : "Vista de cuadrícula"
                        background: Rectangle { radius: 10; color: parent.hovered ? "#302C28" : "#171B21"; border.width: 1; border.color: "#51463B" }
                        contentItem: Label { text: parent.text; color: "#D7CFC5"; font.pixelSize: 16; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: listView
                    visible: !root.gridMode
                    anchors.fill: parent
                    anchors.margins: 12
                    clip: true
                    spacing: 3
                    model: files

                    header: Rectangle {
                        width: listView.width
                        height: 34
                        color: "transparent"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10
                            Label { text: "Nombre"; color: "#7F766D"; font.pixelSize: 8; Layout.fillWidth: true }
                            Label { text: "Modificado"; color: "#7F766D"; font.pixelSize: 8; Layout.preferredWidth: 150 }
                            Label { text: "Tamaño"; color: "#7F766D"; font.pixelSize: 8; Layout.preferredWidth: 88 }
                        }
                    }

                    delegate: Rectangle {
                        id: fileRow
                        required property int index
                        required property string fileName
                        required property bool isDirectory
                        required property string sizeText
                        required property string modifiedText
                        required property string iconName
                        width: listView.width
                        height: 49
                        radius: 12
                        color: root.selectedIndex === fileRow.index
                               ? "#49352B"
                               : (rowMouse.containsMouse ? "#24211D" : "#111419")
                        border.width: root.selectedIndex === fileRow.index || rowMouse.containsMouse ? 1 : 0
                        border.color: root.selectedIndex === fileRow.index ? "#D6A85F" : "#51463B"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10
                            Image {
                                source: "image://theme/" + fileRow.iconName
                                width: 26
                                height: 26
                                sourceSize.width: 28
                                sourceSize.height: 28
                                fillMode: Image.PreserveAspectFit
                            }
                            Label { text: fileRow.fileName; color: "#E8E1D8"; font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true }
                            Label { text: fileRow.modifiedText; color: "#8F877F"; font.pixelSize: 8; Layout.preferredWidth: 150 }
                            Label { text: fileRow.sizeText; color: "#8F877F"; font.pixelSize: 8; Layout.preferredWidth: 88 }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: function(event) {
                                root.selectEntry(fileRow.index, fileRow.fileName)
                                if (event.button === Qt.RightButton)
                                    fileMenu.popup()
                            }
                            onDoubleClicked: {
                                files.activate(fileRow.index)
                                root.clearSelection()
                            }
                        }
                    }
                }

                GridView {
                    id: gridView
                    visible: root.gridMode
                    anchors.fill: parent
                    anchors.margins: 14
                    clip: true
                    model: files
                    cellWidth: 136
                    cellHeight: 120

                    delegate: Rectangle {
                        id: fileTile
                        required property int index
                        required property string fileName
                        required property string sizeText
                        required property string iconName
                        width: 122
                        height: 106
                        radius: 16
                        color: root.selectedIndex === fileTile.index
                               ? "#49352B"
                               : (tileMouse.containsMouse ? "#24211D" : "#111419")
                        border.width: root.selectedIndex === fileTile.index || tileMouse.containsMouse ? 1 : 0
                        border.color: root.selectedIndex === fileTile.index ? "#D6A85F" : "#51463B"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 9
                            spacing: 5
                            Item { Layout.fillHeight: true }
                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                source: "image://theme/" + fileTile.iconName
                                width: 40
                                height: 40
                                sourceSize.width: 44
                                sourceSize.height: 44
                                fillMode: Image.PreserveAspectFit
                            }
                            Label { Layout.fillWidth: true; text: fileTile.fileName; color: "#E8E1D8"; font.pixelSize: 9; font.bold: true; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight }
                            Label { Layout.fillWidth: true; text: fileTile.sizeText; color: "#8F877F"; font.pixelSize: 7; horizontalAlignment: Text.AlignHCenter }
                            Item { Layout.fillHeight: true }
                        }

                        MouseArea {
                            id: tileMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: function(event) {
                                root.selectEntry(fileTile.index, fileTile.fileName)
                                if (event.button === Qt.RightButton)
                                    fileMenu.popup()
                            }
                            onDoubleClicked: {
                                files.activate(fileTile.index)
                                root.clearSelection()
                            }
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: files.count === 0
                    text: searchField.text.length > 0 ? "No hay coincidencias" : "Esta carpeta está vacía"
                    color: "#7F766D"
                    font.pixelSize: 12
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                color: root.errorText.length > 0 ? "#7A3A302F" : "#E60F1318"
                border.color: root.errorText.length > 0 ? "#76544A" : "#35312D"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 8
                    BusyIndicator {
                        visible: files.fileOperationBusy
                        running: visible
                        width: 18
                        height: 18
                    }
                    Label {
                        Layout.fillWidth: true
                        text: root.errorText.length > 0
                              ? root.errorText
                              : (files.statusText.length > 0 ? files.statusText : files.currentPath)
                        color: root.errorText.length > 0 ? "#FFD6D0" : "#8F877F"
                        font.pixelSize: 8
                        elide: Text.ElideMiddle
                    }
                    Label {
                        visible: files.volumes.length > 0
                        text: files.volumes.length + (files.volumes.length === 1 ? " unidad" : " unidades")
                        color: "#7F766D"
                        font.pixelSize: 8
                    }
                }
            }
        }
    }

    Menu {
        id: fileMenu
        MenuItem {
            text: "Abrir"
            enabled: root.selectedIndex >= 0
            onTriggered: {
                files.activate(root.selectedIndex)
                root.clearSelection()
            }
        }
        MenuSeparator { }
        MenuItem { text: "Copiar"; enabled: root.selectedIndex >= 0; onTriggered: files.copyEntry(root.selectedIndex) }
        MenuItem { text: "Cortar"; enabled: root.selectedIndex >= 0; onTriggered: files.cutEntry(root.selectedIndex) }
        MenuItem { text: "Pegar aquí"; enabled: files.canPaste && !files.fileOperationBusy; onTriggered: files.pasteClipboard() }
        MenuSeparator { }
        MenuItem { text: "Renombrar"; enabled: root.selectedIndex >= 0; onTriggered: root.beginRename() }
        MenuItem { text: "Mover a la papelera"; enabled: root.selectedIndex >= 0; onTriggered: root.beginTrash() }
    }
}
