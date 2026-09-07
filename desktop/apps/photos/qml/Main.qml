import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholPhotos 1.0

ApplicationWindow {
    id: root
    width: 1120
    height: 740
    minimumWidth: 760
    minimumHeight: 520
    visible: true
    title: backend.fileName.length ? backend.fileName + " — MurSchol Photos" : "MurSchol Photos"
    color: "#08141d"

    property bool infoOpen: false
    property bool editMode: false
    property bool drawMode: false
    property bool cropMode: false
    property real zoomFactor: 1.0
    property real straightenAngle: 0

    PhotoBackend { id: backend }

    Component.onCompleted: {
        if (initialSource && initialSource.length > 0)
            backend.openFile(initialSource)
    }

    Shortcut { sequence: "Left"; onActivated: backend.openPrevious() }
    Shortcut { sequence: "Right"; onActivated: backend.openNext() }
    Shortcut { sequence: "Escape"; onActivated: { infoOpen = false; editMode = false; drawMode = false; cropMode = false } }
    Shortcut { sequence: "+"; onActivated: root.zoomFactor = Math.min(5.0, root.zoomFactor + 0.1) }
    Shortcut { sequence: "-"; onActivated: root.zoomFactor = Math.max(0.1, root.zoomFactor - 0.1) }

    header: Rectangle {
        height: 58
        color: "#0d202c"
        border.color: "#1c3a4a"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 8

            ToolButton {
                text: "←"
                enabled: backend.sourceUrl.length > 0
                onClicked: backend.openPrevious()
            }

            ToolButton {
                text: "→"
                enabled: backend.sourceUrl.length > 0
                onClicked: backend.openNext()
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Label {
                    Layout.fillWidth: true
                    text: backend.fileName.length ? backend.fileName : "MurSchol Photos"
                    color: "#f2f7f8"
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideMiddle
                }
                Label {
                    visible: backend.sourceUrl.length > 0
                    text: backend.format + (backend.dimensions.length ? " · " + backend.dimensions : "")
                    color: "#7997a5"
                    font.pixelSize: 9
                }
            }

            ToolButton {
                text: "−"
                enabled: backend.sourceUrl.length > 0
                onClicked: root.zoomFactor = Math.max(0.1, root.zoomFactor - 0.1)
            }
            Label {
                text: Math.round(root.zoomFactor * 100) + "%"
                color: "#b8cbd3"
                font.pixelSize: 10
                Layout.preferredWidth: 46
                horizontalAlignment: Text.AlignHCenter
            }
            ToolButton {
                text: "+"
                enabled: backend.sourceUrl.length > 0
                onClicked: root.zoomFactor = Math.min(5.0, root.zoomFactor + 0.1)
            }
            ToolButton {
                text: "Ajustar"
                enabled: backend.sourceUrl.length > 0
                onClicked: root.zoomFactor = 1.0
            }
            ToolButton {
                text: "ⓘ"
                checkable: true
                checked: root.infoOpen
                enabled: backend.sourceUrl.length > 0
                onClicked: root.infoOpen = !root.infoOpen
            }
            ToolButton {
                text: "Editar"
                checkable: true
                checked: root.editMode
                enabled: backend.sourceUrl.length > 0
                onClicked: {
                    root.editMode = !root.editMode
                    if (!root.editMode) {
                        root.drawMode = false
                        root.cropMode = false
                        root.straightenAngle = 0
                    }
                }
            }
        }
    }

    Rectangle {
        id: editorBar
        visible: root.editMode && backend.sourceUrl.length > 0
        z: 6
        height: 60
        radius: 18
        color: "#ee0f2633"
        border.color: "#315569"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14
        width: Math.min(760, parent.width - 40)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            Button { text: "↶ 90°"; onClicked: backend.rotateLeft() }
            Button { text: "↷ 90°"; onClicked: backend.rotateRight() }
            Button {
                text: root.cropMode ? "Recorte activo" : "Recortar"
                checkable: true
                checked: root.cropMode
                onClicked: root.cropMode = !root.cropMode
            }
            Button {
                text: root.drawMode ? "Dibujo activo" : "Rayar"
                checkable: true
                checked: root.drawMode
                onClicked: root.drawMode = !root.drawMode
            }
            Label { text: "Enderezar"; color: "#91aab5"; font.pixelSize: 10 }
            Slider {
                Layout.fillWidth: true
                from: -10
                to: 10
                stepSize: 0.25
                value: root.straightenAngle
                onMoved: root.straightenAngle = value
            }
            Label {
                text: root.straightenAngle.toFixed(1) + "°"
                color: "#d8e7eb"
                font.pixelSize: 10
                Layout.preferredWidth: 42
            }
        }
    }

    Item {
        id: viewer
        anchors.fill: parent
        anchors.rightMargin: root.infoOpen ? infoPanel.width : 0
        clip: true

        Rectangle {
            anchors.fill: parent
            color: "#071119"

            Repeater {
                model: 14
                Rectangle {
                    width: 16
                    height: 16
                    x: (index % 7) * 16
                    y: Math.floor(index / 7) * 16
                    visible: false
                }
            }
        }

        Item {
            id: imageStage
            anchors.centerIn: parent
            width: Math.max(1, viewer.width * root.zoomFactor)
            height: Math.max(1, viewer.height * root.zoomFactor)
            transform: Rotation {
                origin.x: imageStage.width / 2
                origin.y: imageStage.height / 2
                angle: backend.rotation + root.straightenAngle
            }

            Image {
                id: stillImage
                anchors.fill: parent
                visible: backend.sourceUrl.length > 0 && !backend.animated
                source: backend.sourceUrl
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: true
                smooth: true
                mipmap: true
            }

            AnimatedImage {
                anchors.fill: parent
                visible: backend.sourceUrl.length > 0 && backend.animated
                source: backend.sourceUrl
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: true
                playing: visible
            }

            Rectangle {
                visible: root.cropMode
                anchors.centerIn: parent
                width: parent.width * 0.68
                height: parent.height * 0.68
                color: "transparent"
                border.width: 2
                border.color: "#67e6df"
                radius: 4
            }

            Canvas {
                id: drawingLayer
                anchors.fill: parent
                visible: root.drawMode
                property real lastX: -1
                property real lastY: -1

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.lineWidth = 3
                    ctx.strokeStyle = "#52e4dd"
                    ctx.lineCap = "round"
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.drawMode
                    onPressed: mouse => {
                        drawingLayer.lastX = mouse.x
                        drawingLayer.lastY = mouse.y
                    }
                    onPositionChanged: mouse => {
                        if (!pressed)
                            return
                        const ctx = drawingLayer.getContext("2d")
                        ctx.beginPath()
                        ctx.moveTo(drawingLayer.lastX, drawingLayer.lastY)
                        ctx.lineTo(mouse.x, mouse.y)
                        ctx.stroke()
                        drawingLayer.lastX = mouse.x
                        drawingLayer.lastY = mouse.y
                        drawingLayer.requestPaint()
                    }
                }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            visible: backend.sourceUrl.length === 0
            spacing: 10
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "▧"
                color: "#4edbd5"
                font.pixelSize: 54
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "MurSchol Photos"
                color: "#eef7f8"
                font.bold: true
                font.pixelSize: 24
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Abre una imagen desde MurSchol Files"
                color: "#7895a2"
                font.pixelSize: 12
            }
            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "JPG · PNG · GIF · SVG · WebP"
                color: "#4a7587"
                font.pixelSize: 10
            }
        }
    }

    Rectangle {
        id: infoPanel
        z: 8
        visible: root.infoOpen
        width: Math.min(330, root.width * 0.36)
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        color: "#f30d202c"
        border.color: "#274858"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Información"
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                }
                ToolButton { text: "×"; onClicked: root.infoOpen = false }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#294656" }

            Repeater {
                model: [
                    {label: "Nombre", value: backend.fileName},
                    {label: "Tipo", value: backend.format},
                    {label: "Dimensiones", value: backend.dimensions},
                    {label: "Tamaño", value: backend.fileSizeText},
                    {label: "Modificada", value: backend.modifiedText},
                    {label: "Ubicación", value: backend.filePath}
                ]
                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 2
                    Label { text: modelData.label; color: "#6f8c98"; font.pixelSize: 9; font.bold: true }
                    Label {
                        Layout.fillWidth: true
                        text: modelData.value || "—"
                        color: "#dce9ed"
                        font.pixelSize: 11
                        wrapMode: Text.WrapAnywhere
                    }
                }
            }

            Item { Layout.fillHeight: true }
            Label {
                Layout.fillWidth: true
                text: "Los metadatos EXIF de cámara y GPS se añadirán cuando estén presentes, sin ralentizar la apertura inicial."
                color: "#66838f"
                wrapMode: Text.WordWrap
                font.pixelSize: 9
            }
        }
    }

    Label {
        visible: backend.errorText.length > 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        text: backend.errorText
        color: "#ffb7b7"
        background: Rectangle { radius: 12; color: "#cc401d28" }
        padding: 10
    }
}
