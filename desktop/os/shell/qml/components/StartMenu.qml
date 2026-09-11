import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var appModel
    property var searchModel
    property var backend
    property string selectedCategory: "Todas"
    signal closeRequested()

    width: Math.min(860, parent ? parent.width - 80 : 860)
    height: Math.min(590, parent ? parent.height - 130 : 590)
    radius: 26
    color: "#F0191C21"
    border.width: 1
    border.color: "#6A5A493C"

    onVisibleChanged: {
        if (visible) {
            selectedCategory = appModel.pinnedCount > 0 ? "Fijadas" : "Todas"
            appModel.categoryFilter = selectedCategory
            appModel.filter = ""
            search.text = ""
            search.forceActiveFocus()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 42
                height: 42
                radius: 14
                color: "#2A211B"
                border.width: 1
                border.color: backend.accentColor
                Label {
                    anchors.centerIn: parent
                    text: "✝"
                    color: backend.accentColor
                    font.pixelSize: 18
                    font.bold: true
                }
            }

            ColumnLayout {
                spacing: 1
                Label {
                    text: "MurSchol OS"
                    color: "#F5F1E8"
                    font.pixelSize: 20
                    font.bold: true
                }
                Label {
                    text: "Scientia ad Sanctitatem"
                    color: "#AFA293"
                    font.pixelSize: 9
                    font.family: "Noto Serif"
                }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: workspaceText.implicitWidth + 30
                height: 34
                radius: 17
                color: "#302820"
                border.width: 1
                border.color: "#6A51382F"
                Label {
                    id: workspaceText
                    anchors.centerIn: parent
                    text: backend.workspace
                    color: "#F1DEC1"
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Button {
                width: 34
                height: 34
                text: "×"
                onClicked: root.closeRequested()
                background: Rectangle {
                    radius: 11
                    color: parent.hovered ? "#3C272629" : "transparent"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#EAE4DA"
                    font.pixelSize: 18
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        TextField {
            id: search
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            placeholderText: "Buscar aplicaciones, archivos o ajustes…"
            color: "#F4F0E8"
            placeholderTextColor: "#8F8982"
            leftPadding: 17
            rightPadding: 17
            font.pixelSize: 12
            background: Rectangle {
                radius: 16
                color: "#171A1F"
                border.width: search.activeFocus ? 1 : 1
                border.color: search.activeFocus ? backend.accentColor : "#4B433C35"
            }
            onTextChanged: {
                root.appModel.filter = text
                root.searchModel.query = text
            }
            Keys.onReturnPressed: {
                if (text.trim().length >= 2 && root.searchModel.count > 0) {
                    root.searchModel.activate(0)
                    root.closeRequested()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            Rectangle {
                visible: search.text.trim().length < 2
                Layout.preferredWidth: 182
                Layout.fillHeight: true
                radius: 18
                color: "#C912151A"
                border.width: 1
                border.color: "#3A342F2B"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Label {
                        text: "Biblioteca de aplicaciones"
                        color: "#9D9489"
                        font.pixelSize: 9
                        font.bold: true
                        Layout.leftMargin: 8
                        Layout.bottomMargin: 3
                    }

                    Repeater {
                        model: [
                            {name:"Fijadas", symbol:"★"},
                            {name:"Recientes", symbol:"◷"},
                            {name:"Todas", symbol:"▦"},
                            {name:"Educación", symbol:"▤"},
                            {name:"Productividad", symbol:"◆"},
                            {name:"Internet", symbol:"◎"},
                            {name:"Multimedia", symbol:"▶"},
                            {name:"Sistema", symbol:"⚙"}
                        ]

                        delegate: Button {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 39
                            onClicked: {
                                root.selectedCategory = modelData.name
                                root.appModel.categoryFilter = modelData.name
                            }
                            background: Rectangle {
                                radius: 12
                                color: root.selectedCategory === modelData.name
                                       ? "#3C2D2427"
                                       : (parent.hovered ? "#222126" : "transparent")
                                border.width: root.selectedCategory === modelData.name ? 1 : 0
                                border.color: backend.accentColor
                            }
                            contentItem: RowLayout {
                                spacing: 9
                                Label {
                                    text: modelData.symbol
                                    color: root.selectedCategory === modelData.name ? backend.accentColor : "#9A9188"
                                    font.pixelSize: 13
                                    Layout.preferredWidth: 20
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Label {
                                    text: modelData.name
                                    color: root.selectedCategory === modelData.name ? "#F3E7D7" : "#CBC4BA"
                                    font.pixelSize: 10
                                    font.bold: root.selectedCategory === modelData.name
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#3A342F2B"
                    }
                    Label {
                        Layout.leftMargin: 8
                        text: appModel.count + " aplicaciones"
                        color: "#80786F"
                        font.pixelSize: 8
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                GridView {
                    id: grid
                    visible: search.text.trim().length < 2
                    anchors.fill: parent
                    clip: true
                    cellWidth: Math.max(130, width / Math.max(3, Math.floor(width / 142)))
                    cellHeight: 112
                    model: root.appModel

                    delegate: Button {
                        id: appButton
                        width: grid.cellWidth - 10
                        height: 100
                        onClicked: {
                            root.appModel.launch(index)
                            root.closeRequested()
                        }
                        background: Rectangle {
                            radius: 17
                            color: appButton.hovered ? "#2B272329" : "#111419"
                            border.width: 1
                            border.color: appButton.hovered ? backend.accentColor : "#39342F2B"
                        }
                        contentItem: ColumnLayout {
                            spacing: 5
                            Item { Layout.fillHeight: true }
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 48
                                height: 48
                                radius: 14
                                color: appButton.hovered ? "#372C232B" : "#1D2025"
                                border.width: 1
                                border.color: appButton.hovered ? backend.accentColor : "#49423B34"
                                Image {
                                    id: appThemeIcon
                                    anchors.centerIn: parent
                                    width: 32
                                    height: 32
                                    source: "image://theme/" + iconName
                                    sourceSize.width: 36
                                    sourceSize.height: 36
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }
                                Label {
                                    anchors.centerIn: parent
                                    visible: appThemeIcon.status === Image.Error
                                    text: appName.length > 0 ? appName.substring(0, 1).toUpperCase() : "•"
                                    color: "#F2ECE2"
                                    font.pixelSize: 17
                                    font.bold: true
                                }
                            }
                            Label {
                                Layout.fillWidth: true
                                text: appName
                                color: "#F0EBE3"
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: 10
                                font.bold: true
                            }
                            Item { Layout.fillHeight: true }
                        }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 7
                            anchors.rightMargin: 7
                            width: 25
                            height: 25
                            radius: 9
                            visible: appPinned || appButton.hovered
                            color: pinArea.containsMouse ? "#342C252A" : "#1A1D22"
                            border.width: appPinned ? 1 : 0
                            border.color: backend.accentColor
                            Label {
                                anchors.centerIn: parent
                                text: appPinned ? "★" : "☆"
                                color: appPinned ? backend.accentColor : "#8D857D"
                                font.pixelSize: 13
                            }
                            MouseArea {
                                id: pinArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: mouse => {
                                    mouse.accepted = true
                                    root.appModel.togglePinned(index)
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: results
                    visible: search.text.trim().length >= 2
                    anchors.fill: parent
                    clip: true
                    spacing: 7
                    model: root.searchModel

                    delegate: Button {
                        width: results.width
                        height: 64
                        onClicked: {
                            root.searchModel.activate(index)
                            root.closeRequested()
                        }
                        background: Rectangle {
                            radius: 15
                            color: parent.hovered ? "#2B272329" : "#111419"
                            border.width: 1
                            border.color: parent.hovered ? backend.accentColor : "#39342F2B"
                        }
                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 11
                            Rectangle {
                                width: 38
                                height: 38
                                radius: 12
                                color: "#231F1C"
                                border.width: 1
                                border.color: "#544637"
                                Label {
                                    anchors.centerIn: parent
                                    text: resultKind === "Aplicación" ? "A" : (resultKind === "Documento" ? "D" : "→")
                                    color: backend.accentColor
                                    font.bold: true
                                }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Label {
                                    Layout.fillWidth: true
                                    text: resultTitle
                                    color: "#F1ECE4"
                                    font.bold: true
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: resultSubtitle
                                    color: "#8E867E"
                                    font.pixelSize: 9
                                    elide: Text.ElideMiddle
                                }
                            }
                            Label {
                                text: resultKind
                                color: "#9D9489"
                                font.pixelSize: 8
                            }
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: (search.text.trim().length >= 2 && root.searchModel.count === 0)
                             || (search.text.trim().length < 2 && root.appModel.count === 0)
                    text: search.text.trim().length >= 2
                          ? "No encontramos resultados locales."
                          : "No hay aplicaciones en esta categoría."
                    color: "#91887E"
                    font.pixelSize: 11
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Label {
                text: "Super+Espacio · Inicio   ·   Super+1…4 · Espacios"
                color: "#80786F"
                font.pixelSize: 8
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Archivos"
                onClicked: {
                    backend.openFiles()
                    root.closeRequested()
                }
                background: Rectangle {
                    radius: 11
                    color: parent.hovered ? "#2B272329" : "#15181D"
                    border.width: 1
                    border.color: "#443C352F"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#D8D0C5"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                }
            }
            Button {
                text: "Configuración"
                onClicked: {
                    backend.openSettings("appearance")
                    root.closeRequested()
                }
                background: Rectangle {
                    radius: 11
                    color: parent.hovered ? "#3C2D2427" : "#15181D"
                    border.width: 1
                    border.color: parent.hovered ? backend.accentColor : "#443C352F"
                }
                contentItem: Label {
                    text: parent.text
                    color: parent.hovered ? "#F3E1C5" : "#D8D0C5"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 9
                }
            }
        }
    }
}
