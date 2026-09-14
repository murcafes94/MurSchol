#include "AppIndexModel.h"

#include <algorithm>
#include <utility>

#include <QDateTime>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QLocale>
#include <QProcess>
#include <QRegularExpression>
#include <QSettings>
#include <QStandardPaths>

namespace {
bool containsDesktopName(const QString &list, const QString &name)
{
    const QStringList values = list.split(';', Qt::SkipEmptyParts);
    for (const QString &value : values) {
        if (value.trimmed().compare(name, Qt::CaseInsensitive) == 0)
            return true;
    }
    return false;
}

bool localeMatches(const QString &desktopLocale)
{
    QString candidate = desktopLocale.trimmed();
    candidate.replace('_', '-');
    candidate = candidate.toLower();

    for (QString language : QLocale::system().uiLanguages()) {
        language.replace('_', '-');
        language = language.toLower();
        if (candidate == language
            || language.startsWith(candidate + '-')
            || candidate.startsWith(language + '-')) {
            return true;
        }
    }
    return false;
}
}

AppIndexModel::AppIndexModel(QObject *parent) : QAbstractListModel(parent)
{
    loadState();
    refresh();
}

int AppIndexModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_visible.size();
}

QVariant AppIndexModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_visible.size())
        return {};

    const auto &app = m_visible.at(index.row());
    switch (role) {
    case NameRole: return app.name;
    case ExecRole: return app.exec;
    case IconRole: return app.icon;
    case SourceRole: return app.source;
    case CategoriesRole: return app.categories;
    case IdRole: return app.id;
    case PinnedRole: return app.pinned;
    case LastUsedRole: return app.lastUsed;
    default: return {};
    }
}

QHash<int, QByteArray> AppIndexModel::roleNames() const
{
    return {
        {NameRole, "appName"},
        {ExecRole, "appExec"},
        {IconRole, "iconName"},
        {SourceRole, "appSource"},
        {CategoriesRole, "appCategories"},
        {IdRole, "appId"},
        {PinnedRole, "appPinned"},
        {LastUsedRole, "appLastUsed"}
    };
}

void AppIndexModel::setFilter(const QString &filter)
{
    if (m_filter == filter)
        return;
    m_filter = filter;
    emit filterChanged();
    rebuildVisible();
}

void AppIndexModel::setCategoryFilter(const QString &category)
{
    const QString normalized = category.trimmed().isEmpty() ? QStringLiteral("Todas") : category.trimmed();
    if (m_categoryFilter == normalized)
        return;
    m_categoryFilter = normalized;
    emit categoryFilterChanged();
    rebuildVisible();
}

int AppIndexModel::pinnedCount() const
{
    return static_cast<int>(std::count_if(m_all.cbegin(), m_all.cend(), [](const MurScholAppEntry &app) {
        return app.pinned;
    }));
}

int AppIndexModel::recentCount() const
{
    return static_cast<int>(std::count_if(m_all.cbegin(), m_all.cend(), [](const MurScholAppEntry &app) {
        return app.lastUsed > 0;
    }));
}

QString AppIndexModel::stateFilePath() const
{
    QString configRoot = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    if (configRoot.isEmpty())
        configRoot = QDir::homePath() + QStringLiteral("/.config");
    return configRoot + QStringLiteral("/murschol/start.ini");
}

void AppIndexModel::loadState()
{
    m_pinnedIds.clear();
    m_lastUsed.clear();

    QSettings settings(stateFilePath(), QSettings::IniFormat);
    const QStringList pinned = settings.value(QStringLiteral("pinned/apps")).toStringList();
    for (const QString &id : pinned) {
        if (!id.trimmed().isEmpty())
            m_pinnedIds.insert(id.trimmed());
    }

    settings.beginGroup(QStringLiteral("recent"));
    for (const QString &id : settings.childKeys()) {
        const qint64 timestamp = settings.value(id).toLongLong();
        if (timestamp > 0)
            m_lastUsed.insert(id, timestamp);
    }
    settings.endGroup();
}

void AppIndexModel::savePinnedState() const
{
    const QString path = stateFilePath();
    QDir().mkpath(QFileInfo(path).absolutePath());

    QStringList pinned;
    pinned.reserve(m_pinnedIds.size());
    for (const QString &id : m_pinnedIds)
        pinned.append(id);
    pinned.sort(Qt::CaseInsensitive);

    QSettings settings(path, QSettings::IniFormat);
    settings.setValue(QStringLiteral("pinned/apps"), pinned);
    settings.sync();
}

