#include "AppsBackend.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QSet>
#include <QStandardPaths>
#include <QTextStream>

namespace {
QStringList desktopRoots()
{
    return {
        QDir::homePath() + QStringLiteral("/.local/share/applications"),
        QStringLiteral("/usr/local/share/applications"),
        QStringLiteral("/usr/share/applications")
    };
}

QString runAndRead(const QString &program, const QStringList &arguments)
{
    QProcess process;
    process.start(program, arguments);
    if (!process.waitForStarted(1200))
        return {};
    process.waitForFinished(1800);
    if (process.exitStatus() != QProcess::NormalExit || process.exitCode() != 0)
        return {};
    return QString::fromUtf8(process.readAllStandardOutput()).trimmed();
}
}

AppsBackend::AppsBackend(QObject *parent)
    : QObject(parent)
{
    refresh();
}

bool AppsBackend::desktopExists(const QString &desktopId) const
{
    if (desktopId.trimmed().isEmpty())
        return false;
    for (const QString &root : desktopRoots()) {
        if (QFileInfo::exists(QDir(root).filePath(desktopId)))
            return true;
    }
    return false;
}

QString AppsBackend::desktopDisplayName(const QString &desktopId) const
{
    if (desktopId.trimmed().isEmpty())
        return QStringLiteral("No definido");

    for (const QString &root : desktopRoots()) {
        QFile file(QDir(root).filePath(desktopId));
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
            continue;

        bool inDesktopEntry = false;
        while (!file.atEnd()) {
            const QString line = QString::fromUtf8(file.readLine()).trimmed();
            if (line.startsWith('[')) {
                inDesktopEntry = line == QStringLiteral("[Desktop Entry]");
                continue;
            }
            if (inDesktopEntry && line.startsWith(QStringLiteral("Name=")))
                return line.mid(5).trimmed();
        }
    }

    QString fallback = desktopId;
    if (fallback.endsWith(QStringLiteral(".desktop")))
        fallback.chop(8);
    return fallback;
}

QString AppsBackend::queryDefault(const QString &mime) const
{
    const QString xdgMime = QStandardPaths::findExecutable(QStringLiteral("xdg-mime"));
    if (xdgMime.isEmpty())
        return {};
    return runAndRead(xdgMime, {QStringLiteral("query"), QStringLiteral("default"), mime});
}

int AppsBackend::countDesktopApps() const
{
    QSet<QString> ids;
    for (const QString &root : desktopRoots()) {
        QDir dir(root);
        const QStringList files = dir.entryList({QStringLiteral("*.desktop")}, QDir::Files);
        for (const QString &file : files)
            ids.insert(file.toLower());
    }
    return ids.size();
}

void AppsBackend::setStatus(const QString &text)
{
    m_statusText = text;
    emit changed();
}

void AppsBackend::refresh()
{
    m_installedCount = countDesktopApps();

    const QString browserId = queryDefault(QStringLiteral("x-scheme-handler/https"));
    const QString filesId = queryDefault(QStringLiteral("inode/directory"));
    const QString imageId = queryDefault(QStringLiteral("image/png"));
    const QString pdfId = queryDefault(QStringLiteral("application/pdf"));

    m_defaultBrowser = desktopDisplayName(browserId);
    m_defaultFileManager = desktopDisplayName(filesId);
    m_defaultImageViewer = desktopDisplayName(imageId);
    m_defaultPdfViewer = desktopDisplayName(pdfId);

    m_firefoxAvailable = desktopExists(QStringLiteral("firefox-esr.desktop"))
                         || desktopExists(QStringLiteral("firefox.desktop"));
    m_edgeAvailable = desktopExists(QStringLiteral("microsoft-edge.desktop"))
                      || desktopExists(QStringLiteral("microsoft-edge-stable.desktop"))
                      || desktopExists(QStringLiteral("murschol-edge.desktop"));
    m_murScholFilesAvailable = desktopExists(QStringLiteral("murschol-files.desktop"));
    m_murScholPhotosAvailable = desktopExists(QStringLiteral("murschol-photos.desktop"));

    m_flatpakAvailable = !QStandardPaths::findExecutable(QStringLiteral("flatpak")).isEmpty();
    m_waydroidAvailable = !QStandardPaths::findExecutable(QStringLiteral("waydroid")).isEmpty();
    m_wineAvailable = !QStandardPaths::findExecutable(QStringLiteral("wine")).isEmpty();

    const bool nativeBottles = !QStandardPaths::findExecutable(QStringLiteral("bottles")).isEmpty();
    const bool userBottles = QFileInfo::exists(QDir::homePath() + QStringLiteral("/.local/share/flatpak/app/com.usebottles.bottles"));
    const bool systemBottles = QFileInfo::exists(QStringLiteral("/var/lib/flatpak/app/com.usebottles.bottles"));
    m_bottlesAvailable = nativeBottles || userBottles || systemBottles;

    m_statusText = QStringLiteral("%1 aplicaciones detectadas").arg(m_installedCount);
    emit changed();
}

