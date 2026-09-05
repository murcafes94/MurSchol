#include "UniversalSearchModel.h"

#include <algorithm>
#include <utility>

#include <QDesktopServices>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QRegularExpression>
#include <QSet>
#include <QStandardPaths>
#include <QUrl>
#include <QUrlQuery>

namespace {
MurScholSearchApp parseDesktopFile(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};

    MurScholSearchApp app;
    bool inDesktopEntry = false;
    bool applicationType = false;
    bool hidden = false;

    while (!file.atEnd()) {
        const QString line = QString::fromUtf8(file.readLine()).trimmed();
        if (line.startsWith('[')) {
            inDesktopEntry = (line == QStringLiteral("[Desktop Entry]"));
            continue;
        }
        if (!inDesktopEntry || line.startsWith('#'))
            continue;

        const int equal = line.indexOf('=');
        if (equal < 1)
            continue;
        const QString key = line.left(equal);
        const QString value = line.mid(equal + 1);

        if (key == QStringLiteral("Name") && app.name.isEmpty())
            app.name = value;
        else if (key == QStringLiteral("Exec"))
            app.exec = value;
        else if (key == QStringLiteral("Icon"))
            app.icon = value;
        else if (key == QStringLiteral("Type"))
            applicationType = value == QStringLiteral("Application");
        else if ((key == QStringLiteral("NoDisplay") || key == QStringLiteral("Hidden"))
                 && value.compare(QStringLiteral("true"), Qt::CaseInsensitive) == 0)
            hidden = true;
    }

    if (!applicationType || hidden || app.name.isEmpty() || app.exec.isEmpty())
        return {};
    return app;
}

bool betterMatch(const MurScholSearchEntry &a, const MurScholSearchEntry &b, const QString &needle)
{
    const bool aStarts = a.title.startsWith(needle, Qt::CaseInsensitive);
    const bool bStarts = b.title.startsWith(needle, Qt::CaseInsensitive);
    if (aStarts != bStarts)
        return aStarts;

    const auto priority = [](const QString &kind) {
        if (kind == QStringLiteral("Aplicación")) return 0;
        if (kind == QStringLiteral("Documento")) return 1;
        return 2;
    };
    if (priority(a.kind) != priority(b.kind))
        return priority(a.kind) < priority(b.kind);
    return a.title.localeAwareCompare(b.title) < 0;
}
}

UniversalSearchModel::UniversalSearchModel(QObject *parent)
    : QAbstractListModel(parent)
{
    refreshIndexes();
}

int UniversalSearchModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_results.size();
}

QVariant UniversalSearchModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_results.size())
        return {};

    const auto &entry = m_results.at(index.row());
    switch (role) {
    case TitleRole: return entry.title;
    case SubtitleRole: return entry.subtitle;
    case KindRole: return entry.kind;
    case IconRole: return entry.icon;
    default: return {};
    }
}

QHash<int, QByteArray> UniversalSearchModel::roleNames() const
{
    return {
        {TitleRole, "resultTitle"},
        {SubtitleRole, "resultSubtitle"},
        {KindRole, "resultKind"},
        {IconRole, "resultIcon"}
    };
}

void UniversalSearchModel::setQuery(const QString &query)
{
    const QString normalized = query.trimmed();
    if (m_query == normalized)
        return;

    m_query = normalized;
    emit queryChanged();
    rebuild();
}

QString UniversalSearchModel::cleanExec(QString command)
{
    command.remove(QRegularExpression(QStringLiteral("\\s+%[fFuUdDnNickvm]")));
    command.remove(QRegularExpression(QStringLiteral("%[fFuUdDnNickvm]")));
    return command.trimmed();
}

void UniversalSearchModel::refreshIndexes()
{
    indexApplications();
    indexFiles();
    rebuild();
}

void UniversalSearchModel::indexApplications()
{
    m_apps.clear();
    QSet<QString> known;
    const QStringList roots = {
        QStringLiteral("/usr/share/applications"),
        QStringLiteral("/usr/local/share/applications"),
        QDir::homePath() + QStringLiteral("/.local/share/applications")
    };

    for (const QString &root : roots) {
        const QDir dir(root);
        const QStringList files = dir.entryList({QStringLiteral("*.desktop")}, QDir::Files);
        for (const QString &fileName : files) {
            auto app = parseDesktopFile(dir.absoluteFilePath(fileName));
            app.exec = cleanExec(app.exec);
            const QString key = app.name.toLower();
            if (!app.name.isEmpty() && !app.exec.isEmpty() && !known.contains(key)) {
                known.insert(key);
                m_apps.append(app);
            }
        }
    }
}

