#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QStandardPaths>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QVariantList>

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
    Q_PROPERTY(QVariantList volumes READ volumes NOTIFY volumesChanged)
    Q_PROPERTY(bool canPaste READ canPaste NOTIFY clipboardStateChanged)
    Q_PROPERTY(bool fileOperationBusy READ fileOperationBusy NOTIFY fileOperationBusyChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusChanged)

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
    QVariantList volumes() const { return m_volumes; }
    bool canPaste() const { return m_canPaste; }
    bool fileOperationBusy() const { return m_fileOperationBusy; }
    QString statusText() const { return m_statusText; }

    void setFilter(const QString &filter);

    Q_INVOKABLE void setPath(const QString &path);
    Q_INVOKABLE void goHome();
    Q_INVOKABLE void goDocuments();
    Q_INVOKABLE void goDownloads();
    Q_INVOKABLE void goPictures();
    Q_INVOKABLE void goMusic();
    Q_INVOKABLE void goVideos();
    Q_INVOKABLE void goComputer();
    Q_INVOKABLE void goUp();
    Q_INVOKABLE bool activate(int row);
    Q_INVOKABLE bool createFolder();
    Q_INVOKABLE bool createFolderNamed(const QString &name);
    Q_INVOKABLE bool renameEntry(int row, const QString &newName);
    Q_INVOKABLE bool moveToTrash(int row);
    Q_INVOKABLE bool copyEntry(int row);
    Q_INVOKABLE bool cutEntry(int row);
    Q_INVOKABLE bool pasteClipboard();
    Q_INVOKABLE bool openVolume(int index);
    Q_INVOKABLE bool unmountVolume(int index);
    Q_INVOKABLE QString entryName(int row) const;
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void refreshVolumes();

signals:
    void currentPathChanged();
    void filterChanged();
    void countChanged();
    void volumesChanged();
    void clipboardStateChanged();
    void fileOperationBusyChanged();
    void statusChanged();
    void errorOccurred(const QString &message);

private:
    void rebuildVisible();
    void refreshClipboardState();
    void setStatus(const QString &text);
    bool putEntryOnClipboard(int row, bool move);
    QString uniqueDestinationPath(const QString &sourcePath) const;
    bool startFileOperation(const QString &program,
                            const QStringList &arguments,
                            const QString &successMessage,
                            bool clearClipboardOnSuccess);
    bool validName(const QString &name) const;
    static QString formatBytes(qint64 bytes);
    static QString iconForFile(const QString &path, bool directory);
    static QString standardLocation(QStandardPaths::StandardLocation location);

    QString m_currentPath;
    QString m_filter;
    QList<MurScholFileEntry> m_all;
    QList<MurScholFileEntry> m_visible;
    QVariantList m_volumes;
    bool m_canPaste = false;
    bool m_fileOperationBusy = false;
    QString m_statusText;
    QTimer m_volumeTimer;
};
