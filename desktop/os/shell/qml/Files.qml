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

    FileListModel {
        id: files
        onCurrentPathChanged: addressField.text = currentPath
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

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
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
                        Label { text: "Almacenamiento local"; color: "#67838f"; font.pixelSize: 8 }
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
                        onAccepted: files.setPath(text)
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
                        onTextChanged: files.filter = text
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
                        onClicked: files.createFolder()
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
                        text: "↻"
                        onClicked: files.refresh()
                        ToolTip.visible: hovered
                        ToolTip.text: "Actualizar"
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
                        text: files.count + (files.count === 1 ? " elemento" : " elementos")
                        color: "#748f9a"
                        font.pixelSize: 9
                    }

                    Button {
                        text: root.gridMode ? "☷" : "▦"
                        onClicked: root.gridMode = !root.gridMode
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
                        color: mouse.containsMouse ? "#193747" : "#101f29"
                        border.width: mouse.containsMouse ? 1 : 0
                        border.color: "#315667"

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
                            onDoubleClicked: files.activate(fileRow.index)
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
                        color: tileMouse.containsMouse ? "#1a3d4e" : "#102632"
                        border.width: tileMouse.containsMouse ? 1 : 0
                        border.color: "#356174"

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
                            onDoubleClicked: files.activate(fileTile.index)
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
}
