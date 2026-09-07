import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import MurScholShell 1.0
import "components"

Window {
    id: root
    width: 980
    height: (startOpen || systemOpen) ? 720 : (appManagerOpen ? 610 : (dockRaised ? 110 : 8))
    visible: false
    color: "transparent"
    flags: Qt.FramelessWindowHint
    title: "MurSchol Panel"

    property bool startOpen: false
    property bool systemOpen: false
    property bool appManagerOpen: false
    property bool dockRaised: true

    SystemBackend { id: backend }
    AppIndexModel { id: appModel }
    UniversalSearchModel { id: searchModel }
    AppManagerBackend { id: appManagerBackend }

    function animationDuration(normalValue, reducedValue) {
        if (backend.profile === "Ligero" || backend.animationMode === "Desactivadas")
            return 0
        if (backend.animationMode === "Reducidas")
            return reducedValue
        return normalValue
    }

    function showDock() {
        dockRaised = true
        hideTimer.stop()
    }

    function scheduleHide() {
        if (!backend.dockAutoHide) {
            dockRaised = true
            hideTimer.stop()
            return
        }
        if (!startOpen && !systemOpen && !appManagerOpen && !dock.pointerInside)
            hideTimer.restart()
    }

    Connections {
        target: backend
        function onDockSettingsChanged() {
            if (!backend.dockAutoHide)
                root.dockRaised = true
            else
                root.scheduleHide()
        }
    }

    Timer {
        id: hideTimer
        interval: 850
        repeat: false
        onTriggered: {
            if (backend.dockAutoHide && !root.startOpen && !root.systemOpen && !root.appManagerOpen && !dock.pointerInside)
                root.dockRaised = false
        }
    }

    Timer {
        interval: 2200
        running: backend.dockAutoHide
        repeat: false
        onTriggered: root.scheduleHide()
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    MouseArea {
        visible: backend.dockAutoHide
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.dockRaised ? 16 : 8
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered: root.showDock()
    }

    StartMenu {
        id: startMenu
        visible: root.startOpen
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: dock.top
        anchors.bottomMargin: 14
        appModel: appModel
        searchModel: searchModel
        backend: backend
        onCloseRequested: {
            root.startOpen = false
            root.scheduleHide()
        }
    }

    // Se conserva durante la migración; el acceso visible abre MurSchol Settings.
    SystemCenter {
        visible: root.systemOpen
        anchors.right: parent.right
        anchors.bottom: dock.top
        anchors.rightMargin: 16
        anchors.bottomMargin: 14
        backend: backend
    }

    Rectangle {
        visible: root.appManagerOpen
        anchors.fill: parent
        color: "#6a02070c"
        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.appManagerOpen = false
                root.scheduleHide()
            }
        }
    }

    AppManagerPanel {
        visible: root.appManagerOpen
        anchors.centerIn: parent
        backend: appManagerBackend
        onCloseRequested: {
            root.appManagerOpen = false
            root.scheduleHide()
        }
    }

    Dock {
        id: dock
        preferredSize: backend.dockSize
        magnifyOnHover: backend.dockMagnify && backend.animationMode !== "Desactivadas"
        accentColor: backend.accentColor
        x: Math.round((root.width - width) / 2)
        y: root.dockRaised ? root.height - height - 10 : root.height - 8

        Behavior on y {
            NumberAnimation {
                duration: root.animationDuration(210, 90)
                easing.type: Easing.OutCubic
            }
        }

        onPointerInsideChanged: {
            if (pointerInside)
                root.showDock()
            else
                root.scheduleHide()
        }

        onStartClicked: {
            root.startOpen = !root.startOpen
            root.systemOpen = false
            root.appManagerOpen = false
            root.showDock()
        }
        onFilesClicked: { backend.openFiles(); root.scheduleHide() }
        onBrowserClicked: { backend.openBrowser(); root.scheduleHide() }
        onTerminalClicked: { backend.openTerminal(); root.scheduleHide() }
        onAppManagerClicked: {
            root.appManagerOpen = !root.appManagerOpen
            root.startOpen = false
            root.systemOpen = false
            root.showDock()
        }
        onSystemClicked: {
            backend.openSettings("appearance")
            root.startOpen = false
            root.systemOpen = false
            root.appManagerOpen = false
            root.scheduleHide()
        }
    }

    Rectangle {
        visible: backend.dockAutoHide
        width: 76
        height: 5
        radius: 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        color: root.dockRaised ? backend.accentColor : "#547080"
        opacity: root.dockRaised ? 0.72 : 0.46
    }
}
