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

    width: 432
    height: 66
    radius: 21
    color: "#ee0b1824"
    border.width: 1
    border.color: "#486a7a"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: root.radius - 1
        color: "transparent"
        border.width: 1
        border.color: "#132f3d"
        opacity: 0.92
    }

    HoverHandler { id: dockHover }

    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: [
                {label:"Inicio", icon:"", fallback:"MS", action:"start"},
                {label:"Archivos", icon:"system-file-manager", fallback:"▰", action:"files"},
                {label:"Navegador", icon:"firefox-esr", fallback:"◎", action:"browser"},
                {label:"Terminal", icon:"utilities-terminal", fallback:">_", action:"terminal"},
                {label:"Instalar aplicaciones", icon:"system-software-install", fallback:"+", action:"install"},
                {label:"Sistema", icon:"preferences-system", fallback:"⚙", action:"system"}
            ]

            delegate: Button {
                id: dockButton
                required property var modelData
                width: 58
                height: 54
                scale: hovered ? 1.06 : 1.0

                ToolTip.visible: hovered
                ToolTip.text: modelData.label
                ToolTip.delay: 420

                Behavior on scale {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }

                background: Rectangle {
                    radius: 15
                    color: dockButton.down
                           ? "#31596c"
                           : (dockButton.hovered ? "#253f4e" : "transparent")
                    border.width: dockButton.hovered ? 1 : 0
                    border.color: "#466d7e"
                    Behavior on color { ColorAnimation { duration: 110 } }
                }

                contentItem: Item {
                    anchors.fill: parent

                    Rectangle {
                        visible: modelData.action === "start"
                        anchors.centerIn: parent
                        width: 34
                        height: 34
                        radius: 11
                        color: dockButton.hovered ? "#1d6270" : "#164653"
                        border.width: 1
                        border.color: dockButton.hovered ? "#59ddd6" : "#2e7380"

                        Label {
                            anchors.centerIn: parent
                            text: "MS"
                            color: "#ddfffc"
                            font.bold: true
                            font.pixelSize: 11
                        }
                    }

                    Image {
                        id: themeIcon
                        visible: modelData.action !== "start"
                        anchors.centerIn: parent
                        width: 29
                        height: 29
                        source: modelData.icon.length > 0 ? "image://theme/" + modelData.icon : ""
                        sourceSize.width: 34
                        sourceSize.height: 34
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        anchors.centerIn: parent
                        visible: modelData.action !== "start" && themeIcon.status === Image.Error
                        text: modelData.fallback
                        color: dockButton.hovered ? "#78eee7" : "#e4eff3"
                        font.pixelSize: modelData.action === "terminal" ? 13 : 19
                        font.bold: true
                    }

                    // Reserva visual para el futuro estado de aplicaciones abiertas:
                    // el punto se activará cuando el modelo de ventanas de labwc esté conectado.
                    Rectangle {
                        visible: false
                        width: 5
                        height: 5
                        radius: 3
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        color: "#63e4de"
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
        width: 46
        height: 3
        radius: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        color: "#56d8d2"
        opacity: 0.58
    }
}
