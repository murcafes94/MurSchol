#pragma once

#include <QObject>
#include <QStringList>

class AppsBackend : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int installedCount READ installedCount NOTIFY changed)
    Q_PROPERTY(QString defaultBrowser READ defaultBrowser NOTIFY changed)
    Q_PROPERTY(QString defaultFileManager READ defaultFileManager NOTIFY changed)
    Q_PROPERTY(QString defaultImageViewer READ defaultImageViewer NOTIFY changed)
    Q_PROPERTY(QString defaultPdfViewer READ defaultPdfViewer NOTIFY changed)
    Q_PROPERTY(bool firefoxAvailable READ firefoxAvailable NOTIFY changed)
    Q_PROPERTY(bool edgeAvailable READ edgeAvailable NOTIFY changed)
    Q_PROPERTY(bool murScholFilesAvailable READ murScholFilesAvailable NOTIFY changed)
    Q_PROPERTY(bool murScholPhotosAvailable READ murScholPhotosAvailable NOTIFY changed)
    Q_PROPERTY(bool flatpakAvailable READ flatpakAvailable NOTIFY changed)
    Q_PROPERTY(bool waydroidAvailable READ waydroidAvailable NOTIFY changed)
    Q_PROPERTY(bool wineAvailable READ wineAvailable NOTIFY changed)
    Q_PROPERTY(bool bottlesAvailable READ bottlesAvailable NOTIFY changed)
    Q_PROPERTY(QString statusText READ statusText NOTIFY changed)

public:
    explicit AppsBackend(QObject *parent = nullptr);

    int installedCount() const { return m_installedCount; }
    QString defaultBrowser() const { return m_defaultBrowser; }
    QString defaultFileManager() const { return m_defaultFileManager; }
    QString defaultImageViewer() const { return m_defaultImageViewer; }
    QString defaultPdfViewer() const { return m_defaultPdfViewer; }

    bool firefoxAvailable() const { return m_firefoxAvailable; }
    bool edgeAvailable() const { return m_edgeAvailable; }
    bool murScholFilesAvailable() const { return m_murScholFilesAvailable; }
    bool murScholPhotosAvailable() const { return m_murScholPhotosAvailable; }
    bool flatpakAvailable() const { return m_flatpakAvailable; }
    bool waydroidAvailable() const { return m_waydroidAvailable; }
    bool wineAvailable() const { return m_wineAvailable; }
    bool bottlesAvailable() const { return m_bottlesAvailable; }
    QString statusText() const { return m_statusText; }

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool useFirefoxAsBrowser();
    Q_INVOKABLE bool useEdgeAsBrowser();
    Q_INVOKABLE bool useMurScholFiles();
    Q_INVOKABLE bool useMurScholPhotos();

signals:
    void changed();

private:
    QString queryDefault(const QString &mime) const;
    QString desktopDisplayName(const QString &desktopId) const;
    bool setMimeDefault(const QString &desktopId, const QStringList &mimes);
    bool desktopExists(const QString &desktopId) const;
    int countDesktopApps() const;
    void setStatus(const QString &text);

    int m_installedCount = 0;
    QString m_defaultBrowser;
    QString m_defaultFileManager;
    QString m_defaultImageViewer;
    QString m_defaultPdfViewer;
    bool m_firefoxAvailable = false;
    bool m_edgeAvailable = false;
    bool m_murScholFilesAvailable = false;
    bool m_murScholPhotosAvailable = false;
    bool m_flatpakAvailable = false;
    bool m_waydroidAvailable = false;
    bool m_wineAvailable = false;
    bool m_bottlesAvailable = false;
    QString m_statusText = QStringLiteral("Preparando aplicaciones…");
};
