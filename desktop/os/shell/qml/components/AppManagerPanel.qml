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
    color: "#f0152632"
    border.color: "#3a6272"

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
                Label { text: "MurSchol App Manager"; color: "white"; font.pixelSize: 23; font.bold: true }
                Label { text: "Una instalación, tres ecosistemas"; color: "#7899a6"; font.pixelSize: 11 }
            }
            Button {
                text: "×"
                flat: true
                onClicked: root.closeRequested()
                contentItem: Label {
                    text: parent.text; color: "white"; font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 112
            radius: 18
            color: "#182f3b"
            border.color: root.backend.selectedFile.length ? "#2d7078" : "#365665"

            Column {
                anchors.centerIn: parent
                width: parent.width - 30
                spacing: 8
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.backend.selectedFile.length ? root.backend.fileName : "Selecciona un APK, EXE, MSI, DEB, AppImage o Flatpak"
                    color: "white"
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
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 10

            Rectangle {
                Layout.fillWidth: true; height: 72; radius: 15; color: "#1a323e"; border.color: "#315363"
                Column { anchors.centerIn: parent; spacing: 3
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: "ECOSISTEMA"; color: "#6f8c99"; font.pixelSize: 9 }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: root.backend.ecosystem; color: "white"; font.bold: true; font.pixelSize: 15 }
                }
            }
            Rectangle {
                Layout.fillWidth: true; height: 72; radius: 15; color: "#1a323e"; border.color: "#315363"
                Column { anchors.centerIn: parent; spacing: 3
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: "MOTOR"; color: "#6f8c99"; font.pixelSize: 9 }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: root.backend.engine; color: "#8ee0d9"; font.bold: true; font.pixelSize: 13 }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 68
            radius: 15
            color: root.backend.canInstall ? "#173b35" : "#3a3024"
            border.color: root.backend.canInstall ? "#2a8776" : "#8d6a3e"
            RowLayout {
                anchors.fill: parent
                anchors.margins: 13
                Rectangle {
                    width: 30; height: 30; radius: 15
                    color: root.backend.canInstall ? "#266a59" : "#69502f"
                    Label { anchors.centerIn: parent; text: root.backend.canInstall ? "✓" : "!"; color: "white"; font.bold: true }
                }
                Label {
                    Layout.fillWidth: true
                    text: root.backend.readiness
                    color: "#dce8e5"
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: root.backend.statusText
            color: "#7896a2"
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
            }
            Item { Layout.fillWidth: true }
            Button {
                text: "Instalar / Abrir"
                enabled: root.backend.canInstall
                onClicked: root.backend.installSelected()
                background: Rectangle {
                    radius: 12
                    color: parent.enabled ? (parent.hovered ? "#268a91" : "#1d6f77") : "#263a42"
                }
                contentItem: Label {
                    text: parent.text
                    color: parent.enabled ? "white" : "#6f8087"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
