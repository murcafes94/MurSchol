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
    color: "#07131f"

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
    Shortcut { sequence: "Meta+2"; onActivated: systemBackend.setWorkspace("Trabajos") }
    Shortcut { sequence: "Meta+3"; onActivated: systemBackend.setWorkspace("Personal") }
    Shortcut {
        sequence: "Escape"
        onActivated: {
            root.startOpen = false
            root.systemOpen = false
            root.appManagerOpen = false
            root.scheduleDockHide()
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#06131f" }
            GradientStop { position: 0.52; color: "#092d3f" }
            GradientStop { position: 1; color: "#11182d" }
        }
    }

    Rectangle {
        width: parent.width * 0.7
        height: parent.height * 0.64
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#0e2940"
        opacity: systemBackend.profile === "Ligero" ? 0.12 : 0.28
        rotation: -7
        radius: systemBackend.profile === "Ligero" ? 18 : 46
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
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.leftMargin: 38
        anchors.topMargin: 38
        spacing: 12

        Label { text: "MurSchol OS"; color: "white"; font.pixelSize: 32; font.bold: true }
        Label { text: "Aprender. Crear. Sin límites."; color: "#a9bdc6"; font.pixelSize: 15 }
        Rectangle { width: 66; height: 3; radius: 2; color: systemBackend.accentColor }
        Label {
            width: 420
            wrapMode: Text.WordWrap
            text: "“Concédeme agudeza para entender y facilidad para aprender.”\n— Santo Tomás de Aquino"
            color: "#d2e5eb"
            opacity: 0.78
            font.pixelSize: 13
            font.italic: true
        }

        RowLayout {
            spacing: 8
            Rectangle {
                width: activeSpace.implicitWidth + 22
                height: 28
                radius: 14
                color: "#153442"
                border.color: "#2b5969"
                Label {
                    id: activeSpace
                    anchors.centerIn: parent
                    text: "Espacio: " + systemBackend.workspace
                    color: systemBackend.accentColor
                    font.pixelSize: 9
                    font.bold: true
                }
            }
            Rectangle {
                width: profileText.implicitWidth + 22
                height: 28
                radius: 14
                color: "#142d3a"
                border.color: "#294b5a"
                Label {
                    id: profileText
                    anchors.centerIn: parent
                    text: "Modo: " + systemBackend.profile
                    color: "#aec5ce"
                    font.pixelSize: 9
                }
            }
        }
    }

    WorkspacePanel {
        visible: root.width >= 1200 && !root.startOpen && !root.systemOpen && !root.appManagerOpen
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 30
        anchors.bottomMargin: 28
        backend: systemBackend
    }

    Rectangle {
        visible: root.width >= 1180 && !root.startOpen && !root.systemOpen && !root.appManagerOpen
        width: 300
        height: 78
        radius: 20
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 30
        anchors.bottomMargin: 28
        color: "#b5102531"
        border.color: "#315666"
        RowLayout {
            anchors.fill: parent
            anchors.margins: 13
            spacing: 10
            Rectangle {
                width: 42
                height: 42
                radius: 13
                color: "#173e4e"
                Label { anchors.centerIn: parent; text: "⇄"; color: systemBackend.accentColor; font.pixelSize: 20; font.bold: true }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Label { text: "Multitarea"; color: "white"; font.bold: true; font.pixelSize: 12 }
                Label { text: "Alt+Tab · Super+←/→ · Super+D escritorio"; color: "#839da8"; font.pixelSize: 8 }
            }
        }
    }

    Rectangle {
        id: dockRevealHandle
        visible: !systemBackend.externalPanel && systemBackend.dockAutoHide
        z: 79
        width: 76
        height: 7
        radius: 4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        color: root.dockRaised ? systemBackend.accentColor : "#456b7c"
        opacity: root.dockRaised ? 0.75 : 0.48
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
        y: root.dockRaised ? root.height - height - 14 : root.height - 5
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
        anchors.bottomMargin: dock.height + 28
        appModel: appModel
        searchModel: universalSearch
        backend: systemBackend
        onCloseRequested: {
            root.startOpen = false
            root.scheduleDockHide()
        }
    }

    // Conservamos el componente durante la migración por compatibilidad interna,
    // pero el acceso visible de configuración abre MurSchol Settings.
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
        color: "#7a02070c"
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
        anchors.left: parent.left
        anchors.leftMargin: 22
        anchors.bottomMargin: 8
        text: systemBackend.statusText
        color: "#647f8c"
        font.pixelSize: 9
    }
}
