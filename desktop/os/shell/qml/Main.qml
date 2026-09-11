import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholShell 1.0
import "components"

ApplicationWindow {
    id: root
    width: 1440
    height: 900
    minimumWidth: 1024
    minimumHeight: 640
    visible: true
    visibility: Window.Maximized
    flags: Qt.FramelessWindowHint
    title: "MurSchol OS"
    color: "#0B0E12"

    property bool startOpen: false
    property bool systemOpen: false
    property bool appManagerOpen: false
    property bool dockRaised: true

    SystemBackend { id: systemBackend }
    AppIndexModel { id: appModel }
    UniversalSearchModel { id: universalSearch }
    AppManagerBackend { id: appManagerBackend }

    function animationDuration(normalValue, reducedValue) {
        if (systemBackend.profile === "Ligero" || systemBackend.animationMode === "Desactivadas")
            return 0
        if (systemBackend.animationMode === "Reducidas")
            return reducedValue
        return normalValue
    }

    function showDock() {
        if (systemBackend.externalPanel)
            return
        dockRaised = true
        dockHideTimer.stop()
    }

    function scheduleDockHide() {
        if (systemBackend.externalPanel)
            return
        if (!systemBackend.dockAutoHide) {
            dockRaised = true
            dockHideTimer.stop()
            return
        }
        if (!startOpen && !appManagerOpen && !dock.pointerInside)
            dockHideTimer.restart()
    }

    Connections {
        target: systemBackend
        function onDockSettingsChanged() {
            if (!systemBackend.dockAutoHide)
                root.dockRaised = true
            else
                root.scheduleDockHide()
        }
    }

    Timer {
        id: dockHideTimer
        interval: 850
        repeat: false
        onTriggered: {
            if (systemBackend.dockAutoHide && !root.startOpen && !root.appManagerOpen && !dock.pointerInside)
                root.dockRaised = false
        }
    }

    Timer {
        interval: 2200
        running: !systemBackend.externalPanel && systemBackend.dockAutoHide
        repeat: false
        onTriggered: root.scheduleDockHide()
    }

    Shortcut {
        enabled: !systemBackend.externalPanel
        sequence: "Meta+Space"
        onActivated: {
            root.startOpen = !root.startOpen
            root.showDock()
        }
    }
    Shortcut { sequence: "Meta+1"; onActivated: systemBackend.setWorkspace("Estudio") }
    Shortcut { sequence: "Meta+2"; onActivated: systemBackend.setWorkspace("Biblioteca") }
    Shortcut { sequence: "Meta+3"; onActivated: systemBackend.setWorkspace("Ministerium") }
    Shortcut { sequence: "Meta+4"; onActivated: systemBackend.setWorkspace("Personal") }
    Shortcut {
        sequence: "Escape"
        onActivated: {
            root.startOpen = false
            root.systemOpen = false
            root.appManagerOpen = false
            root.scheduleDockHide()
        }
    }

    // Fondo propio: oscuro, cálido y sobrio, inspirado en el concepto visual
    // de MurSchol sin depender de una imagen estática de la interfaz.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#080B10" }
            GradientStop { position: 0.48; color: "#111820" }
            GradientStop { position: 1.0; color: "#241A14" }
        }
    }

    Rectangle {
        width: parent.width * 0.62
        height: parent.height * 0.72
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        radius: width / 2
        color: "#7A4D2D"
        opacity: systemBackend.profile === "Ligero" ? 0.05 : 0.11
    }

    Rectangle {
        width: parent.width * 0.72
        height: parent.height * 0.34
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        color: "#111820"
        opacity: 0.64
        rotation: -4
    }

    Canvas {
        id: skyline
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Math.min(260, parent.height * 0.31)
        opacity: systemBackend.profile === "Ligero" ? 0.38 : 0.62

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var w = width
            var h = height

            ctx.fillStyle = "#0B1117"
            ctx.beginPath()
            ctx.moveTo(0, h)
            ctx.lineTo(0, h * 0.72)
            ctx.lineTo(w * 0.10, h * 0.50)
            ctx.lineTo(w * 0.20, h * 0.66)
            ctx.lineTo(w * 0.33, h * 0.42)
            ctx.lineTo(w * 0.44, h * 0.61)
            ctx.lineTo(w * 0.57, h * 0.39)
            ctx.lineTo(w * 0.70, h * 0.63)
            ctx.lineTo(w * 0.82, h * 0.46)
            ctx.lineTo(w, h * 0.68)
            ctx.lineTo(w, h)
            ctx.closePath()
            ctx.fill()

            ctx.fillStyle = "#12161A"
            ctx.fillRect(0, h * 0.76, w, h * 0.24)

            var baseX = w * 0.79
            var baseY = h * 0.76
            ctx.strokeStyle = "#8E6A42"
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.arc(baseX, baseY - 39, 28, Math.PI, 0)
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(baseX - 28, baseY - 39)
            ctx.lineTo(baseX - 28, baseY)
            ctx.moveTo(baseX + 28, baseY - 39)
            ctx.lineTo(baseX + 28, baseY)
            ctx.moveTo(baseX, baseY - 71)
            ctx.lineTo(baseX, baseY - 88)
            ctx.stroke()

            ctx.fillStyle = "#8E6A42"
            ctx.fillRect(baseX - 52, baseY - 4, 104, 4)
        }
    }

    TopBar {
        id: topBar
        z: 30
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        backend: systemBackend
        onSystemClicked: {
            systemBackend.openSettings("system")
            root.startOpen = false
            root.systemOpen = false
            root.appManagerOpen = false
            root.scheduleDockHide()
        }
    }

    ColumnLayout {
        visible: !root.startOpen && !root.appManagerOpen
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 28
        anchors.bottomMargin: 34
        spacing: 3

        Label {
            text: "MURSCHOL OS"
            color: "#F0E9DD"
            font.pixelSize: 12
            font.bold: true
            font.letterSpacing: 2
        }
        Label {
            text: "Scientia ad Sanctitatem"
            color: systemBackend.accentColor
            opacity: 0.86
            font.pixelSize: 10
            font.family: "Noto Serif"
        }
    }

    ColumnLayout {
        visible: root.width > 1100 && !root.startOpen && !root.appManagerOpen
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 34
        anchors.bottomMargin: 34
        spacing: 3

        Label {
            Layout.alignment: Qt.AlignRight
            text: "“Tú buscas, Él te encuentra.”"
            color: "#E3D8C7"
            font.pixelSize: 11
            font.italic: true
            font.family: "Noto Serif"
        }
        Label {
            Layout.alignment: Qt.AlignRight
            text: "— San Agustín"
            color: "#A98D6B"
            font.pixelSize: 9
            font.family: "Noto Serif"
        }
    }

    Rectangle {
        id: workspaceStrip
        visible: root.width >= 1080 && !root.startOpen && !root.appManagerOpen
        z: 12
        width: workspaceRow.implicitWidth + 22
        height: 38
        radius: 19
        anchors.top: topBar.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 16
        color: "#D915181D"
        border.width: 1
        border.color: "#51463B32"

        RowLayout {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: ["Estudio", "Biblioteca", "Ministerium", "Personal"]
                delegate: Button {
                    required property string modelData
                    implicitWidth: label.implicitWidth + 24
                    implicitHeight: 28
                    onClicked: systemBackend.setWorkspace(modelData)
                    background: Rectangle {
                        radius: 14
                        color: systemBackend.workspace === modelData
                               ? "#49352B2A"
                               : (parent.hovered ? "#28221D22" : "transparent")
                        border.width: systemBackend.workspace === modelData ? 1 : 0
                        border.color: systemBackend.accentColor
                    }
                    contentItem: Label {
                        id: label
                        text: modelData
                        color: systemBackend.workspace === modelData ? "#F6E8D4" : "#B9B2A8"
                        font.pixelSize: 9
                        font.bold: systemBackend.workspace === modelData
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    Rectangle {
        id: dockRevealHandle
        visible: !systemBackend.externalPanel && systemBackend.dockAutoHide
        z: 79
        width: 64
        height: 5
        radius: 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        color: root.dockRaised ? systemBackend.accentColor : "#6D6257"
        opacity: root.dockRaised ? 0.72 : 0.42
    }

    MouseArea {
        visible: !systemBackend.externalPanel && systemBackend.dockAutoHide
        z: 90
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 620
        height: 12
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered: root.showDock()
    }

    Dock {
        id: dock
        visible: !systemBackend.externalPanel
        z: 80
        preferredSize: systemBackend.dockSize
        magnifyOnHover: systemBackend.dockMagnify && systemBackend.animationMode !== "Desactivadas"
        accentColor: systemBackend.accentColor
        x: (root.width - width) / 2
        y: root.dockRaised ? root.height - height - 12 : root.height - 5
        opacity: root.dockRaised ? 1 : 0.15

        Behavior on y {
            NumberAnimation {
                duration: root.animationDuration(210, 90)
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation { duration: root.animationDuration(160, 70) }
        }

        onPointerInsideChanged: {
            if (pointerInside)
                root.showDock()
            else
                root.scheduleDockHide()
        }

        onStartClicked: {
            root.startOpen = !root.startOpen
            root.systemOpen = false
            root.appManagerOpen = false
            root.showDock()
        }
        onFilesClicked: { systemBackend.openFiles(); root.scheduleDockHide() }
        onBrowserClicked: { systemBackend.openBrowser(); root.scheduleDockHide() }
        onTerminalClicked: { systemBackend.openTerminal(); root.scheduleDockHide() }
        onAppManagerClicked: {
            root.appManagerOpen = !root.appManagerOpen
            root.startOpen = false
            root.systemOpen = false
            root.showDock()
        }
        onSystemClicked: {
            systemBackend.openSettings("appearance")
            root.startOpen = false
            root.systemOpen = false
            root.appManagerOpen = false
            root.scheduleDockHide()
        }
    }

    StartMenu {
        id: startMenu
        z: 60
        visible: !systemBackend.externalPanel && root.startOpen
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: dock.height + 26
        appModel: appModel
        searchModel: universalSearch
        backend: systemBackend
        onCloseRequested: {
            root.startOpen = false
            root.scheduleDockHide()
        }
    }

    SystemCenter {
        id: systemCenter
        z: 55
        visible: root.systemOpen
        anchors.top: topBar.bottom
        anchors.right: parent.right
        anchors.topMargin: 12
        anchors.rightMargin: 20
        backend: systemBackend
    }

    Rectangle {
        z: 40
        visible: !systemBackend.externalPanel && root.appManagerOpen
        anchors.fill: parent
        color: "#88080A0D"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.appManagerOpen = false
                root.scheduleDockHide()
            }
        }
    }

    AppManagerPanel {
        z: 41
        visible: !systemBackend.externalPanel && root.appManagerOpen
        anchors.centerIn: parent
        backend: appManagerBackend
        onCloseRequested: {
            root.appManagerOpen = false
            root.scheduleDockHide()
        }
    }

    Label {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: dock.height + 22
        visible: systemBackend.statusText !== "MurSchol listo"
        text: systemBackend.statusText
        color: "#9D9388"
        font.pixelSize: 9
    }
}
