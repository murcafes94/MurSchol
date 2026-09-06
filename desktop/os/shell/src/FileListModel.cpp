#include "FileListModel.h"

#include <algorithm>

#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QFileInfo>
#include <QStandardPaths>
#include <QUrl>

FileListModel::FileListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    goHome();
}

int FileListModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_visible.size();
}

QVariant FileListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_visible.size())
        return {};

    const auto &entry = m_visible.at(index.row());
    switch (role) {
    case NameRole: return entry.name;
    case PathRole: return entry.path;
    case IsDirectoryRole: return entry.directory;
    case SizeTextRole: return entry.sizeText;
    case ModifiedTextRole: return entry.modifiedText;
    case IconNameRole: return entry.iconName;
    default: return {};
    }
}

QHash<int, QByteArray> FileListModel::roleNames() const
{
    return {
        {NameRole, "fileName"},
        {PathRole, "filePath"},
        {IsDirectoryRole, "isDirectory"},
        {SizeTextRole, "sizeText"},
        {ModifiedTextRole, "modifiedText"},
        {IconNameRole, "iconName"}
    };
}

bool FileListModel::canGoUp() const
{
    if (m_currentPath.isEmpty())
        return false;
    QDir dir(m_currentPath);
    return dir.cdUp();
}

void FileListModel::setFilter(const QString &filter)
{
    if (m_filter == filter)
        return;
    m_filter = filter;
    emit filterChanged();
    rebuildVisible();
}

QString FileListModel::standardLocation(QStandardPaths::StandardLocation location)
{
    const QString path = QStandardPaths::writableLocation(location);
    return path.isEmpty() ? QDir::homePath() : path;
}

void FileListModel::setPath(const QString &path)
{
    QString resolved = path.trimmed();
    if (resolved.startsWith(QStringLiteral("~")))
        resolved.replace(0, 1, QDir::homePath());

    QFileInfo info(resolved);
    if (!info.exists() || !info.isDir()) {
        emit errorOccurred(QStringLiteral("La carpeta no existe: %1").arg(resolved));
        return;
    }

    const QString canonical = info.canonicalFilePath();
    if (canonical.isEmpty()) {
        emit errorOccurred(QStringLiteral("No se pudo abrir la carpeta"));
        return;
    }

    m_currentPath = canonical;
    m_filter.clear();
    emit currentPathChanged();
    emit filterChanged();
    refresh();
}

void FileListModel::goHome()
{
    setPath(QDir::homePath());
}

void FileListModel::goDocuments()
{
    setPath(standardLocation(QStandardPaths::DocumentsLocation));
}

void FileListModel::goDownloads()
{
    setPath(standardLocation(QStandardPaths::DownloadLocation));
}

void FileListModel::goPictures()
{
    setPath(standardLocation(QStandardPaths::PicturesLocation));
}

void FileListModel::goMusic()
{
    setPath(standardLocation(QStandardPaths::MusicLocation));
}

void FileListModel::goVideos()
{
    setPath(standardLocation(QStandardPaths::MoviesLocation));
}

void FileListModel::goUp()
{
    QDir dir(m_currentPath);
    if (dir.cdUp())
        setPath(dir.absolutePath());
}

bool FileListModel::activate(int row)
{
    if (row < 0 || row >= m_visible.size())
        return false;

    const auto &entry = m_visible.at(row);
    if (entry.directory) {
        setPath(entry.path);
        return true;
    }

    const bool ok = QDesktopServices::openUrl(QUrl::fromLocalFile(entry.path));
    if (!ok)
        emit errorOccurred(QStringLiteral("No se pudo abrir %1").arg(entry.name));
    return ok;
}

bool FileListModel::createFolder()
{
    QDir dir(m_currentPath);
    if (!dir.exists())
        return false;

    QString base = QStringLiteral("Nueva carpeta");
    QString candidate = base;
    int suffix = 2;
    while (dir.exists(candidate))
        candidate = base + QStringLiteral(" %1").arg(suffix++);

    if (!dir.mkdir(candidate)) {
        emit errorOccurred(QStringLiteral("No se pudo crear la carpeta"));
        return false;
    }

    refresh();
    return true;
}

