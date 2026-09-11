import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property bool pointerInside: dockHover.hovered
    property int preferredSize: 64
    property bool magnifyOnHover: true
    property color accentColor: "#D6A85F"
    readonly property real sizeFactor: Math.max(0.84, Math.min(1.22, preferredSize / 64.0))
    signal startClicked()
    signal filesClicked()
    signal browserClicked()
    signal terminalClicked()
    signal appManagerClicked()
    signal systemClicked()

    width: Math.round(438 * sizeFactor)
    height: Math.round(64 * sizeFactor)
    radius: Math.round(20 * sizeFactor)
    color: "#F21A1D22"
    border.width: 1
    border.color: "#6A5A493C"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: root.radius - 2
        color: "#15181D"
        opacity: 0.82
        border.width: 1
        border.color: "#332C2723"
    }

    HoverHandler { id: dockHover }

    RowLayout {
        anchors.centerIn: parent
        spacing: Math.max(4, Math.round(6 * root.sizeFactor))

        Repeater {
            model: [
                {label:"Inicio", icon:"", fallback:"✝", action:"start", tone:"#2A211B"},
                {label:"Archivos", icon:"system-file-manager", fallback:"▰", action:"files", tone:"#B78947"},
                {label:"MurSchol Browser", icon:"web-browser", fallback:"◉", action:"browser", tone:"#2E5878"},
                {label:"Aplicaciones", icon:"system-software-install", fallback:"▦", action:"install", tone:"#74504A"},
                {label:"Terminal", icon:"utilities-terminal", fallback:">_", action:"terminal", tone:"#242B31"},
                {label:"Configuración", icon:"preferences-system", fallback:"⚙", action:"system", tone:"#4B4F55"}
            ]

            delegate: Button {
                id: dockButton
                required property var modelData
                width: Math.round(58 * root.sizeFactor)
                height: Math.round(54 * root.sizeFactor)
                scale: root.magnifyOnHover && hovered ? 1.08 : 1.0

                ToolTip.visible: hovered
                ToolTip.text: modelData.label
                ToolTip.delay: 350

                Behavior on scale {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }

                background: Rectangle {
                    radius: Math.round(15 * root.sizeFactor)
                    color: dockButton.down
                           ? "#40332629"
                           : (dockButton.hovered ? "#29251F24" : "transparent")
                    border.width: dockButton.hovered ? 1 : 0
                    border.color: dockButton.hovered ? root.accentColor : "transparent"
                }

                contentItem: Item {
                    anchors.fill: parent

                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.round(36 * root.sizeFactor)
                        height: Math.round(36 * root.sizeFactor)
                        radius: Math.round(11 * root.sizeFactor)
                        color: modelData.tone
                        border.width: 1
                        border.color: dockButton.hovered ? root.accentColor : "#5A50473C"

                        Image {
                            id: themeIcon
                            visible: modelData.action !== "start"
                            anchors.centerIn: parent
                            width: Math.round(24 * root.sizeFactor)
                            height: Math.round(24 * root.sizeFactor)
                            source: modelData.icon.length > 0 ? "image://theme/" + modelData.icon : ""
                            sourceSize.width: Math.round(30 * root.sizeFactor)
                            sourceSize.height: Math.round(30 * root.sizeFactor)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        Label {
                            anchors.centerIn: parent
                            visible: modelData.action === "start" || themeIcon.status === Image.Error
                            text: modelData.fallback
                            color: dockButton.hovered ? root.accentColor : "#F2EEE6"
                            font.pixelSize: Math.round((modelData.action === "terminal" ? 12 : 18) * root.sizeFactor)
                            font.bold: true
                        }
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
        width: Math.round(42 * root.sizeFactor)
        height: Math.max(2, Math.round(2 * root.sizeFactor))
        radius: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        color: root.accentColor
        opacity: 0.72
    }
}
