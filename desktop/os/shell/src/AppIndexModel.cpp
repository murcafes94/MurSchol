#include "AppIndexModel.h"

#include <algorithm>
#include <utility>

#include <QDir>
#include <QFile>
#include <QProcess>
#include <QRegularExpression>
#include <QSet>

AppIndexModel::AppIndexModel(QObject *parent) : QAbstractListModel(parent)
{
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
        {CategoriesRole, "appCategories"}
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

MurScholAppEntry AppIndexModel::parseDesktopFile(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};

    MurScholAppEntry entry;
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
        if (key == QStringLiteral("Name") && entry.name.isEmpty()) entry.name = value;
        else if (key == QStringLiteral("Exec")) entry.exec = value;
        else if (key == QStringLiteral("Icon")) entry.icon = value;
        else if (key == QStringLiteral("Categories")) entry.categories = value;
        else if (key == QStringLiteral("Type")) applicationType = (value == QStringLiteral("Application"));
        else if ((key == QStringLiteral("NoDisplay") || key == QStringLiteral("Hidden"))
                 && value.compare(QStringLiteral("true"), Qt::CaseInsensitive) == 0) hidden = true;
    }

    if (!applicationType || hidden || entry.name.isEmpty() || entry.exec.isEmpty())
        return {};

    entry.exec = cleanExec(entry.exec);
    entry.source = path.startsWith(QDir::homePath()) ? QStringLiteral("Usuario") : QStringLiteral("Linux");
    return entry;
}

QString AppIndexModel::cleanExec(QString command)
{
    command.remove(QRegularExpression(QStringLiteral("\\s+%[fFuUdDnNickvm]")));
    command.remove(QRegularExpression(QStringLiteral("%[fFuUdDnNickvm]")));
    return command.trimmed();
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
    QSet<QString> names;
    const QStringList roots = {
        QStringLiteral("/usr/share/applications"),
        QStringLiteral("/usr/local/share/applications"),
        QDir::homePath() + QStringLiteral("/.local/share/applications")
    };

    for (const QString &root : roots) {
        QDir dir(root);
        const QStringList files = dir.entryList({QStringLiteral("*.desktop")}, QDir::Files);
        for (const QString &fileName : files) {
            auto entry = parseDesktopFile(dir.absoluteFilePath(fileName));
            if (!entry.name.isEmpty() && !names.contains(entry.name.toLower())) {
                names.insert(entry.name.toLower());
                discovered.append(entry);
            }
        }
    }

    std::sort(discovered.begin(), discovered.end(), [](const auto &a, const auto &b) {
        return a.name.localeAwareCompare(b.name) < 0;
    });

    m_all = discovered;
    rebuildVisible();
}

void AppIndexModel::rebuildVisible()
{
    beginResetModel();
    m_visible.clear();
    for (const auto &app : std::as_const(m_all)) {
        const bool textMatch = m_filter.isEmpty() || app.name.contains(m_filter, Qt::CaseInsensitive);
        if (textMatch && matchesCategory(app, m_categoryFilter))
            m_visible.append(app);
    }
    endResetModel();
    emit countChanged();
}

bool AppIndexModel::launch(int row) const
{
    if (row < 0 || row >= m_visible.size())
        return false;
    const QStringList parts = QProcess::splitCommand(m_visible.at(row).exec);
    if (parts.isEmpty())
        return false;
    QStringList args = parts;
    const QString program = args.takeFirst();
    return QProcess::startDetached(program, args);
}
