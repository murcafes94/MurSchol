import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import MurScholMedia 1.0

ApplicationWindow {
    id: root
    width: 1180
    height: 720
    minimumWidth: 760
    minimumHeight: 480
    visible: true
    title: player.mediaTitle.length > 0 ? player.mediaTitle + " — MurSchol Media" : "MurSchol Media"
    color: "#0B0E12"

    palette.window: "#0B0E12"
    palette.windowText: "#F3EEE5"
    palette.base: "#171B21"
    palette.alternateBase: "#1E2025"
    palette.text: "#F3EEE5"
    palette.button: "#1E2025"
    palette.buttonText: "#F3EEE5"
    palette.highlight: "#D6A85F"
    palette.highlightedText: "#201B17"

    property bool controlsVisible: true
    property bool settingsOpen: false
    property string statusText: ""

    function wakeControls() {
        controlsVisible = true
        hideControls.restart()
    }

    function formatTime(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00"
        var total = Math.floor(seconds)
        var hours = Math.floor(total / 3600)
        var minutes = Math.floor((total % 3600) / 60)
        var secs = total % 60
        if (hours > 0)
            return hours + ":" + String(minutes).padStart(2, "0") + ":" + String(secs).padStart(2, "0")
        return minutes + ":" + String(secs).padStart(2, "0")
    }

    MpvPlayer {
        id: player
        anchors.fill: parent
        visible: !audioOnly && filePath.length > 0
    }

    Rectangle {
        anchors.fill: parent
        visible: player.audioOnly && player.filePath.length > 0
        color: "#0B0E12"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 18

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: Math.min(280, root.height * 0.42)
                height: width
                radius: 34
                color: "#171B21"
                border.width: 1
                border.color: "#51463B"

                Label {
                    anchors.centerIn: parent
                    text: "♫"
                    color: "#D6A85F"
                    font.pixelSize: 84
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: 500
                text: player.mediaTitle
                color: "#F3EEE5"
                font.pixelSize: 24
                font.bold: true
                elide: Text.ElideRight
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Audio local"
                color: "#A79E94"
                font.pixelSize: 11
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: player.filePath.length === 0
        color: "#0B0E12"

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 14

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 92
                height: 92
                radius: 28
                color: "#49352B"
                border.color: "#D6A85F"
                Label {
                    anchors.centerIn: parent
                    text: "▶"
                    color: "#D6A85F"
                    font.pixelSize: 36
                }
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "MurSchol Media"
                color: "#F3EEE5"
                font.pixelSize: 27
                font.bold: true
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Arrastra aquí un vídeo o audio para reproducirlo"
                color: "#A79E94"
                font.pixelSize: 12
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "MP4 · MKV · WebM · MOV · MP3 · FLAC · WAV · OGG · M4A"
                color: "#7F766D"
                font.pixelSize: 9
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPositionChanged: root.wakeControls()
    }

    DropArea {
        anchors.fill: parent
        onEntered: (drag) => root.wakeControls()
        onDropped: (drop) => {
            if (drop.hasUrls && drop.urls.length > 0)
                player.openFile(drop.urls[0].toString())
        }
    }

    Rectangle {
        id: topBar
        z: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 58
        visible: root.controlsVisible || player.audioOnly || player.filePath.length === 0
        color: "#E615181D"
        border.color: "#35312D"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 10

            Rectangle {
                width: 34
                height: 34
                radius: 11
                color: "#49352B"
                border.width: 1
                border.color: "#D6A85F"
                Label {
                    anchors.centerIn: parent
                    text: "▶"
                    color: "#D6A85F"
                    font.pixelSize: 12
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Label {
                    Layout.fillWidth: true
                    text: player.mediaTitle.length > 0 ? player.mediaTitle : "MurSchol Media"
                    color: "#F3EEE5"
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                }
                Label {
                    visible: player.filePath.length > 0
                    Layout.fillWidth: true
                    text: player.audioOnly ? "Audio" : "Vídeo"
                    color: "#8F867D"
                    font.pixelSize: 9
                    elide: Text.ElideMiddle
                }
            }

            Button {
                text: "Pista audio"
                visible: !player.audioOnly && player.filePath.length > 0
                onClicked: player.cycleAudioTrack()
            }
            Button {
                text: "Subtítulos"
                visible: !player.audioOnly && player.filePath.length > 0
                onClicked: player.cycleSubtitles()
            }
            Button {
                text: "⋮"
                width: 42
                onClicked: {
                    root.settingsOpen = !root.settingsOpen
                    root.wakeControls()
                }
            }
        }
    }

    Rectangle {
        id: bottomControls
        z: 4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 118
        visible: player.filePath.length > 0 && (root.controlsVisible || player.audioOnly)
        color: "#EA15181D"
        border.color: "#35312D"

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            anchors.topMargin: 8
            anchors.bottomMargin: 10
            spacing: 6

            Slider {
                id: timeline
                Layout.fillWidth: true
                from: 0
                to: Math.max(1, player.duration)
                value: player.position
                onMoved: player.seekAbsolute(value)
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: root.formatTime(player.position) + " / " + root.formatTime(player.duration)
                    color: "#A79E94"
                    font.pixelSize: 10
                    Layout.preferredWidth: 118
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: "⏮"
                    enabled: player.hasPrevious
                    onClicked: player.previous()
                }
                Button { text: "↶ 10"; onClicked: player.seekRelative(-10) }
                Button {
                    id: playButton
                    width: 54
                    height: 42
                    text: player.paused ? "▶" : "Ⅱ"
                    onClicked: player.togglePause()
                    background: Rectangle {
                        radius: 14
                        color: playButton.down ? "#8E6A42" : (playButton.hovered ? "#E3BB78" : "#D6A85F")
                    }
                    contentItem: Label {
                        text: playButton.text
                        color: "#201B17"
                        font.bold: true
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                Button { text: "10 ↷"; onClicked: player.seekRelative(10) }
                Button {
                    text: "⏭"
                    enabled: player.hasNext
                    onClicked: player.next()
                }

                Item { Layout.fillWidth: true }

                Label { text: "🔊"; color: "#C9C0B6" }
                Slider {
                    Layout.preferredWidth: 120
                    from: 0
                    to: 130
                    value: player.volume
                    onMoved: player.setVolume(value)
                }

                ComboBox {
                    id: speedBox
                    Layout.preferredWidth: 88
                    model: ["0.5×", "0.75×", "1×", "1.25×", "1.5×", "2×"]
                    currentIndex: 2
                    onActivated: {
                        var values = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                        player.setSpeed(values[currentIndex])
                    }
                }

                Button {
                    text: "⛶"
                    onClicked: {
                        if (root.visibility === Window.FullScreen)
                            root.showNormal()
                        else
                            root.showFullScreen()
                        root.wakeControls()
                    }
                }
            }
        }
    }

    Rectangle {
        id: settingsPanel
        z: 6
        visible: root.settingsOpen
        width: 280
        height: 250
        radius: 22
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.rightMargin: 14
        anchors.topMargin: 10
        color: "#F315181D"
        border.color: "#51463B"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            Label { text: "Reproducción"; color: "#F3EEE5"; font.pixelSize: 16; font.bold: true }
            Label { text: "Velocidad"; color: "#A79E94"; font.pixelSize: 10 }
            RowLayout {
                Repeater {
                    model: [0.75, 1.0, 1.25, 1.5]
                    delegate: Button {
                        required property real modelData
                        text: modelData + "×"
                        onClicked: player.setSpeed(modelData)
                    }
                }
            }
            Button {
                Layout.fillWidth: true
                text: "Cambiar pista de audio"
                enabled: !player.audioOnly
                onClicked: player.cycleAudioTrack()
            }
            Button {
                Layout.fillWidth: true
                text: "Cambiar subtítulos"
                enabled: !player.audioOnly
                onClicked: player.cycleSubtitles()
            }
            Label {
                Layout.fillWidth: true
                text: "La posición se guarda automáticamente para continuar después."
                color: "#8F867D"
                font.pixelSize: 9
                wrapMode: Text.WordWrap
            }
        }
    }

    Rectangle {
        z: 8
        visible: root.statusText.length > 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: bottomControls.visible ? bottomControls.top : parent.bottom
        anchors.bottomMargin: 18
        radius: 14
        color: "#ED24211D"
        border.color: "#51463B"
        width: Math.min(520, statusLabel.implicitWidth + 36)
        height: 42
        Label {
            id: statusLabel
            anchors.centerIn: parent
            text: root.statusText
            color: "#F3EEE5"
            font.pixelSize: 11
        }
    }

    Timer {
        id: hideControls
        interval: 2500
        repeat: false
        onTriggered: {
            if (!player.audioOnly && !player.paused && !root.settingsOpen && player.filePath.length > 0)
                root.controlsVisible = false
        }
    }

    Timer {
        id: statusTimer
        interval: 3000
        repeat: false
        onTriggered: root.statusText = ""
    }

    Connections {
        target: player
        function onErrorOccurred(message) {
            root.statusText = message
            statusTimer.restart()
            root.wakeControls()
        }
    }

    Shortcut { sequence: "Space"; onActivated: player.togglePause() }
    Shortcut { sequence: "Left"; onActivated: player.seekRelative(-5) }
    Shortcut { sequence: "Right"; onActivated: player.seekRelative(5) }
    Shortcut {
        sequence: "F"
        onActivated: {
            if (root.visibility === Window.FullScreen)
                root.showNormal()
            else
                root.showFullScreen()
        }
    }
    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (root.settingsOpen)
                root.settingsOpen = false
            else if (root.visibility === Window.FullScreen)
                root.showNormal()
            root.wakeControls()
        }
    }

    Component.onCompleted: {
        if (initialMediaFile && initialMediaFile.length > 0)
            player.openFile(initialMediaFile)
        hideControls.restart()
    }
}
