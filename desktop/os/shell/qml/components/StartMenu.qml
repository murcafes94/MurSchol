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

    width: Math.min(900, parent ? parent.width - 70 : 900)
    height: Math.min(620, parent ? parent.height - 110 : 620)
    radius: 30
    color: "#f20B0D12"
    border.width: 1
    border.color: "#5B6573"

    function categoryCountText() {
        if (selectedCategory === "Fijadas")
            return appModel.pinnedCount + " fijadas"
        if (selectedCategory === "Recientes")
            return appModel.recentCount + " recientes"
        return appModel.count + " aplicaciones"
    }

    function emptyCategoryText() {
        if (selectedCategory === "Fijadas")
            return "Todavía no has fijado aplicaciones. Usa ☆ en cualquier app."
        if (selectedCategory === "Recientes")
            return "Las aplicaciones que abras desde Inicio aparecerán aquí."
        return "No hay aplicaciones en esta categoría."
    }

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
        anchors.margins: 22
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                width: 46
                height: 46
                radius: 15
                color: "#123A7A"
                border.color: "#2563EB"
                Label {
                    anchors.centerIn: parent
                    text: "MS"
                    color: "#F8FAFC"
                    font.bold: true
                    font.pixelSize: 14
                }
            }

            ColumnLayout {
                spacing: 0
                Label { text: "MurSchol OS"; color: "#F8FAFC"; font.pixelSize: 23; font.bold: true }
                Label { text: "Aprender. Crear. Sin límites."; color: "#9AA4B2"; font.pixelSize: 10 }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 130
                height: 36
                radius: 18
                color: "#171C24"
                border.width: 1
                border.color: "#252B35"
                Label {
                    anchors.centerIn: parent
                    text: "Espacio: " + backend.workspace
                    color: "#3B82F6"
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Button {
                width: 38
                height: 38
                text: "×"
                onClicked: root.closeRequested()
                background: Rectangle { radius: 12; color: parent.hovered ? "#3a1519" : "transparent" }
                contentItem: Label {
                    text: parent.text
                    color: "#F8FAFC"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        TextField {
            id: search
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            placeholderText: "Buscar aplicaciones, archivos, ajustes…"
            color: "#F8FAFC"
            placeholderTextColor: "#9AA4B2"
            leftPadding: 18
            rightPadding: 18
            font.pixelSize: 13
            background: Rectangle {
                radius: 18
                color: "#171C24"
                border.width: search.activeFocus ? 2 : 1
                border.color: search.activeFocus ? "#2563EB" : "#5B6573"
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
            spacing: 16

            Rectangle {
                visible: search.text.trim().length < 2
                Layout.preferredWidth: 185
                Layout.fillHeight: true
                radius: 20
                color: "#e611151c"
                border.color: "#252B35"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Label {
                        text: "Inicio"
                        color: "#9AA4B2"
                        font.pixelSize: 10
                        font.bold: true
                        Layout.leftMargin: 9
                        Layout.topMargin: 4
                    }

                    Repeater {
                        model: [
                            {name:"Fijadas", symbol:"★"},
                            {name:"Recientes", symbol:"◷"},
                            {name:"Todas", symbol:"▦"}
                        ]

                        delegate: Button {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            onClicked: {
                                root.selectedCategory = modelData.name
                                root.appModel.categoryFilter = modelData.name
                            }
                            background: Rectangle {
                                radius: 13
                                color: root.selectedCategory === modelData.name
                                       ? "#123A7A"
                                       : (parent.hovered ? "#171C24" : "transparent")
                                border.width: root.selectedCategory === modelData.name ? 1 : 0
                                border.color: "#2563EB"
                            }
                            contentItem: RowLayout {
                                spacing: 9
                                Label {
                                    text: modelData.symbol
                                    color: root.selectedCategory === modelData.name ? "#3B82F6" : "#9AA4B2"
                                    font.pixelSize: 15
                                    Layout.preferredWidth: 22
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Label {
                                    text: modelData.name
                                    color: root.selectedCategory === modelData.name ? "#F8FAFC" : "#D8DEE9"
                                    font.pixelSize: 11
                                    font.bold: root.selectedCategory === modelData.name
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        Layout.topMargin: 4
                        Layout.bottomMargin: 2
                        height: 1
                        color: "#252B35"
                    }

                    Label {
                        text: "Categorías"
                        color: "#9AA4B2"
                        font.pixelSize: 10
                        font.bold: true
                        Layout.leftMargin: 9
                        Layout.topMargin: 2
                    }

                    Repeater {
                        model: [
                            {name:"Educación", symbol:"▣"},
                            {name:"Productividad", symbol:"◆"},
                            {name:"Multimedia", symbol:"▶"},
                            {name:"Internet", symbol:"◎"},
                            {name:"Sistema", symbol:"⚙"},
                            {name:"Accesibilidad", symbol:"♿"}
                        ]

                        delegate: Button {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 37
                            onClicked: {
                                root.selectedCategory = modelData.name
                                root.appModel.categoryFilter = modelData.name
                            }
                            background: Rectangle {
                                radius: 12
                                color: root.selectedCategory === modelData.name
                                       ? "#123A7A"
                                       : (parent.hovered ? "#171C24" : "transparent")
                                border.width: root.selectedCategory === modelData.name ? 1 : 0
                                border.color: "#2563EB"
                            }
                            contentItem: RowLayout {
                                spacing: 9
                                Label {
                                    text: modelData.symbol
                                    color: root.selectedCategory === modelData.name ? "#3B82F6" : "#9AA4B2"
                                    font.pixelSize: 14
                                    Layout.preferredWidth: 22
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Label {
                                    text: modelData.name
                                    color: root.selectedCategory === modelData.name ? "#F8FAFC" : "#D8DEE9"
                                    font.pixelSize: 10
                                    font.bold: root.selectedCategory === modelData.name
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#252B35" }
                    Label {
                        Layout.leftMargin: 9
                        text: root.categoryCountText()
                        color: "#9AA4B2"
                        font.pixelSize: 9
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
                    cellWidth: Math.max(132, width / Math.max(3, Math.floor(width / 145)))
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
                            radius: 18
                            color: appButton.hovered ? "#123A7A" : "#11151C"
                            border.width: 1
                            border.color: appButton.hovered ? "#2563EB" : "#252B35"
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        contentItem: ColumnLayout {
                            spacing: 5
                            Item { Layout.fillHeight: true }
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 50
                                height: 50
                                radius: 15
                                color: appButton.hovered ? "#2563EB" : "#171C24"
                                border.width: 1
                                border.color: appButton.hovered ? "#3B82F6" : "#252B35"

                                Image {
                                    id: appThemeIcon
                                    anchors.centerIn: parent
                                    width: 35
                                    height: 35
                                    source: "image://theme/" + iconName
                                    sourceSize.width: 40
                                    sourceSize.height: 40
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }

                                Label {
                                    anchors.centerIn: parent
                                    visible: appThemeIcon.status === Image.Error
                                    text: appName.length > 0 ? appName.substring(0, 1).toUpperCase() : "•"
                                    color: "#F8FAFC"
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }
                            Label {
                                Layout.fillWidth: true
                                text: appName
                                color: "#F8FAFC"
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: 10
                                font.bold: true
                            }
                            Item { Layout.fillHeight: true }
                        }

                        Rectangle {
                            z: 5
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 7
                            anchors.rightMargin: 7
                            width: 26
                            height: 26
                            radius: 9
                            visible: appPinned || appButton.hovered
                            color: pinArea.containsMouse ? "#123A7A" : "#171C24"
                            border.width: appPinned ? 1 : 0
                            border.color: "#2563EB"

                            Label {
                                anchors.centerIn: parent
                                text: appPinned ? "★" : "☆"
                                color: appPinned ? "#3B82F6" : "#9AA4B2"
                                font.pixelSize: 14
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
                    spacing: 8
                    model: root.searchModel

                    delegate: Button {
                        width: results.width
                        height: 68
                        onClicked: {
                            root.searchModel.activate(index)
                            root.closeRequested()
                        }
                        background: Rectangle {
                            radius: 16
                            color: parent.hovered ? "#123A7A" : "#11151C"
                            border.color: parent.hovered ? "#2563EB" : "#252B35"
                        }
                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 12
                                color: resultKind === "Aplicación" ? "#123A7A" : "#171C24"
                                Label {
                                    anchors.centerIn: parent
                                    text: resultKind === "Aplicación" ? "A" : (resultKind === "Documento" ? "D" : "→")
                                    color: resultKind === "Aplicación" ? "#3B82F6" : "#F8FAFC"
                                    font.bold: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Label {
                                    Layout.fillWidth: true
                                    text: resultTitle
                                    color: "#F8FAFC"
                                    font.bold: true
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: resultSubtitle
                                    color: "#9AA4B2"
                                    font.pixelSize: 9
                                    elide: Text.ElideMiddle
                                }
                            }

                            Label { text: resultKind; color: "#9AA4B2"; font.pixelSize: 9 }
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 40, 420)
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    visible: (search.text.trim().length >= 2 && root.searchModel.count === 0)
                             || (search.text.trim().length < 2 && root.appModel.count === 0)
                    text: search.text.trim().length >= 2
                          ? "No encontramos resultados locales."
                          : root.emptyCategoryText()
                    color: "#9AA4B2"
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: search.text.trim().length >= 2
                      ? root.searchModel.count + " resultados"
                      : "Alt+Tab cambia entre ventanas · Super+←/→ divide la pantalla"
                color: "#9AA4B2"
                font.pixelSize: 9
            }
            Item { Layout.fillWidth: true }

            Button {
                visible: search.text.trim().length < 2 && root.selectedCategory === "Recientes" && root.appModel.recentCount > 0
                text: "Borrar recientes"
                onClicked: root.appModel.clearRecent()
                background: Rectangle {
                    radius: 12
                    color: parent.hovered ? "#3a1519" : "#11151C"
                    border.width: 1
                    border.color: "#E63946"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#E63946"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                text: "Archivos"
                onClicked: {
                    backend.openFiles()
                    root.closeRequested()
                }
                background: Rectangle {
                    radius: 12
                    color: parent.hovered ? "#171C24" : "#11151C"
                    border.width: 1
                    border.color: parent.hovered ? "#2563EB" : "#5B6573"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#F8FAFC"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                text: "Configuración"
                onClicked: {
                    backend.openSettings("")
                    root.closeRequested()
                }
                background: Rectangle {
                    radius: 12
                    color: parent.hovered ? "#3B82F6" : "#2563EB"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#FFFFFF"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                text: "Apagar"
                onClicked: backend.powerOff()
                background: Rectangle {
                    radius: 12
                    color: parent.hovered ? "#FF4D5A" : "#E63946"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#FFFFFF"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
