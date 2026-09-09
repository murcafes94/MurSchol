import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var backend
    property bool lightTheme: false
    property color accent: "#2563EB"
    spacing: 14

    readonly property color surface: lightTheme ? "#FFFFFF" : "#11151C"
    readonly property color raised: lightTheme ? "#F4F6F9" : "#171C24"
    readonly property color border: lightTheme ? "#D8DEE9" : "#252B35"
    readonly property color textPrimary: lightTheme ? "#0B0D12" : "#F8FAFC"
    readonly property color textSecondary: lightTheme ? "#5B6573" : "#9AA4B2"
    readonly property color danger: "#E63946"

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 94
        radius: 18
        color: root.surface
        border.color: root.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Rectangle {
                width: 48
                height: 48
                radius: 15
                color: root.lightTheme ? "#EAF1FF" : "#123A7A"
                Label { anchors.centerIn: parent; text: "▥"; color: root.accent; font.pixelSize: 21; font.bold: true }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label { text: backend.installedCount + " aplicaciones detectadas"; color: root.textPrimary; font.pixelSize: 17; font.bold: true }
                Label {
                    text: "MurSchol usa asociaciones XDG reales para decidir qué aplicación abre cada tipo de archivo."
                    color: root.textSecondary
                    font.pixelSize: 9
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            Button {
                id: refreshButton
                text: "Actualizar"
                onClicked: backend.refresh()
                background: Rectangle {
                    radius: 12
                    color: refreshButton.hovered ? (root.lightTheme ? "#EAF1FF" : "#123A7A") : root.raised
                    border.width: 1
                    border.color: refreshButton.hovered ? root.accent : root.border
                }
                contentItem: Label {
                    text: refreshButton.text
                    color: root.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                    font.bold: true
                }
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
                implicitHeight: 90
                radius: 16
                color: root.surface
                border.color: root.border

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12
                    Rectangle {
                        width: 42
                        height: 42
                        radius: 13
                        color: root.lightTheme ? "#EAF1FF" : "#123A7A"
                        Label { anchors.centerIn: parent; text: modelData.symbol; color: root.accent; font.pixelSize: modelData.symbol === "PDF" ? 9 : 18; font.bold: true }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Label { text: modelData.title; color: root.textSecondary; font.pixelSize: 9 }
                        Label { text: modelData.value; color: root.textPrimary; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: browserColumn.implicitHeight + 34
        radius: 18
        color: root.surface
        border.color: root.border

        ColumnLayout {
            id: browserColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 17
            spacing: 11

            Label { text: "Navegador predeterminado"; color: root.textPrimary; font.pixelSize: 13; font.bold: true }
            Label { text: "El cambio se aplica a enlaces HTTP/HTTPS y páginas HTML."; color: root.textSecondary; font.pixelSize: 9 }

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
                    color: root.danger
                    font.pixelSize: 9
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: localColumn.implicitHeight + 34
        radius: 18
        color: root.surface
        border.color: root.border

        ColumnLayout {
            id: localColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 17
            spacing: 11

            Label { text: "Aplicaciones MurSchol"; color: root.textPrimary; font.pixelSize: 13; font.bold: true }
            Label { text: "Puedes devolver estas asociaciones a las aplicaciones nativas de MurSchol sin tocar tus archivos."; color: root.textSecondary; font.pixelSize: 9; wrapMode: Text.WordWrap; Layout.fillWidth: true }

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
