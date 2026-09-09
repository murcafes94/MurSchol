import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholSettings 1.0

ApplicationWindow {
    id: root
    width: 1220
    height: 780
    minimumWidth: 920
    minimumHeight: 640
    visible: true
    title: "MurSchol Settings"
    color: backgroundColor

    property string currentPage: "appearance"
    property bool lightTheme: backend.theme === "Claro"
    property color accent: backend.accentColor

    readonly property color backgroundColor: lightTheme ? "#F4F6F9" : "#0B0D12"
    readonly property color surfaceColor: lightTheme ? "#FFFFFF" : "#11151C"
    readonly property color raisedColor: lightTheme ? "#EEF1F5" : "#171C24"
    readonly property color borderColor: lightTheme ? "#D8DEE9" : "#252B35"
    readonly property color textPrimary: lightTheme ? "#0B0D12" : "#F8FAFC"
    readonly property color textSecondary: lightTheme ? "#5B6573" : "#9AA4B2"
    readonly property color danger: "#E63946"

    property var pages: [
        { key: "display", title: "Pantalla", group: "Sistema", symbol: "▣", keywords: "monitor resolución escala brillo orientación luz nocturna filtro azul" },
        { key: "sound", title: "Sonido", group: "Sistema", symbol: "◕", keywords: "audio volumen micrófono altavoz pipewire" },
        { key: "network", title: "Red e Internet", group: "Sistema", symbol: "◎", keywords: "wifi ethernet red internet network" },
        { key: "bluetooth", title: "Bluetooth", group: "Sistema", symbol: "ᛒ", keywords: "bluetooth dispositivos auriculares" },
        { key: "power", title: "Energía", group: "Sistema", symbol: "ϟ", keywords: "batería energía suspensión brillo corriente" },
        { key: "storage", title: "Almacenamiento", group: "Sistema", symbol: "▤", keywords: "disco almacenamiento espacio archivos usb papelera limpieza expulsar" },
        { key: "appearance", title: "Apariencia", group: "Personalización", symbol: "◈", keywords: "tema claro oscuro color animaciones apariencia" },
        { key: "dock", title: "Dock y panel", group: "Personalización", symbol: "▰", keywords: "dock panel ocultar tamaño iconos ampliar" },
        { key: "workspaces", title: "Espacios", group: "Personalización", symbol: "▦", keywords: "espacios estudio trabajos personal escritorios" },
        { key: "apps", title: "Aplicaciones", group: "Aplicaciones", symbol: "▥", keywords: "apps instaladas predeterminadas navegador fotos archivos pdf mime" },
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
    AppsBackend { id: appsBackend }
    StorageBackend { id: storageBackend }

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

    function pageGroup(key) {
        for (let i = 0; i < pages.length; ++i) {
            if (pages[i].key === key)
                return pages[i].group
        }
        return "MurSchol OS"
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
        case "storage": return "Discos internos y USB, espacio disponible, papelera y limpieza segura."
        case "apps": return "Aplicaciones instaladas y asociaciones predeterminadas mediante XDG."
        case "compatibility": return "Estado real de las capas Linux, Flatpak, Android y Windows."
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
                || key === "power" || key === "display" || key === "apps"
                || key === "compatibility"
    }

    function refreshPage(key) {
        if (key === "network") networkBackend.refresh()
        if (key === "sound") soundBackend.refresh()
        if (key === "bluetooth") bluetoothBackend.refresh()
        if (key === "power") powerBackend.refresh()
        if (key === "display") {
            displayBackend.refresh()
            powerBackend.refresh()
        }
        if (key === "storage") storageBackend.refresh()
        if (key === "apps" || key === "compatibility") appsBackend.refresh()
    }

    function currentStatus() {
        if (currentPage === "network") return networkBackend.statusText
        if (currentPage === "sound") return soundBackend.statusText
        if (currentPage === "bluetooth") return bluetoothBackend.statusText
        if (currentPage === "power") return powerBackend.statusText
        if (currentPage === "display") return displayBackend.statusText
        if (currentPage === "storage") return storageBackend.statusText
        if (currentPage === "apps" || currentPage === "compatibility") return appsBackend.statusText
        return backend.statusText
    }

    function statusIsDanger() {
        const status = currentStatus().toLowerCase()
        return status.includes("error") || status.includes("no se") || status.includes("fall")
    }

    Component.onCompleted: {
        if (initialPage && pageKnown(initialPage))
            currentPage = initialPage
        else if (initialPage === "settings")
            currentPage = "appearance"
        refreshPage(currentPage)
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 264
            Layout.minimumWidth: 248
            Layout.fillHeight: true
            color: root.surfaceColor
            border.width: 0

            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: root.borderColor
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    spacing: 11

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 12
                        color: "#2563EB"
                        Label {
                            anchors.centerIn: parent
                            text: "MS"
                            color: "#FFFFFF"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label { text: "MurSchol"; color: root.textPrimary; font.pixelSize: 15; font.bold: true }
                        Label { text: "Configuración"; color: root.textSecondary; font.pixelSize: 9 }
                    }
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    placeholderText: "Buscar ajustes"
                    color: root.textPrimary
                    placeholderTextColor: root.textSecondary
                    leftPadding: 14
                    rightPadding: 14
                    selectByMouse: true
                    background: Rectangle {
                        radius: 13
                        color: root.raisedColor
                        border.width: searchField.activeFocus ? 2 : 1
                        border.color: searchField.activeFocus ? root.accent : root.borderColor
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        width: parent.width
                        spacing: 3

                        Repeater {
                            model: root.pages
                            delegate: Item {
                                id: navItem
                                required property var modelData
                                required property int index
                                width: parent.width
                                height: root.matchesPage(modelData)
                                        ? (groupLabel.visible ? 64 : 46)
                                        : 0
                                visible: root.matchesPage(modelData)

                                Label {
                                    id: groupLabel
                                    visible: navItem.index === 0
                                             || root.pages[navItem.index - 1].group !== navItem.modelData.group
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.top: parent.top
                                    anchors.topMargin: 4
                                    text: navItem.modelData.group.toUpperCase()
                                    color: root.textSecondary
                                    font.pixelSize: 8
                                    font.bold: true
                                    font.letterSpacing: 0.8
                                }

                                Button {
                                    id: navButton
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 44
                                    text: navItem.modelData.title
                                    onClicked: {
                                        root.currentPage = navItem.modelData.key
                                        searchField.text = ""
                                        root.refreshPage(navItem.modelData.key)
                                    }
                                    background: Rectangle {
                                        radius: 12
                                        color: root.currentPage === navItem.modelData.key
                                               ? (root.lightTheme ? "#EAF1FF" : "#123A7A")
                                               : (navButton.hovered ? root.raisedColor : "transparent")
                                        border.width: root.currentPage === navItem.modelData.key ? 1 : 0
                                        border.color: root.currentPage === navItem.modelData.key ? root.accent : "transparent"
                                    }
                                    contentItem: RowLayout {
                                        spacing: 9
                                        Label {
                                            text: navItem.modelData.symbol
                                            color: root.currentPage === navItem.modelData.key ? root.accent : root.textSecondary
                                            font.pixelSize: 14
                                            font.bold: true
                                            Layout.preferredWidth: 24
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        Label {
                                            Layout.fillWidth: true
                                            text: navItem.modelData.title
                                            color: root.textPrimary
                                            font.pixelSize: 10
                                            font.bold: root.currentPage === navItem.modelData.key
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    radius: 13
                    color: root.raisedColor
                    border.width: 1
                    border.color: root.borderColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: root.statusIsDanger() ? root.danger : root.accent
                        }
                        Label {
                            Layout.fillWidth: true
                            text: root.currentStatus()
                            color: root.textSecondary
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
            color: root.backgroundColor

            ScrollView {
                anchors.fill: parent
                clip: true

                ColumnLayout {
                    width: Math.max(620, Math.min(900, parent.width - 72))
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 18
                    y: 34

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Label {
                                text: root.pageGroup(root.currentPage)
                                color: root.accent
                                font.pixelSize: 9
                                font.bold: true
                                font.letterSpacing: 0.6
                            }
                            Label {
                                text: root.pageTitle(root.currentPage)
                                color: root.textPrimary
                                font.pixelSize: 30
                                font.bold: true
                            }
                            Label {
                                Layout.fillWidth: true
                                text: root.pageDescription(root.currentPage)
                                color: root.textSecondary
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                            }
                        }

                        Rectangle {
                            Layout.alignment: Qt.AlignTop
                            width: 112
                            height: 34
                            radius: 17
                            color: root.surfaceColor
                            border.width: 1
                            border.color: root.borderColor
                            Label {
                                anchors.centerIn: parent
                                text: root.backend.profile
                                color: root.textSecondary
                                font.pixelSize: 9
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.borderColor
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
                        visible: root.currentPage === "system" || root.currentPage === "about"
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
                    StoragePage {
                        visible: root.currentPage === "storage"
                        Layout.fillWidth: true
                        backend: storageBackend
                        lightTheme: root.lightTheme
                        accent: root.accent
                    }
                    AppsPage {
                        visible: root.currentPage === "apps"
                        Layout.fillWidth: true
                        backend: appsBackend
                        lightTheme: root.lightTheme
                        accent: root.accent
                    }
                    CompatibilityPage {
                        visible: root.currentPage === "compatibility"
                        Layout.fillWidth: true
                        backend: appsBackend
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