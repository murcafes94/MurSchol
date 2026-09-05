#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QString>

struct MurScholSearchEntry {
    QString title;
    QString subtitle;
    QString kind;
    QString icon;
    QString actionType;
    QString action;
};

struct MurScholSearchApp {
    QString name;
    QString exec;
    QString icon;
};

class UniversalSearchModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        SubtitleRole,
        KindRole,
        IconRole
    };

    explicit UniversalSearchModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString query() const { return m_query; }
    void setQuery(const QString &query);

    Q_INVOKABLE bool activate(int row) const;
    Q_INVOKABLE void refreshIndexes();

signals:
    void queryChanged();
    void countChanged();

private:
    void rebuild();
    void indexApplications();
    void indexFiles();
    void appendMatchingActions(const QString &needle, QList<MurScholSearchEntry> &results) const;
    static QString cleanExec(QString command);

    QList<MurScholSearchApp> m_apps;
    QStringList m_files;
    QList<MurScholSearchEntry> m_results;
    QString m_query;
};