void AppIndexModel::recordRecent(const QString &id)
{
    if (id.isEmpty())
        return;

    m_lastUsed.insert(id, QDateTime::currentSecsSinceEpoch());

    QList<QPair<QString, qint64>> ordered;
    ordered.reserve(m_lastUsed.size());
    for (auto it = m_lastUsed.cbegin(); it != m_lastUsed.cend(); ++it)
        ordered.append(qMakePair(it.key(), it.value()));

    std::sort(ordered.begin(), ordered.end(), [](const auto &a, const auto &b) {
        return a.second > b.second;
    });

    while (ordered.size() > 20) {
        m_lastUsed.remove(ordered.constLast().first);
        ordered.removeLast();
    }

    for (auto &app : m_all)
        app.lastUsed = m_lastUsed.value(app.id, 0);

    const QString path = stateFilePath();
    QDir().mkpath(QFileInfo(path).absolutePath());
    QSettings settings(path, QSettings::IniFormat);
    settings.beginGroup(QStringLiteral("recent"));
    settings.remove(QString());
    for (auto it = m_lastUsed.cbegin(); it != m_lastUsed.cend(); ++it)
        settings.setValue(it.key(), it.value());
    settings.endGroup();
    settings.sync();

    rebuildVisible();
    emit stateChanged();
}

MurScholAppEntry AppIndexModel::parseDesktopFile(const QString &path, const QString &id)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};

    MurScholAppEntry entry;
    entry.id = id;
    bool inDesktopEntry = false;
    bool applicationType = false;
    bool noDisplay = false;
    QString genericName;
    QString localizedName;

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

        if (key == QStringLiteral("Name")) {
            genericName = value;
        } else if (key.startsWith(QStringLiteral("Name[")) && key.endsWith(']')) {
            const QString locale = key.mid(5, key.size() - 6);
            if (localeMatches(locale))
                localizedName = value;
        } else if (key == QStringLiteral("Exec")) {
            entry.exec = value;
        } else if (key == QStringLiteral("TryExec")) {
            entry.tryExec = value.trimmed();
        } else if (key == QStringLiteral("Icon")) {
            entry.icon = value;
        } else if (key == QStringLiteral("Categories")) {
            entry.categories = value;
        } else if (key == QStringLiteral("OnlyShowIn")) {
            entry.onlyShowIn = value;
        } else if (key == QStringLiteral("NotShowIn")) {
            entry.notShowIn = value;
        } else if (key == QStringLiteral("Type")) {
            applicationType = (value == QStringLiteral("Application"));
        } else if (key == QStringLiteral("Terminal")) {
            entry.terminal = value.compare(QStringLiteral("true"), Qt::CaseInsensitive) == 0;
        } else if (key == QStringLiteral("Hidden")) {
            entry.hidden = value.compare(QStringLiteral("true"), Qt::CaseInsensitive) == 0;
        } else if (key == QStringLiteral("NoDisplay")) {
            noDisplay = value.compare(QStringLiteral("true"), Qt::CaseInsensitive) == 0;
        }
    }

    entry.hidden = entry.hidden || noDisplay;
    entry.valid = applicationType || entry.hidden;
    entry.name = localizedName.isEmpty() ? genericName : localizedName;

    if (!entry.valid)
        return entry;
    if (!entry.hidden && (entry.name.isEmpty() || entry.exec.isEmpty())) {
        entry.valid = false;
        return entry;
    }

    entry.exec = cleanExec(entry.exec);
    if (path.contains(QStringLiteral("/flatpak/")))
        entry.source = QStringLiteral("Flatpak");
    else if (path.startsWith(QDir::homePath()))
        entry.source = QStringLiteral("Usuario");
    else
        entry.source = QStringLiteral("Linux");
    return entry;
}

QString AppIndexModel::cleanExec(QString command)
{
    // Los códigos de campo se expanden cuando una aplicación se abre con un
    // archivo/URL. Desde Inicio no existe ese argumento, por lo que se eliminan.
    command.remove(QRegularExpression(QStringLiteral("\\s+%[fFuUdDnNickvm]")));
    command.remove(QRegularExpression(QStringLiteral("%[fFuUdDnNickvm]")));
    return command.trimmed();
}

