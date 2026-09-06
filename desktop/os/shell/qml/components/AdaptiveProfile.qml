import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property var backend

    width: 430
    height: 226
    radius: 24
    color: "#e20d202d"
    border.color: "#39687b"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                spacing: 1
                Label { text: "Modo de rendimiento"; color: "white"; font.bold: true; font.pixelSize: 16 }
                Label {
                    text: "Recomendado: " + root.backend.recommendedProfile
                    color: "#78d8d1"
                    font.pixelSize: 10
                }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 58
                height: 24
                radius: 12
                color: "#173b49"
                Label {
                    anchors.centerIn: parent
                    text: Math.round(root.backend.totalMemoryGb) + " GB"
                    color: "#b9d5df"
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
                        color: parent.checked ? "#17485e" : (parent.hovered ? "#173847" : "#122d3a")
                        border.width: parent.checked ? 2 : 1
                        border.color: parent.checked ? "#2bd6e1" : "#315262"
                    }

                    contentItem: ColumnLayout {
                        spacing: 5
                        Item { Layout.fillHeight: true }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.symbol
                            color: parent.parent.checked ? "#66ebe5" : "#9eb7c2"
                            font.pixelSize: 20
                            font.bold: true
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.name
                            color: "white"
                            font.bold: true
                            font.pixelSize: 11
                        }
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            visible: modelData.name === root.backend.recommendedProfile
                            width: recommendedLabel.implicitWidth + 12
                            height: 20
                            radius: 10
                            color: "#196a59"
                            Label {
                                id: recommendedLabel
                                anchors.centerIn: parent
                                text: "Recomendado"
                                color: "#baffdf"
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }
                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.description
                            color: "#9bb0ba"
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
            background: Rectangle { radius: 11; color: parent.hovered ? "#287b83" : "#205f67" }
            contentItem: Label {
                text: parent.text
                color: "white"
                font.bold: true
                font.pixelSize: 9
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
