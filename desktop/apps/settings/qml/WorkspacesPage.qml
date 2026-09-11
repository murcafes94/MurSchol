import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    property bool lightTheme: false
    property color accent: "#D6A85F"

    implicitHeight: content.implicitHeight + 36
    radius: 20
    color: lightTheme ? "#FFFFFF" : "#11151C"
    border.color: lightTheme ? "#D5C5AE" : "#35312D"

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        spacing: 14

        Label {
            text: "Espacio activo"
            color: lightTheme ? "#201B17" : "#F3EEE5"
            font.bold: true
            font.pixelSize: 13
        }

        Label {
            Layout.fillWidth: true
            text: "Los espacios organizan el contexto de trabajo del escritorio y del navegador sin separar tus archivos. Puedes cambiar de uno a otro con Super + 1/2/3/4."
            color: lightTheme ? "#6B625A" : "#A79E94"
            font.pixelSize: 10
            wrapMode: Text.WordWrap
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 10
            columnSpacing: 10

            Repeater {
                model: [
                    { name: "Estudio", description: "Clases, Moodle, NotCan y materiales de estudio", shortcut: "Super + 1", symbol: "✎" },
                    { name: "Biblioteca", description: "Libros, PDFs, consulta y Biblioteca del Seminario", shortcut: "Super + 2", symbol: "▤" },
                    { name: "Ministerium", description: "Biblia, liturgia, magisterio y trabajo pastoral", shortcut: "Super + 3", symbol: "✝" },
                    { name: "Personal", description: "Navegación y aplicaciones fuera del contexto académico", shortcut: "Super + 4", symbol: "⌂" }
                ]

                delegate: Button {
                    id: workspaceButton
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 104
                    checkable: true
                    checked: root.backend.workspace === modelData.name
                    onClicked: root.backend.setWorkspace(modelData.name)

                    background: Rectangle {
                        radius: 16
                        color: workspaceButton.checked
                               ? (root.lightTheme ? "#F0E2CF" : "#49352B")
                               : (workspaceButton.hovered
                                  ? (root.lightTheme ? "#F1E8DA" : "#24211D")
                                  : (root.lightTheme ? "#FFFDF9" : "#171B21"))
                        border.width: workspaceButton.checked ? 2 : 1
                        border.color: workspaceButton.checked
                                      ? root.accent
                                      : (root.lightTheme ? "#D5C5AE" : "#35312D")
                    }

                    contentItem: RowLayout {
                        spacing: 12

                        Rectangle {
                            width: 44
                            height: 44
                            radius: 14
                            color: workspaceButton.checked
                                   ? root.accent
                                   : (root.lightTheme ? "#F0E2CF" : "#24211D")
                            Label {
                                anchors.centerIn: parent
                                text: workspaceButton.modelData.symbol
                                color: workspaceButton.checked ? "#201B17" : root.accent
                                font.pixelSize: 17
                                font.bold: true
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3
                            Label {
                                Layout.fillWidth: true
                                text: workspaceButton.modelData.name
                                color: root.lightTheme ? "#201B17" : "#F3EEE5"
                                font.pixelSize: 13
                                font.bold: true
                            }
                            Label {
                                Layout.fillWidth: true
                                text: workspaceButton.modelData.description
                                color: root.lightTheme ? "#6B625A" : "#A79E94"
                                font.pixelSize: 9
                                wrapMode: Text.WordWrap
                            }
                            Label {
                                text: workspaceButton.modelData.shortcut
                                color: root.accent
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: infoColumn.implicitHeight + 26
            radius: 16
            color: lightTheme ? "#FFFDF9" : "#171B21"
            border.color: lightTheme ? "#D5C5AE" : "#35312D"

            ColumnLayout {
                id: infoColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 4

                Label {
                    text: "Espacio actual: " + root.backend.workspace
                    color: lightTheme ? "#201B17" : "#F3EEE5"
                    font.bold: true
                    font.pixelSize: 11
                }
                Label {
                    Layout.fillWidth: true
                    text: "El cambio se guarda inmediatamente y el shell lo detecta desde la configuración común de MurSchol."
                    color: lightTheme ? "#6B625A" : "#A79E94"
                    font.pixelSize: 9
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