bool AppIndexModel::entryVisibleForMurSchol(const MurScholAppEntry &entry)
{
    if (!entry.valid || entry.hidden)
        return false;
    if (!entry.onlyShowIn.trimmed().isEmpty()
        && !containsDesktopName(entry.onlyShowIn, QStringLiteral("MurSchol"))) {
        return false;
    }
    if (containsDesktopName(entry.notShowIn, QStringLiteral("MurSchol")))
        return false;
    return true;
}

bool AppIndexModel::tryExecAvailable(const QString &tryExec)
{
    const QString command = tryExec.trimmed();
    if (command.isEmpty())
        return true;
    if (QFileInfo(command).isAbsolute())
        return QFileInfo(command).isExecutable();
    return !QStandardPaths::findExecutable(command).isEmpty();
}

bool AppIndexModel::matchesCategory(const MurScholAppEntry &app, const QString &category)
{
    if (category.isEmpty() || category == QStringLiteral("Todas"))
        return true;

    const QString cats = app.categories.toLower();
    const QString name = app.name.toLower();

    if (category == QStringLiteral("Educación"))
        return cats.contains(QStringLiteral("education"))
               || name.contains(QStringLiteral("moodle"))
               || name.contains(QStringLiteral("biblioteca"))
               || name.contains(QStringLiteral("notcan"));
    if (category == QStringLiteral("Productividad"))
        return cats.contains(QStringLiteral("office"))
               || cats.contains(QStringLiteral("utility"))
               || cats.contains(QStringLiteral("texteditor"))
               || cats.contains(QStringLiteral("development"));
    if (category == QStringLiteral("Multimedia"))
        return cats.contains(QStringLiteral("audiovideo"))
               || cats.contains(QStringLiteral("audio"))
               || cats.contains(QStringLiteral("video"))
               || cats.contains(QStringLiteral("graphics"));
    if (category == QStringLiteral("Internet"))
        return cats.contains(QStringLiteral("network"))
               || cats.contains(QStringLiteral("webbrowser"))
               || cats.contains(QStringLiteral("email"));
    if (category == QStringLiteral("Sistema"))
        return cats.contains(QStringLiteral("system"))
               || cats.contains(QStringLiteral("settings"));
    if (category == QStringLiteral("Accesibilidad"))
        return cats.contains(QStringLiteral("accessibility"));

    return true;
}

void AppIndexModel::refresh()
{
    QList<MurScholAppEntry> discovered;
    QSet<QString> claimedIds;
    QSet<QString> visibleNames;
    QStringList roots;

    const QString userData = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    if (!userData.isEmpty())
        roots << QDir(userData).filePath(QStringLiteral("applications"));

    // Flatpak no siempre aparece en XDG_DATA_DIRS al arrancar una sesión mínima.
    roots << QDir::homePath() + QStringLiteral("/.local/share/flatpak/exports/share/applications");

    QString dataDirs = qEnvironmentVariable("XDG_DATA_DIRS");
    if (dataDirs.trimmed().isEmpty())
        dataDirs = QStringLiteral("/usr/local/share:/usr/share");
    for (const QString &dataDir : dataDirs.split(':', Qt::SkipEmptyParts))
        roots << QDir(dataDir).filePath(QStringLiteral("applications"));

    roots << QStringLiteral("/var/lib/flatpak/exports/share/applications");
    roots.removeDuplicates();

    // XDG da prioridad al primer directorio de datos. Un desktop Hidden/NoDisplay
    // de usuario debe poder ocultar la copia del sistema con el mismo ID.
    for (const QString &root : std::as_const(roots)) {
        QDir rootDir(root);
        if (!rootDir.exists())
            continue;

        QDirIterator it(root, {QStringLiteral("*.desktop")}, QDir::Files,
                        QDirIterator::Subdirectories);
        while (it.hasNext()) {
            const QString path = it.next();
            QString relative = rootDir.relativeFilePath(path);
            relative.replace('/', '-');
            const QString id = relative;
            if (id.isEmpty() || claimedIds.contains(id))
                continue;

            auto entry = parseDesktopFile(path, id);
            if (!entry.valid)
                continue;

            claimedIds.insert(id);
            if (!entryVisibleForMurSchol(entry) || !tryExecAvailable(entry.tryExec))
                continue;

            // Evita tarjetas duplicadas con el mismo nombre visible, conservando
            // la entrada de mayor prioridad XDG.
            const QString normalizedName = entry.name.toCaseFolded();
            if (visibleNames.contains(normalizedName))
                continue;
            visibleNames.insert(normalizedName);

            entry.pinned = m_pinnedIds.contains(entry.id);
            entry.lastUsed = m_lastUsed.value(entry.id, 0);
            discovered.append(entry);
        }
    }

    std::sort(discovered.begin(), discovered.end(), [](const auto &a, const auto &b) {
        return a.name.localeAwareCompare(b.name) < 0;
    });

    m_all = discovered;
    rebuildVisible();
    emit stateChanged();
}

