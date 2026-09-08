#include "StorageBackend.h"

#include <functional>

#include <QDesktopServices>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QProcess>
#include <QStandardPaths>
#include <QStorageInfo>
#include <QUrl>

namespace {
QString firstMountPoint(const QJsonValue &value)
{
    if (value.isString())
        return value.toString();
    if (!value.isArray())
        return {};

    const QJsonArray entries = value.toArray();
    for (const QJsonValue &entry : entries) {
        const QString path = entry.toString().trimmed();
        if (!path.isEmpty())
            return path;
    }
    return {};
}

bool boolish(const QJsonValue &value)
{
    if (value.isBool())
        return value.toBool();
    if (value.isDouble())
        return value.toInt() != 0;
    const QString text = value.toString().trimmed().toLower();
    return text == QStringLiteral("1") || text == QStringLiteral("true") || text == QStringLiteral("yes");
}
}

StorageBackend::StorageBackend(QObject *parent)
    : QObject(parent)
{
    refresh();
}

QString StorageBackend::formatBytes(quint64 bytes)
{
    static const char *units[] = {"B", "KB", "MB", "GB", "TB", "PB"};
    double value = double(bytes);
    int unit = 0;
    while (value >= 1024.0 && unit < 5) {
        value /= 1024.0;
        ++unit;
    }
    const int decimals = unit == 0 ? 0 : (value >= 100.0 ? 0 : 1);
    return QStringLiteral("%1 %2").arg(QString::number(value, 'f', decimals), QString::fromLatin1(units[unit]));
}

quint64 StorageBackend::directorySize(const QString &path)
{
    QDir dir(path);
    if (!dir.exists())
        return 0;

    quint64 total = 0;
    QDirIterator it(path,
                    QDir::Files | QDir::Hidden | QDir::System | QDir::NoDotAndDotDot,
                    QDirIterator::Subdirectories);
    while (it.hasNext()) {
        it.next();
        const QFileInfo info = it.fileInfo();
        if (!info.isSymLink())
            total += quint64(qMax<qint64>(0, info.size()));
    }
    return total;
}

bool StorageBackend::clearDirectory(const QString &path)
{
    QDir dir(path);
    if (!dir.exists())
        return true;

    bool ok = true;
    const QFileInfoList entries = dir.entryInfoList(QDir::AllEntries | QDir::Hidden | QDir::System | QDir::NoDotAndDotDot);
    for (const QFileInfo &entry : entries) {
        if (entry.isDir() && !entry.isSymLink()) {
            QDir child(entry.absoluteFilePath());
            if (!child.removeRecursively())
                ok = false;
        } else if (!QFile::remove(entry.absoluteFilePath())) {
            ok = false;
        }
    }
    return ok;
}

void StorageBackend::setStatus(const QString &text)
{
    m_statusText = text;
    emit changed();
}

