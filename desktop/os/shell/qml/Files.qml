import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholFiles 1.0

ApplicationWindow {
    id: root
    width: 1120
    height: 720
    minimumWidth: 820
    minimumHeight: 520
    visible: true
    title: "MurSchol Files"
    color: "#0a1620"

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
        interval: 3500
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
    Shortcut {
        sequence: "Ctrl+N"
        onActivated: newFolderDialog.open()
    }
    Shortcut {
        sequence: "Ctrl+R"
        onActivated: {
            files.refresh()
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
        enabled: root.selectedIndex >= 0
        onActivated: root.beginTrash()
    }
    Shortcut {
        sequence: "Backspace"
        enabled: files.canGoUp && !addressField.activeFocus && !searchField.activeFocus
        onActivated: files.goUp()
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
            Label { text: "Nombre de la carpeta"; color: "#dce8ed" }
            TextField {
                id: folderNameField
                Layout.preferredWidth: 360
                selectByMouse: true
                onAccepted: newFolderDialog.accept()
            }
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
            Label { text: "Nuevo nombre"; color: "#dce8ed" }
            TextField {
                id: renameField
                Layout.preferredWidth: 360
                selectByMouse: true
                onAccepted: renameDialog.accept()
            }
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
            wrapMode: Text.WordWrap
            color: "#dce8ed"
            text: root.selectedName.length > 0
                  ? "¿Mover “" + root.selectedName + "” a la papelera? Podrás recuperarlo después."
                  : "¿Mover el elemento seleccionado a la papelera?"
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#08141e" }
            GradientStop { position: 1; color: "#0d2230" }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 208
            Layout.fillHeight: true
            color: "#d90c1b26"
            border.color: "#1e3948"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    spacing: 9
                    Rectangle {
                        width: 34
                        height: 34
                        radius: 10
                        color: "#164052"
                        border.color: "#2dd7d1"
                        Label {
                            anchors.centerIn: parent
                            text: "MS"
                            color: "#d4fffc"
                            font.bold: true
                            font.pixelSize: 10
                        }
                    }
                    ColumnLayout {
                        spacing: 0
                        Label { text: "MurSchol Files"; color: "white"; font.bold: true; font.pixelSize: 13 }
                        Label { text: "Tus archivos, sin complicaciones"; color: "#6f8d99"; font.pixelSize: 8 }
                    }
                }

                Label {
                    text: "Ubicaciones"
                    color: "#6e8a97"
                    font.bold: true
                    font.pixelSize: 9
                    Layout.leftMargin: 8
                    Layout.topMargin: 8
                    Layout.bottomMargin: 4
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
                        Layout.preferredHeight: 40
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
                            radius: 12
                            color: parent.hovered ? "#18394a" : "transparent"
                        }
                        contentItem: RowLayout {
                            spacing: 9
                            Image {
                                source: "image://theme/" + modelData.icon
                                sourceSize.width: 22
                                sourceSize.height: 22
                                width: 21
                                height: 21
                                fillMode: Image.PreserveAspectFit
                            }
                            Label {
                                text: modelData.label
                                color: "#dbe7ec"
                                font.pixelSize: 10
                                Layout.fillWidth: true
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#1f3b49"
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    onClicked: files.goComputer()
                    ToolTip.visible: hovered
                    ToolTip.text: "Abrir la raíz del sistema y dispositivos montados"
                    background: Rectangle {
                        radius: 12
                        color: parent.hovered ? "#18394a" : "transparent"
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
                            Label { text: "Este equipo"; color: "#cbd9df"; font.pixelSize: 9; font.bold: true }
                            Label { text: "Sistema y unidades"; color: "#67838f"; font.pixelSize: 8 }
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
                Layout.preferredHeight: 58
                color: "#d80b1924"
                border.color: "#1f3b4a"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 8

                    Button {
                        width: 36
                        height: 36
                        enabled: files.canGoUp
                        text: "↑"
                        onClicked: files.goUp()
                        ToolTip.visible: hovered
                        ToolTip.text: "Subir una carpeta"
                        background: Rectangle { radius: 11; color: parent.hovered ? "#214353" : "#132b37" }
                        contentItem: Label {
                            text: parent.text
                            color: parent.parent.enabled ? "#d9e8ed" : "#526a75"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 17
                        }
                    }

                    TextField {
                        id: addressField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        text: files.currentPath
                        color: "#dce8ed"
                        selectByMouse: true
                        font.pixelSize: 10
                        leftPadding: 13
                        rightPadding: 13
                        background: Rectangle {
                            radius: 12
                            color: "#142a36"
                            border.width: addressField.activeFocus ? 2 : 1
                            border.color: addressField.activeFocus ? "#2bd6d1" : "#294756"
                        }
                        onAccepted: {
                            files.setPath(text)
                            root.clearSelection()
                        }
                    }

                    TextField {
                        id: searchField
                        Layout.preferredWidth: 220
                        Layout.preferredHeight: 38
                        placeholderText: "Buscar en esta carpeta"
                        color: "white"
                        placeholderTextColor: "#6c8792"
                        font.pixelSize: 10
                        leftPadding: 12
                        rightPadding: 12
                        background: Rectangle {
                            radius: 12
                            color: "#142a36"
                            border.width: searchField.activeFocus ? 2 : 1
                            border.color: searchField.activeFocus ? "#2bd6d1" : "#294756"
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
                Layout.preferredHeight: 54
                color: "#b80c1b27"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 7

                    Button {
                        text: "+ Nueva carpeta"
                        onClicked: newFolderDialog.open()
                        background: Rectangle { radius: 11; color: parent.hovered ? "#245667" : "#194353" }
                        contentItem: Label {
                            text: parent.text
                            color: "#dff7f5"
                            font.pixelSize: 9
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: renameButton
                        text: "Renombrar"
                        enabled: root.selectedIndex >= 0
                        onClicked: root.beginRename()
                        ToolTip.visible: hovered
                        ToolTip.text: "Renombrar (F2)"
                        background: Rectangle {
                            radius: 10
                            color: renameButton.enabled && renameButton.hovered ? "#1f4251" : "transparent"
                        }
                        contentItem: Label {
                            text: renameButton.text
                            color: renameButton.enabled ? "#c9d9df" : "#536b76"
                            font.pixelSize: 9
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: trashButton
                        text: "Papelera"
                        enabled: root.selectedIndex >= 0
                        onClicked: root.beginTrash()
                        ToolTip.visible: hovered
                        ToolTip.text: "Mover a la papelera (Supr)"
                        background: Rectangle {
                            radius: 10
                            color: trashButton.enabled && trashButton.hovered ? "#492c32" : "transparent"
                        }
                        contentItem: Label {
                            text: trashButton.text
                            color: trashButton.enabled ? "#e6c8cd" : "#536b76"
                            font.pixelSize: 9
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "↻"
                        onClicked: {
                            files.refresh()
                            root.clearSelection()
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "Actualizar (Ctrl+R)"
                        background: Rectangle { radius: 10; color: parent.hovered ? "#1f4251" : "transparent" }
                        contentItem: Label {
                            text: parent.text
                            color: "#c9d9df"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Label {
                        visible: root.selectedIndex >= 0
                        text: root.selectedName
                        color: "#a9c0c9"
                        font.pixelSize: 8
                        elide: Text.ElideMiddle
                        Layout.maximumWidth: 180
                    }

                    Label {
                        text: files.count + (files.count === 1 ? " elemento" : " elementos")
                        color: "#748f9a"
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
                        background: Rectangle { radius: 10; color: parent.hovered ? "#1f4251" : "#132b36" }
                        contentItem: Label {
                            text: parent.text
                            color: "#d6e5ea"
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
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
                            Label { text: "Nombre"; color: "#6f8d99"; font.pixelSize: 8; Layout.fillWidth: true }
                            Label { text: "Modificado"; color: "#6f8d99"; font.pixelSize: 8; Layout.preferredWidth: 150 }
                            Label { text: "Tamaño"; color: "#6f8d99"; font.pixelSize: 8; Layout.preferredWidth: 88 }
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
                        height: 48
                        radius: 12
                        color: root.selectedIndex === fileRow.index
                               ? "#23546a"
                               : (mouse.containsMouse ? "#193747" : "#101f29")
                        border.width: root.selectedIndex === fileRow.index || mouse.containsMouse ? 1 : 0
                        border.color: root.selectedIndex === fileRow.index ? "#2bd6d1" : "#315667"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10
                            Image {
                                source: "image://theme/" + fileRow.iconName
                                sourceSize.width: 28
                                sourceSize.height: 28
                                width: 26
                                height: 26
                                fillMode: Image.PreserveAspectFit
                            }
                            Label {
                                text: fileRow.fileName
                                color: "#e8f0f3"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Label {
                                text: fileRow.modifiedText
                                color: "#78929e"
                                font.pixelSize: 8
                                Layout.preferredWidth: 150
                            }
                            Label {
                                text: fileRow.sizeText
                                color: "#78929e"
                                font.pixelSize: 8
                                Layout.preferredWidth: 88
                            }
                        }

                        MouseArea {
                            id: mouse
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
                    cellWidth: 132
                    cellHeight: 116

                    delegate: Rectangle {
                        id: fileTile
                        required property int index
                        required property string fileName
                        required property bool isDirectory
                        required property string sizeText
                        required property string iconName
                        width: 120
                        height: 104
                        radius: 16
                        color: root.selectedIndex === fileTile.index
                               ? "#23546a"
                               : (tileMouse.containsMouse ? "#1a3d4e" : "#102632")
                        border.width: root.selectedIndex === fileTile.index || tileMouse.containsMouse ? 1 : 0
                        border.color: root.selectedIndex === fileTile.index ? "#2bd6d1" : "#356174"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 9
                            spacing: 5
                            Item { Layout.fillHeight: true }
                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                source: "image://theme/" + fileTile.iconName
                                sourceSize.width: 44
                                sourceSize.height: 44
                                width: 40
                                height: 40
                                fillMode: Image.PreserveAspectFit
                            }
                            Label {
                                Layout.fillWidth: true
                                text: fileTile.fileName
                                color: "#e7f0f3"
                                font.pixelSize: 9
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                            Label {
                                Layout.fillWidth: true
                                text: fileTile.sizeText
                                color: "#6d8995"
                                font.pixelSize: 7
                                horizontalAlignment: Text.AlignHCenter
                            }
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
                    color: "#6f8c98"
                    font.pixelSize: 12
                }
            }

            Rectangle {
                visible: root.errorText.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                color: "#8c5a2a2a"
                Label {
                    anchors.centerIn: parent
                    text: root.errorText
                    color: "#ffd6d6"
                    font.pixelSize: 9
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
        MenuItem {
            text: "Renombrar"
            enabled: root.selectedIndex >= 0
            onTriggered: root.beginRename()
        }
        MenuItem {
            text: "Mover a la papelera"
            enabled: root.selectedIndex >= 0
            onTriggered: root.beginTrash()
        }
    }
}
