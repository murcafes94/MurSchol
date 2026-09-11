import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend
    signal closeRequested()

    width: 580
    height: 460
    radius: 28
    color: "#F016191E"
    border.width: 1
    border.color: "#5E50443A"

    FileDialog {
        id: picker
        title: "Selecciona una aplicación para MurSchol"
        nameFilters: [
            "Aplicaciones (*.apk *.exe *.msi *.deb *.AppImage *.appimage *.flatpakref)",
            "Todos los archivos (*)"
        ]
        onAccepted: root.backend.selectFile(selectedFile)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label { text: "MurSchol App Manager"; color: "#F3EEE5"; font.pixelSize: 23; font.bold: true }
                Label { text: "Una instalación, tres ecosistemas"; color: "#968C82"; font.pixelSize: 11 }
            }
            Button {
                width: 34
                height: 34
                text: "×"
                onClicked: root.closeRequested()
                background: Rectangle {
                    radius: 11
                    color: parent.hovered ? "#3C272629" : "transparent"
                }
                contentItem: Label {
                    text: parent.text
                    color: "#EAE4DA"
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 112
            radius: 18
            color: "#1A1D22"
            border.width: 1
            border.color: root.backend.selectedFile.length ? "#D6A85F" : "#4A423A34"

            Column {
                anchors.centerIn: parent
                width: parent.width - 30
                spacing: 8
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.backend.selectedFile.length ? root.backend.fileName : "Selecciona un APK, EXE, MSI, DEB, AppImage o Flatpak"
                    color: "#F3EEE5"
                    font.pixelSize: root.backend.selectedFile.length ? 16 : 13
                    font.bold: root.backend.selectedFile.length
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                }
                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.backend.selectedFile.length ? "Elegir otro archivo" : "Elegir archivo"
                    onClicked: picker.open()
                    background: Rectangle {
                        radius: 11
                        color: parent.hovered ? "#3C2D242A" : "#25211D"
                        border.width: 1
                        border.color: "#675A4B"
                    }
                    contentItem: Label {
                        text: parent.text
                        color: "#D7CFC5"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 10

            Rectangle {
                Layout.fillWidth: true
                height: 72
                radius: 15
                color: "#1A1D22"
                border.width: 1
                border.color: "#4A423A34"
                Column {
                    anchors.centerIn: parent
                    spacing: 3
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: "ECOSISTEMA"; color: "#8D8379"; font.pixelSize: 9 }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: root.backend.ecosystem; color: "#F3EEE5"; font.bold: true; font.pixelSize: 15 }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                height: 72
                radius: 15
                color: "#1A1D22"
                border.width: 1
                border.color: "#4A423A34"
                Column {
                    anchors.centerIn: parent
                    spacing: 3
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: "MOTOR"; color: "#8D8379"; font.pixelSize: 9 }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: root.backend.engine; color: "#E3BB78"; font.bold: true; font.pixelSize: 13 }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 68
            radius: 15
            color: root.backend.canInstall ? "#202E24" : "#33291F"
            border.width: 1
            border.color: root.backend.canInstall ? "#537A60" : "#7B6241"
            RowLayout {
                anchors.fill: parent
                anchors.margins: 13
                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: root.backend.canInstall ? "#35513D" : "#5B472D"
                    Label { anchors.centerIn: parent; text: root.backend.canInstall ? "✓" : "!"; color: "#F3EEE5"; font.bold: true }
                }
                Label {
                    Layout.fillWidth: true
                    text: root.backend.readiness
                    color: root.backend.canInstall ? "#B9D2BF" : "#D8BE91"
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: root.backend.statusText
            color: "#8D8379"
            font.pixelSize: 10
            elide: Text.ElideMiddle
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            Button {
                text: "Limpiar"
                enabled: root.backend.selectedFile.length > 0
                onClicked: root.backend.clear()
                background: Rectangle {
                    radius: 11
                    color: parent.enabled ? (parent.hovered ? "#29251F24" : "#1A1D22") : "#15171B"
                    border.width: 1
                    border.color: "#4A423A34"
                }
                contentItem: Label {
                    text: parent.text
                    color: parent.enabled ? "#C9C0B6" : "#665F58"
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Instalar / Abrir"
                enabled: root.backend.canInstall
                onClicked: root.backend.installSelected()
                background: Rectangle {
                    radius: 12
                    color: parent.enabled ? (parent.hovered ? "#E3BB78" : "#D6A85F") : "#2B2926"
                }
                contentItem: Label {
                    text: parent.text
                    color: parent.enabled ? "#15120F" : "#6F6861"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