void StorageBackend::refresh()
{
    m_volumes.clear();
    m_udisksAvailable = !QStandardPaths::findExecutable(QStringLiteral("udisksctl")).isEmpty();

    const QStorageInfo root = QStorageInfo::root();
    if (root.isValid() && root.isReady() && root.bytesTotal() > 0) {
        const quint64 total = quint64(root.bytesTotal());
        const quint64 free = quint64(qMax<qint64>(0, root.bytesAvailable()));
        const quint64 used = total > free ? total - free : 0;
        m_rootTotalText = formatBytes(total);
        m_rootUsedText = formatBytes(used);
        m_rootFreeText = formatBytes(free);
        m_rootUsedPercent = total > 0 ? qBound(0, int((100.0 * double(used)) / double(total)), 100) : 0;
    } else {
        m_rootTotalText = m_rootUsedText = m_rootFreeText = QStringLiteral("—");
        m_rootUsedPercent = 0;
    }

    const QString trashBase = QDir::homePath() + QStringLiteral("/.local/share/Trash");
    const quint64 trashBytes = directorySize(trashBase + QStringLiteral("/files"))
                               + directorySize(trashBase + QStringLiteral("/info"));
    m_trashSizeText = formatBytes(trashBytes);

    const QString thumbnails = QDir::homePath() + QStringLiteral("/.cache/thumbnails");
    m_thumbnailsSizeText = formatBytes(directorySize(thumbnails));

    const QString lsblk = QStandardPaths::findExecutable(QStringLiteral("lsblk"));
    if (!lsblk.isEmpty()) {
        QProcess process;
        process.start(lsblk, {
            QStringLiteral("--json"), QStringLiteral("--bytes"),
            QStringLiteral("--output"),
            QStringLiteral("NAME,PATH,TYPE,SIZE,RM,HOTPLUG,FSTYPE,LABEL,MOUNTPOINTS,MODEL,TRAN")
        });

        if (process.waitForStarted(2500) && process.waitForFinished(5000)
            && process.exitStatus() == QProcess::NormalExit && process.exitCode() == 0) {
            const QJsonDocument document = QJsonDocument::fromJson(process.readAllStandardOutput());
            const QJsonArray devices = document.object().value(QStringLiteral("blockdevices")).toArray();

            std::function<void(const QJsonObject &, bool, bool, const QString &, const QString &)> addDevice;
            addDevice = [&](const QJsonObject &object,
                            bool parentRemovable,
                            bool parentHotplug,
                            const QString &parentTransport,
                            const QString &parentModel) {
                const QString type = object.value(QStringLiteral("type")).toString();
                const QString device = object.value(QStringLiteral("path")).toString();
                const QString fstype = object.value(QStringLiteral("fstype")).toString();
                const QString label = object.value(QStringLiteral("label")).toString().trimmed();
                const QString model = object.value(QStringLiteral("model")).toString().trimmed().isEmpty()
                                          ? parentModel
                                          : object.value(QStringLiteral("model")).toString().trimmed();
                const QString transport = object.value(QStringLiteral("tran")).toString().trimmed().isEmpty()
                                              ? parentTransport
                                              : object.value(QStringLiteral("tran")).toString().trimmed();
                const bool removable = parentRemovable || boolish(object.value(QStringLiteral("rm")));
                const bool hotplug = parentHotplug || boolish(object.value(QStringLiteral("hotplug")));
                const QString mountPoint = firstMountPoint(object.value(QStringLiteral("mountpoints")));
                const bool mounted = !mountPoint.isEmpty();
                const bool system = mountPoint == QStringLiteral("/");

                const bool usefulNode = type == QStringLiteral("part")
                                        || type == QStringLiteral("crypt")
                                        || type == QStringLiteral("lvm")
                                        || (type == QStringLiteral("disk") && !fstype.isEmpty());

                if (usefulNode && !device.isEmpty()) {
                    quint64 totalBytes = quint64(qMax<qint64>(0, object.value(QStringLiteral("size")).toVariant().toLongLong()));
                    quint64 freeBytes = 0;
                    quint64 usedBytes = 0;
                    int usedPercent = 0;

                    if (mounted) {
                        QStorageInfo storage(mountPoint);
                        if (storage.isValid() && storage.isReady() && storage.bytesTotal() > 0) {
                            totalBytes = quint64(storage.bytesTotal());
                            freeBytes = quint64(qMax<qint64>(0, storage.bytesAvailable()));
                            usedBytes = totalBytes > freeBytes ? totalBytes - freeBytes : 0;
                            usedPercent = totalBytes > 0
                                              ? qBound(0, int((100.0 * double(usedBytes)) / double(totalBytes)), 100)
                                              : 0;
                        }
                    }

                    const bool external = removable || hotplug || transport == QStringLiteral("usb");
                    QString name;
                    if (system)
                        name = QStringLiteral("Sistema");
                    else if (!label.isEmpty())
                        name = label;
                    else if (!model.isEmpty())
                        name = model;
                    else
                        name = QFileInfo(device).fileName();

                    QVariantMap item;
                    item.insert(QStringLiteral("name"), name);
                    item.insert(QStringLiteral("device"), device);
                    item.insert(QStringLiteral("mountPoint"), mountPoint);
                    item.insert(QStringLiteral("mounted"), mounted);
                    item.insert(QStringLiteral("system"), system);
                    item.insert(QStringLiteral("external"), external);
                    item.insert(QStringLiteral("transport"), transport.isEmpty() ? QStringLiteral("local") : transport);
                    item.insert(QStringLiteral("fileSystem"), fstype.isEmpty() ? QStringLiteral("—") : fstype);
                    item.insert(QStringLiteral("totalText"), formatBytes(totalBytes));
                    item.insert(QStringLiteral("usedText"), mounted ? formatBytes(usedBytes) : QStringLiteral("—"));
                    item.insert(QStringLiteral("freeText"), mounted ? formatBytes(freeBytes) : QStringLiteral("—"));
                    item.insert(QStringLiteral("usedPercent"), usedPercent);
                    item.insert(QStringLiteral("kind"), system ? QStringLiteral("Sistema")
                                                               : (external ? QStringLiteral("Extraíble") : QStringLiteral("Disco interno")));
                    item.insert(QStringLiteral("canMount"), !mounted && m_udisksAvailable);
                    item.insert(QStringLiteral("canUnmount"), mounted && !system && m_udisksAvailable);
                    item.insert(QStringLiteral("canOpen"), mounted);
                    m_volumes.append(item);
                }

                const QJsonArray children = object.value(QStringLiteral("children")).toArray();
                for (const QJsonValue &child : children)
                    addDevice(child.toObject(), removable, hotplug, transport, model);
            };

            for (const QJsonValue &device : devices)
                addDevice(device.toObject(), false, false, {}, {});
        }
    }

    // Respaldo mínimo si lsblk no está disponible o no devolvió volúmenes.
    if (m_volumes.isEmpty()) {
        const auto mountedVolumes = QStorageInfo::mountedVolumes();
        for (const QStorageInfo &storage : mountedVolumes) {
            if (!storage.isValid() || !storage.isReady() || storage.bytesTotal() <= 0)
                continue;
            const QString mountPoint = storage.rootPath();
            if (mountPoint.startsWith(QStringLiteral("/proc"))
                || mountPoint.startsWith(QStringLiteral("/sys"))
                || mountPoint.startsWith(QStringLiteral("/dev")))
                continue;

            const quint64 total = quint64(storage.bytesTotal());
            const quint64 free = quint64(qMax<qint64>(0, storage.bytesAvailable()));
            const quint64 used = total > free ? total - free : 0;
            const bool system = mountPoint == QStringLiteral("/");
            const bool external = mountPoint.startsWith(QStringLiteral("/media/"))
                                  || mountPoint.startsWith(QStringLiteral("/run/media/"));

            QVariantMap item;
            item.insert(QStringLiteral("name"), system ? QStringLiteral("Sistema") : storage.displayName());
            item.insert(QStringLiteral("device"), QString::fromUtf8(storage.device()));
            item.insert(QStringLiteral("mountPoint"), mountPoint);
            item.insert(QStringLiteral("mounted"), true);
            item.insert(QStringLiteral("system"), system);
            item.insert(QStringLiteral("external"), external);
            item.insert(QStringLiteral("transport"), external ? QStringLiteral("extraíble") : QStringLiteral("local"));
            item.insert(QStringLiteral("fileSystem"), QString::fromUtf8(storage.fileSystemType()));
            item.insert(QStringLiteral("totalText"), formatBytes(total));
            item.insert(QStringLiteral("usedText"), formatBytes(used));
            item.insert(QStringLiteral("freeText"), formatBytes(free));
            item.insert(QStringLiteral("usedPercent"), total > 0 ? qBound(0, int((100.0 * double(used)) / double(total)), 100) : 0);
            item.insert(QStringLiteral("kind"), system ? QStringLiteral("Sistema")
                                                       : (external ? QStringLiteral("Extraíble") : QStringLiteral("Disco interno")));
            item.insert(QStringLiteral("canMount"), false);
            item.insert(QStringLiteral("canUnmount"), !system && m_udisksAvailable);
            item.insert(QStringLiteral("canOpen"), true);
            m_volumes.append(item);
        }
    }

    m_statusText = QStringLiteral("%1 volumen(es) detectado(s) · %2 libre en el sistema")
                       .arg(m_volumes.size())
                       .arg(m_rootFreeText);
    emit changed();
}

