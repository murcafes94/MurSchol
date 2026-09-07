import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    property bool lightTheme: false
    property color accent: "#22d6cf"
    property bool showAbout: false

    implicitHeight: content.implicitHeight + 36
    radius: 20
    color: lightTheme ? "#f9fbfc" : "#0d202a"
    border.color: lightTheme ? "#d5e0e4" : "#284653"

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 18
        spacing: 10

        Repeater {
            model: [
                { label: "Sistema", value: root.backend.distroName },
                { label: "Kernel", value: root.backend.kernelVersion },
                { label: "Procesador", value: root.backend.cpuModel },
                { label: "Hilos", value: root.backend.cpuThreads.toString() },
                { label: "Memoria", value: root.backend.totalMemoryGb.toFixed(1) + " GB" },
                { label: "Almacenamiento", value: root.backend.storageSummary }
            ]
            delegate: Rectangle {
                required property var modelData
                Layout.fillWidth: true
                height: 52
                radius: 13
                color: root.lightTheme ? "#edf2f4" : "#112630"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 13
                    anchors.rightMargin: 13
                    Label {
                        text: parent.parent.modelData.label
                        color: root.lightTheme ? "#667b84" : "#7896a2"
                        font.pixelSize: 9
                        Layout.preferredWidth: 120
                    }
                    Label {
                        Layout.fillWidth: true
                        text: parent.parent.modelData.value
                        color: root.lightTheme ? "#18313b" : "#e7f0f3"
                        font.pixelSize: 10
                        elide: Text.ElideMiddle
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        Label {
            visible: root.showAbout
            Layout.fillWidth: true
            text: "MurSchol Settings 0.1 · configuración local-first. Las preferencias propias se guardan en " + root.backend.settingsFilePath()
            color: root.lightTheme ? "#6d8088" : "#688793"
            font.pixelSize: 9
            wrapMode: Text.WordWrap
        }
    }
}