QString FileListModel::formatBytes(qint64 bytes)
{
    if (bytes < 0)
        return {};
    if (bytes < 1024)
        return QStringLiteral("%1 B").arg(bytes);
    if (bytes < 1024 * 1024)
        return QStringLiteral("%1 KB").arg(QString::number(double(bytes) / 1024.0, 'f', 1));
    if (bytes < qint64(1024) * 1024 * 1024)
        return QStringLiteral("%1 MB").arg(QString::number(double(bytes) / (1024.0 * 1024.0), 'f', 1));
    return QStringLiteral("%1 GB").arg(QString::number(double(bytes) / (1024.0 * 1024.0 * 1024.0), 'f', 1));
}

QString FileListModel::iconForFile(const QString &path, bool directory)
{
    if (directory)
        return QStringLiteral("folder");

    const QString suffix = QFileInfo(path).suffix().toLower();
    if (suffix == QStringLiteral("pdf"))
        return QStringLiteral("application-pdf");
    if (QStringList{QStringLiteral("png"), QStringLiteral("jpg"), QStringLiteral("jpeg"), QStringLiteral("webp"), QStringLiteral("svg"), QStringLiteral("gif")}.contains(suffix))
        return QStringLiteral("image-x-generic");
    if (QStringList{QStringLiteral("mp3"), QStringLiteral("wav"), QStringLiteral("ogg"), QStringLiteral("flac"), QStringLiteral("m4a")}.contains(suffix))
        return QStringLiteral("audio-x-generic");
    if (QStringList{QStringLiteral("mp4"), QStringLiteral("mkv"), QStringLiteral("webm"), QStringLiteral("avi"), QStringLiteral("mov")}.contains(suffix))
        return QStringLiteral("video-x-generic");
    if (QStringList{QStringLiteral("zip"), QStringLiteral("7z"), QStringLiteral("tar"), QStringLiteral("gz"), QStringLiteral("xz"), QStringLiteral("rar")}.contains(suffix))
        return QStringLiteral("package-x-generic");
    if (QStringList{QStringLiteral("doc"), QStringLiteral("docx"), QStringLiteral("odt")}.contains(suffix))
        return QStringLiteral("x-office-document");
    if (QStringList{QStringLiteral("xls"), QStringLiteral("xlsx"), QStringLiteral("ods")}.contains(suffix))
        return QStringLiteral("x-office-spreadsheet");
    if (QStringList{QStringLiteral("ppt"), QStringLiteral("pptx"), QStringLiteral("odp")}.contains(suffix))
        return QStringLiteral("x-office-presentation");
    return QStringLiteral("text-x-generic");
}

void FileListModel::refresh()
{
    QList<MurScholFileEntry> entries;
    QDir dir(m_currentPath);
    dir.setFilter(QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Readable);
    dir.setSorting(QDir::DirsFirst | QDir::IgnoreCase | QDir::Name);

    const QFileInfoList infos = dir.entryInfoList();
    entries.reserve(infos.size());
    for (const QFileInfo &info : infos) {
        MurScholFileEntry entry;
        entry.name = info.fileName();
        entry.path = info.absoluteFilePath();
        entry.directory = info.isDir();
        entry.sizeText = info.isDir() ? QStringLiteral("Carpeta") : formatBytes(info.size());
        entry.modifiedText = info.lastModified().toString(QStringLiteral("dd MMM yyyy, HH:mm"));
        entry.iconName = iconForFile(entry.path, entry.directory);
        entries.append(entry);
    }

    m_all = entries;
    rebuildVisible();
}

void FileListModel::rebuildVisible()
{
    beginResetModel();
    m_visible.clear();
    for (const auto &entry : std::as_const(m_all)) {
        if (m_filter.isEmpty() || entry.name.contains(m_filter, Qt::CaseInsensitive))
            m_visible.append(entry);
    }
    endResetModel();
    emit countChanged();
}
