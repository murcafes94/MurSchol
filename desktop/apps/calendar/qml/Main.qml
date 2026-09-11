import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MurScholCalendar 1.0

ApplicationWindow {
    id: root
    width: 1180
    height: 760
    minimumWidth: 820
    minimumHeight: 560
    visible: true
    title: "MurSchol Calendar"
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
    palette.placeholderText: "#7F766D"

    property date cursorDate: new Date()
    property var monthNames: ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    property var dayNames: ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
    property string statusText: ""

    function firstOffset() {
        var day = new Date(cursorDate.getFullYear(), cursorDate.getMonth(), 1).getDay()
        return day === 0 ? 6 : day - 1
    }

    function daysInMonth() {
        return new Date(cursorDate.getFullYear(), cursorDate.getMonth() + 1, 0).getDate()
    }

    function dayForCell(cell) {
        return cell - firstOffset() + 1
    }

    function isoForDay(day) {
        var month = cursorDate.getMonth() + 1
        var mm = month < 10 ? "0" + month : String(month)
        var dd = day < 10 ? "0" + day : String(day)
        return cursorDate.getFullYear() + "-" + mm + "-" + dd
    }

    function moveMonth(delta) {
        cursorDate = new Date(cursorDate.getFullYear(), cursorDate.getMonth() + delta, 1)
    }

    EventModel {
        id: events
        onErrorOccurred: message => {
            root.statusText = message
            statusTimer.restart()
        }
    }

    Component.onCompleted: {
        events.selectedDate = Qt.formatDate(new Date(), "yyyy-MM-dd")
    }

    Timer {
        id: statusTimer
        interval: 3500
        onTriggered: root.statusText = ""
    }

    header: Rectangle {
        height: 66
        color: "#15181D"
        border.color: "#35312D"
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 10

            Rectangle {
                width: 38
                height: 38
                radius: 12
                color: "#49352B"
                border.width: 1
                border.color: "#D6A85F"
                Label {
                    anchors.centerIn: parent
                    text: "31"
                    color: "#D6A85F"
                    font.pixelSize: 11
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Label {
                    text: "MurSchol Calendar"
                    color: "#F3EEE5"
                    font.pixelSize: 17
                    font.bold: true
                }
                Label {
                    text: "Agenda local para estudio, vida personal y ministerio"
                    color: "#A79E94"
                    font.pixelSize: 10
                }
            }

            Button {
                text: "Hoy"
                onClicked: {
                    root.cursorDate = new Date()
                    events.selectedDate = Qt.formatDate(new Date(), "yyyy-MM-dd")
                }
            }

            Button {
                id: newEventButton
                text: "+ Nuevo evento"
                onClicked: {
                    dateField.text = events.selectedDate
                    titleField.text = ""
                    startField.text = "08:00"
                    endField.text = "09:00"
                    allDayCheck.checked = false
                    notesField.text = ""
                    reminderBox.currentIndex = 1
                    eventDialog.open()
                }
                background: Rectangle {
                    radius: 12
                    color: newEventButton.down ? "#8E6A42" : (newEventButton.hovered ? "#E3BB78" : "#D6A85F")
                }
                contentItem: Label {
                    text: newEventButton.text
                    color: "#201B17"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 16

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 760
            radius: 20
            color: "#11151C"
            border.color: "#35312D"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Button {
                        text: "‹"
                        width: 42
                        onClicked: root.moveMonth(-1)
                    }
                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.monthNames[root.cursorDate.getMonth()] + " " + root.cursorDate.getFullYear()
                        color: "#F3EEE5"
                        font.pixelSize: 22
                        font.bold: true
                    }
                    Button {
                        text: "›"
                        width: 42
                        onClicked: root.moveMonth(1)
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 6
                    rowSpacing: 6

                    Repeater {
                        model: root.dayNames
                        delegate: Label {
                            required property string modelData
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            color: "#A79E94"
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 7
                    rows: 6
                    columnSpacing: 6
                    rowSpacing: 6

                    Repeater {
                        model: 42
                        delegate: Rectangle {
                            required property int index
                            property int dayNumber: root.dayForCell(index)
                            property bool validDay: dayNumber >= 1 && dayNumber <= root.daysInMonth()
                            property string isoDate: validDay ? root.isoForDay(dayNumber) : ""
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 12
                            color: isoDate === events.selectedDate ? "#49352B" : dayMouse.containsMouse ? "#24211D" : "#171B21"
                            border.width: isoDate === Qt.formatDate(new Date(), "yyyy-MM-dd") || isoDate === events.selectedDate ? 1 : 0
                            border.color: "#D6A85F"
                            opacity: validDay ? 1.0 : 0.28

                            Label {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.margins: 10
                                text: parent.validDay ? parent.dayNumber : ""
                                color: parent.isoDate === events.selectedDate ? "#F6E5C8" : "#C9C0B6"
                                font.pixelSize: 12
                                font.bold: parent.isoDate === events.selectedDate
                            }

                            Rectangle {
                                visible: parent.isoDate === Qt.formatDate(new Date(), "yyyy-MM-dd")
                                width: 5
                                height: 5
                                radius: 3
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 7
                                color: "#D6A85F"
                            }

                            MouseArea {
                                id: dayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: parent.validDay
                                onClicked: events.selectedDate = parent.isoDate
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 350
            Layout.minimumWidth: 300
            radius: 20
            color: "#11151C"
            border.color: "#35312D"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Label {
                    text: "Agenda"
                    color: "#F3EEE5"
                    font.pixelSize: 20
                    font.bold: true
                }

                Label {
                    text: events.selectedDate
                    color: "#D6A85F"
                    font.pixelSize: 11
                }

                Label {
                    visible: events.count === 0
                    Layout.fillWidth: true
                    Layout.topMargin: 22
                    text: "No hay eventos para este día."
                    color: "#A79E94"
                    wrapMode: Text.WordWrap
                }

                ListView {
                    id: agendaList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    clip: true
                    model: events

                    delegate: Rectangle {
                        required property int index
                        required property string title
                        required property string startTime
                        required property string endTime
                        required property bool allDay
                        required property string calendar
                        required property string notes
                        required property int reminderMinutes
                        width: agendaList.width
                        height: notes.length > 0 ? 110 : 88
                        radius: 14
                        color: "#171B21"
                        border.color: "#51463B"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 11
                            spacing: 3

                            RowLayout {
                                Layout.fillWidth: true
                                Label {
                                    Layout.fillWidth: true
                                    text: title
                                    color: "#F3EEE5"
                                    font.pixelSize: 13
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                                Button {
                                    id: deleteEventButton
                                    text: "×"
                                    width: 32
                                    height: 28
                                    onClicked: events.removeEvent(index)
                                    background: Rectangle {
                                        radius: 9
                                        color: deleteEventButton.hovered ? "#4A2824" : "transparent"
                                    }
                                    contentItem: Label {
                                        text: deleteEventButton.text
                                        color: deleteEventButton.hovered ? "#F0B09F" : "#A79E94"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        font.pixelSize: 16
                                    }
                                }
                            }

                            Label {
                                text: allDay ? "Todo el día" : startTime + (endTime.length > 0 ? " — " + endTime : "")
                                color: "#D6A85F"
                                font.pixelSize: 10
                            }

                            Label {
                                text: calendar + (reminderMinutes > 0 ? " · aviso " + reminderMinutes + " min antes" : "")
                                color: "#8F867D"
                                font.pixelSize: 9
                            }

                            Label {
                                visible: notes.length > 0
                                Layout.fillWidth: true
                                text: notes
                                color: "#C1B7AC"
                                font.pixelSize: 9
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Label {
                    visible: root.statusText.length > 0
                    Layout.fillWidth: true
                    text: root.statusText
                    color: "#E28A78"
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    Dialog {
        id: eventDialog
        modal: true
        anchors.centerIn: Overlay.overlay
        width: Math.min(500, root.width - 40)
        title: "Nuevo evento"
        standardButtons: Dialog.Save | Dialog.Cancel

        onAccepted: {
            if (events.createEvent(titleField.text,
                    dateField.text,
                    startField.text,
                    endField.text,
                    allDayCheck.checked,
                    calendarBox.currentText,
                    notesField.text,
                    reminderBox.currentValue)) {
                events.selectedDate = dateField.text
            }
        }

        contentItem: ColumnLayout {
            spacing: 10

            TextField {
                id: titleField
                Layout.fillWidth: true
                placeholderText: "Título"
            }

            TextField {
                id: dateField
                Layout.fillWidth: true
                placeholderText: "AAAA-MM-DD"
            }

            CheckBox {
                id: allDayCheck
                text: "Todo el día"
            }

            RowLayout {
                Layout.fillWidth: true
                enabled: !allDayCheck.checked
                TextField {
                    id: startField
                    Layout.fillWidth: true
                    placeholderText: "Inicio 08:00"
                }
                TextField {
                    id: endField
                    Layout.fillWidth: true
                    placeholderText: "Fin 09:00"
                }
            }

            ComboBox {
                id: calendarBox
                Layout.fillWidth: true
                model: ["Personal", "Estudio", "Ministerium", "Trabajo"]
            }

            ComboBox {
                id: reminderBox
                Layout.fillWidth: true
                textRole: "text"
                valueRole: "minutes"
                model: [
                    { "text": "Sin aviso", "minutes": 0 },
                    { "text": "10 min antes", "minutes": 10 },
                    { "text": "30 min antes", "minutes": 30 },
                    { "text": "1 hora antes", "minutes": 60 },
                    { "text": "1 día antes", "minutes": 1440 }
                ]
            }

            TextArea {
                id: notesField
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                placeholderText: "Descripción o notas"
                wrapMode: TextEdit.Wrap
            }
        }
    }
}