bool AppsBackend::setMimeDefault(const QString &desktopId, const QStringList &mimes)
{
    if (!desktopExists(desktopId)) {
        setStatus(QStringLiteral("La aplicación seleccionada no está instalada"));
        return false;
    }

    const QString xdgMime = QStandardPaths::findExecutable(QStringLiteral("xdg-mime"));
    if (xdgMime.isEmpty()) {
        setStatus(QStringLiteral("xdg-mime no está disponible"));
        return false;
    }

    bool ok = true;
    for (const QString &mime : mimes) {
        QProcess process;
        process.start(xdgMime, {QStringLiteral("default"), desktopId, mime});
        if (!process.waitForStarted(1200) || !process.waitForFinished(1800)
            || process.exitStatus() != QProcess::NormalExit || process.exitCode() != 0) {
            ok = false;
            break;
        }
    }

    if (ok) {
        setStatus(QStringLiteral("Aplicación predeterminada actualizada"));
        refresh();
    } else {
        setStatus(QStringLiteral("No se pudo cambiar la aplicación predeterminada"));
    }
    return ok;
}

bool AppsBackend::useFirefoxAsBrowser()
{
    QString id;
    if (desktopExists(QStringLiteral("firefox-esr.desktop")))
        id = QStringLiteral("firefox-esr.desktop");
    else if (desktopExists(QStringLiteral("firefox.desktop")))
        id = QStringLiteral("firefox.desktop");
    if (id.isEmpty()) {
        setStatus(QStringLiteral("Firefox no está instalado"));
        return false;
    }
    return setMimeDefault(id, {
        QStringLiteral("x-scheme-handler/http"),
        QStringLiteral("x-scheme-handler/https"),
        QStringLiteral("text/html")
    });
}

bool AppsBackend::useEdgeAsBrowser()
{
    QString id;
    if (desktopExists(QStringLiteral("microsoft-edge-stable.desktop")))
        id = QStringLiteral("microsoft-edge-stable.desktop");
    else if (desktopExists(QStringLiteral("microsoft-edge.desktop")))
        id = QStringLiteral("microsoft-edge.desktop");
    else if (desktopExists(QStringLiteral("murschol-edge.desktop")))
        id = QStringLiteral("murschol-edge.desktop");
    if (id.isEmpty()) {
        setStatus(QStringLiteral("Microsoft Edge no está disponible"));
        return false;
    }
    return setMimeDefault(id, {
        QStringLiteral("x-scheme-handler/http"),
        QStringLiteral("x-scheme-handler/https"),
        QStringLiteral("text/html")
    });
}

bool AppsBackend::useMurScholFiles()
{
    return setMimeDefault(QStringLiteral("murschol-files.desktop"), {QStringLiteral("inode/directory")});
}

bool AppsBackend::useMurScholPhotos()
{
    return setMimeDefault(QStringLiteral("murschol-photos.desktop"), {
        QStringLiteral("image/png"),
        QStringLiteral("image/jpeg"),
        QStringLiteral("image/webp"),
        QStringLiteral("image/gif"),
        QStringLiteral("image/svg+xml")
    });
}
