import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property bool pointerInside: dockHover.hovered
    signal startClicked()
    signal filesClicked()
    signal browserClicked()
    signal terminalClicked()
    signal appManagerClicked()
    signal systemClicked()

    width: 520
    height: 78
    radius: 25
    color: "#e80b1a27"
    border.width: 1
    border.color: "#3c6f83"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: root.radius - 1
        color: "transparent"
        border.width: 1
        border.color: "#153748"
        opacity: 0.9
    }

    HoverHandler { id: dockHover }

    RowLayout {
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: [
                {label:"Inicio", icon:"start-here", fallback:"⌂", action:"start"},
                {label:"Archivos", icon:"system-file-manager", fallback:"▰", action:"files"},
                {label:"Navegador", icon:"firefox-esr", fallback:"◎", action:"browser"},
                {label:"Terminal", icon:"utilities-terminal", fallback:">_", action:"terminal"},
                {label:"Instalar", icon:"system-software-install", fallback:"+", action:"install"},
                {label:"Sistema", icon:"preferences-system", fallback:"⚙", action:"system"}
            ]

            delegate: Button {
                id: dockButton
                required property var modelData
                width: 72
                height: 62

                ToolTip.visible: hovered
                ToolTip.text: modelData.label
                ToolTip.delay: 500

                background: Rectangle {
                    radius: 18
                    color: dockButton.hovered ? "#284b60" : (dockButton.down ? "#315e73" : "transparent")
                    border.width: dockButton.hovered ? 1 : 0
                    border.color: "#4d8093"
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                contentItem: ColumnLayout {
                    spacing: 1
                    Item {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34

                        Image {
                            id: themeIcon
                            anchors.centerIn: parent
                            width: 29
                            height: 29
                            source: "image://theme/" + modelData.icon
                            sourceSize.width: 32
                            sourceSize.height: 32
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        Label {
                            anchors.centerIn: parent
                            visible: themeIcon.status === Image.Error
                            text: modelData.fallback
                            color: dockButton.hovered ? "#7bf0e8" : "#e9f4f7"
                            font.pixelSize: modelData.action === "terminal" ? 14 : 20
                            font.bold: true
                        }
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.label
                        color: "#d9e6eb"
                        font.pixelSize: 9
                    }
                }

                onClicked: {
                    switch (modelData.action) {
                    case "start": root.startClicked(); break
                    case "files": root.filesClicked(); break
                    case "browser": root.browserClicked(); break
                    case "terminal": root.terminalClicked(); break
                    case "install": root.appManagerClicked(); break
                    case "system": root.systemClicked(); break
                    }
                }
            }
        }
    }

    Rectangle {
        width: 54
        height: 3
        radius: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        color: "#61dcd6"
        opacity: 0.75
    }
}
