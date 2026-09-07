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
    property string annotationTool: "pen"
    property string annotationText: "Texto"
    property var annotationActions: []
    property var annotationRedo: []

    function commitAnnotation(action) {
        var next = annotationActions.slice(0)
        next.push(action)
        annotationActions = next
        annotationRedo = []
        drawingLayer.requestPaint()
    }

    function undoAnnotation() {
        if (annotationActions.length === 0)
            return
        var next = annotationActions.slice(0)
        var removed = next.pop()
        var redo = annotationRedo.slice(0)
        redo.push(removed)
        annotationActions = next
        annotationRedo = redo
        drawingLayer.requestPaint()
    }

    function redoAnnotation() {
        if (annotationRedo.length === 0)
            return
        var redo = annotationRedo.slice(0)
        var restored = redo.pop()
        var next = annotationActions.slice(0)
        next.push(restored)
        annotationActions = next
        annotationRedo = redo
        drawingLayer.requestPaint()
    }

    PhotoBackend { id: backend }

    Component.onCompleted: {
        if (initialSource && initialSource.length > 0)
            backend.openFile(initialSource)
        if (initialAnnotationMode) {
            editMode = true
            drawMode = true
            annotationTool = "pen"
        }
    }

    Shortcut { sequence: "Left"; onActivated: backend.openPrevious() }
    Shortcut { sequence: "Right"; onActivated: backend.openNext() }
    Shortcut { sequence: "Escape"; onActivated: { infoOpen = false; editMode = false; drawMode = false; cropMode = false } }
    Shortcut { sequence: "+"; onActivated: root.zoomFactor = Math.min(5.0, root.zoomFactor + 0.1) }
    Shortcut { sequence: "-"; onActivated: root.zoomFactor = Math.max(0.1, root.zoomFactor - 0.1) }
    Shortcut { sequence: "Ctrl+Z"; onActivated: root.undoAnnotation() }
    Shortcut { sequence: "Ctrl+Shift+Z"; onActivated: root.redoAnnotation() }

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
        height: 112
        radius: 18
        color: "#ee0f2633"
        border.color: "#315569"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14
        width: Math.min(1000, parent.width - 32)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                contentWidth: toolsRow.implicitWidth
                contentHeight: height
                clip: true

                RowLayout {
                    id: toolsRow
                    height: parent.height
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
                        text: "Lápiz"
                        checkable: true
                        checked: root.drawMode && root.annotationTool === "pen"
                        onClicked: { root.drawMode = true; root.annotationTool = "pen" }
                    }
                    Button {
                        text: "Resaltar"
                        checkable: true
                        checked: root.drawMode && root.annotationTool === "highlight"
                        onClicked: { root.drawMode = true; root.annotationTool = "highlight" }
                    }
                    Button {
                        text: "Flecha"
                        checkable: true
                        checked: root.drawMode && root.annotationTool === "arrow"
                        onClicked: { root.drawMode = true; root.annotationTool = "arrow" }
                    }
                    Button {
                        text: "Cuadro"
                        checkable: true
                        checked: root.drawMode && root.annotationTool === "rectangle"
                        onClicked: { root.drawMode = true; root.annotationTool = "rectangle" }
                    }
                    Button {
                        text: "Texto"
                        checkable: true
                        checked: root.drawMode && root.annotationTool === "text"
                        onClicked: { root.drawMode = true; root.annotationTool = "text" }
                    }
                    Button {
                        text: "Ocultar"
                        checkable: true
                        checked: root.drawMode && root.annotationTool === "redact"
                        onClicked: { root.drawMode = true; root.annotationTool = "redact" }
                    }
                    Button { text: "Deshacer"; enabled: root.annotationActions.length > 0; onClicked: root.undoAnnotation() }
                    Button { text: "Rehacer"; enabled: root.annotationRedo.length > 0; onClicked: root.redoAnnotation() }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
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
                TextField {
                    visible: root.annotationTool === "text"
                    Layout.preferredWidth: 180
                    placeholderText: "Texto de la anotación"
                    text: root.annotationText
                    onTextChanged: root.annotationText = text
                }
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
                visible: root.editMode && backend.sourceUrl.length > 0 && !backend.animated
                property real startX: 0
                property real startY: 0
                property var temporaryAction: null

                function drawArrow(ctx, action) {
                    var dx = action.x2 - action.x1
                    var dy = action.y2 - action.y1
                    var angle = Math.atan2(dy, dx)
                    var size = 14
                    ctx.beginPath()
                    ctx.moveTo(action.x1, action.y1)
                    ctx.lineTo(action.x2, action.y2)
                    ctx.moveTo(action.x2, action.y2)
                    ctx.lineTo(action.x2 - size * Math.cos(angle - Math.PI / 6), action.y2 - size * Math.sin(angle - Math.PI / 6))
                    ctx.moveTo(action.x2, action.y2)
                    ctx.lineTo(action.x2 - size * Math.cos(angle + Math.PI / 6), action.y2 - size * Math.sin(angle + Math.PI / 6))
                    ctx.stroke()
                }

                function drawAction(ctx, action) {
                    ctx.save()
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"

                    if (action.tool === "pen" || action.tool === "highlight") {
                        ctx.lineWidth = action.tool === "highlight" ? 14 : 3
                        ctx.globalAlpha = action.tool === "highlight" ? 0.35 : 1.0
                        ctx.strokeStyle = action.tool === "highlight" ? "#ffe66d" : "#52e4dd"
                        if (action.points && action.points.length > 1) {
                            ctx.beginPath()
                            ctx.moveTo(action.points[0].x, action.points[0].y)
                            for (var p = 1; p < action.points.length; ++p)
                                ctx.lineTo(action.points[p].x, action.points[p].y)
                            ctx.stroke()
                        }
                    } else if (action.tool === "rectangle") {
                        ctx.lineWidth = 3
                        ctx.strokeStyle = "#52e4dd"
                        ctx.strokeRect(action.x1, action.y1, action.x2 - action.x1, action.y2 - action.y1)
                    } else if (action.tool === "arrow") {
                        ctx.lineWidth = 4
                        ctx.strokeStyle = "#52e4dd"
                        drawArrow(ctx, action)
                    } else if (action.tool === "text") {
                        ctx.fillStyle = "#f8fbfc"
                        ctx.font = "bold 22px sans-serif"
                        ctx.fillText(action.text || "Texto", action.x1, action.y1)
                    } else if (action.tool === "redact") {
                        ctx.globalAlpha = 0.92
                        ctx.fillStyle = "#101010"
                        ctx.fillRect(action.x1, action.y1, action.x2 - action.x1, action.y2 - action.y1)
                    }
                    ctx.restore()
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    for (var i = 0; i < root.annotationActions.length; ++i)
                        drawAction(ctx, root.annotationActions[i])
                    if (temporaryAction)
                        drawAction(ctx, temporaryAction)
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: root.drawMode && !root.cropMode

                    onPressed: mouse => {
                        drawingLayer.startX = mouse.x
                        drawingLayer.startY = mouse.y
                        if (root.annotationTool === "pen" || root.annotationTool === "highlight") {
                            drawingLayer.temporaryAction = {
                                tool: root.annotationTool,
                                points: [{x: mouse.x, y: mouse.y}]
                            }
                        } else {
                            drawingLayer.temporaryAction = {
                                tool: root.annotationTool,
                                x1: mouse.x,
                                y1: mouse.y,
                                x2: mouse.x,
                                y2: mouse.y,
                                text: root.annotationText
                            }
                        }
                        drawingLayer.requestPaint()
                    }

                    onPositionChanged: mouse => {
                        if (!pressed || !drawingLayer.temporaryAction)
                            return
                        var action = drawingLayer.temporaryAction
                        if (action.tool === "pen" || action.tool === "highlight") {
                            var points = action.points.slice(0)
                            points.push({x: mouse.x, y: mouse.y})
                            drawingLayer.temporaryAction = {tool: action.tool, points: points}
                        } else {
                            drawingLayer.temporaryAction = {
                                tool: action.tool,
                                x1: drawingLayer.startX,
                                y1: drawingLayer.startY,
                                x2: mouse.x,
                                y2: mouse.y,
                                text: root.annotationText
                            }
                        }
                        drawingLayer.requestPaint()
                    }

                    onReleased: mouse => {
                        if (!drawingLayer.temporaryAction)
                            return
                        var action = drawingLayer.temporaryAction
                        if (action.tool === "text") {
                            action = {
                                tool: "text",
                                x1: mouse.x,
                                y1: mouse.y,
                                x2: mouse.x,
                                y2: mouse.y,
                                text: root.annotationText
                            }
                        }
                        root.commitAnnotation(action)
                        drawingLayer.temporaryAction = null
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