bool StorageBackend::openPath(const QString &path)
{
    const QString cleaned = path.trimmed();
    if (cleaned.isEmpty() || !QDir(cleaned).exists()) {
        setStatus(QStringLiteral("La ubicación no está montada"));
        return false;
    }

    const bool ok = QDesktopServices::openUrl(QUrl::fromLocalFile(cleaned));
    setStatus(ok ? QStringLiteral("Ubicación abierta") : QStringLiteral("No se pudo abrir la ubicación"));
    return ok;
}

bool StorageBackend::mountDevice(const QString &device)
{
    if (!m_udisksAvailable || !device.startsWith(QStringLiteral("/dev/"))) {
        setStatus(QStringLiteral("Montaje no disponible para este dispositivo"));
        return false;
    }

    QProcess process;
    process.start(QStringLiteral("udisksctl"), {QStringLiteral("mount"), QStringLiteral("-b"), device});
    if (!process.waitForStarted(2500) || !process.waitForFinished(15000)) {
        setStatus(QStringLiteral("No se pudo completar el montaje"));
        return false;
    }

    const bool ok = process.exitStatus() == QProcess::NormalExit && process.exitCode() == 0;
    if (ok) {
        refresh();
        setStatus(QStringLiteral("Dispositivo montado"));
    } else {
        QString error = QString::fromUtf8(process.readAllStandardError()).simplified();
        if (error.isEmpty())
            error = QStringLiteral("No se pudo montar el dispositivo");
        setStatus(error.left(180));
    }
    return ok;
}

