#include "EventModel.h"

#include <QDir>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>

EventModel::EventModel(QObject *parent)
    : QAbstractListModel(parent)
{
    if (initializeDatabase())
        loadEvents();
}

EventModel::~EventModel()
{
    const QString connectionName = m_db.connectionName();
    if (m_db.isValid())
        m_db.close();
    m_db = QSqlDatabase();
    if (!connectionName.isEmpty())
        QSqlDatabase::removeDatabase(connectionName);
}

int EventModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_events.size();
}

QVariant EventModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_events.size())
        return {};

    const Event &event = m_events.at(index.row());
    switch (role) {
    case IdRole: return event.id;
    case TitleRole: return event.title;
    case StartTimeRole: return event.startTime;
    case EndTimeRole: return event.endTime;
    case AllDayRole: return event.allDay;
    case CalendarRole: return event.calendar;
    case NotesRole: return event.notes;
    case ReminderMinutesRole: return event.reminderMinutes;
    default: return {};
    }
}

QHash<int, QByteArray> EventModel::roleNames() const
{
    return {
        { IdRole, "eventId" },
        { TitleRole, "title" },
        { StartTimeRole, "startTime" },
        { EndTimeRole, "endTime" },
        { AllDayRole, "allDay" },
        { CalendarRole, "calendar" },
        { NotesRole, "notes" },
        { ReminderMinutesRole, "reminderMinutes" }
    };
}

void EventModel::setSelectedDate(const QString &isoDate)
{
    const QDate date = QDate::fromString(isoDate, Qt::ISODate);
    if (!date.isValid() || date == m_selectedDate)
        return;

    m_selectedDate = date;
    emit selectedDateChanged();
    loadEvents();
}

bool EventModel::createEvent(const QString &title,
                             const QString &date,
                             const QString &startTime,
                             const QString &endTime,
                             bool allDay,
                             const QString &calendar,
                             const QString &notes,
                             int reminderMinutes)
{
    if (!m_db.isOpen()) {
        emit errorOccurred(QStringLiteral("La base del calendario no está disponible"));
        return false;
    }

    const QDate eventDate = QDate::fromString(date, Qt::ISODate);
    if (title.trimmed().isEmpty() || !eventDate.isValid()) {
        emit errorOccurred(QStringLiteral("El evento necesita un título y una fecha válidos"));
        return false;
    }

    QSqlQuery query(m_db);
    query.prepare(QStringLiteral(
        "INSERT INTO events(title, event_date, start_time, end_time, all_day, calendar_name, notes, reminder_minutes) "
        "VALUES(?, ?, ?, ?, ?, ?, ?, ?)"));
    query.addBindValue(title.trimmed());
    query.addBindValue(eventDate.toString(Qt::ISODate));
    query.addBindValue(allDay ? QString() : startTime.trimmed());
    query.addBindValue(allDay ? QString() : endTime.trimmed());
    query.addBindValue(allDay ? 1 : 0);
    query.addBindValue(calendar.trimmed().isEmpty() ? QStringLiteral("Personal") : calendar.trimmed());
    query.addBindValue(notes.trimmed());
    query.addBindValue(qMax(0, reminderMinutes));

    if (!query.exec()) {
        emit errorOccurred(query.lastError().text());
        return false;
    }

    if (eventDate == m_selectedDate)
        loadEvents();
    return true;
}

bool EventModel::removeEvent(int row)
{
    if (row < 0 || row >= m_events.size() || !m_db.isOpen())
        return false;

    QSqlQuery query(m_db);
    query.prepare(QStringLiteral("DELETE FROM events WHERE id = ?"));
    query.addBindValue(m_events.at(row).id);
    if (!query.exec()) {
        emit errorOccurred(query.lastError().text());
        return false;
    }

    loadEvents();
    return true;
}

void EventModel::refresh()
{
    loadEvents();
}

bool EventModel::initializeDatabase()
{
    const QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (dataDir.isEmpty()) {
        emit errorOccurred(QStringLiteral("No se encontró una ubicación para guardar el calendario"));
        return false;
    }

    QDir().mkpath(dataDir);
    const QString connectionName = QStringLiteral("murschol-calendar-%1")
        .arg(QString::number(reinterpret_cast<quintptr>(this)));
    m_db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), connectionName);
    m_db.setDatabaseName(dataDir + QStringLiteral("/calendar.sqlite"));

    if (!m_db.open()) {
        emit errorOccurred(m_db.lastError().text());
        return false;
    }

    QSqlQuery query(m_db);
    if (!query.exec(QStringLiteral(
            "CREATE TABLE IF NOT EXISTS events ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "title TEXT NOT NULL,"
            "event_date TEXT NOT NULL,"
            "start_time TEXT,"
            "end_time TEXT,"
            "all_day INTEGER NOT NULL DEFAULT 0,"
            "calendar_name TEXT NOT NULL DEFAULT 'Personal',"
            "notes TEXT,"
            "reminder_minutes INTEGER NOT NULL DEFAULT 0"
            ")"))) {
        emit errorOccurred(query.lastError().text());
        return false;
    }

    query.exec(QStringLiteral("CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date)"));
    return true;
}

void EventModel::loadEvents()
{
    beginResetModel();
    m_events.clear();

    if (m_db.isOpen()) {
        QSqlQuery query(m_db);
        query.prepare(QStringLiteral(
            "SELECT id, title, start_time, end_time, all_day, calendar_name, notes, reminder_minutes "
            "FROM events WHERE event_date = ? "
            "ORDER BY all_day DESC, start_time ASC, title COLLATE NOCASE ASC"));
        query.addBindValue(m_selectedDate.toString(Qt::ISODate));

        if (query.exec()) {
            while (query.next()) {
                Event event;
                event.id = query.value(0).toInt();
                event.title = query.value(1).toString();
                event.startTime = query.value(2).toString();
                event.endTime = query.value(3).toString();
                event.allDay = query.value(4).toInt() != 0;
                event.calendar = query.value(5).toString();
                event.notes = query.value(6).toString();
                event.reminderMinutes = query.value(7).toInt();
                m_events.append(event);
            }
        } else {
            emit errorOccurred(query.lastError().text());
        }
    }

    endResetModel();
    emit countChanged();
}
