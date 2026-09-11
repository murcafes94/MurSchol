import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend

    width: 430
    height: 226
    radius: 24
    color: "#E816191E"
    border.width: 1
    border.color: "#5E50443A"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 1
                Label { text: "Modo de rendimiento"; color: "#F3EEE5"; font.bold: true; font.pixelSize: 16 }
                Label {
                    text: "Recomendado: " + root.backend.recommendedProfile
                    color: "#C9A86F"
                    font.pixelSize: 10
                }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 62
                height: 26
                radius: 13
                color: "#302820"
                border.width: 1
                border.color: "#5A493A"
                Label {
                    anchors.centerIn: parent
                    text: Math.round(root.backend.totalMemoryGb) + " GB"
                    color: "#D7CFC5"
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Repeater {
                model: [
                    {name:"Ligero", symbol:"◆", description:"Menos efectos\ny consumo"},
                    {name:"Normal", symbol:"▣", description:"Equilibrio para\nel día a día"},
                    {name:"Rendimiento", symbol:"▲", description:"Más potencia y\nmultitarea"}
                ]

                delegate: Button {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    checked: root.backend.profile === modelData.name
                    checkable: true
                    autoExclusive: true
                    onClicked: root.backend.setProfile(modelData.name)

                    background: Rectangle {
                        radius: 17
                        color: parent.checked ? "#3C2D242A" : (parent.hovered ? "#29251F24" : "#1A1D22")
                        border.width: parent.checked ? 2 : 1
                        border.color: parent.checked ? root.backend.accentColor : "#4A423A34"
                    }

                    contentItem: ColumnLayout {
                        spacing: 5
                        Item { Layout.fillHeight: true }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.symbol
                            color: parent.parent.checked ? root.backend.accentColor : "#B8AEA4"
                            font.pixelSize: 20
                            font.bold: true
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.name
                            color: "#F3EEE5"
                            font.bold: true
                            font.pixelSize: 11
                        }
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            visible: modelData.name === root.backend.recommendedProfile
                            width: recommendedLabel.implicitWidth + 12
                            height: 20
                            radius: 10
                            color: "#273E30"
                            border.width: 1
                            border.color: "#537A60"
                            Label {
                                id: recommendedLabel
                                anchors.centerIn: parent
                                text: "Recomendado"
                                color: "#A5D1AF"
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.description
                            color: "#91877D"
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 8
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }

        Button {
            Layout.alignment: Qt.AlignRight
            visible: root.backend.profile !== root.backend.recommendedProfile
            text: "Usar recomendado"
            onClicked: root.backend.applyRecommendedProfile()
            background: Rectangle {
                radius: 11
                color: parent.hovered ? "#4A392D" : "#332820"
                border.width: 1
                border.color: root.backend.accentColor
            }
            contentItem: Label {
                text: parent.text
                color: "#F1DEC1"
                font.bold: true
                font.pixelSize: 9
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