void UniversalSearchModel::indexFiles()
{
    m_files.clear();
    QSet<QString> known;
    int indexed = 0;
    constexpr int maxIndexedFiles = 3000;

    QStringList roots;
    for (const QStandardPaths::StandardLocation location : {QStandardPaths::DesktopLocation, QStandardPaths::DocumentsLocation, QStandardPaths::DownloadLocation}) {
        const QString path = QStandardPaths::writableLocation(location);
        if (!path.isEmpty() && !roots.contains(path))
            roots.append(path);
    }

    for (const QString &rootPath : roots) {
        QDir root(rootPath);
        if (!root.exists())
            continue;

        auto addFiles = [&](const QDir &dir) {
            const QFileInfoList infos = dir.entryInfoList(QDir::Files | QDir::NoDotAndDotDot, QDir::Name | QDir::IgnoreCase);
            for (const QFileInfo &info : infos) {
                const QString absolute = info.absoluteFilePath();
                if (!known.contains(absolute)) {
                    known.insert(absolute);
                    m_files.append(absolute);
                    if (++indexed >= maxIndexedFiles)
                        return false;
                }
            }
            return true;
        };

        if (!addFiles(root))
            return;

        const QFileInfoList folders = root.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name | QDir::IgnoreCase);
        for (const QFileInfo &folder : folders) {
            if (!addFiles(QDir(folder.absoluteFilePath())))
                return;
        }
    }
}

void UniversalSearchModel::appendMatchingActions(const QString &needle, QList<MurScholSearchEntry> &results) const
{
    struct StaticAction { const char *title; const char *subtitle; const char *type; const char *action; };
    const StaticAction actions[] = {
        {"Abrir Archivos", "Carpeta personal", "open", "home"},
        {"Abrir Documentos", "Carpeta Documentos", "open", "documents"},
        {"Abrir Descargas", "Carpeta Descargas", "open", "downloads"},
        {"Abrir Terminal", "Herramienta del sistema", "terminal", ""}
    };

    for (const auto &action : actions) {
        const QString title = QString::fromUtf8(action.title);
        const QString subtitle = QString::fromUtf8(action.subtitle);
        if (title.contains(needle, Qt::CaseInsensitive) || subtitle.contains(needle, Qt::CaseInsensitive)) {
            results.append({title, subtitle, QStringLiteral("Acción"), QString(), QString::fromLatin1(action.type), QString::fromLatin1(action.action)});
        }
    }

    QUrl searchUrl(QStringLiteral("https://www.google.com/search"));
    QUrlQuery parameters;
    parameters.addQueryItem(QStringLiteral("q"), m_query);
    searchUrl.setQuery(parameters);
    results.append({
        QStringLiteral("Buscar “%1” en Internet").arg(m_query),
        QStringLiteral("Abrir en el navegador predeterminado"),
        QStringLiteral("Acción"),
        QString(),
        QStringLiteral("url"),
        searchUrl.toString()
    });
}

void UniversalSearchModel::rebuild()
{
    beginResetModel();
    m_results.clear();

    if (m_query.size() >= 2) {
        const QString needle = m_query;

        int appMatches = 0;
        for (const auto &app : std::as_const(m_apps)) {
            if (!app.name.contains(needle, Qt::CaseInsensitive))
                continue;
            m_results.append({app.name, QStringLiteral("Aplicación Linux"), QStringLiteral("Aplicación"), app.icon, QStringLiteral("exec"), app.exec});
            if (++appMatches >= 12)
                break;
        }

        int fileMatches = 0;
        for (const QString &path : std::as_const(m_files)) {
            const QFileInfo info(path);
            if (!info.fileName().contains(needle, Qt::CaseInsensitive))
                continue;
            m_results.append({info.fileName(), info.absolutePath(), QStringLiteral("Documento"), QString(), QStringLiteral("file"), path});
            if (++fileMatches >= 12)
                break;
        }

        appendMatchingActions(needle, m_results);

        std::stable_sort(m_results.begin(), m_results.end(), [&](const auto &a, const auto &b) {
            return betterMatch(a, b, needle);
        });

        if (m_results.size() > 30)
            m_results = m_results.mid(0, 30);
    }

    endResetModel();
    emit countChanged();
}

bool UniversalSearchModel::activate(int row) const
{
    if (row < 0 || row >= m_results.size())
        return false;

    const auto &entry = m_results.at(row);
    if (entry.actionType == QStringLiteral("exec")) {
        QStringList parts = QProcess::splitCommand(entry.action);
        if (parts.isEmpty())
            return false;
        const QString program = parts.takeFirst();
        return QProcess::startDetached(program, parts);
    }

    if (entry.actionType == QStringLiteral("file"))
        return QDesktopServices::openUrl(QUrl::fromLocalFile(entry.action));

    if (entry.actionType == QStringLiteral("url"))
        return QDesktopServices::openUrl(QUrl(entry.action));

    if (entry.actionType == QStringLiteral("open")) {
        QString path = QDir::homePath();
        if (entry.action == QStringLiteral("documents"))
            path = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
        else if (entry.action == QStringLiteral("downloads"))
            path = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
        if (path.isEmpty())
            path = QDir::homePath();
        return QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    }

    if (entry.actionType == QStringLiteral("terminal")) {
        const QStringList terminals = {
            QStringLiteral("foot"), QStringLiteral("kgx"), QStringLiteral("konsole"),
            QStringLiteral("gnome-terminal"), QStringLiteral("xfce4-terminal"), QStringLiteral("xterm")
        };
        for (const QString &terminal : terminals) {
            const QString executable = QStandardPaths::findExecutable(terminal);
            if (!executable.isEmpty())
                return QProcess::startDetached(executable);
        }
    }

    return false;
}
