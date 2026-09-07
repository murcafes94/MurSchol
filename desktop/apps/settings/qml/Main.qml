import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholSettings 1.0

ApplicationWindow {
    id: root
    width: 1180
    height: 760
    minimumWidth: 900
    minimumHeight: 620
    visible: true
    title: "MurSchol Settings"
    color: lightTheme ? "#edf2f4" : "#07131d"

    property string currentPage: "appearance"
    property bool lightTheme: backend.theme === "Claro"
    property color accent: backend.accentColor
    property var pages: [
        { key: "display", title: "Pantalla", group: "Sistema", symbol: "▣", keywords: "monitor resolución escala brillo orientación" },
        { key: "sound", title: "Sonido", group: "Sistema", symbol: "◕", keywords: "audio volumen micrófono altavoz pipewire" },
        { key: "network", title: "Red e Internet", group: "Sistema", symbol: "◎", keywords: "wifi ethernet red internet network" },
        { key: "bluetooth", title: "Bluetooth", group: "Sistema", symbol: "ᛒ", keywords: "bluetooth dispositivos auriculares" },
        { key: "power", title: "Energía", group: "Sistema", symbol: "ϟ", keywords: "batería energía suspensión brillo" },
        { key: "storage", title: "Almacenamiento", group: "Sistema", symbol: "▤", keywords: "disco almacenamiento espacio archivos" },
        { key: "appearance", title: "Apariencia", group: "Personalización", symbol: "◈", keywords: "tema claro oscuro color animaciones apariencia" },
        { key: "dock", title: "Dock y panel", group: "Personalización", symbol: "▰", keywords: "dock panel ocultar tamaño iconos ampliar" },
        { key: "workspaces", title: "Espacios", group: "Personalización", symbol: "▦", keywords: "espacios estudio trabajos personal escritorios" },
        { key: "apps", title: "Aplicaciones", group: "Aplicaciones", symbol: "▥", keywords: "apps instaladas inicio predeterminadas mime" },
        { key: "compatibility", title: "Compatibilidad", group: "Aplicaciones", symbol: "⇄", keywords: "linux android windows waydroid wine bottles flatpak" },
        { key: "performance", title: "Rendimiento", group: "Dispositivo", symbol: "▲", keywords: "ligero normal rendimiento memoria cpu perfil" },
        { key: "system", title: "Sistema y hardware", group: "Dispositivo", symbol: "◉", keywords: "cpu ram kernel hardware sistema información" },
        { key: "updates", title: "Actualizaciones", group: "MurSchol OS", symbol: "↻", keywords: "actualizar update debian flatpak sistema" },
        { key: "accessibility", title: "Accesibilidad", group: "MurSchol OS", symbol: "◇", keywords: "accesibilidad texto contraste animaciones" },
        { key: "about", title: "Acerca de", group: "MurSchol OS", symbol: "i", keywords: "versión acerca de licencia sistema" }
    ]

    SettingsBackend { id: backend }

    function pageKnown(key) {
        for (let i = 0; i < pages.length; ++i) {
            if (pages[i].key === key)
                return true
        }
        return false
    }

    function pageTitle(key) {
        for (let i = 0; i < pages.length; ++i) {
            if (pages[i].key === key)
                return pages[i].title
        }
        return "Configuración"
    }

    function matchesPage(page) {
        const query = searchField.text.trim().toLowerCase()
        if (query.length === 0)
            return true
        return page.title.toLowerCase().includes(query)
                || page.group.toLowerCase().includes(query)
                || page.keywords.toLowerCase().includes(query)
    }

    Component.onCompleted: {
        if (initialPage && pageKnown(initialPage))
            currentPage = initialPage
        else if (initialPage === "settings")
            currentPage = "appearance"
    }

    header: Rectangle {
        height: 62
        color: lightTheme ? "#f8fbfc" : "#0b1d28"
        border.color: lightTheme ? "#d5e0e4" : "#1e3c4a"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 14

            Rectangle {
                width: 34
                height: 34
                radius: 11
                color: root.accent
                Label {
                    anchors.centerIn: parent
                    text: "MS"
                    color: "#07131d"
                    font.bold: true
                    font.pixelSize: 11
                }
            }

            ColumnLayout {
                spacing: 0
                Label {
                    text: "MurSchol Settings"
                    color: lightTheme ? "#132833" : "#f3f8fa"
                    font.pixelSize: 16
                    font.bold: true
                }
                Label {
                    text: "Configuración del sistema"
                    color: lightTheme ? "#6a7d86" : "#7897a5"
                    font.pixelSize: 9
                }
            }

            Item { Layout.fillWidth: true }

            TextField {
                id: searchField
                Layout.preferredWidth: 360
                placeholderText: "Buscar un ajuste..."
                color: lightTheme ? "#172c36" : "#eef7f9"
                placeholderTextColor: lightTheme ? "#72858e" : "#698895"
                selectByMouse: true
                background: Rectangle {
                    radius: 16
                    color: lightTheme ? "#eaf0f2" : "#102833"
                    border.color: searchField.activeFocus ? root.accent : (lightTheme ? "#cbd8dd" : "#294a59")
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 278
            Layout.fillHeight: true
            color: lightTheme ? "#f7fafb" : "#091923"
            border.color: lightTheme ? "#d8e2e6" : "#173441"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 5

                        Repeater {
                            model: root.pages
                            delegate: Button {
                                id: navButton
                                required property var modelData
                                width: parent.width
                                height: root.matchesPage(modelData) ? 46 : 0
                                visible: root.matchesPage(modelData)
                                text: modelData.title
                                onClicked: {
                                    root.currentPage = modelData.key
                                    searchField.text = ""
                                }

                                background: Rectangle {
                                    radius: 13
                                    color: root.currentPage === navButton.modelData.key
                                           ? (lightTheme ? "#d8eeed" : "#123a44")
                                           : (navButton.hovered ? (lightTheme ? "#e8eff1" : "#102731") : "transparent")
                                    border.width: root.currentPage === navButton.modelData.key ? 1 : 0
                                    border.color: root.accent
                                }

                                contentItem: RowLayout {
                                    spacing: 9
                                    Label {
                                        text: navButton.modelData.symbol
                                        color: root.currentPage === navButton.modelData.key ? root.accent : (lightTheme ? "#59707a" : "#83a2ae")
                                        font.pixelSize: 15
                                        font.bold: true
                                        Layout.preferredWidth: 24
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                    ColumnLayout {
                                        spacing: 0
                                        Layout.fillWidth: true
                                        Label {
                                            text: navButton.modelData.title
                                            color: lightTheme ? "#17303a" : "#eef5f7"
                                            font.pixelSize: 11
                                            font.bold: root.currentPage === navButton.modelData.key
                                        }
                                        Label {
                                            text: navButton.modelData.group
                                            color: lightTheme ? "#7b8d95" : "#607f8c"
                                            font.pixelSize: 7
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: 13
                    color: lightTheme ? "#edf3f4" : "#0f2731"
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        Label { text: "●"; color: root.accent; font.pixelSize: 10 }
                        Label {
                            Layout.fillWidth: true
                            text: backend.statusText
                            color: lightTheme ? "#51666f" : "#7897a4"
                            font.pixelSize: 8
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: lightTheme ? "#edf2f4" : "#07131d"

            ScrollView {
                anchors.fill: parent
                clip: true

                ColumnLayout {
                    width: Math.max(620, parent.width - 64)
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 16
                    topPadding: 30
                    bottomPadding: 38

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Label {
                            text: root.pageTitle(root.currentPage)
                            color: lightTheme ? "#122933" : "#f1f7f9"
                            font.pixelSize: 28
                            font.bold: true
                        }
                        Label {
                            text: {
                                switch (root.currentPage) {
                                case "appearance": return "Tema, color y movimiento del entorno MurSchol."
                                case "dock": return "Comportamiento del dock global y del panel."
                                case "performance": return "Perfil compartido para priorizar ligereza o respuesta."
                                case "system": return "Información real detectada en este equipo."
                                case "network": return "Conexiones administradas por NetworkManager."
                                case "sound": return "Audio administrado por PipeWire y WirePlumber."
                                case "bluetooth": return "Dispositivos Bluetooth administrados por BlueZ."
                                case "storage": return "Estado básico del almacenamiento local."
                                case "about": return "Información de MurSchol OS y de esta configuración."
                                default: return "Esta sección se conectará al subsistema correspondiente sin duplicar su estado."
                                }
                            }
                            color: lightTheme ? "#647984" : "#7895a2"
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        visible: root.currentPage === "appearance"
                        Layout.fillWidth: true
                        height: appearanceColumn.implicitHeight + 36
                        radius: 20
                        color: lightTheme ? "#f9fbfc" : "#0d202a"
                        border.color: lightTheme ? "#d5e0e4" : "#284653"

                        ColumnLayout {
                            id: appearanceColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 18
                            spacing: 14

                            Label { text: "Tema"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 13 }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Repeater {
                                    model: ["Automático", "Claro", "Oscuro"]
                                    delegate: Button {
                                        required property string modelData
                                        Layout.fillWidth: true
                                        height: 48
                                        checkable: true
                                        checked: backend.theme === modelData
                                        text: modelData
                                        onClicked: backend.setTheme(modelData)
                                        background: Rectangle {
                                            radius: 14
                                            color: parent.checked ? (lightTheme ? "#d9eeee" : "#153c45") : (lightTheme ? "#edf2f4" : "#122832")
                                            border.width: parent.checked ? 2 : 1
                                            border.color: parent.checked ? root.accent : (lightTheme ? "#d2dde1" : "#294653")
                                        }
                                        contentItem: Label {
                                            text: parent.text
                                            color: lightTheme ? "#17303a" : "#eef6f8"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: 10
                                            font.bold: parent.checked
                                        }
                                    }
                                }
                            }

                            Label { text: "Color de énfasis"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 13 }
                            RowLayout {
                                spacing: 10
                                Repeater {
                                    model: ["#22d6cf", "#38bdf8", "#6d8cff", "#9a71f5", "#55d58a", "#e6a85c"]
                                    delegate: Button {
                                        required property string modelData
                                        width: 42
                                        height: 42
                                        onClicked: backend.setAccentColor(modelData)
                                        background: Rectangle {
                                            radius: 21
                                            color: modelData
                                            border.width: backend.accentColor === modelData ? 4 : 1
                                            border.color: backend.accentColor === modelData ? (lightTheme ? "#17303a" : "white") : "#60808d"
                                        }
                                        contentItem: Item {}
                                    }
                                }
                            }

                            Label { text: "Animaciones"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 13 }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Repeater {
                                    model: ["Normal", "Reducidas", "Desactivadas"]
                                    delegate: Button {
                                        required property string modelData
                                        Layout.fillWidth: true
                                        height: 44
                                        checkable: true
                                        checked: backend.animationMode === modelData
                                        text: modelData
                                        onClicked: backend.setAnimationMode(modelData)
                                        background: Rectangle {
                                            radius: 13
                                            color: parent.checked ? (lightTheme ? "#d9eeee" : "#153c45") : (lightTheme ? "#edf2f4" : "#122832")
                                            border.color: parent.checked ? root.accent : (lightTheme ? "#d2dde1" : "#294653")
                                        }
                                        contentItem: Label {
                                            text: parent.text
                                            color: lightTheme ? "#17303a" : "#eef6f8"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.pixelSize: 9
                                        }
                                    }
                                }
                            }

                            Label {
                                Layout.fillWidth: true
                                text: "El tema y el color quedan guardados en la configuración común. La adopción visual completa por todas las aplicaciones MurSchol se hará de forma progresiva."
                                color: lightTheme ? "#71838b" : "#668694"
                                font.pixelSize: 9
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Rectangle {
                        visible: root.currentPage === "dock"
                        Layout.fillWidth: true
                        height: dockColumn.implicitHeight + 36
                        radius: 20
                        color: lightTheme ? "#f9fbfc" : "#0d202a"
                        border.color: lightTheme ? "#d5e0e4" : "#284653"

                        ColumnLayout {
                            id: dockColumn
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
                                Switch { checked: backend.dockAutoHide; onToggled: backend.setDockAutoHide(checked) }
                            }

                            Rectangle { Layout.fillWidth: true; height: 1; color: lightTheme ? "#dce5e8" : "#23414e" }

                            Label { text: "Tamaño del dock"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 12 }
                            RowLayout {
                                Layout.fillWidth: true
                                Label { text: "Pequeño"; color: lightTheme ? "#6c7f87" : "#7895a1"; font.pixelSize: 9 }
                                Slider {
                                    id: dockSizeSlider
                                    Layout.fillWidth: true
                                    from: 54
                                    to: 84
                                    stepSize: 2
                                    value: backend.dockSize
                                    onMoved: backend.setDockSize(Math.round(value))
                                }
                                Label {
                                    text: backend.dockSize + " px"
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
                                    Label { text: "Efecto discreto; se desactiva con animaciones desactivadas."; color: lightTheme ? "#74868e" : "#708e9a"; font.pixelSize: 9 }
                                }
                                Switch { checked: backend.dockMagnify; onToggled: backend.setDockMagnify(checked) }
                            }
                        }
                    }

                    Rectangle {
                        visible: root.currentPage === "performance"
                        Layout.fillWidth: true
                        height: performanceColumn.implicitHeight + 36
                        radius: 20
                        color: lightTheme ? "#f9fbfc" : "#0d202a"
                        border.color: lightTheme ? "#d5e0e4" : "#284653"

                        ColumnLayout {
                            id: performanceColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 18
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                Label { text: "Perfil activo"; color: lightTheme ? "#1b323c" : "white"; font.bold: true; font.pixelSize: 13; Layout.fillWidth: true }
                                Rectangle {
                                    width: recommendation.implicitWidth + 22
                                    height: 28
                                    radius: 14
                                    color: lightTheme ? "#dcefee" : "#153943"
                                    Label {
                                        id: recommendation
                                        anchors.centerIn: parent
                                        text: "Recomendado: " + backend.recommendedProfile
                                        color: root.accent
                                        font.pixelSize: 9
                                        font.bold: true
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Repeater {
                                    model: [
                                        { name: "Ligero", detail: "Menos efectos y menos actividad secundaria", symbol: "◆" },
                                        { name: "Normal", detail: "Equilibrio para el uso diario", symbol: "▣" },
                                        { name: "Rendimiento", detail: "Más respuesta y precarga cuando sea útil", symbol: "▲" }
                                    ]
                                    delegate: Button {
                                        id: profileButton
                                        required property var modelData
                                        Layout.fillWidth: true
                                        height: 118
                                        checkable: true
                                        checked: backend.profile === modelData.name
                                        onClicked: backend.setProfile(modelData.name)
                                        background: Rectangle {
                                            radius: 16
                                            color: profileButton.checked ? (lightTheme ? "#dcefee" : "#143943") : (lightTheme ? "#edf2f4" : "#112630")
                                            border.width: profileButton.checked ? 2 : 1
                                            border.color: profileButton.checked ? root.accent : (lightTheme ? "#d1dde1" : "#294754")
                                        }
                                        contentItem: ColumnLayout {
                                            spacing: 4
                                            Label { Layout.alignment: Qt.AlignHCenter; text: profileButton.modelData.symbol; color: root.accent; font.pixelSize: 19; font.bold: true }
                                            Label { Layout.alignment: Qt.AlignHCenter; text: profileButton.modelData.name; color: lightTheme ? "#18313b" : "white"; font.pixelSize: 11; font.bold: true }
                                            Label {
                                                Layout.fillWidth: true
                                                text: profileButton.modelData.detail
                                                color: lightTheme ? "#6c7f87" : "#7895a1"
                                                font.pixelSize: 8
                                                wrapMode: Text.WordWrap
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                    }
                                }
                            }

                            Label {
                                Layout.fillWidth: true
                                text: "En la alpha el perfil ya controla la frecuencia de estadísticas y parte de las animaciones del shell. CPU, compositor, cachés y precarga se irán conectando sin prometer optimizaciones que aún no estén implementadas."
                                color: lightTheme ? "#71838b" : "#668694"
                                font.pixelSize: 9
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Rectangle {
                        visible: root.currentPage === "system" || root.currentPage === "storage" || root.currentPage === "about"
                        Layout.fillWidth: true
                        height: systemColumn.implicitHeight + 36
                        radius: 20
                        color: lightTheme ? "#f9fbfc" : "#0d202a"
                        border.color: lightTheme ? "#d5e0e4" : "#284653"

                        ColumnLayout {
                            id: systemColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 18
                            spacing: 10

                            Repeater {
                                model: [
                                    { label: "Sistema", value: backend.distroName },
                                    { label: "Kernel", value: backend.kernelVersion },
                                    { label: "Procesador", value: backend.cpuModel },
                                    { label: "Hilos", value: backend.cpuThreads.toString() },
                                    { label: "Memoria", value: backend.totalMemoryGb.toFixed(1) + " GB" },
                                    { label: "Almacenamiento", value: backend.storageSummary }
                                ]
                                delegate: Rectangle {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    height: 52
                                    radius: 13
                                    color: lightTheme ? "#edf2f4" : "#112630"
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 13
                                        anchors.rightMargin: 13
                                        Label {
                                            text: parent.parent.modelData.label
                                            color: lightTheme ? "#667b84" : "#7896a2"
                                            font.pixelSize: 9
                                            Layout.preferredWidth: 120
                                        }
                                        Label {
                                            Layout.fillWidth: true
                                            text: parent.parent.modelData.value
                                            color: lightTheme ? "#18313b" : "#e7f0f3"
                                            font.pixelSize: 10
                                            elide: Text.ElideMiddle
                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }
                                }
                            }

                            Label {
                                visible: root.currentPage === "about"
                                Layout.fillWidth: true
                                text: "MurSchol Settings 0.1 · configuración local-first de MurSchol OS. Las preferencias propias se guardan en " + backend.settingsFilePath()
                                color: lightTheme ? "#6d8088" : "#688793"
                                font.pixelSize: 9
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    Rectangle {
                        visible: root.currentPage === "network" || root.currentPage === "sound" || root.currentPage === "bluetooth"
                        Layout.fillWidth: true
                        height: externalColumn.implicitHeight + 36
                        radius: 20
                        color: lightTheme ? "#f9fbfc" : "#0d202a"
                        border.color: lightTheme ? "#d5e0e4" : "#284653"

                        ColumnLayout {
                            id: externalColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 18
                            spacing: 12

                            Label {
                                Layout.fillWidth: true
                                text: root.currentPage === "network"
                                      ? "MurSchol todavía no duplica el estado de NetworkManager. Puedes abrir su editor real desde aquí."
                                      : (root.currentPage === "sound"
                                         ? "MurSchol todavía no duplica controles de PipeWire. Puedes abrir el mezclador real desde aquí."
                                         : "MurSchol todavía no duplica BlueZ. Puedes abrir el administrador real desde aquí.")
                                color: lightTheme ? "#4f6670" : "#8ca6b0"
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                            }

                            Button {
                                text: root.currentPage === "network" ? "Abrir conexiones de red"
                                      : (root.currentPage === "sound" ? "Abrir controles de sonido" : "Abrir Bluetooth")
                                enabled: root.currentPage === "network" ? backend.networkSettingsAvailable
                                         : (root.currentPage === "sound" ? backend.audioSettingsAvailable : backend.bluetoothSettingsAvailable)
                                onClicked: {
                                    if (root.currentPage === "network") backend.openNetworkSettings()
                                    else if (root.currentPage === "sound") backend.openAudioSettings()
                                    else backend.openBluetoothSettings()
                                }
                                background: Rectangle {
                                    radius: 13
                                    color: parent.enabled ? root.accent : (lightTheme ? "#dbe2e5" : "#263942")
                                }
                                contentItem: Label {
                                    text: parent.text
                                    color: parent.enabled ? "#07131d" : (lightTheme ? "#89969b" : "#71858d")
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 10
                                    font.bold: parent.enabled
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: root.currentPage !== "appearance"
                                 && root.currentPage !== "dock"
                                 && root.currentPage !== "performance"
                                 && root.currentPage !== "system"
                                 && root.currentPage !== "storage"
                                 && root.currentPage !== "about"
                                 && root.currentPage !== "network"
                                 && root.currentPage !== "sound"
                                 && root.currentPage !== "bluetooth"
                        Layout.fillWidth: true
                        height: placeholderColumn.implicitHeight + 36
                        radius: 20
                        color: lightTheme ? "#f9fbfc" : "#0d202a"
                        border.color: lightTheme ? "#d5e0e4" : "#284653"

                        ColumnLayout {
                            id: placeholderColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 18
                            spacing: 7
                            Label {
                                text: "Preparado, todavía sin controles ficticios"
                                color: lightTheme ? "#1b323c" : "white"
                                font.bold: true
                                font.pixelSize: 13
                            }
                            Label {
                                Layout.fillWidth: true
                                text: "La sección forma parte de la navegación definitiva, pero sus controles aparecerán únicamente cuando estén conectados al backend real del sistema."
                                color: lightTheme ? "#667a83" : "#77939f"
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
    }
}
