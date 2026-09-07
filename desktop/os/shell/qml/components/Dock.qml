import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property bool pointerInside: dockHover.hovered
    property int preferredSize: 66
    property bool magnifyOnHover: true
    property color accentColor: "#56d8d2"
    readonly property real sizeFactor: Math.max(0.82, Math.min(1.28, preferredSize / 66.0))
    signal startClicked()
    signal filesClicked()
    signal browserClicked()
    signal terminalClicked()
    signal appManagerClicked()
    signal systemClicked()

    width: Math.round(432 * sizeFactor)
    height: Math.round(66 * sizeFactor)
    radius: Math.round(21 * sizeFactor)
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
        spacing: Math.max(4, Math.round(6 * root.sizeFactor))

        Repeater {
            model: [
                {label:"Inicio", icon:"", fallback:"MS", action:"start"},
                {label:"Archivos", icon:"system-file-manager", fallback:"▰", action:"files"},
                {label:"Navegador", icon:"firefox-esr", fallback:"◎", action:"browser"},
                {label:"Terminal", icon:"utilities-terminal", fallback:">_", action:"terminal"},
                {label:"Instalar aplicaciones", icon:"system-software-install", fallback:"+", action:"install"},
                {label:"Configuración", icon:"preferences-system", fallback:"⚙", action:"system"}
            ]

            delegate: Button {
                id: dockButton
                required property var modelData
                width: Math.round(58 * root.sizeFactor)
                height: Math.round(54 * root.sizeFactor)
                scale: root.magnifyOnHover && hovered ? 1.06 : 1.0

                ToolTip.visible: hovered
                ToolTip.text: modelData.label
                ToolTip.delay: 420

                Behavior on scale {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }

                background: Rectangle {
                    radius: Math.round(15 * root.sizeFactor)
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
                        width: Math.round(34 * root.sizeFactor)
                        height: Math.round(34 * root.sizeFactor)
                        radius: Math.round(11 * root.sizeFactor)
                        color: dockButton.hovered ? "#1d6270" : "#164653"
                        border.width: 1
                        border.color: dockButton.hovered ? root.accentColor : "#2e7380"

                        Label {
                            anchors.centerIn: parent
                            text: "MS"
                            color: "#ddfffc"
                            font.bold: true
                            font.pixelSize: Math.round(11 * root.sizeFactor)
                        }
                    }

                    Image {
                        id: themeIcon
                        visible: modelData.action !== "start"
                        anchors.centerIn: parent
                        width: Math.round(29 * root.sizeFactor)
                        height: Math.round(29 * root.sizeFactor)
                        source: modelData.icon.length > 0 ? "image://theme/" + modelData.icon : ""
                        sourceSize.width: Math.round(34 * root.sizeFactor)
                        sourceSize.height: Math.round(34 * root.sizeFactor)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        anchors.centerIn: parent
                        visible: modelData.action !== "start" && themeIcon.status === Image.Error
                        text: modelData.fallback
                        color: dockButton.hovered ? root.accentColor : "#e4eff3"
                        font.pixelSize: Math.round((modelData.action === "terminal" ? 13 : 19) * root.sizeFactor)
                        font.bold: true
                    }

                    // Reserva visual para el futuro estado de aplicaciones abiertas:
                    // el punto se activará cuando el modelo de ventanas de labwc esté conectado.
                    Rectangle {
                        visible: false
                        width: Math.max(4, Math.round(5 * root.sizeFactor))
                        height: width
                        radius: width / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        color: root.accentColor
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
        width: Math.round(46 * root.sizeFactor)
        height: Math.max(2, Math.round(3 * root.sizeFactor))
        radius: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 3
        color: root.accentColor
        opacity: 0.58
    }
}