void AppIndexModel::rebuildVisible()
{
    beginResetModel();
    m_visible.clear();

    for (const auto &app : std::as_const(m_all)) {
        const bool textMatch = m_filter.isEmpty()
                               || app.name.contains(m_filter, Qt::CaseInsensitive);
        if (!textMatch)
            continue;

        bool categoryMatch = false;
        if (m_categoryFilter == QStringLiteral("Fijadas"))
            categoryMatch = app.pinned;
        else if (m_categoryFilter == QStringLiteral("Recientes"))
            categoryMatch = app.lastUsed > 0;
        else
            categoryMatch = matchesCategory(app, m_categoryFilter);

        if (categoryMatch)
            m_visible.append(app);
    }

    if (m_categoryFilter == QStringLiteral("Recientes")) {
        std::sort(m_visible.begin(), m_visible.end(), [](const auto &a, const auto &b) {
            if (a.lastUsed == b.lastUsed)
                return a.name.localeAwareCompare(b.name) < 0;
            return a.lastUsed > b.lastUsed;
        });
        while (m_visible.size() > 12)
            m_visible.removeLast();
    }

    endResetModel();
    emit countChanged();
}

bool AppIndexModel::launch(int row)
{
    if (row < 0 || row >= m_visible.size())
        return false;

    const auto entry = m_visible.at(row);
    const QStringList parts = QProcess::splitCommand(entry.exec);
    if (parts.isEmpty())
        return false;

    QStringList args = parts;
    QString program = args.takeFirst();

    // Las aplicaciones con Terminal=true no deben lanzarse sin una ventana
    // visible. Foot es la terminal nativa de MurSchol; xterm queda de respaldo.
    if (entry.terminal) {
        QString terminal = QStandardPaths::findExecutable(QStringLiteral("foot"));
        if (!terminal.isEmpty()) {
            QStringList terminalArgs { QStringLiteral("--"), program };
            terminalArgs.append(args);
            program = terminal;
            args = terminalArgs;
        } else {
            terminal = QStandardPaths::findExecutable(QStringLiteral("xterm"));
            if (terminal.isEmpty())
                return false;
            QStringList terminalArgs { QStringLiteral("-e"), program };
            terminalArgs.append(args);
            program = terminal;
            args = terminalArgs;
        }
    }

    bool started = false;
    const QString diagnosticLauncher = QStandardPaths::findExecutable(QStringLiteral("murschol-launch"));
    if (!diagnosticLauncher.isEmpty()) {
        QStringList launchArgs;
        launchArgs << entry.name << QStringLiteral("--") << program;
        launchArgs.append(args);
        started = QProcess::startDetached(diagnosticLauncher, launchArgs);
    } else {
        started = QProcess::startDetached(program, args);
    }

    if (started)
        recordRecent(entry.id);
    return started;
}

void AppIndexModel::togglePinned(int row)
{
    if (row < 0 || row >= m_visible.size())
        return;

    const QString id = m_visible.at(row).id;
    if (id.isEmpty())
        return;

    if (m_pinnedIds.contains(id))
        m_pinnedIds.remove(id);
    else
        m_pinnedIds.insert(id);

    for (auto &app : m_all)
        app.pinned = m_pinnedIds.contains(app.id);

    savePinnedState();
    rebuildVisible();
    emit stateChanged();
}

void AppIndexModel::clearRecent()
{
    if (m_lastUsed.isEmpty())
        return;

    m_lastUsed.clear();
    for (auto &app : m_all)
        app.lastUsed = 0;

    QSettings settings(stateFilePath(), QSettings::IniFormat);
    settings.remove(QStringLiteral("recent"));
    settings.sync();

    rebuildVisible();
    emit stateChanged();
}
