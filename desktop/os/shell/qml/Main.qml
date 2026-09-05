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
    title: "MurSchol OS"
    color: "#07131f"

    property bool startOpen: false
    property bool systemOpen: false

    SystemBackend { id: systemBackend }
    AppIndexModel { id: appModel }

    Shortcut { sequence: "Meta+Space"; onActivated: root.startOpen = !root.startOpen }
    Shortcut { sequence: "Escape"; onActivated: { root.startOpen = false; root.systemOpen = false } }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#06131f" }
            GradientStop { position: 0.55; color: "#092b3b" }
            GradientStop { position: 1; color: "#13162c" }
        }
    }

    Rectangle {
        width: parent.width * 0.62; height: parent.height * 0.62
        anchors.right: parent.right; anchors.bottom: parent.bottom
        color: "#0d2133"; opacity: 0.35; rotation: -8; radius: 40
    }

    TopBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        backend: systemBackend
        onSystemClicked: root.systemOpen = !root.systemOpen
    }

    ColumnLayout {
        anchors.top: topBar.bottom
        anchors.left: parent.left
        anchors.leftMargin: 34
        anchors.topMargin: 34
        spacing: 16

        Label { text: "MurSchol OS"; color: "white"; font.pixelSize: 34; font.bold: true }
        Label { text: "Aprender. Crear. Sin límites."; color: "#b6c7d4"; font.pixelSize: 17 }
        Rectangle { width: 72; height: 3; radius: 2; color: "#22d6cf" }
        Label {
            width: 360; wrapMode: Text.WordWrap
            text: "“Concédeme agudeza para entender y facilidad para aprender.”\n— Santo Tomás de Aquino"
            color: "#d5e8ee"; opacity: 0.84; font.pixelSize: 15; font.italic: true
        }
    }

    WorkspacePanel {
        anchors.left: parent.left
        anchors.bottom: dock.top
        anchors.leftMargin: 30
        anchors.bottomMargin: 18
    }

    AdaptiveProfile {
        anchors.right: parent.right
        anchors.bottom: dock.top
        anchors.rightMargin: 30
        anchors.bottomMargin: 18
        backend: systemBackend
    }

    Dock {
        id: dock
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 18
        onStartClicked: root.startOpen = !root.startOpen
        onFilesClicked: systemBackend.openFiles()
        onTerminalClicked: systemBackend.openTerminal()
        onSystemClicked: root.systemOpen = !root.systemOpen
    }

    StartMenu {
        id: startMenu
        visible: root.startOpen
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: dock.top
        anchors.bottomMargin: 14
        appModel: appModel
        backend: systemBackend
        onCloseRequested: root.startOpen = false
    }

    SystemCenter {
        id: systemCenter
        visible: root.systemOpen
        anchors.top: topBar.bottom
        anchors.right: parent.right
        anchors.topMargin: 12
        anchors.rightMargin: 20
        backend: systemBackend
    }

    Label {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 22
        anchors.bottomMargin: 8
        text: systemBackend.statusText
        color: "#79909e"
        font.pixelSize: 11
    }
}
