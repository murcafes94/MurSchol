import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    property bool lightTheme: false
    property color accent: "#2563EB"

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
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Label { text: "Ocultar automáticamente"; color: lightTheme ? "#0B0D12" : "#F8FAFC"; font.bold: true; font.pixelSize: 12 }
                Label { text: "El dock aparece al llevar el puntero al borde inferior."; color: lightTheme ? "#5B6573" : "#9AA4B2"; font.pixelSize: 9 }
            }
            Switch { checked: root.backend.dockAutoHide; onToggled: root.backend.setDockAutoHide(checked) }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: lightTheme ? "#D8DEE9" : "#252B35" }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            Label { text: "Tamaño del dock"; color: lightTheme ? "#0B0D12" : "#F8FAFC"; font.bold: true; font.pixelSize: 12 }
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Label { text: "Pequeño"; color: lightTheme ? "#5B6573" : "#9AA4B2"; font.pixelSize: 9 }
                Slider {
                    Layout.fillWidth: true
                    from: 54
                    to: 84
                    stepSize: 2
                    value: root.backend.dockSize
                    onMoved: root.backend.setDockSize(Math.round(value))
                }
                Rectangle {
                    width: 58
                    height: 30
                    radius: 10
                    color: lightTheme ? "#EEF1F5" : "#171C24"
                    border.width: 1
                    border.color: lightTheme ? "#D8DEE9" : "#252B35"
                    Label {
                        anchors.centerIn: parent
                        text: root.backend.dockSize + " px"
                        color: lightTheme ? "#0B0D12" : "#F8FAFC"
                        font.pixelSize: 9
                        font.bold: true
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: lightTheme ? "#D8DEE9" : "#252B35" }

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Label { text: "Ampliar iconos al pasar el puntero"; color: lightTheme ? "#0B0D12" : "#F8FAFC"; font.bold: true; font.pixelSize: 12 }
                Label { text: "Efecto discreto; respeta la preferencia global de animaciones."; color: lightTheme ? "#5B6573" : "#9AA4B2"; font.pixelSize: 9 }
            }
            Switch { checked: root.backend.dockMagnify; onToggled: root.backend.setDockMagnify(checked) }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: previewContent.implicitHeight + 28
            radius: 16
            color: lightTheme ? "#EEF1F5" : "#0B0D12"
            border.width: 1
            border.color: lightTheme ? "#D8DEE9" : "#252B35"

            RowLayout {
                id: previewContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 10
                Label { text: "Vista previa"; color: lightTheme ? "#5B6573" : "#9AA4B2"; font.pixelSize: 9; font.bold: true }
                Item { Layout.fillWidth: true }
                Repeater {
                    model: ["MS", "▰", "◎", ">_", "⚙"]
                    delegate: Rectangle {
                        required property string modelData
                        width: 34
                        height: 34
                        radius: 11
                        color: modelData === "MS" ? root.accent : (root.lightTheme ? "#FFFFFF" : "#171C24")
                        border.width: 1
                        border.color: root.lightTheme ? "#D8DEE9" : "#252B35"
                        Label {
                            anchors.centerIn: parent
                            text: parent.modelData
                            color: parent.modelData === "MS" ? "#FFFFFF" : (root.lightTheme ? "#0B0D12" : "#F8FAFC")
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }
            }
        }
    }
}