bool StorageBackend::unmountDevice(const QString &device)
{
    if (!m_udisksAvailable || !device.startsWith(QStringLiteral("/dev/"))) {
        setStatus(QStringLiteral("Desmontaje no disponible para este dispositivo"));
        return false;
    }

    QProcess process;
    process.start(QStringLiteral("udisksctl"), {QStringLiteral("unmount"), QStringLiteral("-b"), device});
    if (!process.waitForStarted(2500) || !process.waitForFinished(15000)) {
        setStatus(QStringLiteral("No se pudo completar el desmontaje"));
        return false;
    }

    const bool ok = process.exitStatus() == QProcess::NormalExit && process.exitCode() == 0;
    if (ok) {
        refresh();
        setStatus(QStringLiteral("Dispositivo desmontado de forma segura"));
    } else {
        QString error = QString::fromUtf8(process.readAllStandardError()).simplified();
        if (error.isEmpty())
            error = QStringLiteral("No se pudo desmontar el dispositivo");
        setStatus(error.left(180));
    }
    return ok;
}

bool StorageBackend::emptyTrash()
{
    const QString base = QDir::homePath() + QStringLiteral("/.local/share/Trash");
    const bool filesOk = clearDirectory(base + QStringLiteral("/files"));
    const bool infoOk = clearDirectory(base + QStringLiteral("/info"));
    QDir().mkpath(base + QStringLiteral("/files"));
    QDir().mkpath(base + QStringLiteral("/info"));
    refresh();
    setStatus(filesOk && infoOk ? QStringLiteral("Papelera vaciada")
                                : QStringLiteral("Algunos elementos de la papelera no pudieron eliminarse"));
    return filesOk && infoOk;
}

bool StorageBackend::clearThumbnails()
{
    const QString path = QDir::homePath() + QStringLiteral("/.cache/thumbnails");
    const bool ok = clearDirectory(path);
    QDir().mkpath(path);
    refresh();
    setStatus(ok ? QStringLiteral("Miniaturas temporales eliminadas")
                 : QStringLiteral("Algunas miniaturas no pudieron eliminarse"));
    return ok;
}
