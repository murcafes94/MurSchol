#pragma once
#include <QObject>
#include <QSettings>
#include <QUrl>
#include <QVariantList>

// Reading metadata only: this class never writes to or removes a document.
class ReadingStore : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList recentDocuments READ recentDocuments NOTIFY changed)
public:
    explicit ReadingStore(QObject *parent = nullptr);
    QVariantList recentDocuments() const;
    Q_INVOKABLE QVariantMap state(const QUrl &url) const;
    Q_INVOKABLE void remember(const QUrl &url, int page, double zoom);
    Q_INVOKABLE QVariantList bookmarks(const QUrl &url) const;
    Q_INVOKABLE void toggleBookmark(const QUrl &url, int page);
    Q_INVOKABLE void forget(const QUrl &url);
    Q_INVOKABLE QUrl localDocument(const QUrl &url) const;
signals:
    void changed();
    void storageError(const QString &message);
private:
    QString key(const QUrl &url) const;
    void sync();
    QSettings settings;
};
