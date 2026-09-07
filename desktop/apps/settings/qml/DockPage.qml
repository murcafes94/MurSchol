import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var backend
    property bool lightTheme: false
    property color accent: "#22d6cf"

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
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label { text: "Ocultar automáticamente"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 12 }
                Label { text: "El dock aparece al llevar el puntero al borde inferior."; color: lightTheme ? "#74868e" : "#708e9a"; font.pixelSize: 9 }
            }
            Switch { checked: root.backend.dockAutoHide; onToggled: root.backend.setDockAutoHide(checked) }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: lightTheme ? "#dce5e8" : "#23414e" }

        Label { text: "Tamaño del dock"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 12 }
        RowLayout {
            Layout.fillWidth: true
            Label { text: "Pequeño"; color: lightTheme ? "#6c7f87" : "#7895a1"; font.pixelSize: 9 }
            Slider {
                Layout.fillWidth: true
                from: 54
                to: 84
                stepSize: 2
                value: root.backend.dockSize
                onMoved: root.backend.setDockSize(Math.round(value))
            }
            Label {
                text: root.backend.dockSize + " px"
                color: lightTheme ? "#334b55" : "#c7d9df"
                font.pixelSize: 9
                Layout.preferredWidth: 48
            }
        }

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Label { text: "Ampliar iconos al pasar el puntero"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 12 }
                Label { text: "Efecto discreto; se respeta la preferencia global de animaciones."; color: lightTheme ? "#74868e" : "#708e9a"; font.pixelSize: 9 }
            }
            Switch { checked: root.backend.dockMagnify; onToggled: root.backend.setDockMagnify(checked) }
        }
    }
}
