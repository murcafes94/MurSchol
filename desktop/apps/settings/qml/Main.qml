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
        { key: "display", title: "Pantalla", group: "Sistema", symbol: "▣", keywords: "monitor resolución escala brillo orientación luz nocturna filtro azul" },
        { key: "sound", title: "Sonido", group: "Sistema", symbol: "◕", keywords: "audio volumen micrófono altavoz pipewire" },
        { key: "network", title: "Red e Internet", group: "Sistema", symbol: "◎", keywords: "wifi ethernet red internet network" },
        { key: "bluetooth", title: "Bluetooth", group: "Sistema", symbol: "ᛒ", keywords: "bluetooth dispositivos auriculares" },
        { key: "power", title: "Energía", group: "Sistema", symbol: "ϟ", keywords: "batería energía suspensión brillo corriente" },
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
    NetworkBackend { id: networkBackend }
    SoundBackend { id: soundBackend }
    BluetoothBackend { id: bluetoothBackend }
    PowerBackend { id: powerBackend }
    DisplayBackend { id: displayBackend }

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

    function pageDescription(key) {
        switch (key) {
        case "display": return "Pantallas, brillo y Luz nocturna con información real de Wayland."
        case "appearance": return "Tema, color y movimiento del entorno MurSchol."
        case "dock": return "Comportamiento del dock global y del panel."
        case "performance": return "Perfil compartido para priorizar ligereza o respuesta."
        case "system": return "Información real detectada en este equipo."
        case "network": return "Wi-Fi y conectividad leídos directamente desde NetworkManager."
        case "sound": return "Salida, entrada y volumen controlados mediante PipeWire/WirePlumber."
        case "bluetooth": return "Adaptador y dispositivos controlados directamente mediante BlueZ."
        case "power": return "Batería, brillo y suspensión conectados a UPower, brightnessctl y logind."
        case "storage": return "Estado básico del almacenamiento local."
        case "about": return "Información de MurSchol OS y de esta configuración."
        default: return "Esta sección se conectará al subsistema correspondiente sin duplicar su estado."
        }
    }

    function matchesPage(page) {
        const query = searchField.text.trim().toLowerCase()
        if (query.length === 0)
            return true
        return page.title.toLowerCase().includes(query)
                || page.group.toLowerCase().includes(query)
                || page.keywords.toLowerCase().includes(query)
    }

    function pageImplemented(key) {
        return key === "appearance" || key === "dock" || key === "performance"
                || key === "system" || key === "storage" || key === "about"
                || key === "network" || key === "sound" || key === "bluetooth"
                || key === "power" || key === "display"
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
                Label { anchors.centerIn: parent; text: "MS"; color: "#07131d"; font.bold: true; font.pixelSize: 11 }
            }

            ColumnLayout {
                spacing: 0
                Label { text: "MurSchol Settings"; color: lightTheme ? "#132833" : "#f3f8fa"; font.pixelSize: 16; font.bold: true }
                Label { text: "Configuración del sistema"; color: lightTheme ? "#6a7d86" : "#7897a5"; font.pixelSize: 9 }
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
                                    if (modelData.key === "network") networkBackend.refresh()
                                    if (modelData.key === "sound") soundBackend.refresh()
                                    if (modelData.key === "bluetooth") bluetoothBackend.refresh()
                                    if (modelData.key === "power") powerBackend.refresh()
                                    if (modelData.key === "display") {
                                        displayBackend.refresh()
                                        powerBackend.refresh()
                                    }
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
                                        Label { text: navButton.modelData.title; color: lightTheme ? "#17303a" : "#eef5f7"; font.pixelSize: 11; font.bold: root.currentPage === navButton.modelData.key }
                                        Label { text: navButton.modelData.group; color: lightTheme ? "#7b8d95" : "#607f8c"; font.pixelSize: 7 }
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
                            text: root.currentPage === "network" ? networkBackend.statusText
                                  : (root.currentPage === "sound" ? soundBackend.statusText
                                     : (root.currentPage === "bluetooth" ? bluetoothBackend.statusText
                                        : (root.currentPage === "power" ? powerBackend.statusText
                                           : (root.currentPage === "display" ? displayBackend.statusText : backend.statusText))))
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
                        Label { text: root.pageTitle(root.currentPage); color: lightTheme ? "#122933" : "#f1f7f9"; font.pixelSize: 28; font.bold: true }
                        Label {
                            text: root.pageDescription(root.currentPage)
                            color: lightTheme ? "#647984" : "#7895a2"
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }

                    DisplayPage {
                        visible: root.currentPage === "display"
                        Layout.fillWidth: true
                        backend: displayBackend
                        powerBackend: powerBackend
                        lightTheme: root.lightTheme
                        accent: root.accent
                    }
                    AppearancePage { visible: root.currentPage === "appearance"; Layout.fillWidth: true; backend: backend; lightTheme: root.lightTheme; accent: root.accent }
                    DockPage { visible: root.currentPage === "dock"; Layout.fillWidth: true; backend: backend; lightTheme: root.lightTheme; accent: root.accent }
                    PerformancePage { visible: root.currentPage === "performance"; Layout.fillWidth: true; backend: backend; lightTheme: root.lightTheme; accent: root.accent }
                    SystemPage {
                        visible: root.currentPage === "system" || root.currentPage === "storage" || root.currentPage === "about"
                        Layout.fillWidth: true
                        backend: backend
                        lightTheme: root.lightTheme
                        accent: root.accent
                        showAbout: root.currentPage === "about"
                    }
                    NetworkPage {
                        visible: root.currentPage === "network"
                        Layout.fillWidth: true
                        backend: networkBackend
                        settingsBackend: backend
                        lightTheme: root.lightTheme
                        accent: root.accent
                    }
                    SoundPage {
                        visible: root.currentPage === "sound"
                        Layout.fillWidth: true
                        backend: soundBackend
                        settingsBackend: backend
                        lightTheme: root.lightTheme
                        accent: root.accent
                    }
                    BluetoothPage {
                        visible: root.currentPage === "bluetooth"
                        Layout.fillWidth: true
                        backend: bluetoothBackend
                        settingsBackend: backend
                        lightTheme: root.lightTheme
                        accent: root.accent
                    }
                    PowerPage {
                        visible: root.currentPage === "power"
                        Layout.fillWidth: true
                        backend: powerBackend
                        settingsBackend: backend
                        lightTheme: root.lightTheme
                        accent: root.accent
                    }
                    PlaceholderPage {
                        visible: !root.pageImplemented(root.currentPage)
                        Layout.fillWidth: true
                        lightTheme: root.lightTheme
                    }
                }
            }
        }
    }
}
