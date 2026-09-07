#pragma once

#include <QAbstractListModel>
#include <QDate>
#include <QSqlDatabase>
#include <QString>
#include <QVector>

class EventModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString selectedDate READ selectedDate WRITE setSelectedDate NOTIFY selectedDateChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        TitleRole,
        StartTimeRole,
        EndTimeRole,
        AllDayRole,
        CalendarRole,
        NotesRole,
        ReminderMinutesRole
    };

    explicit EventModel(QObject *parent = nullptr);
    ~EventModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString selectedDate() const { return m_selectedDate.toString(Qt::ISODate); }
    void setSelectedDate(const QString &isoDate);
    int count() const { return m_events.size(); }

    Q_INVOKABLE bool createEvent(const QString &title,
                                 const QString &date,
                                 const QString &startTime,
                                 const QString &endTime,
                                 bool allDay,
                                 const QString &calendar,
                                 const QString &notes,
                                 int reminderMinutes);
    Q_INVOKABLE bool removeEvent(int row);
    Q_INVOKABLE void refresh();

signals:
    void selectedDateChanged();
    void countChanged();
    void errorOccurred(const QString &message);

private:
    struct Event {
        int id = 0;
        QString title;
        QString startTime;
        QString endTime;
        bool allDay = false;
        QString calendar;
        QString notes;
        int reminderMinutes = 0;
    };

    bool initializeDatabase();
    void loadEvents();

    QSqlDatabase m_db;
    QDate m_selectedDate = QDate::currentDate();
    QVector<Event> m_events;
};
