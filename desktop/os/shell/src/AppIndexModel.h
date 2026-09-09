#pragma once

#include <QAbstractListModel>
#include <QHash>
#include <QSet>

struct MurScholAppEntry {
    QString id;
    QString name;
    QString exec;
    QString icon;
    QString source;
    QString categories;
    bool pinned = false;
    qint64 lastUsed = 0;
};

class AppIndexModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(QString categoryFilter READ categoryFilter WRITE setCategoryFilter NOTIFY categoryFilterChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(int pinnedCount READ pinnedCount NOTIFY stateChanged)
    Q_PROPERTY(int recentCount READ recentCount NOTIFY stateChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        ExecRole,
        IconRole,
        SourceRole,
        CategoriesRole,
        IdRole,
        PinnedRole,
        LastUsedRole
    };

    explicit AppIndexModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString filter() const { return m_filter; }
    void setFilter(const QString &filter);

    QString categoryFilter() const { return m_categoryFilter; }
    void setCategoryFilter(const QString &category);

    int pinnedCount() const;
    int recentCount() const;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool launch(int row);
    Q_INVOKABLE void togglePinned(int row);
    Q_INVOKABLE void clearRecent();

signals:
    void filterChanged();
    void categoryFilterChanged();
    void countChanged();
    void stateChanged();

private:
    void rebuildVisible();
    void loadState();
    void savePinnedState() const;
    void recordRecent(const QString &id);
    QString stateFilePath() const;
    static MurScholAppEntry parseDesktopFile(const QString &path);
    static QString cleanExec(QString command);
    static bool matchesCategory(const MurScholAppEntry &app, const QString &category);

    QList<MurScholAppEntry> m_all;
    QList<MurScholAppEntry> m_visible;
    QSet<QString> m_pinnedIds;
    QHash<QString, qint64> m_lastUsed;
    QString m_filter;
    QString m_categoryFilter = QStringLiteral("Todas");
};
