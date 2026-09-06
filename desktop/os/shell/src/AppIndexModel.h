#pragma once

#include <QAbstractListModel>

struct MurScholAppEntry {
    QString name;
    QString exec;
    QString icon;
    QString source;
    QString categories;
};

class AppIndexModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(QString categoryFilter READ categoryFilter WRITE setCategoryFilter NOTIFY categoryFilterChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles { NameRole = Qt::UserRole + 1, ExecRole, IconRole, SourceRole, CategoriesRole };

    explicit AppIndexModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString filter() const { return m_filter; }
    void setFilter(const QString &filter);

    QString categoryFilter() const { return m_categoryFilter; }
    void setCategoryFilter(const QString &category);

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool launch(int row) const;

signals:
    void filterChanged();
    void categoryFilterChanged();
    void countChanged();

private:
    void rebuildVisible();
    static MurScholAppEntry parseDesktopFile(const QString &path);
    static QString cleanExec(QString command);
    static bool matchesCategory(const MurScholAppEntry &app, const QString &category);

    QList<MurScholAppEntry> m_all;
    QList<MurScholAppEntry> m_visible;
    QString m_filter;
    QString m_categoryFilter = QStringLiteral("Todas");
};
