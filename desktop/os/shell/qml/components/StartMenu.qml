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
    color: "#f20c1c29"
    border.width: 1
    border.color: "#3d6577"

    onVisibleChanged: {
        if (visible) {
            selectedCategory = "Todas"
            appModel.categoryFilter = "Todas"
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
                color: "#154052"
                border.color: "#29d9d1"
                Label {
                    anchors.centerIn: parent
                    text: "MS"
                    color: "#cffffb"
                    font.bold: true
                    font.pixelSize: 14
                }
            }

            ColumnLayout {
                spacing: 0
                Label { text: "MurSchol OS"; color: "white"; font.pixelSize: 23; font.bold: true }
                Label { text: "Aprender. Crear. Sin límites."; color: "#7899a8"; font.pixelSize: 10 }
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                width: 130
                height: 36
                radius: 18
                color: "#142f3c"
                Label {
                    anchors.centerIn: parent
                    text: "Espacio: " + backend.workspace
                    color: "#9fe7e2"
                    font.pixelSize: 10
                    font.bold: true
                }
            }

            Button {
                width: 38
                height: 38
                text: "×"
                onClicked: root.closeRequested()
                background: Rectangle { radius: 12; color: parent.hovered ? "#29495a" : "transparent" }
                contentItem: Label {
                    text: parent.text
                    color: "#dce8ec"
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
            color: "white"
            placeholderTextColor: "#77929f"
            leftPadding: 18
            rightPadding: 18
            font.pixelSize: 13
            background: Rectangle {
                radius: 18
                color: "#172d3a"
                border.width: search.activeFocus ? 2 : 1
                border.color: search.activeFocus ? "#28d4d0" : "#355567"
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
                color: "#8a102632"
                border.color: "#294859"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Label {
                        text: "Categorías"
                        color: "#7998a6"
                        font.pixelSize: 10
                        font.bold: true
                        Layout.leftMargin: 9
                        Layout.topMargin: 4
                    }

                    Repeater {
                        model: [
                            {name:"Todas", symbol:"▦"},
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
                            Layout.preferredHeight: 42
                            onClicked: {
                                root.selectedCategory = modelData.name
                                root.appModel.categoryFilter = modelData.name
                            }
                            background: Rectangle {
                                radius: 13
                                color: root.selectedCategory === modelData.name
                                       ? "#174c66"
                                       : (parent.hovered ? "#173543" : "transparent")
                                border.width: root.selectedCategory === modelData.name ? 1 : 0
                                border.color: "#2a82a0"
                            }
                            contentItem: RowLayout {
                                spacing: 9
                                Label {
                                    text: modelData.symbol
                                    color: root.selectedCategory === modelData.name ? "#65e9e2" : "#8da9b5"
                                    font.pixelSize: 15
                                    Layout.preferredWidth: 22
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                Label {
                                    text: modelData.name
                                    color: root.selectedCategory === modelData.name ? "white" : "#c2d0d6"
                                    font.pixelSize: 11
                                    font.bold: root.selectedCategory === modelData.name
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#294553" }
                    Label {
                        Layout.leftMargin: 9
                        text: appModel.count + " aplicaciones"
                        color: "#708b97"
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
                        width: grid.cellWidth - 10
                        height: 100
                        text: appName
                        icon.name: iconName
                        icon.width: 34
                        icon.height: 34
                        display: AbstractButton.TextUnderIcon
                        spacing: 8

                        onClicked: {
                            root.appModel.launch(index)
                            root.closeRequested()
                        }

                        background: Rectangle {
                            radius: 18
                            color: parent.hovered ? "#21475a" : "#132b38"
                            border.width: 1
                            border.color: parent.hovered ? "#3f7c91" : "#294b5c"
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        contentItem: ColumnLayout {
                            spacing: 5
                            Item { Layout.fillHeight: true }
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 44
                                height: 44
                                radius: 13
                                color: "#1c4356"
                                Label {
                                    anchors.centerIn: parent
                                    text: appName.length > 0 ? appName.substring(0, 1).toUpperCase() : "•"
                                    color: "#7ceae4"
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }
                            Label {
                                Layout.fillWidth: true
                                text: appName
                                color: "#f0f6f8"
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: 10
                                font.bold: true
                            }
                            Label {
                                Layout.fillWidth: true
                                text: appSource
                                color: "#6f8995"
                                horizontalAlignment: Text.AlignHCenter
                                font.pixelSize: 8
                            }
                            Item { Layout.fillHeight: true }
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
                            color: parent.hovered ? "#224758" : "#142c38"
                            border.color: parent.hovered ? "#3b788d" : "#294958"
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
                                color: resultKind === "Aplicación" ? "#174957" : (resultKind === "Documento" ? "#263e5a" : "#254339")
                                Label {
                                    anchors.centerIn: parent
                                    text: resultKind === "Aplicación" ? "A" : (resultKind === "Documento" ? "D" : "→")
                                    color: resultKind === "Aplicación" ? "#65e3dc" : (resultKind === "Documento" ? "#9fc8ff" : "#92e0af")
                                    font.bold: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Label {
                                    Layout.fillWidth: true
                                    text: resultTitle
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: resultSubtitle
                                    color: "#7f99a5"
                                    font.pixelSize: 9
                                    elide: Text.ElideMiddle
                                }
                            }

                            Label { text: resultKind; color: "#8ea7b2"; font.pixelSize: 9 }
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
                    color: "#708a95"
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
                color: "#718d99"
                font.pixelSize: 9
            }
            Item { Layout.fillWidth: true }
            Button { text: "Archivos"; onClicked: { backend.openFiles(); root.closeRequested() } }
            Button { text: "Apagar"; onClicked: backend.powerOff() }
        }
    }
}
