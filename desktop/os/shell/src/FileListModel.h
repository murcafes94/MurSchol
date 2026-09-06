#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QStandardPaths>
#include <QString>

struct MurScholFileEntry {
    QString name;
    QString path;
    bool directory = false;
    QString sizeText;
    QString modifiedText;
    QString iconName;
};

class FileListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString currentPath READ currentPath NOTIFY currentPathChanged)
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(bool canGoUp READ canGoUp NOTIFY currentPathChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        PathRole,
        IsDirectoryRole,
        SizeTextRole,
        ModifiedTextRole,
        IconNameRole
    };

    explicit FileListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    QString currentPath() const { return m_currentPath; }
    QString filter() const { return m_filter; }
    bool canGoUp() const;

    void setFilter(const QString &filter);

    Q_INVOKABLE void setPath(const QString &path);
    Q_INVOKABLE void goHome();
    Q_INVOKABLE void goDocuments();
    Q_INVOKABLE void goDownloads();
    Q_INVOKABLE void goPictures();
    Q_INVOKABLE void goMusic();
    Q_INVOKABLE void goVideos();
    Q_INVOKABLE void goUp();
    Q_INVOKABLE bool activate(int row);
    Q_INVOKABLE bool createFolder();
    Q_INVOKABLE void refresh();

signals:
    void currentPathChanged();
    void filterChanged();
    void countChanged();
    void errorOccurred(const QString &message);

private:
    void rebuildVisible();
    static QString formatBytes(qint64 bytes);
    static QString iconForFile(const QString &path, bool directory);
    static QString standardLocation(QStandardPaths::StandardLocation location);

    QString m_currentPath;
    QString m_filter;
    QList<MurScholFileEntry> m_all;
    QList<MurScholFileEntry> m_visible;
};
