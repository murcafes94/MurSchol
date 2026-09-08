#pragma once

#include <QObject>
#include <QVariantList>

class StorageBackend final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList volumes READ volumes NOTIFY changed)
    Q_PROPERTY(QString rootTotalText READ rootTotalText NOTIFY changed)
    Q_PROPERTY(QString rootUsedText READ rootUsedText NOTIFY changed)
    Q_PROPERTY(QString rootFreeText READ rootFreeText NOTIFY changed)
    Q_PROPERTY(int rootUsedPercent READ rootUsedPercent NOTIFY changed)
    Q_PROPERTY(QString trashSizeText READ trashSizeText NOTIFY changed)
    Q_PROPERTY(QString thumbnailsSizeText READ thumbnailsSizeText NOTIFY changed)
    Q_PROPERTY(bool udisksAvailable READ udisksAvailable NOTIFY changed)
    Q_PROPERTY(QString statusText READ statusText NOTIFY changed)

public:
    explicit StorageBackend(QObject *parent = nullptr);

    QVariantList volumes() const { return m_volumes; }
    QString rootTotalText() const { return m_rootTotalText; }
    QString rootUsedText() const { return m_rootUsedText; }
    QString rootFreeText() const { return m_rootFreeText; }
    int rootUsedPercent() const { return m_rootUsedPercent; }
    QString trashSizeText() const { return m_trashSizeText; }
    QString thumbnailsSizeText() const { return m_thumbnailsSizeText; }
    bool udisksAvailable() const { return m_udisksAvailable; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool openPath(const QString &path);
    Q_INVOKABLE bool mountDevice(const QString &device);
    Q_INVOKABLE bool unmountDevice(const QString &device);
    Q_INVOKABLE bool emptyTrash();
    Q_INVOKABLE bool clearThumbnails();

signals:
    void changed();

private:
    static QString formatBytes(quint64 bytes);
    static quint64 directorySize(const QString &path);
    static bool clearDirectory(const QString &path);
    void setStatus(const QString &text);

    QVariantList m_volumes;
    QString m_rootTotalText = QStringLiteral("—");
    QString m_rootUsedText = QStringLiteral("—");
    QString m_rootFreeText = QStringLiteral("—");
    int m_rootUsedPercent = 0;
    QString m_trashSizeText = QStringLiteral("0 B");
    QString m_thumbnailsSizeText = QStringLiteral("0 B");
    bool m_udisksAvailable = false;
    QString m_statusText = QStringLiteral("Preparando almacenamiento…");
};
