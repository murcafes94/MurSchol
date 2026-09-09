import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    property bool lightTheme: false
    property color accent: "#2563EB"
    property bool showAbout: false

    implicitHeight: content.implicitHeight + 40
    radius: 18
    color: lightTheme ? "#FFFFFF" : "#11151C"
    border.color: lightTheme ? "#D8DEE9" : "#252B35"

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
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
                height: 56
                radius: 14
                color: root.lightTheme ? "#F4F6F9" : "#171C24"
                border.width: 1
                border.color: root.lightTheme ? "#D8DEE9" : "#252B35"
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    Label {
                        text: parent.parent.modelData.label
                        color: root.lightTheme ? "#5B6573" : "#9AA4B2"
                        font.pixelSize: 9
                        Layout.preferredWidth: 126
                    }
                    Label {
                        Layout.fillWidth: true
                        text: parent.parent.modelData.value
                        color: root.lightTheme ? "#0B0D12" : "#F8FAFC"
                        font.pixelSize: 10
                        font.bold: true
                        elide: Text.ElideMiddle
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }

        Rectangle {
            visible: root.showAbout
            Layout.fillWidth: true
            implicitHeight: aboutText.implicitHeight + 28
            radius: 14
            color: root.lightTheme ? "#EAF1FF" : "#123A7A"
            border.width: 1
            border.color: root.accent
            Label {
                id: aboutText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                text: "MurSchol Settings 0.1 · configuración local-first. Las preferencias propias se guardan en " + root.backend.settingsFilePath()
                color: root.lightTheme ? "#123A7A" : "#DCE8FF"
                font.pixelSize: 9
                wrapMode: Text.WordWrap
            }
        }
    }
}
