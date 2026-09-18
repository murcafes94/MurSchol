#include "ReadingStore.h"
#include <QCryptographicHash>
#include <QFileInfo>
#include <algorithm>
#include <cmath>

ReadingStore::ReadingStore(QObject *parent) : QObject(parent) {}

QUrl ReadingStore::localDocument(const QUrl &url) const {
    if (!url.isLocalFile()) return {};
    const QFileInfo file(url.toLocalFile());
    if (!file.isFile() || !file.isReadable()) return {};
    return QUrl::fromLocalFile(file.canonicalFilePath());
}

QString ReadingStore::key(const QUrl &url) const {
    return QString::fromLatin1(QCryptographicHash::hash(url.toEncoded(), QCryptographicHash::Sha256).toHex());
}

QVariantMap ReadingStore::state(const QUrl &url) const {
    return settings.value("documents/" + key(url)).toMap();
}

QVariantList ReadingStore::recentDocuments() const {
    QVariantList result;
    const auto urls = settings.value("recents").toStringList();
    for (const auto &url : urls) {
        auto item = state(QUrl(url));
        item.insert("url", url);
        item.insert("title", QFileInfo(QUrl(url).toLocalFile()).fileName());
        item.insert("available", !localDocument(QUrl(url)).isEmpty());
        result.append(item);
    }
    return result;
}

void ReadingStore::sync() {
    settings.sync();
    if (settings.status() != QSettings::NoError)
        emit storageError(tr("No se pudo guardar el historial de lectura. Comprueba el espacio y los permisos de tu carpeta de configuración."));
    emit changed();
}

void ReadingStore::remember(const QUrl &url, int page, double zoom) {
    if (!url.isLocalFile() || page < 0 || !std::isfinite(zoom)) return;
    auto item = state(url);
    item.insert("page", page);
    item.insert("zoom", std::clamp(zoom, 0.4, 3.0));
    settings.setValue("documents/" + key(url), item);
    auto urls = settings.value("recents").toStringList();
    urls.removeAll(url.toString());
    urls.prepend(url.toString());
    while (urls.size() > 20) urls.removeLast();
    settings.setValue("recents", urls);
    sync();
}

QVariantList ReadingStore::bookmarks(const QUrl &url) const {
    return state(url).value("bookmarks").toList();
}

void ReadingStore::toggleBookmark(const QUrl &url, int page) {
    if (!url.isLocalFile() || page < 0) return;
    auto item = state(url);
    auto marks = bookmarks(url);
    const QVariant value(page);
    if (marks.contains(value)) marks.removeAll(value);
    else marks.append(value);
    std::sort(marks.begin(), marks.end(), [](const QVariant &a, const QVariant &b) { return a.toInt() < b.toInt(); });
    item.insert("bookmarks", marks);
    settings.setValue("documents/" + key(url), item);
    sync();
}

void ReadingStore::forget(const QUrl &url) {
    auto urls = settings.value("recents").toStringList();
    urls.removeAll(url.toString());
    settings.setValue("recents", urls);
    // Forgetting a recent entry preserves its bookmarks and last reading position.
    sync();
}
