import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var backend
    property bool lightTheme: false
    property color accent: "#29d9d1"
    spacing: 14

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 92
        radius: 18
        color: lightTheme ? "#f8fbfc" : "#0d202b"
        border.color: lightTheme ? "#d7e2e6" : "#234454"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Rectangle {
                width: 48
                height: 48
                radius: 15
                color: lightTheme ? "#dcefed" : "#123d49"
                Label { anchors.centerIn: parent; text: "▥"; color: root.accent; font.pixelSize: 22; font.bold: true }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label { text: backend.installedCount + " aplicaciones detectadas"; color: lightTheme ? "#17303a" : "#f1f6f8"; font.pixelSize: 17; font.bold: true }
                Label {
                    text: "MurSchol usa los estándares XDG para que cada tipo de archivo tenga una aplicación predeterminada real."
                    color: lightTheme ? "#657983" : "#7f9aa6"
                    font.pixelSize: 9
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            Button {
                text: "Actualizar"
                onClicked: backend.refresh()
            }
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: 12
        rowSpacing: 12

        Repeater {
            model: [
                {title:"Navegador", value: backend.defaultBrowser, symbol:"◎"},
                {title:"Carpetas", value: backend.defaultFileManager, symbol:"▤"},
                {title:"Imágenes", value: backend.defaultImageViewer, symbol:"▣"},
                {title:"PDF", value: backend.defaultPdfViewer, symbol:"PDF"}
            ]

            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: 88
                radius: 16
                color: lightTheme ? "#f7fafb" : "#0d202a"
                border.color: lightTheme ? "#d8e2e5" : "#223f4e"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 12
                        color: lightTheme ? "#e5efef" : "#14323e"
                        Label { anchors.centerIn: parent; text: modelData.symbol; color: root.accent; font.pixelSize: modelData.symbol === "PDF" ? 9 : 18; font.bold: true }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Label { text: modelData.title; color: lightTheme ? "#314852" : "#9cb2bc"; font.pixelSize: 9 }
                        Label { text: modelData.value; color: lightTheme ? "#162e38" : "#eef5f7"; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: browserColumn.implicitHeight + 32
        radius: 18
        color: lightTheme ? "#f8fbfc" : "#0d202b"
        border.color: lightTheme ? "#d7e2e6" : "#234454"

        ColumnLayout {
            id: browserColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 10

            Label { text: "Navegador predeterminado"; color: lightTheme ? "#19323c" : "#f0f6f8"; font.pixelSize: 13; font.bold: true }
            Label { text: "El cambio se aplica a enlaces HTTP/HTTPS y páginas HTML."; color: lightTheme ? "#657983" : "#7d98a4"; font.pixelSize: 9 }

            RowLayout {
                spacing: 8
                Button {
                    visible: backend.firefoxAvailable
                    text: "Usar Firefox"
                    onClicked: backend.useFirefoxAsBrowser()
                }
                Button {
                    visible: backend.edgeAvailable
                    text: "Usar Edge"
                    onClicked: backend.useEdgeAsBrowser()
                }
                Label {
                    visible: !backend.firefoxAvailable && !backend.edgeAvailable
                    text: "No hay un navegador compatible detectado."
                    color: lightTheme ? "#7b6666" : "#c89595"
                    font.pixelSize: 9
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: localColumn.implicitHeight + 32
        radius: 18
        color: lightTheme ? "#f8fbfc" : "#0d202b"
        border.color: lightTheme ? "#d7e2e6" : "#234454"

        ColumnLayout {
            id: localColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 10

            Label { text: "Aplicaciones MurSchol"; color: lightTheme ? "#19323c" : "#f0f6f8"; font.pixelSize: 13; font.bold: true }
            Label { text: "Puedes devolver estas asociaciones a las aplicaciones nativas de MurSchol sin tocar tus archivos."; color: lightTheme ? "#657983" : "#7d98a4"; font.pixelSize: 9; wrapMode: Text.WordWrap; Layout.fillWidth: true }

            RowLayout {
                spacing: 8
                Button {
                    visible: backend.murScholFilesAvailable
                    text: "MurSchol Files para carpetas"
                    onClicked: backend.useMurScholFiles()
                }
                Button {
                    visible: backend.murScholPhotosAvailable
                    text: "MurSchol Photos para imágenes"
                    onClicked: backend.useMurScholPhotos()
                }
            }
        }
    }
}
